# Image Generator #
## Authors ##
Jonathan Miranda and Davina Oludipe
## Purpose ##
The goal of this project is to create a tool that can generate images from user input. The project can be broken down into three parts:
1. Create databases of style and content images
2. From user input, choose a style image and a content image and combine them using Neural Style Transfer: https://arxiv.org/abs/1508.06576
3. Create frontend that takes in user input
## Structure ##
This monorepo contains the code for both the frontend and backend of our program. ```client``` contains code pertaining to the Javascript frontend, ```src``` contains code pertaining to the Ocaml backend, ```sample_inputs``` contains sample images that ```nst.main``` can be run with and files that are used in testing. ```tests``` contains tests for testable code.
## Requirements + Dependencies ##
### OCaml ###
* Torch
* Cohttp
* OCaml 5.0.0
* Core
* Yojson
* Postgresql
* Dream
* Lwt
* OUnit2
* Csv
* Ppx_let
### Other ###
* Node.js
* Npm
* Vgg19 model. Download Pretrained weights from: https://github.com/LaurentMazare/ocaml-torch/releases/download/v0.1-unstable/vgg19.ot
## Run ##
Build the entire project at the root by running ```dune clean``` and ```dune build```.
* In ```client```, run ```npm install``` and then ```npm start``` to start the frontend.
* Run
  ```dune exec -- ./content_dataset_utils.exe ./data/content/labels_raw.json ./data/content/output_utils.csv -n 100``` and
  ```dune exec ./style_dataset_utils.exe ./data/style/style_labels.csv ./data/style/output_utils.csv```
  to generate the content and style output_utils.csv files to be used in ```src/database.ml```.
* In ```src/data/content``` unzip and add ```images``` that can be downloaded here: https://drive.google.com/file/d/1PvoVV3cZDQswl5BbYaxdVD2yGYdb1TNl/view?usp=drive_link to properly use ```content_dataset_utils.ml```
  Also unzip ```src/data/style/images.zip``` to use in ```style_dataset_utils.ml```.
* Run
  ```dune exec ./database.exe -- --database "host=localhost port=5432 user=postgres password=12345678 dbname=nst" --clear --seed --content-csv "content.csv" --style-csv "style.csv"```
  to run database executable.
* Run
  ```dune exec ./server.exe -- --database "host=localhost port=5432 user=postgres password=12345678 dbname=nst"```
  to run server executable. In ```src/server.ml``` Replace ```"vgg19.ot"``` in ```let model = "./vgg19.ot"``` with local path to vgg19.ot after downloading above.
* To run tests, add the paths to the model and the images in sample_inputs in ```tests.ml```, then run ```dune test```

