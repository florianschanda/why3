(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    François Bobot                                                     *)
(*    Jean-Christophe Filliâtre                                          *)
(*    Claude Marché                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

(*******************

This file builds some goals using the API and calls
the alt-ergo prover to check them

******************)

(* opening the Why3 library *)
open Why3

(* a ground propositional goal: true or false *)
let fmla_true : Term.term = Term.t_true
let fmla_false : Term.term = Term.t_false
let fmla1 : Term.term = Term.t_or fmla_true fmla_false

(* printing it *)
open Format
let () = printf "@[formula 1 is:@ %a@]@." Pretty.print_term fmla1


(* a propositional goal: A and B implies A *)

let prop_var_A : Term.lsymbol = Term.create_psymbol (Ident.id_fresh "A") []
let prop_var_B : Term.lsymbol = Term.create_psymbol (Ident.id_fresh "B") []
let atom_A : Term.term = Term.ps_app prop_var_A []
let atom_B : Term.term = Term.ps_app prop_var_B []
let fmla2 : Term.term = Term.t_implies (Term.t_and atom_A atom_B) atom_A
let () = printf "@[formula 2 is:@ %a@]@." Pretty.print_term fmla2


(* building the task for formula 1 alone *)
let task1 : Task.task = None (* empty task *)
let goal_id1 : Decl.prsymbol = Decl.create_prsymbol (Ident.id_fresh "goal1")
let task1 : Task.task = Task.add_prop_decl task1 Decl.Pgoal goal_id1 fmla1

(* printing the task *)
let () = printf "@[task 1 is:@\n%a@]@." Pretty.print_task task1

(* task for formula 2 *)
let task2 = None
let task2 = Task.add_param_decl task2 prop_var_A
let task2 = Task.add_param_decl task2 prop_var_B
let goal_id2 = Decl.create_prsymbol (Ident.id_fresh "goal2")
let task2 = Task.add_prop_decl task2 Decl.Pgoal goal_id2 fmla2

let () = printf "@[task 2 created:@\n%a@]@." Pretty.print_task task2



(* To call a prover, we need to access the Why configuration *)

(* reads the config file *)
let config : Whyconf.config = Whyconf.read_config None
(* the [main] section of the config file *)
let main : Whyconf.main = Whyconf.get_main config
(* all the provers detected, from the config file *)
let provers : Whyconf.config_prover Whyconf.Mprover.t =
  Whyconf.get_provers config

(* One prover named Alt-Ergo in the config file *)
let alt_ergo : Whyconf.config_prover =
  let fp = Whyconf.parse_filter_prover "Alt-Ergo" in
  (** all provers that have the name "Alt-Ergo" *)
  let provers = Whyconf.filter_provers config fp in
  if Whyconf.Mprover.is_empty provers then begin
    eprintf "Prover Alt-Ergo not installed or not configured@.";
    exit 0
  end else
    snd (Whyconf.Mprover.choose provers)

(* builds the environment from the [loadpath] *)
let env : Env.env = Env.create_env (Whyconf.loadpath main)

(* loading the Alt-Ergo driver *)
let alt_ergo_driver : Driver.driver =
  try
    Driver.load_driver env alt_ergo.Whyconf.driver []
  with e ->
    eprintf "Failed to load driver for alt-ergo: %a@."
      Exn_printer.exn_printer e;
    exit 1

(* calls Alt-Ergo *)
let result1 : Call_provers.prover_result =
  Call_provers.wait_on_call
    (Driver.prove_task ~command:alt_ergo.Whyconf.command
    alt_ergo_driver task1 ()) ()

(* prints Alt-Ergo answer *)
let () = printf "@[On task 1, alt-ergo answers %a@."
  Call_provers.print_prover_result result1

let result2 : Call_provers.prover_result =
  Call_provers.wait_on_call
    (Driver.prove_task ~command:alt_ergo.Whyconf.command
    ~timelimit:10
    alt_ergo_driver task2 ()) ()

let () = printf "@[On task 2, alt-ergo answers %a in %5.2f seconds@."
  Call_provers.print_prover_answer result1.Call_provers.pr_answer
  result1.Call_provers.pr_time



(*

An arithmetic goal: 2+2 = 4

*)

let two : Term.term = Term.t_const (Term.ConstInt (Term.int_const_decimal "2"))
let four : Term.term = Term.t_const (Term.ConstInt (Term.int_const_decimal "4"))
let int_theory : Theory.theory =
  Env.find_theory env ["int"] "Int"
let plus_symbol : Term.lsymbol =
  Theory.ns_find_ls int_theory.Theory.th_export ["infix +"]
let two_plus_two : Term.term = Term.fs_app plus_symbol [two;two] Ty.ty_int
let two_plus_two : Term.term = Term.t_app_infer plus_symbol [two;two]
let fmla3 : Term.term = Term.t_equ two_plus_two four

let task3 = None
let task3 = Task.use_export task3 int_theory
let goal_id3 = Decl.create_prsymbol (Ident.id_fresh "goal3")
let task3 = Task.add_prop_decl task3 Decl.Pgoal goal_id3 fmla3

(*
let () = printf "@[task 3 created:@\n%a@]@." Pretty.print_task task3
*)
let () = printf "@[task 3 created@]@."

let result3 =
  Call_provers.wait_on_call
    (Driver.prove_task ~command:alt_ergo.Whyconf.command
    alt_ergo_driver task3 ()) ()

let () = printf "@[On task 3, alt-ergo answers %a@."
  Call_provers.print_prover_result result3

(* quantifiers: let's build "forall x:int. x*x >= 0" *)
let zero : Term.term = Term.t_const (Term.ConstInt (Term.int_const_decimal "0"))
let mult_symbol : Term.lsymbol =
  Theory.ns_find_ls int_theory.Theory.th_export ["infix *"]
let ge_symbol : Term.lsymbol =
  Theory.ns_find_ls int_theory.Theory.th_export ["infix >="]

let var_x : Term.vsymbol =
  Term.create_vsymbol (Ident.id_fresh "x") Ty.ty_int
let x : Term.term = Term.t_var var_x
let x_times_x : Term.term =
  Term.t_app_infer mult_symbol [x;x]
let fmla4_aux : Term.term =
  Term.ps_app ge_symbol [x_times_x;zero]
let fmla4 : Term.term = Term.t_forall_close [var_x] [] fmla4_aux

let task4 = None
let task4 = Task.use_export task4 int_theory
let goal_id4 = Decl.create_prsymbol (Ident.id_fresh "goal4")
let task4 = Task.add_prop_decl task4 Decl.Pgoal goal_id4 fmla4

let result4 =
  Call_provers.wait_on_call
    (Driver.prove_task ~command:alt_ergo.Whyconf.command
    alt_ergo_driver task4 ()) ()

let () = printf "@[On task 4, alt-ergo answers %a@."
  Call_provers.print_prover_result result4

(* build a theory with all these goals *)

(* TODO *)





(* build a whyml program *)

let m = Mlw_module.create_module env (Ident.id_fresh "Program")

let mul_int : Term.lsymbol =
  Theory.ns_find_ls int_theory.Theory.th_export ["infix *"]

let unit_type = Ty.ty_tuple []

let d = 
  let args =
    [Mlw_ty.create_pvsymbol 
        (Ident.id_fresh "_dummy") (Mlw_ty.vty_value Mlw_ty.ity_unit)]
  in
  let result = Term.create_vsymbol (Ident.id_fresh "result") unit_type in
  let spec = {
    Mlw_ty.c_pre = Term.t_true;
    c_post = Term.t_eps (Term.t_close_bound result Term.t_true);
    c_xpost = Mlw_ty.Mexn.empty;
    c_effect = Mlw_ty.eff_empty;
    c_variant = [];
    c_letrec  = 0;
  }
  in
  let body =
    let c6 = Term.t_const (Term.ConstInt (Term.int_const_decimal "6")) in
    let c7 = Term.t_const (Term.ConstInt (Term.int_const_decimal "7")) in
    let c42 = Term.t_const (Term.ConstInt (Term.int_const_decimal "42")) in
    let p = 
      Term.t_equ (Term.t_app_infer mul_int [c6;c7]) c42
    in
    Mlw_expr.e_assert Mlw_expr.Aassert p 
  in
  let lambda = {
    Mlw_expr.l_args = args;
    l_expr = body;
    l_spec = spec;
  }
  in
  let def = Mlw_expr.create_fun_defn (Ident.id_fresh "f") lambda in
  Mlw_decl.create_rec_decl [def]


(* TODO: continue *)

(*
let () = Printexc.record_backtrace true

let () =
  try
    let _buggy : Mlw_module.module_uc = Mlw_module.add_pdecl ~wp:true m d in
    ()
  with Not_found ->
    Printexc.print_backtrace stderr;
    flush stderr
*)
