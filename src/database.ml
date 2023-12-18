(* Required:
- database (connection info, same as in the demo)

Optional:
- clear: can be used as a flag OR can pass a list of arguments, which are the table names. This flag deletes the tables.
- seed: indicates seeding db
- content-csv: path to the csv file for content images
- style-csv: path to the csv file for style images 

sample run command:
dune exec ./database.exe -- --database "host=localhost port=5432 user=postgres password=12345678 dbname=nst" --clear --seed --content-csv "content.csv" --style-csv "style.csv"

We are using pgAdmin to view/verify the db. *)


(* Commands to setup db
- docker volume create postgres-data
- docker run --name postgres-container -e POSTGRES_PASSWORD=<password> -p 5432:5432 -v postgres-data:/var/lib/postgresql/data -d postgres
- docker exec -it postgres-container psql -U postgres
- CREATE DATABASE mydatabase; *)


open Postgresql

(* Function to clear tables *)
let clear_tables (c : connection) (table_names : string list) : unit =
  List.iter (fun table ->
    let _ = c#exec ("DROP TABLE IF EXISTS " ^ table) in
    Printf.printf "Cleared table: %s\n" table
  ) table_names


(* Function to create tables *)
let create_tables (c : connection) : unit =
  let _ = c#exec "CREATE TABLE IF NOT EXISTS style (image text, description text, embedding float[])" in
  let _ = c#exec "CREATE TABLE IF NOT EXISTS content (image text, description text, embedding float[])" in
  Printf.printf "Created tables: style, content\n"


(* Helper function to convert a float list to a PostgreSQL array string *)
let float_list_to_pg_array (float_list : float list) : string =
  let float_strings = List.map string_of_float float_list in
  "{" ^ (String.concat "," float_strings) ^ "}"


(* Function to seed database *)
let seed (c :connection) (content_csv : string) (style_csv : string) : unit =
  clear_tables c ["style"; "content"];
  create_tables c;

  let insert_data table csv_file =
    let rows = Csv.load csv_file in
    List.iter (fun row ->
      let image_blob = "./data/" ^ table ^ "/images/" ^ (List.nth row 0) |> Image_utils.image_to_blob in
      let description = List.nth row 1 in
      let embedding = Embedding.parse_embedding (List.nth row 2) in
      let embedding_str = float_list_to_pg_array embedding in
      let query = Printf.sprintf "INSERT INTO %s (image, description, embedding) VALUES ('%s', '%s', '%s')" table image_blob description embedding_str in
      ignore (c#exec query);
      Printf.printf "Inserted data into %s table\n" table
      ) rows
  in

  insert_data "style" style_csv;
  insert_data "content" content_csv;
  Printf.printf "Seeding completed\n"


(* Function to execute when command is run *)
let execute db_conn_info clear s content_csv style_csv () =
  let c = new Postgresql.connection ~conninfo:db_conn_info () in
  if clear then clear_tables c ["style"; "content"];
  if s then seed c content_csv style_csv;
  
  c#finish;
  Printf.printf "Operation completed successfully\n"


(* Command line interface setup *)
let command =
  Command.basic
    ~summary:"Database utility for clearing and seeding tables"
    Command.Let_syntax.(
      let%map_open
        db_conn_info = flag "--database" (required string) ~doc:"Connection string for the PostgreSQL database"
      and clear = flag "--clear" no_arg ~doc:"Clears the specified database tables"
      and seed = flag "--seed" no_arg ~doc:"Seeds the database with provided CSV data"
      and content_csv = flag "--content-csv" (optional_with_default "" string) ~doc:"Path to the CSV file for content images"
      and style_csv = flag "--style-csv" (optional_with_default "" string) ~doc:"Path to the CSV file for style images"
      in
      execute db_conn_info clear seed content_csv style_csv
    )

(* Run the command *)
let () = Command_unix.run command