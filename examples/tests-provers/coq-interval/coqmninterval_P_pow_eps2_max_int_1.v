(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Reals.Rfunctions.
Require BuiltIn.
Require real.Real.
Require real.RealInfix.
Require int.Int.
Require real.PowerInt.

Require Import Interval_tactic.

(* Why3 goal *)
Theorem pow_eps2_max_int : ((Reals.Rfunctions.powerRZ (1%R + ((7 / 1125899906842624)%R + (3 / 9007199254740992)%R)%R)%R 2147483647%Z) <= 2%R)%R.
Strategy 1000 [Rfunctions.powerRZ].
interval with (i_prec 34).
Qed.

