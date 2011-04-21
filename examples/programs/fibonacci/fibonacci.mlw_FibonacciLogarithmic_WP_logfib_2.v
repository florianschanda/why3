(* Beware! Only edit allowed sections below    *)
(* This file is generated by Why3's Coq driver *)
Require Import ZArith.
Require Import Rbase.
Require Import Zdiv.
Parameter ghost : forall (a:Type), Type.

Definition unit  := unit.

Parameter ignore: forall (a:Type), a  -> unit.

Implicit Arguments ignore.

Parameter label_ : Type.

Parameter at1: forall (a:Type), a -> label_  -> a.

Implicit Arguments at1.

Parameter old: forall (a:Type), a  -> a.

Implicit Arguments old.

Parameter fib: Z  -> Z.


Axiom fib0 : ((fib 0%Z) = 0%Z).

Axiom fib1 : ((fib 1%Z) = 1%Z).

Axiom fibn : forall (n:Z), (2%Z <= n)%Z ->
  ((fib n) = ((fib (n - 1%Z)%Z) + (fib (n - 2%Z)%Z))%Z).

Axiom Abs_pos : forall (x:Z), (0%Z <= (Zabs x))%Z.

Axiom Div_mod : forall (x:Z) (y:Z), (~ (y = 0%Z)) ->
  (x = ((y * (Zdiv x y))%Z + (Zmod x y))%Z).

Axiom Div_bound : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ (0%Z <  y)%Z) ->
  ((0%Z <= (Zdiv x y))%Z /\ ((Zdiv x y) <= x)%Z).

Axiom Mod_bound : forall (x:Z) (y:Z), (~ (y = 0%Z)) ->
  ((0%Z <= (Zmod x y))%Z /\ ((Zmod x y) <  (Zabs y))%Z).

Axiom Mod_1 : forall (x:Z), ((Zmod x 1%Z) = 0%Z).

Axiom Div_1 : forall (x:Z), ((Zdiv x 1%Z) = x).

Inductive t  :=
  | mk_t : Z -> Z -> Z -> Z -> t .

Definition a11(u:t): Z := match u with
  | mk_t a111 _ _ _ => a111
  end.

Definition a12(u:t): Z := match u with
  | mk_t _ a121 _ _ => a121
  end.

Definition a21(u:t): Z := match u with
  | mk_t _ _ a211 _ => a211
  end.

Definition a22(u:t): Z := match u with
  | mk_t _ _ _ a221 => a221
  end.

Definition mult(x:t) (y:t): t :=
  (mk_t (((a11 x) * (a11 y))%Z + ((a12 x) * (a21 y))%Z)%Z
  (((a11 x) * (a12 y))%Z + ((a12 x) * (a22 y))%Z)%Z
  (((a21 x) * (a11 y))%Z + ((a22 x) * (a21 y))%Z)%Z
  (((a21 x) * (a12 y))%Z + ((a22 x) * (a22 y))%Z)%Z).

Axiom Assoc : forall (x:t) (y:t) (z:t), ((mult (mult x y) z) = (mult x
  (mult y z))).

Parameter power: t -> Z  -> t.


Axiom Power_0 : forall (x:t), ((power x 0%Z) = (mk_t 1%Z 0%Z 0%Z 1%Z)).

Axiom Power_s : forall (x:t) (n:Z), (0%Z <= n)%Z -> ((power x
  (n + 1%Z)%Z) = (mult x (power x n))).

Axiom power_sum : forall (x:t) (n:Z) (m:Z), (0%Z <= n)%Z -> ((0%Z <= m)%Z ->
  ((power x (n + m)%Z) = (mult (power x n) (power x m)))).

Theorem WP_logfib : forall (n:Z), (0%Z <= n)%Z -> ((~ (n = 0%Z)) ->
  ((((0%Z <= n)%Z /\ ((Zdiv n 2%Z) <  n)%Z) /\ (0%Z <= (Zdiv n 2%Z))%Z) ->
  forall (result:(Z* Z)%type),
  match result with
  | (a, b) => ((power (mk_t 1%Z 1%Z 1%Z 0%Z) (Zdiv n 2%Z)) = (mk_t (a + b)%Z
      b b a))
  end ->
  match result with
  | (a, b) => (~ ((Zmod n 2%Z) = 0%Z)) -> match ((b * (a + (a + b)%Z)%Z)%Z,
      (((a + b)%Z * (a + b)%Z)%Z + (b * b)%Z)%Z) with
      | (a1, b1) => ((power (mk_t 1%Z 1%Z 1%Z 0%Z) n) = (mk_t (a1 + b1)%Z b1
          b1 a1))
      end
  end)).
(* YOU MAY EDIT THE PROOF BELOW *)
intuition.
destruct result as (a,b).
intro.
assert (n mod 2 = 1)%Z.
generalize (Mod_bound n 2).
intuition.
simpl in H8.
omega.
assert (n = 2 * (n/2) + 1)%Z.
generalize (Div_mod n 2); intuition.
rewrite H7.
rewrite Power_s. 2:omega.
replace (2 * (n/2))%Z with (n/2 + n/2)%Z by omega.
rewrite power_sum; try omega.
rewrite H2; clear H2 H3 H4 H5.
unfold mult, a11, a12, a21, a22.
apply f_equal4; ring.
Qed.
(* DO NOT EDIT BELOW *)

