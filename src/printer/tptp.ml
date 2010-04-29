(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    Francois Bobot                                                      *)
(*    Jean-Christophe Filliatre                                           *)
(*    Johannes Kanig                                                      *)
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
open Register
open Format
open Pp
open Ident
open Ty
open Term
open Decl
open Task

let ident_printer =
  (* let bls = ["and";" benchmark";" distinct";"exists";"false";"flet";"forall";
     "if then else";"iff";"implies";"ite";"let";"logic";"not";"or";
     "sat";"theory";"true";"unknown";"unsat";"xor";
     "assumption";"axioms";"defintion";"extensions";"formula";
     "funs";"extrafuns";"extrasorts";"extrapreds";"language";
     "notes";"preds";"sorts";"status";"theory";"Int";"Real";"Bool";
     "Array";"U";"select";"store"] in *)
  let bls = ["fof"; "axiom"; "conjecture"; "&"; "="; "!="; "!"; "|"; "=>"; 
      "~"; "?"; "itef"] in
  let san = sanitizer char_to_alpha char_to_alnumus in
  create_ident_printer bls ~sanitizer:san

let print_ident fmt id =
  fprintf fmt "%s" (id_unique ident_printer id)

let print_functor fmt id =
  let san= Some String.uncapitalize in
  fprintf fmt "%s" (id_unique ?sanitizer:san ident_printer id)

let forget_var v = forget_id ident_printer v.vs_name

let print_var fmt {vs_name = id} =
  let sanitize n = String.capitalize n in
  let n = id_unique ident_printer ~sanitizer:sanitize id in
  fprintf fmt "%s" n


let rec print_type drv fmt ty = match ty.ty_node with
  | Tyvar _ -> unsupported "tptp : you must encode the polymorphism"
  | Tyapp (ts, tl) -> begin match Driver.query_syntax drv ts.ts_name with
      | Some s -> Driver.syntax_arguments s (print_type drv) fmt tl
      | None -> fprintf fmt "%a%a" (print_tyapp drv) tl print_ident ts.ts_name
    end

(* TODO : remove *)
and print_tyapp drv fmt = function
  | [] -> ()
  | [ty] -> fprintf fmt "%a " (print_type drv) ty
  | tl -> fprintf fmt "(%a) " (print_list comma (print_type drv)) tl

let print_type drv fmt = catch_unsupportedType (print_type drv fmt)

let rec print_term drv fmt t = match t.t_node with
  | Tbvar _ -> assert false
  | Tconst c -> fprintf fmt "'%a'"
      Pretty.print_const c
  | Tvar v -> print_var fmt v
  | Tapp (ls, tl) -> begin match Driver.query_syntax drv ls.ls_name with
      | Some s -> Driver.syntax_arguments s (print_term drv) fmt tl
      | None -> begin match tl with (* toto() is not accepted *)
          | [] -> fprintf fmt "@[%a@]" print_functor ls.ls_name
          | _ -> fprintf fmt "@[%a(%a)@]"  print_functor ls.ls_name
                (print_list comma (print_term drv)) tl
          end
      end
  | Tlet (_,_) -> unsupportedTerm t
      "tptp : you must eliminate let"
  | Tif (f1,t1,t2) ->
      fprintf fmt "@[itef(%a@, %a@, %a)@]"
        (print_fmla drv) f1 (print_term drv) t1 (print_term drv) t2
  | Tcase _ -> unsupportedTerm t
      "tptp : you must eliminate match"
  | Teps _ -> unsupportedTerm t
      "tptp : you must eliminate epsilon"

and print_fmla drv fmt f = match f.f_node with
  | Fapp ({ ls_name = id }, []) ->
      print_ident fmt id
  | Fapp (ls, tl) -> begin match Driver.query_syntax drv ls.ls_name with
      | Some s -> Driver.syntax_arguments s (print_term drv) fmt tl
      | None -> fprintf fmt "%a(%a)"
	      print_ident ls.ls_name (print_list comma (print_term drv)) tl
      end
  | Fquant (q, fq) ->
      let q = match q with Fforall -> "!" | Fexists -> "?" in
      let vl, _tl, f = f_open_quant fq in
      (* TODO trigger *)
      let rec forall fmt = function
        | [] -> print_fmla drv fmt f
        | v::l ->
	    fprintf fmt "@[(%s [%a]@ : (%a))@]" q print_var v forall l
      in
      forall fmt vl;
      List.iter forget_var vl
  | Fbinop (Fand, f1, f2) ->
      fprintf fmt "@[(%a &@ %a)@]" (print_fmla drv) f1 (print_fmla drv) f2
  | Fbinop (For, f1, f2) ->
      fprintf fmt "@[(%a |@ %a)@]" (print_fmla drv) f1 (print_fmla drv) f2
  | Fbinop (Fimplies, f1, f2) ->
      fprintf fmt "@[(%a =>@ %a)@]"
        (print_fmla drv) f1 (print_fmla drv) f2
  | Fbinop (Fiff, f1, f2) ->
      fprintf fmt "@[(%a <=> %a)@]" (print_fmla drv) f1 (print_fmla drv) f2
  | Fnot f ->
      fprintf fmt "@[(~@ %a)@]" (print_fmla drv) f
  | Ftrue ->
      fprintf fmt "true"
  | Ffalse ->
      fprintf fmt "false"
  | Fif (_,_,_) -> unsupportedFmla f "Fif not supported"
      (* fprintf fmt "@[(if_then_else %a@ %a@ %a)@]"
	(print_fmla drv) f1 (print_fmla drv) f2 (print_fmla drv) f3 *)
  | Flet (_, _) -> unsupportedFmla f "Flet not supported"
      (* let v, f2 = f_open_bound tb in
      fprintf fmt "@[(let (%a %a)@ %a)@]" print_var v
        (print_term drv) t1 (print_fmla drv) f2;
      forget_var v *)
  | Fcase _ -> unsupportedFmla f
      "tptp : you must eliminate match"

and print_expr drv fmt = e_apply (print_term drv fmt) (print_fmla drv fmt)

and print_triggers drv fmt tl = print_list comma (print_expr drv) fmt tl


let print_logic_binder drv fmt v =
  fprintf fmt "%a: %a" print_ident v.vs_name (print_type drv) v.vs_ty

let print_type_decl drv fmt = function
  | ts, Tabstract when Driver.query_remove drv ts.ts_name -> false
  | ts, Tabstract when ts.ts_args = [] ->
      fprintf fmt ":extrasorts (%a)" print_ident ts.ts_name; true
  | _, Tabstract -> true (*unsupported "tptp : type with argument are not supported" *)
  | _, Talgebraic _ -> true (* unsupported "tptp : algebraic type are not supported" *)
  (* FIXME : types are currently just ignored, which is unsafe *)

let print_logic_decl drv fmt (ls,ld) = match ld with
  | None -> ()
  | Some _ -> unsupported "Predicate and function definition aren't supported"

let print_logic_decl drv fmt d =
  if Driver.query_remove drv (fst d).ls_name then
    false else (print_logic_decl drv fmt d; true)

let print_decl drv fmt d = match d.d_node with
  | Dtype dl ->
      print_list_opt newline (print_type_decl drv) fmt dl
  | Dlogic dl ->
      print_list_opt newline (print_logic_decl drv) fmt dl
  | Dind _ -> unsupportedDecl d
      "tptp : inductive definition are not supported"
  | Dprop (Paxiom, pr, _) when Driver.query_remove drv pr.pr_name -> false
  | Dprop (Paxiom, _pr, f) ->
      fprintf fmt "fof(%s, axiom,@ %a).\n"
         (string_unique ident_printer "axiom") (print_fmla drv) f; true
  | Dprop (Pgoal, pr, f) -> (* TODO : what is pr ? *)
      fprintf fmt "fof(%s, conjecture,@ %a ).\n"
        (string_unique ident_printer "goal") (print_fmla drv) f; true
      (* fprintf fmt "@[;; %a@]@\n" print_ident pr.pr_name; *)
  | Dprop (Plemma, _, _) -> assert false

let print_decl drv fmt = catch_unsupportedDecl (print_decl drv fmt)

let print_task drv fmt task =
  Driver.print_full_prelude drv task fmt;
  let decls = Task.task_decls task in
  ignore (print_list_opt (add_flush newline2) (print_decl drv) fmt decls)

let () = register_printer "tptp"
  (fun drv fmt task ->
     forget_all ident_printer;
     print_task drv fmt task)
