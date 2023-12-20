open Torch
open Torch_vision
open Loader
open Loss

type flags = {
  style_weight : float;
  learning_rate : float;
  total_steps : int;
  layers_style_loss : int list;
  layers_content_loss : int list;
}

let flags =
  {
    style_weight = 9e5;
    learning_rate = 8e-2;
    total_steps = 30;
    layers_content_loss = [21];
    layers_style_loss = [2; 10; 14; 21; 28];
  }

let get_inputs_tensors
    model_name
    cpu
    style_img_path
    content_img_path
    weight_path =
  let model =
    load_vgg_model model_name weight_path flags.layers_style_loss
      flags.layers_content_loss cpu
  in
  let style_img = load_style_img style_img_path cpu in
  let content_img = load_content_img content_img_path cpu in
  (model, style_img, content_img)


[@@@coverage off]
let training_nst
    model
    generated_img
    optimizer
    style_layers
    content_layers
    total_steps =
  for iteration = 1 to total_steps do
    Optimizer.zero_grad optimizer;
    let input_layers = model generated_img in
    let style_loss =
      get_style_loss input_layers style_layers flags.layers_style_loss
    in
    let content_loss =
      get_content_loss input_layers content_layers
        flags.layers_content_loss
    in
    let loss =
      get_combined_loss style_loss flags.style_weight content_loss
    in
    Tensor.backward loss;
    Optimizer.step optimizer;
    Tensor.no_grad (fun () ->
        ignore (Imagenet.clamp_ generated_img : Tensor.t));
    let _ =
      Stdio.printf
        "Iteration: %d,  Combined Loss: %.4f, Style Loss: %.4f, \
         Content Loss: %.4f\n\
         %!"
        iteration
        (Tensor.float_value loss)
        (Tensor.float_value style_loss)
        (Tensor.float_value content_loss)
    in
    Stdlib.Gc.full_major ();
    if iteration mod 5 = 0 then
      let img_idx = iteration / 5 in
      Imagenet.write_image generated_img
        ~filename:(Printf.sprintf "GIF_tmp/gif%04d.png" img_idx)
  done

(*Sample input: main "vgg19" "style.jpg" "contene.jpg" "./vgg19.ot" "output.jpg"*)

let main model_name style content model output =
  let cpu = Device.cuda_if_available () in
  let model, style_img, content_img =
    get_inputs_tensors model_name cpu style content model
  in
  let model_paras = Var_store.create ~name:"optim" ~device:cpu () in
  let image =
    Var_store.new_var_copy model_paras ~src:content_img ~name:"in"
  in
  let style_layers, content_layers =
    let detach = Base.Map.map ~f:Tensor.detach in
    Tensor.no_grad (fun () ->
        (model style_img |> detach, model content_img |> detach))
  in
  let optimizer =
    Optimizer.adam model_paras ~learning_rate:flags.learning_rate
  in
  let _ = Stdio.printf "Training begin for the new artwork \n%!" in
  (* save the processed first image for gif *)
  Imagenet.write_image image
    ~filename:(Printf.sprintf "GIF_tmp/gif000.png");
  let _ =
    training_nst model image optimizer style_layers content_layers
      flags.total_steps
  in
  Imagenet.write_image image ~filename:output