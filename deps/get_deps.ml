open Sys 
open Unix 

type tags = 
  { mutable use_nightly : bool
  ; mutable use_binary_for_ci : bool 
  ; mutable compute_arch : string 
  ; mutable skip_download : bool 
  ; mutable version : string
  }

let current_tags = 
  { use_nightly = false
  ; use_binary_for_ci = false
  ; compute_arch = "cpu"
  ; skip_download = false
  ; version = "2.3.0"
  }

exception Error of string

let echo (s : string) = Printf.printf "%s\n" s

let usage_exit () : unit = 
  echo "Usage: $0 [-n] [-c] [-a \"cpu\" or \"cu117\" or \"cu118\"] [-s]";
  echo " -n # Use nightly libtorch w/  -l";
  echo "    # Use libtorch-$(VERSION)  w/o -l";
  echo " -c # Download libtorch from hasktorch's site w/ -c";
  echo "    # Download libtorch from pytorch's site w/o  -c";
  echo " -a cpu   # Use CPU without CUDA";
  echo " -a cu117 # Use CUDA-11.7";
  echo " -a cu118 # Use CUDA-11.8";
  echo "";
  echo " -s # Skip download";
  echo "";
  echo " -h # Show this help"


let rec parse_args (args : string List.t) : unit =
  match args with 
    | (n::remains) -> 
      begin
      match n with 
      | "-n" -> current_tags.use_nightly <- true; parse_args remains
      | "-c" -> current_tags.use_binary_for_ci <- true; parse_args remains
      | "-a" -> 
        begin 
        match remains with 
        | (arch::rremains) -> current_tags.compute_arch <- arch; parse_args rremains
        | _ -> raise (Error "value error")
        end
      | "-s" -> current_tags.skip_download <- true; parse_args remains
      | "-h" -> usage_exit ()
      | _ -> usage_exit ()
      end
    | [] -> ()


let init () : unit= 
  let args = Array.to_list Sys.argv in
  parse_args (List.tl args)
  

let () = 
  init ();
  