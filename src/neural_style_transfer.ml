open Owl
open Owl_types
open Neural.S
open Neural.S.Graph
open Neural.S.Algodiff
open Neural.S.Graph.Neuron

(*model: VGG19*)

let model h w = 
  let nn = input [|h; w; 3|]
    (* block 1 *)
    |> conv2d [|3;3;3;64|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;64;64|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> max_pool2d [|2;2|] [|2;2|] ~padding:VALID
    (* block 2 *)
    |> conv2d [|3;3;64;128|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;128;128|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> max_pool2d [|2;2|] [|2;2|] ~padding:VALID
    (* block 3 *)
    |> conv2d [|3;3;128;256|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;256;256|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;256;256|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME
    |> conv2d [|3;3;256;256|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME
    |> max_pool2d [|2;2|] [|2;2|] ~padding:VALID
    (* block 4 *)
    |> conv2d [|3;3;256;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME
    |> max_pool2d [|2;2|] [|2;2|] ~padding:VALID
    (* block 5 *)
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME 
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME
    |> conv2d [|3;3;512;512|] [|1;1|] ~act_typ:Activation.Relu ~padding:SAME
    |> max_pool2d [|2;2|] [|2;2|] ~padding:VALID
    (* classification block *)
    (*|> flatten 
    |> fully_connected ~act_typ:Activation.Relu 4096
    |> fully_connected ~act_typ:Activation.Relu 4096
    |> fully_connected ~act_typ:Activation.Softmax classes *)
    |> global_max_pool2d
    |> get_network
  in
  nn


(* let vgg_img_size    = 224 *)
let init_target     = Dense.Ndarray.S.zeros [|1|]
let learning_rate   = 10.

(* let content_nodes     = [|"activation_23"|] *)
let content_nodes_idx = [|23|]
let content_len       = Array.length content_nodes_idx
let content_losses    = Stdlib.Array.make content_len (F 0.)
let content_targets   = Stdlib.Array.make content_len init_target
let alpha             = F 5.

(* let style_nodes     = [|"activation_2"; "activation_7"; "activation_12"; 
                        "activation_21"; "activation_30"|] *)
let style_nodes_idx = [|2; 7; 12; 21; 30|]
let style_len       = Array.length style_nodes_idx
let style_losses    = Stdlib.Array.make style_len (F 0.)
let style_targets   = Stdlib.Array.make style_len init_target
let beta            = F (500. /. (float_of_int style_len))
        
let weight_file = "/home/ooludip1/Fpse/project/fpse-project/src/vgg19_owl_short.weight"


let get_shape x = 
  let s = x |> primal' |> unpack_arr |> Dense.Ndarray.S.shape in 
  assert (Array.length s = 4);
  assert (s.(0) = 1);
  s.(0), s.(1), s.(2), s.(3)


let run' topo x =
  let last_node_output = ref (F 0.) in
  Stdlib.Array.iteri (fun i n ->
    let input  = if i = 0 then x else !last_node_output in 
    let output = run [|input|] n.neuron in
    last_node_output := output;
  ) topo;
  !last_node_output


let gram x = 
  let _, h, w, feature = get_shape x in 
  let new_shape = [|h * w; feature|] in 
  let ff = Maths.(reshape x new_shape) in 
  let size = F (float_of_int (feature * h * w)) in
  Maths.((transpose ff) *@ ff / size)


let c_loss response target = 
  let loss = Maths.((pow (response - target) (F 2.)) |> sum') in 
  let _, h, w, feature = get_shape target in 
  let c = float_of_int ( feature * h * w ) in
  Maths.(loss / (F c))


let s_loss response_gram target_gram = 
  let loss = Maths.((pow (response_gram - target_gram) (F 2.)) |> sum') in 
  let s = Algodiff.shape target_gram in
  let c = float_of_int ( s.(0) * s.(1)) in
  Maths.(loss / (F c))


let fill_content_targets x net = 
  let nn = Neural.S.Graph.copy net in
  let selected_topo = Stdlib.Array.sub nn.topo 0 (content_nodes_idx.(0) + 1) in 
  let t = run' selected_topo x |> unpack_arr in
  Array.set content_targets 0 t


let fill_style_targets x net = 
  let nn = Neural.S.Graph.copy net in
  let last_node_output = ref (F 0.) in
  let j = ref 0 in 

  Stdlib.Array.iteri (fun i n ->
    let input  = if i = 0 then x else !last_node_output in 
    let output = run [|input|] n.neuron in
    last_node_output := output;

    if !j < style_len then (
      if i = style_nodes_idx.(!j) then (
        Array.set style_targets !j (output |> gram |> unpack_arr);
        j := !j + 1
      )
    )

  ) nn.topo

let _convert img_name = 
  let base = Stdlib.Filename.basename img_name in 
  let prefix = Stdlib.Filename.remove_extension base in
  let temp_img = Stdlib.Filename.temp_file prefix ".ppm"in
  temp_img


let get_img_shape img_name = 
  let temp_img = _convert img_name in
  let _ = Stdlib.Sys.command ("convert " ^ img_name ^ " " ^ temp_img) in
  let _, w, h, _ = Image_utils._read_ppm temp_img in
  w, h


let convert_img_to_ppm w h img_name = 
  let temp_img = _convert img_name in
  let _ = Stdlib.Sys.command ("convert -resize " ^ (string_of_int w) ^ 
    "x" ^ (string_of_int h) ^"\\! " ^ 
    img_name ^ " " ^ temp_img) in
  temp_img


let convert_arr_to_img d3array output_name = 
  let temp_img = _convert output_name in
  let output = d3array |> Image_utils.postprocess in
  Image_utils.save_ppm_from_arr output temp_img;
  let _ = Stdlib.Sys.command ("convert " ^ temp_img ^ " " ^ output_name) in
  ()


(** main entry *)
let run ?(ckpt=50) ?(init=true) 
  ~src:content_img ~style:style_img ~dst:output_img iter = 
      
  (* preprocess inputs *)
  let w, h = get_img_shape content_img in

  let content_img = convert_img_to_ppm w h content_img in
  let style_img   = convert_img_to_ppm w h style_img   in
  let content_img = Image_utils.(load_ppm content_img |> extend_dim |> preprocess) in
  let style_img   = Image_utils.(load_ppm style_img   |> extend_dim |> preprocess) in

  (* initialise image with content image or random noise *)
  let input_img = 
    if (init = false) then
      let input_shape = Dense.Ndarray.S.shape content_img in
      Dense.Ndarray.S.(gaussian input_shape |> scalar_mul 0.256)
    else content_img
  in

  (* create network *)
  let nn = model h w in
  Graph.load_weights nn weight_file;

  (* precomputed the content and style targets *)
  fill_content_targets (Arr content_img) nn;
  fill_style_targets   (Arr style_img)   nn;

  let fill_losses x = 
    Gc.compact ();
    let ind_s = ref 0 in 
    let last_node_output = ref (F 0.) in

    Array.iteri (fun i n ->
      let input  = if i = 0 then x else !last_node_output in 
      let output = run [|input|] n.neuron in
      last_node_output := output;

      if i = content_nodes_idx.(0) then (
        let los = c_loss output (Arr content_targets.(0)) in 
        Array.set content_losses 0 los;
      ); 

      if !ind_s < style_len then ( 
        if i = style_nodes_idx.(!ind_s) then (
          let los = s_loss (gram output) (Arr style_targets.(!ind_s)) in
          Array.set style_losses !ind_s Maths.(los * beta);
          ind_s := !ind_s + 1;
        )
      )
    ) nn.topo
  in

  let g x = 
    fill_losses x;
    Gc.compact ();
    let content_loss = Maths.(content_losses.(0) * alpha) in
    let style_loss   = Array.fold_left Maths.(+) (F 0.) style_losses in
    let loss =  Maths.(content_loss + style_loss) in
    loss
  in

  (* define checkpoint function *)
  let chkpt state =
    let open Checkpoint in
    if state.current_batch mod ckpt = 0 then (
      state.stop <- true
    )
  in

  (* optimisation parameters *)
  let params = Params.config
    ~batch:(Batch.Full) 
    ~learning_rate:(Learning_Rate.Adam (learning_rate, 0.9, 0.999))
    ~checkpoint:(Checkpoint.Custom chkpt)
    iter
  in

  (* start gradient descent *)
  let state, img = Optimise.minimise_fun params g (Arr input_img) in
  let x' = ref img in
  let cnt = ref 0 in 
  while Checkpoint.(state.current_batch < state.batches) do
    (* print out intermediate image at checkpoint *)
    cnt := !cnt + ckpt;
    let file_base = Filename.remove_extension output_img in
    let file_exte = Filename.extension output_img in
    let file_name = Printf.sprintf "%s_%04d%s" file_base !cnt file_exte in
    Owl_log.info "checkpoint => %s" file_name;
    convert_arr_to_img (!x' |> unpack_arr) file_name;
    (* continue optimisation *)
    Checkpoint.(state.stop <- false);
    let _, img = Optimise.minimise_fun ~state params g !x' in 
    x' := img
  done;
  
  (* output final result to image file *)
  let x_star = !x' in
  convert_arr_to_img (x_star |> unpack_arr) output_img

  let () = 
  run ~ckpt:50 ~src:"/home/ooludip1/Fpse/project/fpse-project/tests/london.jpg" ~style:"/home/ooludip1/Fpse/project/fpse-project/tests/style-starry.jpg" ~dst:"/home/ooludip1/Fpse/project/fpse-project/tests/output_imgtest.png" 250.