open Yojson.Basic
open Yojson.Basic.Util

(* dune exec -- ./content_dataset_utils.exe ./data/content/labels_raw.json ./data/content/output_utils.csv -n 100 *)


(* Filter annotations based on selected image IDs *)
let filter_annotations_by_images json selected_images =
  let selected_ids = List.map (fun img -> img |> member "id" |> to_int) selected_images in
  let annotations = match json with
                    | `Assoc assoc_list -> List.assoc "annotations" assoc_list |> to_list
                    | _ -> failwith "Invalid JSON format" in
  let filtered_annotations = List.filter (fun ann -> List.mem (ann |> member "image_id" |> to_int) selected_ids) annotations in
  filtered_annotations


(* Select the first N images *)
let select_first_n_images json n =
  match json with
  | `Assoc assoc_list ->
      let images = List.assoc "images" assoc_list |> to_list in
      let selected_images = Core.List.take images n in
      let annotations = filter_annotations_by_images json selected_images in
      (selected_images, annotations)
  | _ -> failwith "Invalid JSON format"


(* Process data for CSV *)
let process_data_for_csv images annotations =
  List.map (fun image ->
    let filename = image |> member "file_name" |> to_string in
    let image_id = image |> member "id" |> to_int in
    let description = 
      annotations 
      |> List.filter (fun ann -> (ann |> member "image_id" |> to_int) = image_id)
      |> List.map (fun ann -> ann |> member "caption" |> to_string)
      |> Core.String.concat ~sep:" " in

    let embedding = Embedding.get_embedding_sync description in
    let embedding_as_list = Embedding.to_list embedding in
    let embedding_string = Core.("[" ^ String.concat ~sep:", " (List.map embedding_as_list ~f:Float.to_string) ^ "]") in
    (* Make sure things are surrounded by quotes *)
    [filename; "\"" ^ description ^ "\""; "\"" ^ embedding_string ^ "\""]

  ) images


(* Function to write data to a CSV file *)
let write_to_csv data output_path =
  Core.(let csv_data = List.map data ~f:(String.concat ~sep:",") in
  let csv_string = String.concat ~sep:"\n" csv_data in
  Out_channel.write_all output_path ~data:csv_string)


(* Convert JSON to CSV format *)
let convert_json_to_csv input_path output_csv n =
  let json = from_file input_path in
  let (selected_images, annotations) = select_first_n_images json n in
  let csv_data = process_data_for_csv selected_images annotations in
  write_to_csv csv_data output_csv


(* Command line interface setup *)
let command =
  Command.basic
    ~summary:"Convert COCO JSON to CSV"
    Command.Let_syntax.(
      let%map_open
        input_path = anon ("input_json_path" %: string)
      and output_csv = anon ("output_csv_path" %: string)
      and n = flag "-n" (optional_with_default 500 int) ~doc:"Number of images to process" in
      fun () -> convert_json_to_csv input_path output_csv n
    )

(* Run the command *)
let () = Command_unix.run command