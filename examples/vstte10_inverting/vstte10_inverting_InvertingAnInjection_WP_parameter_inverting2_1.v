(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require map.Map.
Require map.Occ.
Require map.MapInjection.

(* Why3 assumption *)
Definition unit := unit.

Axiom qtmark : Type.
Parameter qtmark_WhyType : WhyType qtmark.
Existing Instance qtmark_WhyType.

(* Why3 assumption *)
Inductive array (a:Type) :=
  | mk_array : Z -> (map.Map.map Z a) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a]].

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
Definition injective (a:(array Z)) (n:Z): Prop := (map.MapInjection.injective
  (elts a) n).

(* Why3 assumption *)
Definition surjective (a:(array Z)) (n:Z): Prop :=
  (map.MapInjection.surjective (elts a) n).

(* Why3 assumption *)
Definition range (a:(array Z)) (n:Z): Prop := (map.MapInjection.range
  (elts a) n).

(* Why3 goal *)
Theorem WP_parameter_inverting2 : forall (a:Z) (a1:(map.Map.map Z Z)) (n:Z),
  ((0%Z <= a)%Z /\ ((n = a) /\ ((map.MapInjection.injective a1 n) /\
  (map.MapInjection.range a1 n)))) -> ((0%Z <= n)%Z -> forall (b:Z)
  (b1:(map.Map.map Z Z)), ((0%Z <= b)%Z /\ ((b = n) /\ forall (i:Z),
  ((0%Z <= i)%Z /\ (i < n)%Z) -> ((map.Map.get b1 i) = 0%Z))) -> let o :=
  (n - 1%Z)%Z in ((0%Z <= o)%Z -> forall (b2:(map.Map.map Z Z)),
  (forall (j:Z), ((0%Z <= j)%Z /\ (j < (o + 1%Z)%Z)%Z) -> ((map.Map.get b2
  (map.Map.get a1 j)) = j)) -> ((0%Z <= b)%Z -> (map.MapInjection.injective
  b2 n)))).
intros a a1 n (h1,(h2,(h3,h4))) h5 b b1 (h6,(h7,h8)) o h9 b2 h10 h11.
assert (MapInjection.surjective a1 n).
apply MapInjection.injective_surjective; assumption.
red; intros.
generalize (H i H0); unfold get; simpl; intros (i1, (Hi1,Hi2)).
generalize (H j H1); unfold get; simpl; intros (j1, (Hj1,Hj2)).
rewrite <- Hi2.
rewrite <- Hj2.
subst o.
rewrite h10; try omega.
rewrite h10; try omega.
red; intro h.
subst i1.
omega.
Qed.

