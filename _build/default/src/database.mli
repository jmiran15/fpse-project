(* Database Module: Provides utilities for managing PostgreSQL database, including table clearing, creation, and seeding. *)

(** Clears specified tables in the database. *)
val clear_tables : Postgresql.connection -> string list -> unit

(** Creates necessary tables in the database. *)
val create_tables : Postgresql.connection -> unit

(** Converts a float list to a PostgreSQL array string. *)
val float_list_to_pg_array : float list -> string

(** Seeds the database with data from specified CSV files. *)
val seed : Postgresql.connection -> string -> string -> unit