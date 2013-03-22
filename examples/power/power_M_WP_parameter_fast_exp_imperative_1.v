(* This file is generated by Why3's Coq 8.4 driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Import ZOdiv.
Require BuiltIn.
Require int.Int.
Require int.Abs.
Require int.ComputerDivision.
Require int.Power.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 assumption *)
Inductive ref (a:Type) {a_WT:WhyType a} :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Implicit Arguments mk_ref [[a] [a_WT]].

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a} (v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.

Import int.ComputerDivision.
Import Power.

(* Why3 goal *)
Theorem WP_parameter_fast_exp_imperative : forall (x:Z) (n:Z),
  (0%Z <= n)%Z -> forall (e:Z) (p:Z) (r:Z), ((0%Z <= e)%Z /\
  ((r * (int.Power.power p e))%Z = (int.Power.power x n))) -> ((0%Z < e)%Z ->
  (((ZOmod e 2%Z) = 1%Z) -> forall (r1:Z), (r1 = (r * p)%Z) -> forall (p1:Z),
  (p1 = (p * p)%Z) -> forall (e1:Z), (e1 = (ZOdiv e 2%Z)) ->
  ((r1 * (int.Power.power p1 e1))%Z = (int.Power.power x n)))).
(* Why3 intros x n h1 e p r (h2,h3) h4 h5 r1 h6 p1 h7 e1 h8. *)
intros x n h1 e p r (h2,h3) h4 h5 r1 h6 p1 h7 e1 h8.
subst.
assert (h: (2 <> 0)%Z) by omega.
generalize (Div_mod e 2 h). clear h.
assert (h: (0 < 2)%Z) by omega.
generalize (Div_bound e 2 (conj h2 h)). clear h.
rewrite h5; clear h5.
intros.
rewrite <- h3; clear h3.
rewrite H0 at 2. clear H0.
rewrite Power_sum by omega.
replace (2 * (ZOdiv e 2))%Z with (ZOdiv e 2 + ZOdiv e 2)%Z by ring.
rewrite Power_sum by apply H.
rewrite Power_mult2 by apply H.
rewrite Power_1.
ring.
Qed.


