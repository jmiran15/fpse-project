(* Pseudo-code for applying NST to a video using ocaml-ffmpeg

(* Step 1: Split Video into Frames *)
let split_video_into_frames input_video output_frames_folder =
  (* Use ocaml-ffmpeg to read the input video and extract frames as images *)
  (* Save the frames to the output_frames_folder *)

(* Step 2: Apply NST to Each Frame *)
let apply_nst_to_frame frame_path =
  (* Apply the provided NST algorithm to stylize the frame using your algorithm *)

(* Step 3: Combine Modified Frames into a Video *)
let combine_frames_into_video modified_frames output_video_path =
  (* Use ocaml-ffmpeg to create a new video from the modified frames *)
  (* Save the combined frames as a new video file *)

(* Step 4: Full Process *)
let process_video_with_nst input_video output_video style_image model_name content_image =
  split_video_into_frames input_video "frames/"
  (* Apply NST to each frame *)
  let modified_frames = (* Apply NST to each frame using apply_nst_to_frame function *)
  combine_frames_into_video modified_frames output_video *)
