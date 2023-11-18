(*Create a simple HTTP server*)
let () =
  Dream.run
  @@ Dream.logger
  @@ fun _ ->
  Dream.html("Hello, World from Dream!")