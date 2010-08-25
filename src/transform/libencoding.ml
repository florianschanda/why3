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

open Util
open Ident
open Ty
open Term
open Decl

(* sort symbol of (polymorphic) types *)
let ts_type = create_tysymbol (id_fresh "ty") [] None

(* sort of (polymorphic) types *)
let ty_type = ty_app ts_type []

(* ts_type declaration *)
let d_ts_type = create_ty_decl [ts_type, Tabstract]

(* function symbol mapping ty_type^n to ty_type *)
let ls_of_ts = Wts.memoize 63 (fun ts ->
  let args = List.map (const ty_type) ts.ts_args in
  create_fsymbol (id_clone ts.ts_name) args ty_type)

(* test whether a function symbol has ty_type as ls_value *)
let is_ls_of_ts ls = match ls.ls_value with
  | Some { ty_node = Tyapp (ts,_) } when ts_equal ts ts_type -> true
  | _ -> false

(* convert a type to a term of type ty_type *)
let rec term_of_ty tvmap ty = match ty.ty_node with
  | Tyvar tv ->
      t_var (Mtv.find tv tvmap)
  | Tyapp (ts,tl) ->
      t_app (ls_of_ts ts) (List.map (term_of_ty tvmap) tl) ty_type

(* rewrite a closed formula modulo its free typevars *)
let f_type_close fn f =
  let tvs = f_ty_freevars Stv.empty f in
  let get_vs tv = create_vsymbol (id_clone tv.tv_name) ty_type in
  let tvm = Stv.fold (fun v m -> Mtv.add v (get_vs v) m) tvs Mtv.empty in
  let vl = Mtv.fold (fun _ vs acc -> vs::acc) tvm [] in
  f_forall_close_simp vl [] (fn tvm f)

(* convert a type declaration to a list of lsymbol declarations *)
let lsdecl_of_tydecl tdl =
  let add td acc = match td with
    | ts, Talgebraic _ ->
        let ty = ty_app ts (List.map ty_var ts.ts_args) in
        Printer.unsupportedType ty "no algebraic types at this point"
    | { ts_def = Some _ }, _ -> acc
    | ts, _ -> create_logic_decl [ls_of_ts ts, None] :: acc
  in
  List.fold_right add tdl []

(* sort symbol by default (= undeco) *)
let ts_base = create_tysymbol (id_fresh "uni") [] None

(* sort by default (= undeco) *)
let ty_base = ty_app ts_base []

(* ts_base declaration *)
let d_ts_base = create_ty_decl [ts_base, Tabstract]

(* convert a constant to a functional symbol of type ty_base *)
let ls_of_const =
  let ht = Hterm.create 63 in
  let ls_of_t t = match t.t_node with
    | Tconst _ ->
        begin try Hterm.find ht t with Not_found ->
          let s = "const_" ^ Pp.string_of Pretty.print_term t in
          let ls = create_fsymbol (id_fresh s) [] ty_base in
          Hterm.add ht t ls;
          ls
        end
    | _ -> assert false
  in
  fun c -> ls_of_t (t_const c)

(* convert a constant to a term of type ty_base *)
let term_of_const c = t_app (ls_of_const c) [] ty_base

(* convert tysymbols tagged with meta_kept to a set of types *)
let get_kept_types tds =
  let tss = Task.find_tagged_ts Encoding.meta_kept tds Sts.empty in
  let add ts acc = match ts.ts_def with
    | Some ty -> Sty.add ty acc
    | None -> Sty.add (ty_app ts []) acc
  in
  Sts.fold add tss (Sty.singleton ty_type)

(* monomorphise modulo the set of kept types * and an lsymbol map *)

let vs_monomorph kept vs =
  if Sty.mem vs.vs_ty kept then vs else
  create_vsymbol (id_clone vs.vs_name) ty_base

let rec t_monomorph kept lsmap consts vmap t =
  let t_mono = t_monomorph kept lsmap consts in
  let f_mono = f_monomorph kept lsmap consts in
  t_label_copy t (match t.t_node with
    | Tbvar _ ->
        assert false
    | Tvar v ->
        Mvs.find v vmap
    | Tconst _ when Sty.mem t.t_ty kept ->
        t
    | Tconst c ->
        let ls = ls_of_const c in
        consts := Sls.add ls !consts;
        t_app ls [] ty_base
    | Tapp (fs,_) when is_ls_of_ts fs ->
        t
    | Tapp (fs,tl) ->
        let fs = lsmap fs in
        let ty = of_option fs.ls_value in
        t_app fs (List.map (t_mono vmap) tl) ty
    | Tif (f,t1,t2) ->
        t_if (f_mono vmap f) (t_mono vmap t1) (t_mono vmap t2)
    | Tlet (t1,b) ->
        let u,t2,close = t_open_bound_cb b in
        let v = vs_monomorph kept u in
        let t2 = t_mono (Mvs.add u (t_var v) vmap) t2 in
        t_let (t_mono vmap t1) (close v t2)
    | Tcase _ ->
        Printer.unsupportedTerm t "no match expressions at this point"
    | Teps b ->
        let u,f,close = f_open_bound_cb b in
        let v = vs_monomorph kept u in
        let f = f_mono (Mvs.add u (t_var v) vmap) f in
        t_eps (close v f))

and f_monomorph kept lsmap consts vmap f =
  let t_mono = t_monomorph kept lsmap consts in
  let f_mono = f_monomorph kept lsmap consts in
  f_label_copy f (match f.f_node with
    | Fapp (ps,[t1;t2]) when ls_equal ps ps_equ ->
        f_equ (t_mono vmap t1) (t_mono vmap t2)
    | Fapp (ps,tl) ->
        f_app (lsmap ps) (List.map (t_mono vmap) tl)
    | Fquant (q,b) ->
        let ul,tl,f1,close = f_open_quant_cb b in
        let vl = List.map (vs_monomorph kept) ul in
        let add acc u v = Mvs.add u (t_var v) acc in
        let vmap = List.fold_left2 add vmap ul vl in
        let tl = tr_map (t_mono vmap) (f_mono vmap) tl in
        f_quant q (close vl tl (f_mono vmap f1))
    | Fbinop (op,f1,f2) ->
        f_binary op (f_mono vmap f1) (f_mono vmap f2)
    | Fnot f1 ->
        f_not (f_mono vmap f1)
    | Ftrue | Ffalse ->
        f
    | Fif (f1,f2,f3) ->
        f_if (f_mono vmap f1) (f_mono vmap f2) (f_mono vmap f3)
    | Flet (t,b) ->
        let u,f1,close = f_open_bound_cb b in
        let v = vs_monomorph kept u in
        let f1 = f_mono (Mvs.add u (t_var v) vmap) f1 in
        f_let (t_mono vmap t) (close v f1)
    | Fcase _ ->
        Printer.unsupportedFmla f "no match expressions at this point")

let d_monomorph kept lsmap d =
  let consts = ref Sls.empty in
  let dl = match d.d_node with
    | Dtype tdl ->
        let add td acc = match td with
          | _, Talgebraic _ ->
              Printer.unsupportedDecl d "no algebraic types at this point"
          | { ts_def = Some _ }, _ -> acc
          | ts, _ when not (Sty.exists (ty_s_any (ts_equal ts)) kept) -> acc
          | _ -> create_ty_decl [td] :: acc
        in
        List.fold_right add tdl []
    | Dlogic ldl ->
        let conv (ls,ld) =
          let ls =
            if ls_equal ls ps_equ || is_ls_of_ts ls then ls else lsmap ls
          in
          match ld with
          | Some ld ->
              let ul,e = open_ls_defn ld in
              let vl = List.map (vs_monomorph kept) ul in
              let add acc u v = Mvs.add u (t_var v) acc in
              let vmap = List.fold_left2 add Mvs.empty ul vl in
              let e = match e with
                | Term t -> Term (t_monomorph kept lsmap consts vmap t)
                | Fmla f -> Fmla (f_monomorph kept lsmap consts vmap f)
              in
              make_ls_defn ls vl e
          | None ->
              ls, None
        in
        [create_logic_decl (List.map conv ldl)]
    | Dind idl ->
        let iconv (pr,f) = pr, f_monomorph kept lsmap consts Mvs.empty f in
        let conv (ls,il) = lsmap ls, List.map iconv il in
        [create_ind_decl (List.map conv idl)]
    | Dprop (k,pr,f) ->
        [create_prop_decl k pr (f_monomorph kept lsmap consts Mvs.empty f)]
  in
  let add ls acc = create_logic_decl [ls,None] :: acc in
  Sls.fold add !consts dl
