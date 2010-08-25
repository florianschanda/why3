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
open Theory
open Task

let meta_kept = register_meta "encoding_decorate : kept" [MTtysymbol]

(* From Encoding Polymorphism CADE07*)

type tenv = {
  specials : tysymbol Hty.t;
  trans_lsymbol : lsymbol Hls.t
}

let init_tenv = {
  specials = Hty.create 17;
  trans_lsymbol = Hls.create 17 }


(* Convert type *)
let conv_ty tenv undefined ty =
  match ty.ty_node with
    | Tyapp (_,[]) -> ty
    | Tyapp (ts,_) -> 
        let ts = 
          try
            Hty.find tenv.specials ty
          with Not_found ->
            let ts = create_tysymbol (id_dup ts.ts_name) [] None in
            Hty.add tenv.specials ty ts;
            ts in
        Hts.replace undefined ts ();
        ty_app ts [] 
    | _ -> Printer.unsupportedType ty "type variable must be encoded"

(* Convert a variable *)
let conv_vs tenv ud vs =
  let ty = conv_ty tenv ud vs.vs_ty in
  if ty_equal ty vs.vs_ty then vs else
  create_vsymbol (id_dup vs.vs_name) ty

(* Convert a logic symbol to the encoded one *)
let conv_ls tenv ud ls =
  if ls_equal ls ps_equ then ls
  else try Hls.find tenv.trans_lsymbol ls with Not_found ->
  let ty_res = Util.option_map (conv_ty tenv ud) ls.ls_value in
  let ty_arg = List.map (conv_ty tenv ud) ls.ls_args in
  let ls' =
    if Util.option_eq ty_equal ty_res ls.ls_value &&
       List.for_all2 ty_equal ty_arg ls.ls_args then ls
    else create_lsymbol (id_clone ls.ls_name) ty_arg ty_res
  in
  Hls.add tenv.trans_lsymbol ls ls';
  ls'


let rec rewrite_term tenv ud vm t =
  let fnT = rewrite_term tenv ud in
  let fnF = rewrite_fmla tenv ud in
  match t.t_node with
  | Tconst _ -> t
  | Tvar x ->
      Mvs.find x vm
  | Tapp (fs,tl) ->
      let fs = conv_ls tenv ud fs in
      let tl = List.map (fnT vm) tl in
      t_app fs tl (of_option fs.ls_value)
  | Tif (f, t1, t2) ->
      t_if (fnF vm f) (fnT vm t1) (fnT vm t2)
  | Tlet (t1, b) ->
      let u,t2,close = t_open_bound_cb b in
      let u' = conv_vs tenv ud u in
      let t1' = fnT vm t1 in
      let t2' = fnT (Mvs.add u (t_var u') vm) t2 in
      t_let t1' (close u' t2')
  | Tcase _ | Teps _ | Tbvar _ ->
      Printer.unsupportedTerm t "unsupported term"

and rewrite_fmla tenv ud vm f =
  let fnT = rewrite_term tenv ud in
  let fnF = rewrite_fmla tenv ud in
  match f.f_node with
  | Fapp (ps,tl) when ls_equal ps ps_equ ->
      f_app ps (List.map (fnT vm) tl)
  | Fapp (ps,tl) ->
      let ps = conv_ls tenv ud ps in
      let tl = List.map (fnT vm) tl in
      f_app ps tl
  | Fquant (q,b) ->
      let vl, tl, f1, close = f_open_quant_cb b in
      let add m v = let v' = conv_vs tenv ud v in Mvs.add v (t_var v') m, v' in
      let vm', vl' = Util.map_fold_left add vm vl in
      let tl' = tr_map (fnT vm') (fnF vm') tl in
      let f1' = fnF vm' f1 in
      f_quant q (close vl' tl' f1')
  | Flet (t1, b) ->
      let u,f1,close = f_open_bound_cb b in
      let u' = conv_vs tenv ud u in
      let t1' = fnT vm t1 in
      let f1' = fnF (Mvs.add u (t_var u') vm) f1 in
      f_let t1' (close u' f1')
  | Fcase _ ->
      Printer.unsupportedFmla f "unsupported formula"
  | _ -> f_map (fnT vm) (fnF vm) f

let decl_ud ud acc =
  let add ts () acc = (create_ty_decl [ts,Tabstract])::acc in
  Hts.fold add ud acc

let decl tenv d =
  let fnT = rewrite_term tenv in
  let fnF = rewrite_fmla tenv in
  match d.d_node with
  | Dtype dl ->
      let add acc = function
        | ({ts_def = Some _} | {ts_args = _::_}), Tabstract -> acc
        | _, Tabstract as d -> d::acc
        | _ -> Printer.unsupportedDecl d "use eliminate_algebraic"
      in
      let l = List.rev (List.fold_left add [] dl) in
      if l = [] then [] else [create_ty_decl l]
  | Dlogic ll ->
    let ud = Hts.create 3 in
    let conv = function
      | ls, None -> create_logic_decl [conv_ls tenv ud ls, None]
      | _ -> Printer.unsupportedDecl d "use eliminate_definition"
    in
    decl_ud ud (List.map conv ll)
  | Dind _ ->
      Printer.unsupportedDecl d "use eliminate_inductive"
  | Dprop _ ->
    let ud = Hts.create 3 in
    decl_ud ud [decl_map (fnT ud Mvs.empty) (fnF ud Mvs.empty) d]

let t = 
  let tenv = init_tenv in
  Trans.decl (decl tenv) None

let () = Trans.register_transform "encoding_simple2" t
