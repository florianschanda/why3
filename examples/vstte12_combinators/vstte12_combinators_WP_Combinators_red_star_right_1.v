(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.

(* Why3 assumption *)
Definition unit  := unit.

Parameter qtmark : Type.

Parameter at1: forall (a:Type), a -> qtmark -> a.
Implicit Arguments at1.

Parameter old: forall (a:Type), a -> a.
Implicit Arguments old.

(* Why3 assumption *)
Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

(* Why3 assumption *)
Inductive term  :=
  | S : term 
  | K : term 
  | App : term -> term -> term .

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint is_value(t:term) {struct t}: Prop :=
  match t with
  | (K|S) => True
  | ((App K v)|(App S v)) => (is_value v)
  | (App (App S v1) v2) => (is_value v1) /\ (is_value v2)
  | _ => False
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Inductive context  :=
  | Hole : context 
  | Left : context -> term -> context 
  | Right : term -> context -> context .

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint is_context(c:context) {struct c}: Prop :=
  match c with
  | Hole => True
  | (Left c1 _) => (is_context c1)
  | (Right v c1) => (is_value v) /\ (is_context c1)
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint subst(c:context) (t:term) {struct c}: term :=
  match c with
  | Hole => t
  | (Left c1 t2) => (App (subst c1 t) t2)
  | (Right v1 c2) => (App v1 (subst c2 t))
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Inductive infix_mnmngt : term -> term -> Prop :=
  | red_K : forall (c:context), (is_context c) -> forall (v1:term) (v2:term),
      (is_value v1) -> ((is_value v2) -> (infix_mnmngt (subst c (App (App K
      v1) v2)) (subst c v1)))
  | red_S : forall (c:context), (is_context c) -> forall (v1:term) (v2:term)
      (v3:term), (is_value v1) -> ((is_value v2) -> ((is_value v3) ->
      (infix_mnmngt (subst c (App (App (App S v1) v2) v3)) (subst c
      (App (App v1 v3) (App v2 v3)))))).

(* Why3 assumption *)
Inductive relTR : term -> term -> Prop :=
  | BaseTransRefl : forall (x:term), (relTR x x)
  | StepTransRefl : forall (x:term) (y:term) (z:term), (relTR x y) ->
      ((infix_mnmngt y z) -> (relTR x z)).

Axiom relTR_transitive : forall (x:term) (y:term) (z:term), (relTR x y) ->
  ((relTR y z) -> (relTR x z)).

Axiom red_star_left : forall (t1:term) (t2:term) (t:term), (relTR t1 t2) ->
  (relTR (App t1 t) (App t2 t)).

(* Why3 goal *)
Theorem red_star_right : forall (v:term) (t1:term) (t2:term), (is_value v) ->
  ((relTR t1 t2) -> (relTR (App v t1) (App v t2))).
induction 2; intuition.
apply BaseTransRefl.
apply relTR_transitive with (App v y); auto.
eapply StepTransRefl.
apply BaseTransRefl.
inversion H1.
subst y z.
apply (red_K (Right v c)); auto.
simpl; auto.
subst y z.
apply (red_S (Right v c)); auto.
simpl; auto. 
Qed.


