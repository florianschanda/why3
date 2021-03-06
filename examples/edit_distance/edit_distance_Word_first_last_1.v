(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require int.MinMax.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.Append.

Axiom char : Type.
Parameter char_WhyType : WhyType char.
Existing Instance char_WhyType.

(* Why3 assumption *)
Definition word := (list char).

(* Why3 assumption *)
Inductive dist : (list char) -> (list char) -> Z -> Prop :=
  | dist_eps : (dist nil nil 0%Z)
  | dist_add_left : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
      w2 n) -> forall (a:char), (dist (cons a w1) w2 (n + 1%Z)%Z)
  | dist_add_right : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
      w2 n) -> forall (a:char), (dist w1 (cons a w2) (n + 1%Z)%Z)
  | dist_context : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
      w2 n) -> forall (a:char), (dist (cons a w1) (cons a w2) n).

(* Why3 assumption *)
Definition min_dist (w1:(list char)) (w2:(list char)) (n:Z): Prop := (dist w1
  w2 n) /\ forall (m:Z), (dist w1 w2 m) -> (n <= m)%Z.

(* Why3 assumption *)
Fixpoint last_char (a:char) (u:(list char)) {struct u}: char :=
  match u with
  | nil => a
  | (cons c u') => (last_char c u')
  end.

(* Why3 assumption *)
Fixpoint but_last (a:char) (u:(list char)) {struct u}: (list char) :=
  match u with
  | nil => nil
  | (cons c u') => (cons a (but_last c u'))
  end.

Axiom first_last_explicit : forall (u:(list char)) (a:char),
  ((List.app (but_last a u) (cons (last_char a u) nil)) = (cons a u)).

(* Why3 goal *)
Theorem first_last : forall (a:char) (u:(list char)), exists v:(list char),
  exists b:char, ((List.app v (cons b nil)) = (cons a u)) /\
  ((list.Length.length v) = (list.Length.length u)).
intros a u.
exists (but_last a u).
exists (last_char a u).
split.
 exact (first_last_explicit u a).
generalize a; induction u; intros.
simpl; omega.
unfold but_last; fold but_last.
unfold Length.length; fold @Length.length.
generalize (IHu a0); intros; omega.
Qed.


