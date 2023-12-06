
open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix

let uri = Uri.of_string "https://api.openai.com/v1/embeddings"

let post =
  let headers = Header.init ()
    |> fun h -> Header.add h "Authorization" "Bearer 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"
    |> fun h -> Header.add h "Content-Type" "application/json"
  in
  let json_body = `Assoc [
    ("input", `String "The food was delicious and the waiter was very nice.");
    ("model", `String "text-embedding-ada-002");
    ("encoding_format", `String "float")
  ] |> Yojson.Basic.to_string
  in

  Client.post
    ~body:(Cohttp_lwt.Body.of_string json_body)
    ~headers
    uri >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    Printf.printf "Response code: %d\n" code;
    Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
    body |> Cohttp_lwt.Body.to_string >|= fun body ->

    Printf.printf "Body: %s\n" (body);
    body

let () =
  let body = Lwt_main.run post in
  print_endline ("Received body\n" ^ body)