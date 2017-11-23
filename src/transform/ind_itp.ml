(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2017   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

open Decl
open Term
open Generic_arg_trans_utils
open Args_wrapper

(** This file contains the transformation with arguments 'induction on integer' *)


(* Documentation of induction:

   From task [delta, x: int, delta'(x) |- G(x)], variable x and term bound, builds the tasks:
   [delta, x: int, x < bound, delta'(x) |- G(x)] and
   [delta, x: int, x >= bound, (forall n, n < x -> delta'(n) -> G(n)), delta'(x) |- G(x)]

   x cannot occur in delta as it can only appear after its declaration (by
   construction of the task). Also, G is not part of delta'.
   In practice we are "chosing" delta'. The minimal set delta' such that this
   transformation is correct is Min_d = {H | x *directly* appears in H} € delta'. (1)

   Adding any declarations to delta' should be safe(2).

   In practice, we define delta' iterately beginning with the goal (upward) and
   adding any hypothesis that contains symbols defined in a set S.
   Algorithm used:
   S : symbol set = {x} union {symbol_appearing_in goal}
   delta' : list decl = {}
   For decl from goal to x_declaration do
     if ((symbol_appearing_in decl) intersect S) != {} then
       add decl to delta'
       add (symbol_appearing_in decl) to S
     else
       ()
   done


   (1) One may be convinced of this because it is possible to make a lemma of
   the form "forall x: int. Min_d(x) -> G(x)" with appropriate abstract constant
   symbol for every other constant (added in the context). One can then apply
   an induction on this reduced example and apply this lemma on the initial case.
   (This is an argument for the "reduction of context stuff" not a claim that
   the induction is correct)

   (2) If it does not talk about x, we will have to prove it (unchanged) to be
   able to use it in the recursive part. So it should not change the provability.

*)


let is_good_type t ty =
  try (Term.t_ty_check t (Some ty); true) with
  | _ -> false

(* Reverts a declaration d to a goal g *)
let revert g d : Term.term =
  match d.d_node with
  | Dtype _ -> raise (Arg_trans "revert: cannot revert type")
  | Ddata _ -> raise (Arg_trans "revert: cannot revert type")
  | Dparam ls ->
    (try
      let new_ident = Ident.id_fresh ls.ls_name.Ident.id_string in
      let new_var = Term.create_vsymbol new_ident (Opt.get ls.Term.ls_value) in
      let g = t_replace (t_app_infer ls []) (t_var new_var) g in
      t_forall_close [new_var] [] g
    with
    | _ -> raise (Arg_trans ("revert: cannot revert:" ^ ls.ls_name.Ident.id_string)))
  (* TODO extend this *)
  | Dlogic _ ->
    raise (Arg_trans "revert: cannot revert logic decls")
  | Dind _ ->
    raise (Arg_trans "revert: cannot revert induction decls")
  | Dprop (k, _pr, t) when k <> Pgoal ->
    Term.t_implies t g
  | Dprop (Pgoal, _, _) -> raise (Arg_trans "revert: cannot revert goal")
  | _ -> raise (Arg_trans "revert: please report")


(* Takes a list of prop l and a goal g and reverts the list
   of prop to the goal g *)
let revert_list (l: decl list) g =
  List.fold_left revert g l

(* TODO To be checked *)
let add_ls_term s t =
  let rec my_fold s t =
    match t.t_node with
    | Tapp (ls, []) ->
        (* Interesting case *)
        Sls.add ls s
    | _ -> Term.t_fold my_fold s t
  in
  my_fold s t

let add_lsymbol s (ls_def: Decl.ls_defn) =
  let _vsl, t = Decl.open_ls_defn ls_def in
  add_ls_term s t

(* This collects the lsymbols appearing in a decl. It is useful to have
   dependencies during induction. We want to generalize all decls that contain
   some lsymbols (the one which appears in the goal or the symbol on which we do
   the induction. *)
let collect_lsymbol s (d: decl) =
  match d.d_node with
  | Dtype _ | Ddata _ -> (* can be ignored. TODO to check.  *)
    s
  | Dparam ls -> Sls.add ls s
  | Dlogic logic_list ->
      List.fold_left (fun s (ls, ls_def) ->
        add_lsymbol (Sls.add ls s) ls_def) s logic_list
  | Dind (_sign, ind_list) ->
      List.fold_left (fun s (ls, pr_term_list) ->
        let s = Sls.add ls s in
        List.fold_left (fun s (_pr, t) -> add_ls_term s t) s pr_term_list) s ind_list
  | Dprop (_k, _pr, t) ->
      add_ls_term s t



(* s is a set of variables, g is a term. If d contains one of the elements of s
   then all variables of d are added to s and the declaration is prepended to g.
*)
let revert_chosen_decls (g, s) (d: decl) =
  let d_set = collect_lsymbol Sls.empty d in
  let interp = Sls.inter s d_set in
  if Sls.equal interp Sls.empty then
     (g, s)
  else
     (revert g d, Sls.union s d_set)

(* Build a term that generalizes all the declarations that were given in l and
   that contains at least one of the variables in the set s. Actually, only
   revert what is necessary to build a correct term. *)
let revert_chosen_decls_list s (l: decl list) (g: decl) (t: term) =
  (* The goal is a special case, we collect its variable independantly *)
  let s = collect_lsymbol s g in
  fst (List.fold_left revert_chosen_decls (t, s) l)

let induction x bound env =
  (* Default bound is 0 if not given *)
  let bound =
    match bound with
    | None -> Term.t_const (Number.ConstInt (Number.int_const_dec "0")) Ty.ty_int
    | Some bound -> bound
  in

  (* Checking the type of the argument of the tactic *)
  if (not (is_good_type x Ty.ty_int) || not (is_good_type bound Ty.ty_int)) then
    raise (Arg_trans "induction");

  (* Loading of needed symbols from int theory *)
  let th = Env.read_theory env ["int"] "Int" in
  let le_int = Theory.ns_find_ls th.Theory.th_export ["infix <="] in
  let lt_int = Theory.ns_find_ls th.Theory.th_export ["infix <"] in

  (* Symbol associated to term x *)
  let lsx =
    match x.t_node with
    | Tapp (lsx, []) -> lsx
    | _ -> raise (Arg_trans "induction")
  in

  (* Transformation used for the init case *)
  let init_trans = Trans.decl (fun d -> match d.d_node with
    | Dprop (Pgoal, _pr, _t) ->
        let nt = Term.t_app_infer le_int [x; bound] in
        let pr =
          create_prop_decl Paxiom (Decl.create_prsymbol (gen_ident "Init")) nt in
        [pr; d]
    | _ -> [d]) None in

  (* Transformation used for the recursive case *)
  let rec_trans =
    let x_is_passed = ref false in
    let delta' = ref [] in
    Trans.decl (fun d -> match d.d_node with
    | Dparam ls when (Term.ls_equal lsx ls) ->
        (x_is_passed := true; [d])
    | Dprop (Pgoal, _pr, t) ->
        if not (!x_is_passed) then
          raise (Arg_trans "induction")
        else
          let t_delta' =
            revert_chosen_decls_list (Sls.add lsx Sls.empty) !delta' d t in
          let n = Term.create_vsymbol (Ident.id_fresh "n") Ty.ty_int in
          (* t_delta' = forall n, n < x -> t_delta'[x <- n] *)
          let t_delta' =
            t_forall_close [n] []
              (t_implies (Term.t_app_infer lt_int [t_var n; x]) (t_replace x (t_var n) t_delta'))
          in

          (* x_ge_bound = bound <= x *)
          let x_ge_bound_t = t_app_infer le_int [bound; x] in
          let x_ge_bound =
            create_prop_decl Paxiom (Decl.create_prsymbol (gen_ident "Init")) x_ge_bound_t in
          let rec_pr = create_prsymbol (gen_ident "Hrec") in
          let hrec = create_prop_decl Paxiom rec_pr t_delta' in
          [x_ge_bound; hrec; d]
    | Dprop (_p, _pr, _t) ->
        if !x_is_passed then
          begin
            delta' := d :: !delta';
            (* d [x <- x] *)
            [d]
          end
        else
          [d]
    | Dind _ | Dlogic _ | Dtype _ | Ddata _ ->
      if !x_is_passed then
        raise (Arg_trans "induction Dlogic")
      (* TODO we need to add Dlogic and Dind here. The problem is that we cannot
         easily put them into the recursive hypothesis. So, for now, we do not
         allow them. If x does not occur in the Dlogic/Dind, a workaround is to
         use the "sort" tactic.
      *)
      else
        [d]
    | Dparam _ls ->
      if !x_is_passed then
        begin
          delta' := d :: !delta';
          [d]
        end
      else
        [d]
    ) None in
  Trans.par [init_trans; rec_trans]

let () = wrap_and_register
    ~desc:"induction <term1> [from] <term2> performs a strong induction on int term1 from int term2. term2 is optional and default to 0."
    "induction"
    (Tterm (Topt ("from", Tterm Tenvtrans_l))) induction