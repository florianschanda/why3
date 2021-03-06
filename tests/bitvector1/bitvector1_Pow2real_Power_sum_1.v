(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.
Require real.Real.
Require real.RealInfix.

Parameter pow2: Z -> R.

Axiom Power_0 : ((pow2 0%Z) = 1%R).

Axiom Power_s : forall (n:Z), (0%Z <= n)%Z ->
  ((pow2 (n + 1%Z)%Z) = (2%R * (pow2 n))%R).

Axiom Power_p : forall (n:Z), (n <= 0%Z)%Z ->
  ((pow2 (n - 1%Z)%Z) = ((05 / 10)%R * (pow2 n))%R).

Axiom Power_s_all : forall (n:Z), ((pow2 (n + 1%Z)%Z) = (2%R * (pow2 n))%R).

Axiom Power_p_all : forall (n:Z),
  ((pow2 (n - 1%Z)%Z) = ((05 / 10)%R * (pow2 n))%R).

Axiom Power_1_2 : ((05 / 10)%R = (Rdiv 1%R 2%R)%R).

Axiom Power_1 : ((pow2 1%Z) = 2%R).

Axiom Power_neg1 : ((pow2 (-1%Z)%Z) = (05 / 10)%R).

Axiom Power_non_null_aux : forall (n:Z), (0%Z <= n)%Z -> ~ ((pow2 n) = 0%R).

Axiom Power_neg_aux : forall (n:Z), (0%Z <= n)%Z ->
  ((pow2 (-n)%Z) = (Rdiv 1%R (pow2 n))%R).

Axiom Power_non_null : forall (n:Z), ~ ((pow2 n) = 0%R).

Axiom Power_neg : forall (n:Z), ((pow2 (-n)%Z) = (Rdiv 1%R (pow2 n))%R).

Axiom Power_sum_aux : forall (n:Z) (m:Z), (0%Z <= m)%Z ->
  ((pow2 (n + m)%Z) = ((pow2 n) * (pow2 m))%R).

Open Scope Z_scope.

(* Why3 goal *)
Theorem Power_sum : forall (n:Z) (m:Z),
  ((pow2 (n + m)%Z) = ((pow2 n) * (pow2 m))%R).
(* YOU MAY EDIT THE PROOF BELOW *)
intros n m.
assert (hm:m>=0 \/ m <=0) by omega.
destruct hm.
apply Power_sum_aux; auto with zarith.
pose (m' := -m).
replace m with (-m') by (subst m'; omega).
replace (n+ - m') with (- ((-n) + m')) by omega.
repeat rewrite Power_neg.
rewrite Power_sum_aux.
rewrite Power_neg.
field.
split.
apply Power_non_null.
apply Power_non_null.
subst m'.
auto with zarith.
Qed.


