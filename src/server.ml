open Lwt
open Postgresql


(* dune exec ./server.exe -- --database "host=localhost port=5432 user=postgres password=12345678 dbname=nst" *)


(* Global reference for database connection info *)
let db_conn_info_ref = ref ""

let () = Random.self_init ()

(* Function to randomly pick an element from a list *)
let random_pick list =
  let len = List.length list in
  if len = 0 then None
  else Some (List.nth list (Random.int len))


(* Function to fetch rows from a database table and convert them to a list of (image, description, embedding) *)
let fetch_rows (c: connection) table =
  let query = Printf.sprintf "SELECT image, description, embedding FROM %s" table in
  let res = c#exec query in
  Core.(Array.to_list (res#get_all) 
  |> List.map ~f:(fun row ->
      let image = row.(0) in
      let description = row.(1) in
      let embedding_str = row.(2) in
      let embedding = Embedding.parse_embedding embedding_str |> Embedding.of_list in
      (image, description, embedding)))


(* Function to calculate cosine similarity for each row against the query embedding *)
let calculate_similarities rows query_embedding =
  let open Core in
  List.map rows ~f:(fun (image, description, embedding) ->
    let similarity = Embedding.cosine_similarity query_embedding embedding in
    (image, description, embedding, similarity))
  |> List.sort ~compare:(fun (_, _, _, sim1) (_, _, _, sim2) -> Float.compare sim2 sim1)

  
let use_images style_path content_path =
  let open Sys in
  let model = "./vgg19.ot" in
  let output_path = "output.png" in
  Nst.main "vgg19" style_path content_path model output_path;

  if file_exists output_path then
    let encoded_image = Image_utils.image_to_blob output_path in
    remove output_path;  (* Delete the output file *)
    
    match Base64.decode encoded_image with
    | Ok _ -> `Assoc [("result_image", `String encoded_image)]
    | Error (`Msg e) -> `String ("Failed to process output image: " ^ e)
  else
    `String "NST processing failed or output image is corrupt"


(* Function to handle /query route *)
let handle_query (c : connection) body =
  match body with
  | `Assoc [("query", `String query)] ->
      Embedding.generate_embedding query >>= fun query_embedding ->
      let content_rows = fetch_rows c "content" in
      let style_rows = fetch_rows c "style" in

      let content_similarities = calculate_similarities content_rows query_embedding in
      let style_similarities = calculate_similarities style_rows query_embedding in

      let random_style = Core.(List.take (List.sort ~compare:(fun (_, _, _, sim1) (_, _, _, sim2) -> Float.compare sim2 sim1) style_similarities) 10) |> random_pick in

      let (base64_image_content, _, _, content_similarity) = List.hd content_similarities in

      let (base64_image_style, _, _, style_similarity) = match random_style with
        | Some stl -> stl
        | None -> List.hd style_similarities in

      Lwt_preemptive.detach (fun () ->
        Image_utils.with_temp_image_file base64_image_style (fun style_path ->
          Image_utils.with_temp_image_file base64_image_content (fun content_path ->
            use_images style_path content_path
          )
        )
      ) () >>= fun result ->
      let response = match result with
        | Some Some `Assoc [("result_image", `String encoded_image)] ->
            `Assoc [
              ("result_image", `String encoded_image);
              ("content_image", `String base64_image_content);
              ("style_image", `String base64_image_style);
              ("style_similarity", `Float style_similarity);
              ("content_similarity", `Float content_similarity)
            ]
        | _ -> `String "Failed to process images"
      in
      Lwt.return (Some response)
  | _ -> Lwt.return (Some (`String "Invalid request body"))


(* Middleware to set CORS headers *)
let cors_middleware inner_handler request =
  let headers = [
    ("Access-Control-Allow-Origin", "*");
    ("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    ("Access-Control-Allow-Headers", "Content-Type, Accept, Authorization");
  ] in

  match Dream.method_ request with
  | `OPTIONS ->
      (* Handle preflight OPTIONS request *)
      let%lwt response = Dream.respond ~headers ~status:`No_Content "" in
      Lwt.return response
  | _ ->
    let%lwt response = inner_handler request in
    Dream.set_header response "Access-Control-Allow-Origin" "*";
    Dream.set_header response "Access-Control-Allow-Methods" "GET, POST, PUT, DELETE, OPTIONS";
    Dream.set_header response "Access-Control-Allow-Headers" "Content-Type, Accept, Authorization";
    Lwt.return response

    
let start_server db_conn_info =
  db_conn_info_ref := db_conn_info;  (* Store the database connection info *)

  Dream.run
  @@ Dream.logger
  @@ cors_middleware
  @@ Dream.router [
    Dream.post "/query" (fun request ->
      Dream.body request
      >>= fun body ->
      let json_body = Yojson.Basic.from_string body in
      handle_query (new Postgresql.connection ~conninfo:!db_conn_info_ref ()) json_body
      >>= fun response ->
        match response with
        | Some json_response -> Dream.json (Yojson.Basic.to_string json_response)
        | None -> Dream.json "{\"error\": \"Failed to process request\"}"
    )
  ]
  (* @@ Dream.not_found *)


let command =
  Command.basic
    ~summary:"Start the server with database connection info"
    Command.Let_syntax.(
      let%map_open
        db_conn_info = flag "--database" (required string) ~doc:"Connection string for the PostgreSQL database"
      in
      fun () -> start_server db_conn_info
    )

let () = Command_unix.run command