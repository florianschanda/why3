(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2014   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

open Stdlib
open Ident
open Term
open Ity

(** {2 Program symbols} *)

type psymbol = private {
  ps_name  : ident;
  ps_cty   : cty;
  ps_ghost : bool;
  ps_logic : ps_logic;
}

and ps_logic =
  | PLnone            (* non-pure symbol *)
  | PLvs of vsymbol   (* local let-function *)
  | PLls of lsymbol   (* top-level let-function or let-predicate *)
  | PLlemma           (* top-level or local let-lemma *)

module Mps : Extmap.S with type key = psymbol
module Sps : Extset.S with module M = Mps
module Hps : Exthtbl.S with type key = psymbol
module Wps : Weakhtbl.S with type key = psymbol

val ps_compare : psymbol -> psymbol -> int
val ps_equal : psymbol -> psymbol -> bool
val ps_hash : psymbol -> int

type ps_kind =
  | PKnone            (* non-pure symbol *)
  | PKlocal           (* local let-function *)
  | PKfunc of int     (* top-level let-function or constructor *)
  | PKpred            (* top-level let-predicate *)
  | PKlemma           (* top-level or local let-lemma *)

val create_psymbol : preid -> ?ghost:bool -> ?kind:ps_kind -> cty -> psymbol
(** If [?kind] is supplied and is not [PKnone], then [cty]
    must have no effects except for resets which are ignored.
    If [?kind] is [PKnone] or [PKlemma], external mutable reads
    are allowed, otherwise [cty.cty_freeze.isb_reg] must be empty.
    If [?kind] is [PKlocal], the type variables in [cty] are frozen
    but regions are instantiable. If [?kind] is [PKpred] the result
    type must be [ity_bool]. If [?kind] is [PKlemma] and the result
    type is not [ity_unit], an existential premise is generated. *)

val restore_ps : lsymbol -> psymbol
(** raises [Not_found] if the argument is not a [ps_logic] *)

(** {2 Program patterns} *)

type prog_pattern = private {
  pp_pat   : pattern;
  pp_ity   : ity;
  pp_ghost : bool;
}

type pre_pattern =
  | PPwild
  | PPvar of preid
  | PPapp of psymbol * pre_pattern list
  | PPor  of pre_pattern * pre_pattern
  | PPas  of pre_pattern * preid

val create_prog_pattern :
  pre_pattern -> ?ghost:bool -> ity -> pvsymbol Mstr.t * prog_pattern

(** {2 Program expressions} *)

type lazy_op = Eand | Eor

type assertion_kind = Assert | Assume | Check

type for_direction = To | DownTo

type for_bounds = pvsymbol * for_direction * pvsymbol

type invariant = term

type variant = term * lsymbol option (** tau * (tau -> tau -> prop) *)

type vty =
  | VtyI of ity
  | VtyC of cty

type val_decl =
  | ValV of pvsymbol
  | ValS of psymbol

type expr = private {
  e_node   : expr_node;
  e_vty    : vty;
  e_ghost  : bool;
  e_effect : effect;
  e_label  : Slab.t;
  e_loc    : Loc.position option;
}

and expr_node = private
  | Evar    of pvsymbol
  | Esym    of psymbol
  | Econst  of Number.constant
  | Eapp    of expr * pvsymbol list * cty
  | Efun    of expr
  | Elet    of let_defn * expr
  | Erec    of rec_defn * expr
  | Enot    of expr
  | Elazy   of lazy_op * expr * expr
  | Eif     of expr * expr * expr
  | Ecase   of expr * (prog_pattern * expr) list
  | Eassign of expr * pvsymbol (*field*) * pvsymbol
  | Ewhile  of expr * invariant * variant list * expr
  | Efor    of pvsymbol * for_bounds * invariant * expr
  | Etry    of expr * (xsymbol * pvsymbol * expr) list
  | Eraise  of xsymbol * expr
  | Eghost  of expr
  | Eassert of assertion_kind * term
  | Epure   of term
  | Eabsurd
  | Eany

and let_defn = private {
  let_sym  : val_decl;
  let_expr : expr;
}

and rec_defn = private {
  rec_defn : fun_defn list;
}

and fun_defn = {
  fun_sym  : psymbol;
  fun_expr : expr; (* Efun *)
  fun_varl : variant list;
}

val e_label : ?loc:Loc.position -> Slab.t -> expr -> expr
val e_label_add : label -> expr -> expr
val e_label_copy : expr -> expr -> expr

exception ItyExpected of expr
exception CtyExpected of expr

val ity_of_expr : expr -> ity
val cty_of_expr : expr -> cty

(** {2 Smart constructors} *)

val e_var : pvsymbol -> expr
val e_sym : psymbol  -> expr

val e_const : Number.constant -> expr
val e_nat_const : int -> expr

val create_let_defn    : preid -> expr -> let_defn
val create_let_defn_pv : preid -> expr -> let_defn * pvsymbol
val create_let_defn_ps : preid -> ?kind:ps_kind -> expr -> let_defn * psymbol

val e_fun :
  pvsymbol list -> pre list -> post list -> post list Mexn.t -> expr -> expr
