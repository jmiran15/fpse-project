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
