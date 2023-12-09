(* This module defines the server routes and their corresponding functionalities. *)

(* Route: POST /query
Description: this route takes a query (description of the image to be generated) and returns the two images (content, style)
Request:
- query: string
Return:
- content_image: Image.t
- style_image: Image.t *)

(* Route: POST /generate
Description: this route takes a content image and a style image and returns the generated image (through nst)
Request:
- content_image: Image.t
- style_image: Image.t
Return:
- generated_image: Image.t *)