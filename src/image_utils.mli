open Owl

module N = Dense.Ndarray.S

val preprocess: N.arr -> N.arr
val postprocess: N.arr -> N.arr
val save_image_to_file: N.arr -> string -> unit
val save_ppm: string -> string -> unit
val save_ppm_from_arr: N.arr -> string -> unit
val _read_ppm: string -> float array array * int * int * int
val load_ppm: string -> N.arr
val extend_dim: N.arr -> N.arr

