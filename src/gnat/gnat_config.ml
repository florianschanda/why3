open Why3

type report_mode = Fail | Verbose | Detailed

let gnatprove_why3conf_file = "why3.conf"

let opt_verbose = ref false
let opt_timeout = ref 10
let opt_report = ref Fail
let opt_debug = ref false
let opt_force = ref false
let opt_noproof = ref false
let opt_filename : string option ref = ref None
let opt_ide_progress_bar = ref false
let opt_parallel = ref 1
let opt_prover : string option ref = ref None

let opt_limit_line : Gnat_loc.loc option ref = ref None
let opt_limit_subp : Gnat_loc.loc option ref = ref None

let set_filename s =
   if !opt_filename = None then
      opt_filename := Some s
   else
      Gnat_util.abort_with_message "Only one file name should be given."

let set_report s =
   if s = "detailed" then
      opt_report := Detailed
   else if s = "all" then
      opt_report := Verbose
   else if s <> "fail" then
      Gnat_util.abort_with_message
        "argument for option --report should be one of (fail|all|detailed)."

let set_prover s =
   opt_prover := Some s

let parse_line_spec caller s =
   try
      let index = String.rindex s ':' in
      let fn = String.sub s 0 index in
      let line =
         int_of_string (String.sub s (index + 1) (String.length s - index - 1))
      in
      Gnat_loc.mk_loc_line fn line
   with
   | Not_found ->
      Gnat_util.abort_with_message
      (caller ^ ": incorrect line specification - missing ':'")
   | Failure "int_of_string" ->
      Gnat_util.abort_with_message
      (caller ^
        ": incorrect line specification - does not end with line number")

let set_limit_line s = opt_limit_line := Some (parse_line_spec "limit-line" s)
let set_limit_subp s = opt_limit_subp := Some (parse_line_spec "limit-subp" s)

let usage_msg =
  "Usage: gnatwhy3 [options] file"

let options = Arg.align [
   "-v", Arg.Set opt_verbose, " Output extra verbose information";
   "--verbose", Arg.Set opt_verbose, " Output extra verbose information";

   "-t", Arg.Set_int opt_timeout,
          " Set the timeout in seconds (default is 10 seconds)";
   "--timeout", Arg.Set_int opt_timeout,
          " Set the timeout in seconds (default is 10 seconds)";
   "-j", Arg.Set_int opt_parallel,
          " Set the number of parallel processes (default is 1)";
   "-f", Arg.Set opt_force,
          " Rerun VC generation and proofs, even when the result is up to date";
   "--force", Arg.Set opt_force,
          " Rerun VC generation and proofs, even when the result is up to date";
   "--no-proof", Arg.Set opt_noproof,
          " Do not call the prover";
   "--report", Arg.String set_report,
          " Set report mode, one of (fail | all | detailed), default is fail";
   "--limit-line", Arg.String set_limit_line,
          " Limit proof to a file and line, given by \"file:line\"";
   "--limit-subp", Arg.String set_limit_subp,
          " Limit proof to a subprogram defined by \"file:line\"";
   "--prover", Arg.String set_prover,
          " Use prover given in argument instead of Alt-Ergo";
   "--ide-progress-bar", Arg.Set opt_ide_progress_bar,
          " Issue information on number of VCs proved";
   "--debug", Arg.Set opt_debug,
          " Enable debug mode";
]

let filename =
   let is_not_why_loc s =
      not (Filename.check_suffix s "why" ||
           Filename.check_suffix s "mlw") in
   Arg.parse options set_filename usage_msg;
   match !opt_filename with
   | None -> Gnat_util.abort_with_message "No file given."
   | Some s ->
         if is_not_why_loc s then
            Gnat_util.abort_with_message
              (Printf.sprintf "Not a Why input file: %s." s);
         s

let config =
   (* if a prover was given, read default config file and local config file *)
   try
      if !opt_prover = None then Whyconf.read_config (Some "why3.conf")
      else begin
         let conf = Whyconf.read_config None in
         Whyconf.merge_config conf gnatprove_why3conf_file
      end
   with Rc.CannotOpen _ ->
      Gnat_util.abort_with_message "Cannot read file why3.conf."

let config_main = Whyconf.get_main (config)

let env =
   Env.create_env (Whyconf.loadpath config_main)

let provers : Whyconf.config_prover Whyconf.Mprover.t =
   Whyconf.get_provers config


let prover : Whyconf.config_prover =
  try
     match !opt_prover with
      | Some s -> Whyconf.prover_by_id config s
      | None ->
            let conf =
               { Whyconf.prover_name = "Alt-Ergo";
                 prover_version      = "0.94";
                 prover_altern       = "";
               } in
            Whyconf.Mprover.find conf provers
  with Not_found ->
    Gnat_util.abort_with_message
      "Prover not installed or not configured."

(* loading the driver driver *)
let prover_driver : Driver.driver =
  try
    Driver.load_driver env prover.Whyconf.driver
      prover.Whyconf.extra_drivers
  with e ->
    Format.eprintf "Failed to load driver for alt-ergo: %a"
       Exn_printer.exn_printer e;
    Gnat_util.abort_with_message ""

let gnat_driver : Driver.driver =
  try
    Driver.load_driver env
    "/home/kanig/HiLite/hi-lite/install/share/why3/drivers/gnat.drv" []
  with e ->
    Format.eprintf "Failed to load driver for gnat: %a"
       Exn_printer.exn_printer e;
    Gnat_util.abort_with_message ""


(* freeze values *)

let timeout = !opt_timeout
let verbose = !opt_verbose
let report  = !opt_report
let debug = !opt_debug
let force = !opt_force
let noproof = !opt_noproof
let split_name = "split_goal"
let limit_line = !opt_limit_line
let limit_subp = !opt_limit_subp
let ide_progress_bar = !opt_ide_progress_bar
let parallel = !opt_parallel

let autogen_label = Ident.create_label "autogenerated"

(* when not doing proof, stop after typing to avoid the exponential WP work *)
let () = if noproof then Debug.set_flag Typing.debug_type_only
