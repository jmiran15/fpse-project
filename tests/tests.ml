open OUnit2

(* ##### embedding_tests ##### *)
let test_to_of_list _=
let floats = [1.0; 2.0; 3.0] in
let result = Embedding.to_list(Embedding.of_list floats) in
assert_equal floats result

let test_cosine_similarity _= 
assert_equal 1. (Embedding.cosine_similarity (Embedding.of_list [1.0; 0.0]) (Embedding.of_list [1.0; 0.0])) ~printer: string_of_float;
assert_equal (-1.0) (Embedding.cosine_similarity (Embedding.of_list [1.0; 0.0]) (Embedding.of_list [-1.0; 0.0])) ~printer: string_of_float;
assert_equal 0.0 (Embedding.cosine_similarity (Embedding.of_list [0.0; 0.0]) (Embedding.of_list [1.0; 1.0])) ~printer: string_of_float;
assert_equal 0.0 (Embedding.cosine_similarity (Embedding.of_list [1.0; 0.0]) (Embedding.of_list [0.0; 0.0])) ~printer: string_of_float;
assert_equal (1.0 /. sqrt(2.0)) (Embedding.cosine_similarity (Embedding.of_list [1.0; 0.0;]) (Embedding.of_list [1.0; 1.0])) ~printer: string_of_float

let test_parse_embedding _= 
let embedding_str = "[1.0, 2.0, 3.0, 4.0, 5.0]" in
let expected = Embedding.parse_embedding embedding_str in
assert_equal [1.0; 2.0; 3.0; 4.0; 5.0] expected

(* ##### image_utils_tests ##### *)
let test_file_to_string _ =
  let filename = "test_file.txt" in
  let oc = open_out filename in
  output_string oc "Hello, world!";
  close_out oc;
  let result = Image_utils.file_to_string filename in
  assert_equal "Hello, world!" (Bytes.to_string result);
  Sys.remove filename

let test_image_to_blob _ =
  let path = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/20fen.jpg" in
  let _ = Image_utils.image_to_blob path in
  ()

let test_write_binary_to_file _ =
  let filename = "test_binary.bin" in
  let data = "Hello, world!" in
  Image_utils.write_binary_to_file ~filename ~data;
  let content = Image_utils.file_to_string filename in
  assert_equal data (Bytes.to_string content);
  Sys.remove filename

let test_with_temp_image_file _ =
  let path = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/20fen.jpg" in
  let base64_string = Image_utils.image_to_blob path in
  let result = Image_utils.with_temp_image_file base64_string (fun _ -> "test") in
  assert_equal (Some "test") result;
  let base64_string = "invalid base64 string" in 
  let result = Image_utils.with_temp_image_file base64_string (fun _ -> "test") in
  assert_equal None result

(* ##### loader_tests ##### *)
(* Test for load_vgg_model function *)
let test_load_vgg_model _ =
  (* testing that they don't result in an error *)
  let vgg_name = "vgg19" in
  let load_weight_path = "/home/ooludip1/Fpse/project/fpse-project/src/vgg19.ot" in
  let style_layers = [2; 10; 14; 21; 28] in
  let content_layers = [21] in
  let cpu = Torch.Device.cuda_if_available () in
  let _model = Loader.load_vgg_model vgg_name load_weight_path style_layers content_layers cpu in
  ()

(* Test for load_style_img function *)
let test_load_style_img _ =
  let style_img = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/style-cubist.jpg" in
  let cpu = Torch.Device.cuda_if_available () in
  let style = Loader.load_style_img style_img cpu in
  let expected = Torch_vision.Image.load_image style_img |> Base.Or_error.ok_exn in
  assert_equal (Torch.Tensor.shape style) (Torch.Tensor.shape expected)

(* Test for load_content_img function *)
let test_load_content_img _ =
  let content_img = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/new-york.jpg" in
  let cpu = Torch.Device.cuda_if_available () in
  let content = Loader.load_content_img content_img cpu in
  let expected = Torch_vision.Image.load_image content_img |> Base.Or_error.ok_exn in
  assert_equal (Torch.Tensor.shape content) (Torch.Tensor.shape expected)

(* ##### loss_tests ##### *)
let test_gram_matrix _= 
let m = Torch.Tensor.randn [2;2;2;2] in
let gm = Loss.gram_matrix m in
assert_equal (Torch.Tensor.shape gm) [4; 4]

let test_style_loss _= 
let vgg_name = "vgg19" in
let load_weight_path = "/home/ooludip1/Fpse/project/fpse-project/src/vgg19.ot" in
let style = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/style-cubist.jpg" in
let content = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/new-york.jpg" in
let cpu = Torch.Device.cuda_if_available () in
let model, style_img, content_img = Nst.get_inputs_tensors vgg_name cpu style content load_weight_path in
let model_paras = Torch.Var_store.create ~name:"optim" ~device:cpu () in
let image = Torch.Var_store.new_var_copy model_paras ~src:content_img ~name:"in" in
let style_layers, _ =
let detach = Base.Map.map ~f:Torch.Tensor.detach in
Torch.Tensor.no_grad (fun () ->
    (model style_img |> detach, model content_img |> detach)) in
let input_layers = model image in
let style_loss = Loss.get_style_loss input_layers style_layers [2; 10; 14; 21; 28] in
let expected = 0.0201 in
let result = Torch.Tensor.to_float0_exn style_loss |> Base.Float.round_decimal ~decimal_digits:4 in
assert_equal expected result;;

let test_content_loss _= 
let vgg_name = "vgg19" in
let load_weight_path = "/home/ooludip1/Fpse/project/fpse-project/src/vgg19.ot" in
let style = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/style-cubist.jpg" in
let content = "/home/ooludip1/Fpse/project/fpse-project/sample_inputs/new-york.jpg" in
let cpu = Torch.Device.cuda_if_available () in
let model, style_img, content_img = Nst.get_inputs_tensors vgg_name cpu style content load_weight_path in
let model_paras = Torch.Var_store.create ~name:"optim" ~device:cpu () in
let image = Torch.Var_store.new_var_copy model_paras ~src:content_img ~name:"in" in
let _, content_layers =
let detach = Base.Map.map ~f:Torch.Tensor.detach in
Torch.Tensor.no_grad (fun () ->
    (model style_img |> detach, model content_img |> detach)) in
let input_layers = model image in
let content_loss = Loss.get_content_loss input_layers content_layers [21] in
let expected = 0.0000 in
let result = Torch.Tensor.to_float0_exn content_loss |> Base.Float.round_decimal ~decimal_digits:4 in
assert_equal expected result;;

let test_combined_loss _=
let style_loss = Torch.Tensor.of_float0 0.5 in
let style_weight = 9e5 in
let content_loss = Torch.Tensor.of_float0 10.0 in
let result = Torch.Tensor.to_float0_exn (Loss.get_combined_loss style_loss style_weight content_loss) in
let expected = 450010. in
assert_equal result expected

let embedding_tests  = "embedding tests" >::: [
  "test_to_of_list" >:: test_to_of_list;
  "test_cosine_similarity" >:: test_cosine_similarity;
  "test_parse_embedding" >:: test_parse_embedding;
]

let image_utils_tests = "image_utils_tests" >::: [
  "test_file_to_string" >:: test_file_to_string;
  "test_image_to_blob" >:: test_image_to_blob;
  "test_write_binary_to_file" >:: test_write_binary_to_file;
  "test_with_temp_image_file" >:: test_with_temp_image_file;
]

let loader_tests = "loader_tests" >::: [
  "test_load_vgg_model" >:: test_load_vgg_model;
  "test_load_style_image" >:: test_load_style_img;
  "test_load_content_image" >:: test_load_content_img;
]

let loss_tests = "loss_tests" >::: [
  "test_gram_matrix" >:: test_gram_matrix;
  "test_style_loss" >:: test_style_loss;
  "test_content_loss" >:: test_content_loss;
  "test_combined_loss" >:: test_combined_loss;
]

let suite = "Project Tests" >::: [
  embedding_tests;
  image_utils_tests;
  loader_tests;
  loss_tests;
]

let () = run_test_tt_main suite