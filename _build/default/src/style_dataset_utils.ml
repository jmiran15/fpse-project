open Core

(* dune exec ./style_dataset_utils.exe ./data/style/style_labels.csv ./data/style/output_utils.csv *)

(* style dataset -> https://universe.roboflow.com/eric-xiong/art-styles-fuowh/dataset/3 *)

(* Global hash table to store embeddings *)
let embeddings_cache : (string, Embedding.t) Hashtbl.t = Hashtbl.create (module String)

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
      let new_embedding = Embedding.get_embedding_sync description in
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