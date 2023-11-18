(* Image module: Represents images and their associated metadata. *)

type t

(** Type representing image metadata. *)
type metadata = {
  url: string;          (* URL to the image stored in S3 *)
  author: string;       (* Author of the image *)
  description: string;  (* Description of the image *)
  embedding: Embedding.t; (* Vector embedding of the image description *)
}

(** Creates an image with the given metadata. *)
val create : metadata -> t

(** Retrieves the metadata of an image. *)
val get_metadata : t -> metadata