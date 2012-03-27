open Why3

type report_mode = Fail | Verbose | Detailed

let opt_verbose = ref false
let opt_timeout = ref 10
let opt_report = ref Fail
let opt_debug = ref false
let opt_force = ref false
let opt_noproof = ref false
let opt_filename : string option ref = ref None

let opt_limit_line : Gnat_expl.loc option ref = ref None

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

let set_limit_line s =
   try
      let index = String.rindex s ':' in
      let fn = String.sub s 0 index in
      let line =
         int_of_string (String.sub s (index + 1) (String.length s - index - 1))
      in
      opt_limit_line := Some (Gnat_expl.mk_loc_line fn line)
   with
   | Not_found ->
      Gnat_util.abort_with_message
      "limit-line: incorrect line specification - missing ':'"
   | Failure "int_of_string" ->
      Gnat_util.abort_with_message
      "limit-line: incorrect line specification - does not end with line number"


let usage_msg =
  "Usage: gnatwhy3 [options] file"

let options = Arg.align [
   "-v", Arg.Set opt_verbose, "Output extra verbose information";
   "--verbose", Arg.Set opt_verbose, "Output extra verbose information";

   "-t", Arg.Set_int opt_timeout,
          "Set the timeout in seconds (default is 10 seconds)";
   "--timeout", Arg.Set_int opt_timeout,
          "Set the timeout in seconds (default is 10 seconds)";

   "-f", Arg.Set opt_force,
          "Rerun VC generation and proofs, even when the result is up to date";
   "--force", Arg.Set opt_force,
          "Rerun VC generation and proofs, even when the result is up to date";
   "--no-proof", Arg.Set opt_noproof,
          "Do not call the prover";
   "--report", Arg.String set_report,
          "set report mode, one of (fail | all | detailed), default is fail";
   "--limit-line", Arg.String set_limit_line,
          "limit proof to a file and line, given by \"file:line\"";
   "--debug", Arg.Set opt_debug,
          "Enable debug mode";
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
   try Whyconf.read_config (Some "why3.conf")
   with Rc.CannotOpen _ ->
      Gnat_util.abort_with_message "Cannot read file why3.conf."

let config_main = Whyconf.get_main (config)

let env =
   Env.create_env (Whyconf.loadpath config_main)

let provers : Whyconf.config_prover Whyconf.Mprover.t =
   Whyconf.get_provers config

let alt_ergo_conf =
   { Whyconf.prover_name = "Alt-Ergo";
     prover_version      = "0.94";
     prover_altern       = "";
   }

let alt_ergo : Whyconf.config_prover =
  try
    Whyconf.Mprover.find alt_ergo_conf provers
  with Not_found ->
    Gnat_util.abort_with_message
      "Prover alt-ergo not installed or not configured."

(* loading the Alt-Ergo driver *)
let altergo_driver : Driver.driver =
  try
    Driver.load_driver env alt_ergo.Whyconf.driver
      alt_ergo.Whyconf.extra_drivers
  with e ->
    Format.eprintf "Failed to load driver for alt-ergo: %a"
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

let autogen_label = Ident.create_label "autogenerated"
