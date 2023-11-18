(* This module defines the server routes and their corresponding functionalities. *)

(** Route to POST "/images". Takes a description and returns a generated image. *)
val route_generate_image : string -> Image.t
