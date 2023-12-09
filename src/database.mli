(* Commented out because we changed a lot of the helper functions in database.ml *)

(* This module handles interactions with the PostgreSQL database for image data management. *)
(* 
(** Loads images with their metadata from S3 and returns them as a list. *)
(* don't need this anymore *)
val load_images_from_s3 : unit -> Image.t list

(** Generates a vector embedding for a given description string. *)
val generate_embedding : string -> Embedding.t

val generate_embedding_sync : string -> Embedding.t

(** Loads images with metadata, generates embeddings, and inserts them into the database. *)
val load_and_embed_images : unit -> unit

(** Finds the image with the most similar metadata to a given description. *)
val find_similar_image : string -> Image.t option


module type DATABASE_CONFIG = sig
  val connection_path : string
  val username : string
  val password : string
  val port : int
end

module MakeDatabase (Config : DATABASE_CONFIG) : sig
  (** Clears all rows in the database. *)
  val clear : unit -> unit

  (** Initializes the database table. *)
  val init : unit -> unit

  (** Inserts a row into the database. *)
  val insert : Image.t -> unit

  (** Deletes a row from the database. *)
  val delete : int -> unit  (* Assuming 'int' is the type of the id. *)

  (** Updates a row in the database. *)
  val put : int -> Image.t -> unit

end *)
