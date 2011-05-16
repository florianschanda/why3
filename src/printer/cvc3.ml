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

(** SMT v1 printer with some extensions *)

open Format
open Pp
open Ident
open Ty
open Term
open Decl
open Theory
open Task
open Printer

(** Options of this printer *)
let use_builtin_array = Theory.register_meta_excl "Smt : builtin array" []

(** *)

let ident_printer =
  let bls = (*["and";" benchmark";" distinct";"exists";"false";"flet";"forall";
     "if then else";"iff";"implies";"ite";"let";"logic";"not";"or";
     "sat";"theory";"true";"unknown";"unsat";"xor";
     "assumption";"axioms";"defintion";"extensions";"formula";
     "funs";"extrafuns";"extrasorts";"extrapreds";"language";
     "notes";"preds";"sorts";"status";"theory";"Int";"Real";"Bool";
     "Array";"U";"select";"store"]*)
    (** smtlib2 V2 p71 *)
    [(** General: *)
      "!";"_"; "as"; "DECIMAL"; "exists"; "forall"; "let"; "NUMERAL";
      "par"; "STRING";
       (**Command names:*)
      "assert";"check-sat"; "declare-sort";"declare-fun";"define-sort";
      "define-fun";"exit";"get-assertions";"get-assignment"; "get-info";
      "get-option"; "get-proof"; "get-unsat-core"; "get-value"; "pop"; "push";
      "set-logic"; "set-info"; "set-option";
       (** for security *)
      "BOOLEAN";"unsat";"sat";"TRUE";"FALSE";
      "TRUE";"CHECK";"QUERY";"ASSERT";"TYPE";"SUBTYPE"]
  in
  let san = sanitizer char_to_alpha char_to_alnumus in
  create_ident_printer bls ~sanitizer:san

let print_ident fmt id =
  fprintf fmt "%s" (id_unique ident_printer id)

(** type *)
type info = {
  info_syn : string Mid.t;
  info_rem : Sid.t;
  complex_type : ty Hty.t;
}

let rec print_type info fmt ty = match ty.ty_node with
  | Tyvar _ -> unsupported "cvc3 : you must encode the polymorphism"
  | Tyapp (ts, []) -> begin match query_syntax info.info_syn ts.ts_name with
      | Some s -> syntax_arguments s (print_type info) fmt []
      | None -> fprintf fmt "%a" print_ident ts.ts_name
  end
  | Tyapp (ts, l) ->
     begin match query_syntax info.info_syn ts.ts_name with
      | Some s -> syntax_arguments s (print_type info) fmt l
      | None -> print_type info fmt (Hty.find info.complex_type ty)
     end

(* and print_tyapp info fmt = function *)
(*   | [] -> () *)
(*   | [ty] -> fprintf fmt "%a " (print_type info) ty *)
(*   | tl -> fprintf fmt "(%a) " (print_list comma (print_type info)) tl *)

let rec iter_complex_type info fmt () ty = match ty.ty_node with
  | Tyvar _ -> unsupported "cvc3 : you must encode the polymorphism"
  | Tyapp (_, []) -> ()
  | Tyapp (ts, l) ->
    begin match query_syntax info.info_syn ts.ts_name with
      | Some _ -> List.iter (iter_complex_type info fmt ()) l
      | None when not (Hty.mem info.complex_type ty) ->
        let id = id_fresh (Pp.string_of_wnl Pretty.print_ty ty) in
        let ts = create_tysymbol id [] None in
        let cty = ty_app ts [] in
        fprintf fmt "%a: TYPE;@."
          print_ident ts.ts_name;
        Hty.add info.complex_type ty cty
      | None -> ()
    end

let find_complex_type info fmt f =
  t_ty_fold (iter_complex_type info fmt) () f

let find_complex_type_expr info fmt f =
  e_fold
    (t_ty_fold (iter_complex_type info fmt))
    (t_ty_fold (iter_complex_type info fmt))
    () f

let print_type info fmt =
  catch_unsupportedType (print_type info fmt)

let print_type_value info fmt = function
  | None -> fprintf fmt "BOOLEAN"
  | Some ty -> print_type info fmt ty

(** var *)
let forget_var v = forget_id ident_printer v.vs_name

let print_var fmt {vs_name = id} =
  let n = id_unique ident_printer id in
  fprintf fmt "%s" n

let print_typed_var info fmt vs =
  fprintf fmt "%a : %a" print_var vs
    (print_type info) vs.vs_ty

let print_var_list info fmt vsl =
  print_list comma (print_typed_var info) fmt vsl

(** expr *)
let rec print_term info fmt t = match t.t_node with
  | Tconst (ConstInt n) -> fprintf fmt "%s" n
  | Tconst (ConstReal c) ->
      Print_real.print_with_integers
	"%s" "(%s * %s)" "(%s / %s)" fmt c
  | Tvar v -> print_var fmt v
  | Tapp (ls, tl) -> begin match query_syntax info.info_syn ls.ls_name with
      | Some s -> syntax_arguments_typed s (print_term info)
        (print_type info) (Some t) fmt tl
      | None -> begin match tl with (* for cvc3 wich doesn't accept (toto ) *)
          | [] -> fprintf fmt "%a" print_ident ls.ls_name
          | _ -> fprintf fmt "@,%a(%a)"
	      print_ident ls.ls_name (print_list comma (print_term info)) tl
        end end
  | Tlet (t1, tb) ->
      let v, t2 = t_open_bound tb in
      fprintf fmt "@[(LET %a =@ %a IN@ %a)@]" print_var v
        (print_term info) t1 (print_term info) t2;
      forget_var v
  | Tif (f1,t1,t2) ->
      fprintf fmt "@[(IF %a@ THEN %a@ ELSE %a ENDIF)@]"
        (print_fmla info) f1 (print_term info) t1 (print_term info) t2
  | Tcase _ -> unsupportedTerm t
      "cvc3 : you must eliminate match"
  | Teps _ -> unsupportedTerm t
      "cvc3 : you must eliminate epsilon"
  | Fquant _ | Fbinop _ | Fnot _ | Ftrue | Ffalse -> raise (TermExpected t)

and print_fmla info fmt f = match f.t_node with
  | Tapp ({ ls_name = id }, []) ->
      print_ident fmt id
  | Tapp (ls, tl) -> begin match query_syntax info.info_syn ls.ls_name with
      | Some s -> syntax_arguments_typed s (print_term info)
        (print_type info) None fmt tl
      | None -> begin match tl with
          | [] -> fprintf fmt "%a" print_ident ls.ls_name
          | _ -> fprintf fmt "(%a(%a))"
	      print_ident ls.ls_name (print_list comma (print_term info)) tl
        end end
  | Fquant (q, fq) ->
      let q = match q with Fforall -> "FORALL" | Fexists -> "EXISTS" in
      let vl, tl, f = f_open_quant fq in
      (* TODO trigger dépend des capacités du prover : 2 printers?
      smtwithtriggers/smtstrict *)
      if tl = [] then
        fprintf fmt "@[(%s@ (%a):@ %a)@]"
          q
          (print_var_list info) vl
          (print_fmla info) f
      else
        fprintf fmt "@[(%s@ (%a):%a@ %a)@]"
          q
          (print_var_list info) vl
          (print_triggers info) tl
          (print_fmla info) f;
      List.iter forget_var vl
  | Fbinop (Fand, f1, f2) ->
      fprintf fmt "@[(%a@ AND %a)@]" (print_fmla info) f1 (print_fmla info) f2
  | Fbinop (For, f1, f2) ->
      fprintf fmt "@[(%a@ OR %a)@]" (print_fmla info) f1 (print_fmla info) f2
  | Fbinop (Fimplies, f1, f2) ->
      fprintf fmt "@[(%a@ => %a)@]"
        (print_fmla info) f1 (print_fmla info) f2
  | Fbinop (Fiff, f1, f2) ->
      fprintf fmt "@[(%a@ <=> %a)@]" (print_fmla info) f1 (print_fmla info) f2
  | Fnot f ->
      fprintf fmt "@[(NOT@ %a)@]" (print_fmla info) f
  | Ftrue ->
      fprintf fmt "TRUE"
  | Ffalse ->
      fprintf fmt "FALSE"
  | Tif (f1, f2, f3) ->
      fprintf fmt "@[(IF %a@ THEN %a@ ELSE %a ENDIF)@]"
	(print_fmla info) f1 (print_fmla info) f2 (print_fmla info) f3
  | Tlet (t1, tb) ->
      let v, f2 = t_open_bound tb in
      fprintf fmt "@[(LET %a =@ %a IN@ %a)@]" print_var v
        (print_term info) t1 (print_fmla info) f2;
      forget_var v
  | Tcase _ -> unsupportedFmla f
      "cvc3 : you must eliminate match"
  | Tvar _ | Tconst _ | Teps _ -> raise (FmlaExpected f)

and print_expr info fmt = e_map (print_term info fmt) (print_fmla info fmt)

and print_triggers info fmt = function
  | [] -> ()
  | a::l -> fprintf fmt "PATTERN (%a):@ %a"
    (print_list comma (print_expr info)) a
    (print_triggers info) l

let print_logic_binder info fmt v =
  fprintf fmt "%a: %a" print_ident v.vs_name
    (print_type info) v.vs_ty

let print_type_decl info fmt = function
  | ts, Tabstract when Sid.mem ts.ts_name info.info_rem -> false
  | ts, Tabstract when ts.ts_args = [] ->
    fprintf fmt "%a : TYPE;" print_ident ts.ts_name; true
  | _, Tabstract -> false
  | _, Talgebraic _ -> unsupported
    "cvc3 : algebraic type are not supported"

let print_logic_decl info fmt (ls,ld) =
  if not (Mid.mem ls.ls_name info.info_syn) then
    let print_lsargs info fmt = function
      | [] -> ()
      | l ->  fprintf fmt "(%a) -> "
        (print_list comma (print_type info)) l in
  List.iter (iter_complex_type info fmt ()) ls.ls_args;
  Util.option_iter (iter_complex_type info fmt ()) ls.ls_value;
  match ld with
  | None ->
    fprintf fmt "@[<hov 2>%a: %a%a;@]@\n"
      print_ident ls.ls_name
      (print_lsargs info) ls.ls_args
      (print_type_value info) ls.ls_value
  | Some def ->
    let vsl,expr = Decl.open_ls_defn def  in
    find_complex_type_expr info fmt expr;
    fprintf fmt "@[<hov 2>%a: %a%a = LAMBDA (%a): %a;@]@\n"
      print_ident ls.ls_name
      (print_lsargs info) ls.ls_args
      (print_type_value info) ls.ls_value
      (print_var_list info) vsl
      (print_expr info) expr

let print_logic_decl info fmt d =
  if Sid.mem (fst d).ls_name info.info_rem then
    false else (print_logic_decl info fmt d; true)

let print_decl info fmt d = match d.d_node with
  | Dtype dl ->
      print_list_opt newline (print_type_decl info) fmt dl
  | Dlogic dl ->
      print_list_opt newline (print_logic_decl info) fmt dl
  | Dind _ -> unsupportedDecl d
      "cvc3 : inductive definition are not supported"
  | Dprop (Paxiom, pr, _) when Sid.mem pr.pr_name info.info_rem -> false
  | Dprop (Paxiom, pr, f) ->
    find_complex_type info fmt f;
      fprintf fmt "@[<hov 2>%% %s@\nASSERT@ %a;@]@\n"
        pr.pr_name.id_string
        (print_fmla info) f; true
  | Dprop (Pgoal, pr, f) ->
    find_complex_type info fmt f;
      fprintf fmt "@[QUERY@\n";
      fprintf fmt "@[%% %a@]@\n" print_ident pr.pr_name;
      (match pr.pr_name.id_loc with
        | None -> ()
        | Some loc -> fprintf fmt " @[%% %a@]@\n"
            Loc.gen_report_position loc);
      fprintf fmt "  @[%a;@]@]" (print_fmla info) f;
      true
  | Dprop ((Plemma|Pskip), _, _) -> assert false

let print_decl info fmt = catch_unsupportedDecl (print_decl info fmt)

let distingued =
  let dist_syntax mls = function
    | [MAls ls;MAstr s] -> Mls.add ls s mls
    | _ -> assert false in
  let dist_dist syntax mls = function
    | [MAls ls;MAls lsdis] ->
      begin try
              Mid.add lsdis.ls_name (Mls.find ls syntax) mls
        with Not_found -> mls end
    | _ -> assert false in
  Trans.on_meta meta_syntax_logic (fun syntax ->
    let syntax = List.fold_left dist_syntax Mls.empty syntax in
    Trans.on_meta Encoding.meta_lsinst (fun dis ->
      let dis2 = List.fold_left (dist_dist syntax) Mid.empty dis in
      Trans.return dis2))

let print_task pr thpr fmt task =
  print_prelude fmt pr;
  print_th_prelude task fmt thpr;
  let info = {
    info_syn = Mid.union (fun _ _ s -> Some s)
      (get_syntax_map task) (Trans.apply distingued task);
    info_rem = get_remove_set task;
    complex_type = Hty.create 5;
  }
  in
  let decls = Task.task_decls task in
  ignore (print_list_opt (add_flush newline2) (print_decl info) fmt decls)

let () = register_printer "cvc3"
  (fun _env pr thpr ?old:_ fmt task ->
     forget_all ident_printer;
     print_task pr thpr fmt task)