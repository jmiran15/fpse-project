(* Embedding module: Represents vector embeddings for textual descriptions. *)

(** Type representing a vector embedding. *)
type t

(** Creates an embedding from a list of floats. *)
val of_list : float list -> t

(** Converts an embedding to a list of floats. *)
val to_list : t -> float list

(** Calculates the cosine similarity between two embeddings. *)
val cosine_similarity : t -> t -> float

(** Asynchronously generates an embedding from a string. *)
val generate_embedding : string -> t Lwt.t

(** Synchronously generates an embedding from a string. *)
val get_embedding_sync : string -> t


(** Parses a string representation of an embedding into a float list. *)
val parse_embedding : string -> float list
