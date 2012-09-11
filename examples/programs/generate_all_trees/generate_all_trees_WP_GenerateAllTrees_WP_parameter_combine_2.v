(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Inductive list (a:Type) :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Implicit Arguments Nil [[a]].
Implicit Arguments Cons [[a]].

(* Why3 assumption *)
Fixpoint mem {a:Type}(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.

(* Why3 assumption *)
Fixpoint infix_plpl {a:Type}(l1:(list a)) (l2:(list a)) {struct l1}: (list
  a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.

Axiom Append_assoc : forall {a:Type}, forall (l1:(list a)) (l2:(list a))
  (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall {a:Type}, forall (l:(list a)), ((infix_plpl l
  (Nil :(list a))) = l).

(* Why3 assumption *)
Fixpoint length {a:Type}(l:(list a)) {struct l}: Z :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.

Axiom Length_nonnegative : forall {a:Type}, forall (l:(list a)),
  (0%Z <= (length l))%Z.

Axiom Length_nil : forall {a:Type}, forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

Axiom Append_length : forall {a:Type}, forall (l1:(list a)) (l2:(list a)),
  ((length (infix_plpl l1 l2)) = ((length l1) + (length l2))%Z).

Axiom mem_append : forall {a:Type}, forall (x:a) (l1:(list a)) (l2:(list a)),
  (mem x (infix_plpl l1 l2)) <-> ((mem x l1) \/ (mem x l2)).

Axiom mem_decomp : forall {a:Type}, forall (x:a) (l:(list a)), (mem x l) ->
  exists l1:(list a), exists l2:(list a), (l = (infix_plpl l1 (Cons x l2))).

(* Why3 assumption *)
Inductive distinct{a:Type}  : (list a) -> Prop :=
  | distinct_zero : (distinct (Nil :(list a)))
  | distinct_one : forall (x:a), (distinct (Cons x (Nil :(list a))))
  | distinct_many : forall (x:a) (l:(list a)), (~ (mem x l)) ->
      ((distinct l) -> (distinct (Cons x l))).

Axiom distinct_append : forall {a:Type}, forall (l1:(list a)) (l2:(list a)),
  (distinct l1) -> ((distinct l2) -> ((forall (x:a), (mem x l1) -> ~ (mem x
  l2)) -> (distinct (infix_plpl l1 l2)))).

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall {a:Type} {b:Type}, (map a b) -> a -> b.

Parameter set: forall {a:Type} {b:Type}, (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {b:Type}, forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall {a:Type} {b:Type}, forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall {a:Type} {b:Type}, b -> (map a b).

Axiom Const : forall {a:Type} {b:Type}, forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive array (a:Type) :=
  | mk_array : Z -> (map Z a) -> array a.
Implicit Arguments mk_array [[a]].

(* Why3 assumption *)
Definition elts {a:Type}(v:(array a)): (map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length1 {a:Type}(v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get1 {a:Type}(a1:(array a)) (i:Z): a := (get (elts a1) i).

(* Why3 assumption *)
Definition set1 {a:Type}(a1:(array a)) (i:Z) (v:a): (array a) :=
  (mk_array (length1 a1) (set (elts a1) i v)).

(* Why3 assumption *)
Inductive tree  :=
  | Empty : tree 
  | Node : tree -> tree -> tree .

(* Why3 assumption *)
Fixpoint size(t:tree) {struct t}: Z :=
  match t with
  | Empty => 0%Z
  | (Node l r) => ((1%Z + (size l))%Z + (size r))%Z
  end.

Axiom size_nonneg : forall (t:tree), (0%Z <= (size t))%Z.

Axiom size_left : forall (t:tree), (0%Z < (size t))%Z -> exists l:tree,
  exists r:tree, (t = (Node l r)) /\ ((size l) < (size t))%Z.

(* Why3 assumption *)
Definition all_trees(n:Z) (l:(list tree)): Prop := (distinct l) /\
  forall (t:tree), ((size t) = n) <-> (mem t l).

Axiom all_trees_0 : (all_trees 0%Z (Cons Empty (Nil :(list tree)))).

Axiom tree_diff : forall (l1:tree) (l2:tree), (~ ((size l1) = (size l2))) ->
  forall (r1:tree) (r2:tree), ~ ((Node l1 r1) = (Node l2 r2)).



(* Why3 goal *)
Theorem WP_parameter_combine : forall (i1:Z) (l1:(list tree)) (i2:Z)
  (l2:(list tree)), ((0%Z <= i1)%Z /\ ((all_trees i1 l1) /\ ((0%Z <= i2)%Z /\
  (all_trees i2 l2)))) -> forall (l11:(list tree)), (distinct l11) ->
  match l11 with
  | Nil => True
  | (Cons t1 l12) => forall (l21:(list tree)), (distinct l21) ->
      match l21 with
      | Nil => True
      | (Cons t2 l22) => (((0%Z <= (length l21))%Z /\
          ((length l22) < (length l21))%Z) /\ (distinct l22)) ->
          forall (o:(list tree)), ((distinct o) /\ forall (t:tree), (mem t
          o) <-> exists r:tree, (t = (Node t1 r)) /\ (mem r l22)) ->
          forall (t:tree), (mem t (Cons (Node t1 t2) o)) -> exists r:tree,
          (t = (Node t1 r)) /\ (mem r l21)
      end
  end.
(* YOU MAY EDIT THE PROOF BELOW *)
intuition.
destruct l11; intuition.
destruct l21; intuition.
unfold mem in H6; fold @mem in H6.
destruct H6.
exists t0; intuition.
red; intuition.
generalize (H10 t1); clear H8. intuition.
destruct H8 as (r,h); exists r; intuition.
red; intuition.
Qed.


