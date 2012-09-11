(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Inductive list (a:Type) {a_WT:WhyType a} :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Axiom list_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (list a).
Existing Instance list_WhyType.
Implicit Arguments Nil [[a] [a_WT]].
Implicit Arguments Cons [[a] [a_WT]].

(* Why3 assumption *)
Inductive option (a:Type) {a_WT:WhyType a} :=
  | None : option a
  | Some : a -> option a.
Axiom option_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (option a).
Existing Instance option_WhyType.
Implicit Arguments None [[a] [a_WT]].
Implicit Arguments Some [[a] [a_WT]].

Parameter nth: forall {a:Type} {a_WT:WhyType a}, BuiltIn.int -> (list a) ->
  (option a).

Axiom nth_def : forall {a:Type} {a_WT:WhyType a}, forall (n:BuiltIn.int)
  (l:(list a)),
  match l with
  | Nil => ((nth n l) = (None :(option a)))
  | (Cons x r) => ((n = 0%Z) -> ((nth n l) = (Some x))) /\ ((~ (n = 0%Z)) ->
      ((nth n l) = (nth (n - 1%Z)%Z r)))
  end.

(* Why3 assumption *)
Fixpoint length {a:Type} {a_WT:WhyType a}(l:(list
  a)) {struct l}: BuiltIn.int :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.

Axiom Length_nonnegative : forall {a:Type} {a_WT:WhyType a}, forall (l:(list
  a)), (0%Z <= (length l))%Z.

Axiom Length_nil : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

Axiom nth_none_1 : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a))
  (i:BuiltIn.int), (i < 0%Z)%Z -> ((nth i l) = (None :(option a))).

Axiom nth_none_2 : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a))
  (i:BuiltIn.int), ((length l) <= i)%Z -> ((nth i l) = (None :(option a))).

Axiom nth_none_3 : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a))
  (i:BuiltIn.int), ((nth i l) = (None :(option a))) -> ((i < 0%Z)%Z \/
  ((length l) <= i)%Z).

(* Why3 assumption *)
Fixpoint infix_plpl {a:Type} {a_WT:WhyType a}(l1:(list a)) (l2:(list
  a)) {struct l1}: (list a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.

Axiom Append_assoc : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)) (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a)),
  ((infix_plpl l (Nil :(list a))) = l).

Axiom Append_length : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)), ((length (infix_plpl l1
  l2)) = ((length l1) + (length l2))%Z).

(* Why3 assumption *)
Fixpoint mem {a:Type} {a_WT:WhyType a}(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.

Axiom mem_append : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (l1:(list
  a)) (l2:(list a)), (mem x (infix_plpl l1 l2)) <-> ((mem x l1) \/ (mem x
  l2)).

Axiom mem_decomp : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (l:(list
  a)), (mem x l) -> exists l1:(list a), exists l2:(list a),
  (l = (infix_plpl l1 (Cons x l2))).

Axiom nth_append_1 : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)) (i:BuiltIn.int), (i < (length l1))%Z -> ((nth i
  (infix_plpl l1 l2)) = (nth i l1)).

Axiom nth_append_2 : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)) (i:BuiltIn.int), ((length l1) <= i)%Z -> ((nth i
  (infix_plpl l1 l2)) = (nth (i - (length l1))%Z l2)).

Parameter map : forall (a:Type) {a_WT:WhyType a} (b:Type) {b_WT:WhyType b},
  Type.
Axiom map_WhyType : forall (a:Type) {a_WT:WhyType a}
  (b:Type) {b_WT:WhyType b}, WhyType (map a b).
Existing Instance map_WhyType.

Parameter get: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b.

Parameter set: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (m:(map a b)), forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) ->
  ((get (set m a1 b1) a2) = b1).

Axiom Select_neq : forall {a:Type} {a_WT:WhyType a}
  {b:Type} {b_WT:WhyType b}, forall (m:(map a b)), forall (a1:a) (a2:a),
  forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1) a2) = (get m a2)).

Parameter const: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  b -> (map a b).

Axiom Const : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (b1:b) (a1:a), ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive array (a:Type) {a_WT:WhyType a} :=
  | mk_array : BuiltIn.int -> (map BuiltIn.int a) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a] [a_WT]].

(* Why3 assumption *)
Definition elts {a:Type} {a_WT:WhyType a}(v:(array a)): (map BuiltIn.int
  a) := match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length1 {a:Type} {a_WT:WhyType a}(v:(array a)): BuiltIn.int :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get1 {a:Type} {a_WT:WhyType a}(a1:(array a)) (i:BuiltIn.int): a :=
  (get (elts a1) i).

(* Why3 assumption *)
Definition set1 {a:Type} {a_WT:WhyType a}(a1:(array a)) (i:BuiltIn.int)
  (v:a): (array a) := (mk_array (length1 a1) (set (elts a1) i v)).

(* Why3 assumption *)
Inductive buffer (a:Type) {a_WT:WhyType a} :=
  | mk_buffer : BuiltIn.int -> BuiltIn.int -> (array a) -> (list
      a) -> buffer a.
Axiom buffer_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (buffer a).
Existing Instance buffer_WhyType.
Implicit Arguments mk_buffer [[a] [a_WT]].

(* Why3 assumption *)
Definition sequence {a:Type} {a_WT:WhyType a}(v:(buffer a)): (list a) :=
  match v with
  | (mk_buffer x x1 x2 x3) => x3
  end.

(* Why3 assumption *)
Definition data {a:Type} {a_WT:WhyType a}(v:(buffer a)): (array a) :=
  match v with
  | (mk_buffer x x1 x2 x3) => x2
  end.

(* Why3 assumption *)
Definition len {a:Type} {a_WT:WhyType a}(v:(buffer a)): BuiltIn.int :=
  match v with
  | (mk_buffer x x1 x2 x3) => x1
  end.

(* Why3 assumption *)
Definition first {a:Type} {a_WT:WhyType a}(v:(buffer a)): BuiltIn.int :=
  match v with
  | (mk_buffer x x1 x2 x3) => x
  end.

(* Why3 assumption *)
Definition size {a:Type} {a_WT:WhyType a}(b:(buffer a)): BuiltIn.int :=
  (length1 (data b)).

Require Import Why3. Ltac ae := why3 "alt-ergo" timelimit 3.

(* Why3 goal *)
Theorem WP_parameter_pop : forall {a:Type} {a_WT:WhyType a},
  forall (b:BuiltIn.int), forall (rho:(list a)) (rho1:(map BuiltIn.int a))
  (rho2:BuiltIn.int) (rho3:BuiltIn.int), ((0%Z < rho2)%Z /\
  ((((0%Z < rho3)%Z \/ (0%Z = rho3)) /\ (rho3 < b)%Z) /\ ((((0%Z < rho2)%Z \/
  (0%Z = rho2)) /\ ((rho2 < b)%Z \/ (rho2 = b))) /\ ((rho2 = (length rho)) /\
  forall (i:BuiltIn.int), (((0%Z < i)%Z \/ (0%Z = i)) /\ (i < rho2)%Z) ->
  ((((rho3 + i)%Z < b)%Z -> ((nth i rho) = (Some (get rho1
  (rho3 + i)%Z)))) /\ (((0%Z < ((rho3 + i)%Z - b)%Z)%Z \/
  (0%Z = ((rho3 + i)%Z - b)%Z)) -> ((nth i rho) = (Some (get rho1
  ((rho3 + i)%Z - b)%Z))))))))) ->
  match rho with
  | Nil => True
  | (Cons _ s) => forall (rho4:(list a)), (rho4 = s) -> ((((0%Z < rho3)%Z \/
      (0%Z = rho3)) /\ (rho3 < b)%Z) -> forall (rho5:BuiltIn.int),
      (rho5 = (rho2 + (-1%Z)%Z)%Z) -> forall (rho6:BuiltIn.int),
      (rho6 = (rho3 + 1%Z)%Z) -> ((rho6 = b) -> forall (rho7:BuiltIn.int),
      (rho7 = 0%Z) -> (((rho5 = (rho2 + (-1%Z)%Z)%Z) /\
      match rho with
      | Nil => False
      | (Cons x l) => ((get rho1 rho3) = x) /\ (rho4 = l)
      end) -> forall (i:BuiltIn.int), (((0%Z < i)%Z \/ (0%Z = i)) /\
      (i < rho5)%Z) -> (((rho7 + i)%Z < b)%Z -> ((nth i
      rho4) = (Some (get rho1 (rho7 + i)%Z)))))))
  end.
unfold get1, size; simpl.
intros a _a b rho rho1 rho2 rho3 (h1,((h2,h3),((h4,h5),(h6,h7)))).
destruct rho; auto.
intros; subst.
generalize (h7 (i+1)%Z).
ae.
Qed.


