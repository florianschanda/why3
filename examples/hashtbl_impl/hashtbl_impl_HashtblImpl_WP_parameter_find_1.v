(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Import ZOdiv.
Require BuiltIn.
Require int.Int.
Require int.Abs.
Require int.ComputerDivision.
Require map.Map.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 assumption *)
Inductive option
  (a:Type) {a_WT:WhyType a} :=
  | None : option a
  | Some : a -> option a.
Axiom option_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (option a).
Existing Instance option_WhyType.
Implicit Arguments None [[a] [a_WT]].
Implicit Arguments Some [[a] [a_WT]].

(* Why3 assumption *)
Inductive list
  (a:Type) {a_WT:WhyType a} :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Axiom list_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (list a).
Existing Instance list_WhyType.
Implicit Arguments Nil [[a] [a_WT]].
Implicit Arguments Cons [[a] [a_WT]].

(* Why3 assumption *)
Fixpoint mem {a:Type} {a_WT:WhyType a} (x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.

(* Why3 assumption *)
Inductive array
  (a:Type) {a_WT:WhyType a} :=
  | mk_array : Z -> (map.Map.map Z a) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a] [a_WT]].

(* Why3 assumption *)
Definition elts {a:Type} {a_WT:WhyType a} (v:(array a)): (map.Map.map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length {a:Type} {a_WT:WhyType a} (v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get {a:Type} {a_WT:WhyType a} (a1:(array a)) (i:Z): a :=
  (map.Map.get (elts a1) i).

(* Why3 assumption *)
Definition set {a:Type} {a_WT:WhyType a} (a1:(array a)) (i:Z) (v:a): (array
  a) := (mk_array (length a1) (map.Map.set (elts a1) i v)).

(* Why3 assumption *)
Definition make {a:Type} {a_WT:WhyType a} (n:Z) (v:a): (array a) :=
  (mk_array n (map.Map.const v:(map.Map.map Z a))).

Axiom key : Type.
Parameter key_WhyType : WhyType key.
Existing Instance key_WhyType.

Parameter hash: key -> Z.

Axiom hash_nonneg : forall (k:key), (0%Z <= (hash k))%Z.

(* Why3 assumption *)
Definition bucket (k:key) (n:Z): Z := (ZOmod (hash k) n).

Axiom bucket_bounds : forall (n:Z), (0%Z < n)%Z -> forall (k:key),
  (0%Z <= (bucket k n))%Z /\ ((bucket k n) < n)%Z.

(* Why3 assumption *)
Definition in_data {a:Type} {a_WT:WhyType a} (k:key) (v:a) (d:(array (list
  (key* a)%type))): Prop := (mem (k, v) (get d (bucket k (length d)))).

(* Why3 assumption *)
Definition good_data {a:Type} {a_WT:WhyType a} (k:key) (v:a) (m:(map.Map.map
  key (option a))) (d:(array (list (key* a)%type))): Prop := ((map.Map.get m
  k) = (Some v)) <-> (in_data k v d).

(* Why3 assumption *)
Definition good_hash {a:Type} {a_WT:WhyType a} (d:(array (list (key*
  a)%type))) (i:Z): Prop := forall (k:key) (v:a), (mem (k, v) (get d i)) ->
  ((bucket k (length d)) = i).

(* Why3 assumption *)
Inductive t
  (a:Type) {a_WT:WhyType a} :=
  | mk_t : Z -> (array (list (key* a)%type)) -> (map.Map.map key (option
      a)) -> t a.
Axiom t_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (t a).
Existing Instance t_WhyType.
Implicit Arguments mk_t [[a] [a_WT]].

(* Why3 assumption *)
Definition view {a:Type} {a_WT:WhyType a} (v:(t a)): (map.Map.map key (option
  a)) := match v with
  | (mk_t x x1 x2) => x2
  end.

(* Why3 assumption *)
Definition data {a:Type} {a_WT:WhyType a} (v:(t a)): (array (list (key*
  a)%type)) := match v with
  | (mk_t x x1 x2) => x1
  end.

(* Why3 assumption *)
Definition size {a:Type} {a_WT:WhyType a} (v:(t a)): Z :=
  match v with
  | (mk_t x x1 x2) => x
  end.

(* Why3 goal *)
Theorem WP_parameter_find : forall {a:Type} {a_WT:WhyType a}, forall (k:key),
  forall (rho:(map.Map.map key (option a))) (rho1:Z) (rho2:(map.Map.map Z
  (list (key* a)%type))), ((((0%Z < rho1)%Z /\ forall (i:Z), ((0%Z <= i)%Z /\
  (i < rho1)%Z) -> (good_hash (mk_array rho1 rho2) i)) /\ forall (k1:key)
  (v:a), (good_data k1 v rho (mk_array rho1 rho2))) /\ (0%Z <= rho1)%Z) ->
  let i := (bucket k rho1) in (((0%Z <= i)%Z /\ (i < rho1)%Z) -> let o :=
  (map.Map.get rho2 i) in forall (result:(option a)),
  match result with
  | None => forall (v:a), ~ (mem (k, v) o)
  | (Some v) => (mem (k, v) o)
  end -> (result = (map.Map.get rho k))).
(* Why3 intros a a_WT k rho rho1 rho2 (((h1,h2),h3),h4) i (h5,h6) o result
        h7. *)
intros a a_WT k rho rho1 rho2 (((h1,h2),h3),h4) i (h5,h6) o result h7.
subst i.
destruct result.
unfold good_data in h3.
generalize (h3 k); clear h3.
destruct (Map.get rho k).
auto.
intro h; generalize (h a0); clear h.
intuition.
unfold in_data in H.
unfold get in H; simpl in H.
generalize (h7 a0); clear h7.
intuition.
subst o.
generalize (h3 k); clear h3.
intro h; generalize (h a0); clear h; intro h.
unfold good_data in h.
destruct (Map.get rho k).
symmetry.
intuition.
symmetry.
intuition.
Qed.

