(* Helper function to read a file into a string *)
let file_to_string filename =
  let ic = open_in_bin filename in
  let n = in_channel_length ic in
  let s = Bytes.create n in
  really_input ic s 0 n;
  Stdlib.close_in ic;
  s


(* Helper function to convert image file to blob *)
let image_to_blob path =
  let binary_content = file_to_string path in
  Base64.encode_exn (Bytes.to_string binary_content)


(* Helper function to write binary data to a file *)
let write_binary_to_file ~filename ~data =
  let oc = open_out_bin filename in
  output_string oc data;
  close_out oc


(* Function to create a temporary image file from Base64 string, use it, and delete it *)
let with_temp_image_file base64_string f =
  let open Base64 in
  match decode base64_string with
  | Ok binary_data ->
      let temp_filename = Filename.temp_file "image_" ".png" in
      write_binary_to_file ~filename:temp_filename ~data:binary_data;
      begin
        try
          let result = f temp_filename in
          Sys.remove temp_filename;        (* Delete the temporary file *)
          Some result
        with
        | _ -> Sys.remove temp_filename; None  (* Handle any exceptions and return None *)
      end
  | Error (`Msg e) ->
      Printf.printf "Failed to decode image: %s\n" e;
      None