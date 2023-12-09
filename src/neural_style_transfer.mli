(* (*Module for performing neural style transfer on images.

* Weight assigned to the style in the final image. *)
val style_weight : float

(** Learning rate for the optimization process. *)
val learning_rate : float

(** Total number of steps for the style transfer process. *)
val total_steps : int

(** Layer indexes to extract style features. *)
val style_indexes : int list

(** Layer indexes to extract content features. *)
val content_indexes : int list

(** Applies the neural style transfer algorithm on a content image using a style image. *)
val apply_style_transfer : style_img:string -> content_img:string -> filename:string -> unit *)
