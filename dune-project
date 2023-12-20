(lang dune 3.10)

(generate_opam_files true)

(authors "Jonathan Miranda" "Davina Oludipe")

(maintainers "jmiran15@jhu.edu")

(package
 (name image_generator)
 (synopsis "An Image Generator Website")
 (description
  "This website takes in user input. \nIt uses semantic processing to find images content and style that closely match the user input. \nIt then combines the content and style images using Neural style Transfer \nand then output the created image to the user.")
 (depends
  (ounit2
   (>= 2.2.7))
  (core
   (>= 0.16.2))
  (core_unix
   (>= 0.16.0))
  (yojson
   (>= 2.1.2))
  (postgresql
   (>= 5.0.0))
  (csv
   (>= 2.4))
  (base64
   (>= 3.5.1))
  (ppx_let
   (>= 0.16.0))
  (cohttp
   (>= 5.3.0))
  (lwt
   (>= 5.7.0))
  (dream
   (>= 1.0.0~alpha5))
  (lwt_ppx
   (>= 2.1.0))
  (base
   (>= 0.16.3))
  (torch
   (>= 0.16.0))
  (dune
   (>= 3.12.1))))
