(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2015   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

(** {2 User-defined strategies} *)

type instruction =
  | Icall_prover of Whyconf.prover * int * int * int (** timelimit, steplimi, memlimit *)
  | Itransform of string * int (** successor state on success *)
  | Igoto of int (** goto state *)

type t = instruction array
