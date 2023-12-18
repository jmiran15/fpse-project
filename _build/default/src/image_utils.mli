(* Utility Module: Provides file handling utilities, including reading files, converting images to blobs, and handling binary data. *)

(** Reads the contents of a file into a string. *)
val file_to_string : string -> bytes

(** Converts an image file to a Base64-encoded blob. *)
val image_to_blob : string -> string

(** Writes binary data to a file. *)
val write_binary_to_file : filename:string -> data:string -> unit

(** Creates a temporary image file from a Base64 string, uses it in a provided function, and then deletes the file. *)
val with_temp_image_file : string -> (string -> 'a) -> 'a option
