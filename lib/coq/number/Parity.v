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

(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

(* Why3 assumption *)
Definition even (n:Z): Prop := exists k:Z, (n = (2%Z * k)%Z).

(* Why3 assumption *)
Definition odd (n:Z): Prop := exists k:Z, (n = ((2%Z * k)%Z + 1%Z)%Z).

Lemma even_is_Zeven :
  forall n, even n <-> Zeven n.
Proof.
intros n.
refine (conj _ (Zeven_ex n)).
intros (k,H).
rewrite H.
apply Zeven_2p.
Qed.

Lemma odd_is_Zodd :
  forall n, odd n <-> Zodd n.
Proof.
intros n.
refine (conj _ (Zodd_ex n)).
intros (k,H).
rewrite H.
apply Zodd_2p_plus_1.
Qed.

(* Why3 goal *)
Lemma even_or_odd : forall (n:Z), (even n) \/ (odd n).
Proof.
intros n.
destruct (Zeven_odd_dec n).
left.
now apply <- even_is_Zeven.
right.
now apply <- odd_is_Zodd.
Qed.

(* Why3 goal *)
Lemma even_not_odd : forall (n:Z), (even n) -> ~ (odd n).
Proof.
intros n H1 H2.
apply (Zeven_not_Zodd n).
now apply -> even_is_Zeven.
now apply -> odd_is_Zodd.
Qed.

(* Why3 goal *)
Lemma odd_not_even : forall (n:Z), (odd n) -> ~ (even n).
Proof.
intros n H1.
contradict H1.
now apply even_not_odd.
Qed.

(* Why3 goal *)
Lemma even_odd : forall (n:Z), (even n) -> (odd (n + 1%Z)%Z).
Proof.
intros n H.
apply <- odd_is_Zodd.
apply Zeven_plus_Zodd.
now apply -> even_is_Zeven.
easy.
Qed.

(* Why3 goal *)
Lemma odd_even : forall (n:Z), (odd n) -> (even (n + 1%Z)%Z).
Proof.
intros n H.
apply <- even_is_Zeven.
apply Zodd_plus_Zodd.
now apply -> odd_is_Zodd.
easy.
Qed.

(* Why3 goal *)
Lemma even_even : forall (n:Z), (even n) -> (even (n + 2%Z)%Z).
Proof.
intros n H.
apply <- even_is_Zeven.
apply Zeven_plus_Zeven.
now apply -> even_is_Zeven.
easy.
Qed.

(* Why3 goal *)
Lemma odd_odd : forall (n:Z), (odd n) -> (odd (n + 2%Z)%Z).
Proof.
intros n H.
apply <- odd_is_Zodd.
apply Zodd_plus_Zeven.
now apply -> odd_is_Zodd.
easy.
Qed.

(* Why3 goal *)
Lemma even_2k : forall (k:Z), (even (2%Z * k)%Z).
Proof.
intros k.
now exists k.
Qed.

(* Why3 goal *)
Lemma odd_2k1 : forall (k:Z), (odd ((2%Z * k)%Z + 1%Z)%Z).
Proof.
intros k.
now exists k.
Qed.
