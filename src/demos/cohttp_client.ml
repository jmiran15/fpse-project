(* Basic client that make a GET request*)
open Lwt
open Cohttp_lwt_unix

let uri = Uri.of_string "http://httpbin.org/get"

let get () = 
  Client.get uri >>= fun (_, body) ->
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    Printf.printf "Response: %s\n" body;
    Lwt.return ()
  
  let () =
    let _ = Lwt_main.run (get ()) in
    () 