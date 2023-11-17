(* To run torch bindings on M2 mac follow https://github.com/janestreet/torch/issues/2#issuecomment-1646348356
1. uninstall torch and libtorch "opam uninstall torch libtorch"
2. install unofficial libtorch bindings from https://github.com/mlverse/libtorch-mac-m1/releases/tag/LibTorch
2.1 Version should be 1.13.1 (ibtorch-v1.13.1.zip), based on required version for torch from https://opam.ocaml.org/packages/torch/ i.e. libtorch>=1.13.0 & <1.14.0
3. Set LIBTORCH path in .zshrc. i.e. vim ~/.zshrc, then add "export LIBTORCH="$HOME/Downloads/libtorch"" or libtorch path, then source ~/.zshrc
4. opam install torch.v0.16.0 --ignore-constraints-on libtorch
5. sudo xattr -d com.apple.quarantine ./Downloads/libtorch/lib/libtorch.dylib *)

open Torch

let () =
  let tensor = Tensor.randn [ 4; 2 ] in
  Tensor.print tensor