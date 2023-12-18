open Lwt
open Cohttp
open Cohttp_lwt_unix

(* Embedding module implementation *)

type t = float list

(* Creates an embedding from a list of floats. *)
let of_list floats = floats

(* Converts an embedding to a list of floats. *)
let to_list embedding = embedding

(* Helper function to calculate the dot product of two vectors. *)
let dot_product v1 v2 =
  List.fold_left2 (fun acc x y -> acc +. x *. y) 0.0 v1 v2

(* Helper function to calculate the magnitude of a vector. *)
let magnitude v =
  sqrt (List.fold_left (fun acc x -> acc +. x *. x) 0.0 v)

(* Calculates the cosine similarity between two embeddings. *)
let cosine_similarity v1 v2 =
  let dot = dot_product v1 v2 in
  let mag_v1 = magnitude v1 in
  let mag_v2 = magnitude v2 in
  if mag_v1 = 0.0 || mag_v2 = 0.0 then 0.0
  else dot /. (mag_v1 *. mag_v2)


(* Function to generate an embedding from a string *)
let generate_embedding description =
  Core.(
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
  
    let embedding_list = embedding_json |> Yojson.Basic.Util.member "data" |> Yojson.Basic.Util.to_list |> List.hd_exn |> Yojson.Basic.Util.member "embedding" |> Yojson.Basic.Util.to_list |> List.map ~f:Yojson.Basic.Util.to_float in

    of_list embedding_list)


(* Synchronous wrapper for `generate_embedding` *)
let get_embedding_sync description =
  Lwt_main.run (generate_embedding description)


  (* Helper function to split a string by a delimiter *)
let split_string ~delimiter str =
  let rec aux acc i =
    try
      let j = String.index_from str i delimiter in
      aux (String.sub str i (j - i) :: acc) (j + 1)
    with
      | Not_found -> List.rev (String.sub str i (String.length str - i) :: acc)
  in
  aux [] 0


(* Helper function to trim whitespace from a string *)
let trim str =
  let open String in
  let is_space = function
    | ' ' | '\n' | '\r' | '\t' -> true
    | _ -> false
  in
  let len = length str in
  let i = ref 0 in
  while !i < len && is_space (unsafe_get str !i) do
    incr i
  done;
  let j = ref (len - 1) in
  while !j >= !i && is_space (unsafe_get str !j) do
    decr j
  done;
  sub str !i (!j - !i + 1)


(* Function to parse embedding string to float list *)
let parse_embedding (embedding_str : string) : float list =
  let trimmed_str = String.sub embedding_str 1 (String.length embedding_str - 2) in
  let string_list = split_string ~delimiter:',' trimmed_str in
  List.map (fun s -> float_of_string (trim s)) string_list