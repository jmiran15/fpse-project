(* Embedding module: Represents vector embeddings for image descriptions. *)

(** Type representing a vector embedding. *)
type t

(** Creates an embedding from a list of floats. *)
val of_list : float list -> t

(** Converts an embedding to a list of floats. *)
val to_list : t -> float list

(** Calculates the cosine similarity between two embeddings. *)
val cosine_similarity : t -> t -> float