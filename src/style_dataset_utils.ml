open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix

(* style dataset -> https://universe.roboflow.com/eric-xiong/art-styles-fuowh/dataset/3 *)

(* Global hash table to store embeddings *)
let embeddings_cache : (string, Embedding.t) Hashtbl.t = Hashtbl.create (module String)


(* Function to generate an embedding from a string *)
let generate_embedding description =
  let uri = Uri.of_string "https://api.openai.com/v1/embeddings" in

  let headers = Header.init ()
    |> fun h -> Header.add h "Authorization" "Bearer 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"
    |> fun h -> Header.add h "Content-Type" "application/json"
  in

  let json_body = `Assoc [
    ("input", `String description);
    ("model", `String "text-embedding-ada-002");
    ("encoding_format", `String "float")
  ] |> Yojson.Basic.to_string
  in

  Client.post ~body:(Cohttp_lwt.Body.of_string json_body) ~headers uri
    >>= fun (_resp, body) ->
    body |> Cohttp_lwt.Body.to_string >|= fun body_str ->
    (* Parse the response to extract the embedding *)
    let embedding_json = Yojson.Basic.from_string body_str in
  
    let embedding_list = Yojson.Basic.Util.(embedding_json 
    |> member "data" 
    |> to_list 
    |> List.hd_exn
    |> member "embedding"
    |> to_list
    |> List.map ~f:to_float) in

    Embedding.of_list embedding_list


(* Synchronous wrapper for `generate_embedding` *)
let get_embedding_sync description =
  Lwt_main.run (generate_embedding description)


let process_row row =
  let filename = List.hd_exn row in
  let labels = List.tl_exn row in
  let label_names = ["Renaissance"; "Surrealism"; "Unlabeled"; "baroque"; "cubism"; "cubsim"; "minimalist"; "popart"; "realism"; "renaissance"; "romanticism"] in
  let combined = List.zip_exn label_names labels in

  let description = List.fold combined ~init:"" ~f:(fun acc (name, value) ->
    if String.(=) value "1" then
      if String.(=) name "Unlabeled" then "an image in any style" else "an image in " ^ name ^ " style"
    else acc) in

  let embedding =
    match Hashtbl.find embeddings_cache description with
    | Some emb -> emb
    | None ->
      let new_embedding = get_embedding_sync description in
      Hashtbl.set embeddings_cache ~key:description ~data:new_embedding;
      new_embedding
  in

  let embedding_as_list = Embedding.to_list embedding in
  let embedding_string = "[" ^ (String.concat ~sep:", " (List.map embedding_as_list ~f:Float.to_string)) ^ "]" in
  [filename; description; embedding_string]

  
(* Function to read CSV, process it, and write to a new file *)
let reformat_csv input_path output_path =
  let rows = Csv.load input_path in
  let processed_rows = List.map rows ~f:process_row in
  Csv.save output_path processed_rows
  

(* Command line interface setup *)
let command =
  Command.basic
    ~summary:"Reformat a CSV file with art labels"
    Command.Let_syntax.(
      let%map_open input_path = anon ("input_path" %: string)
      and output_path = anon ("output_path" %: string) in
      fun () -> reformat_csv input_path output_path
    )

(* Run the command *)
let () = Command_unix.run command