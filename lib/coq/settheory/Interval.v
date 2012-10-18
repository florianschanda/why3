(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require set.Set.

Open Scope Z_scope.
Import set.Set.

(* Why3 goal *)
Definition integer: (set.Set.set Z).
exact (fun _ => True).
Defined.

(* Why3 goal *)
Lemma mem_integer : forall (x:Z), (set.Set.mem x integer).
easy.
Qed.

(* Why3 goal *)
Definition natural: (set.Set.set Z).
exact (fun n => n >= 0).
Defined.

(* Why3 goal *)
Lemma mem_natural : forall (x:Z), (set.Set.mem x natural) <-> (0%Z <= x)%Z.
intros x.
unfold natural, mem ; intuition. 
Qed.

(* Why3 goal *)
Definition mk: Z -> Z -> (set.Set.set Z).
intros a b.
exact (fun n => a <= n <= b).
Defined.

(* Why3 goal *)
Lemma mem_interval : forall (x:Z) (a:Z) (b:Z), (set.Set.mem x (mk a b)) <->
  ((a <= x)%Z /\ (x <= b)%Z).
intros x a b.
unfold mk, mem ; tauto.
Qed.

(* Why3 goal *)
Lemma interval_empty : forall (a:Z) (b:Z), (b < a)%Z -> ((mk a
  b) = (set.Set.empty :(set.Set.set Z))).
intros a b h1.
apply predicate_extensionality; intro x.
unfold empty, mk, mem; intuition.
Qed.

(* Why3 goal *)
Lemma interval_add : forall (a:Z) (b:Z), (a <= b)%Z -> ((mk a
  b) = (set.Set.add b (mk a (b - 1%Z)%Z))).
intros a b h1.
apply predicate_extensionality; intro x.
unfold mk, add, mem; intuition; omega.
Qed.

