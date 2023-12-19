# Image Generator #
## Authors ##
Jonathan Miranda and Davina Oludipe
## Purpose ##
The goal of this project is to create a tool that can generate images from user input. The project can be broken down into three parts:
1. Create databases of style and content images
2. From user input, choose a style image and a content image and combine them using Neural Style Transfer: https://arxiv.org/abs/1508.06576
3. Create frontend that takes in user input
## Structure ##
This monorepo contains the code for both the frontend and backend of our program. ```client``` contains code pertaining to the Javascript frontend, ```src``` contains code pertaining to the Ocaml backend, 
## Dependencies ##
* Torch
* Cohttp
* OCaml 5.0.0
* Core
* Yojson
* Postgresql
* Dream
* Lwt
