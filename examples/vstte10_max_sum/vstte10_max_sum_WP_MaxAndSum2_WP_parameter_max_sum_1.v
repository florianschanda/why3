(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require map.Map.

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

(* Why3 assumption *)
Definition container := (map.Map.map Z Z).

Parameter sum: (map.Map.map Z Z) -> Z -> Z -> Z.

Axiom Sum_def_empty : forall (c:(map.Map.map Z Z)) (i:Z) (j:Z), (j <= i)%Z ->
  ((sum c i j) = 0%Z).

Axiom Sum_def_non_empty : forall (c:(map.Map.map Z Z)) (i:Z) (j:Z),
  (i < j)%Z -> ((sum c i j) = ((map.Map.get c i) + (sum c (i + 1%Z)%Z j))%Z).

Axiom Sum_right_extension : forall (c:(map.Map.map Z Z)) (i:Z) (j:Z),
  (i < j)%Z -> ((sum c i j) = ((sum c i (j - 1%Z)%Z) + (map.Map.get c
  (j - 1%Z)%Z))%Z).

Axiom Sum_transitivity : forall (c:(map.Map.map Z Z)) (i:Z) (k:Z) (j:Z),
  ((i <= k)%Z /\ (k <= j)%Z) -> ((sum c i j) = ((sum c i k) + (sum c k
  j))%Z).

Axiom Sum_eq : forall (c1:(map.Map.map Z Z)) (c2:(map.Map.map Z Z)) (i:Z)
  (j:Z), (forall (k:Z), ((i <= k)%Z /\ (k < j)%Z) -> ((map.Map.get c1
  k) = (map.Map.get c2 k))) -> ((sum c1 i j) = (sum c2 i j)).

(* Why3 assumption *)
Definition sum1 (a:(array Z)) (l:Z) (h:Z): Z := (sum (elts a) l h).

(* Why3 assumption *)
Definition is_max (a:(array Z)) (l:Z) (h:Z) (m:Z): Prop := (forall (k:Z),
  ((l <= k)%Z /\ (k < h)%Z) -> ((get a k) <= m)%Z) /\ (((h <= l)%Z /\
  (m = 0%Z)) \/ ((l < h)%Z /\ exists k:Z, ((l <= k)%Z /\ (k < h)%Z) /\
  (m = (get a k)))).


(* Why3 goal *)
Theorem WP_parameter_max_sum : forall (a:Z) (n:Z), forall (a1:(map.Map.map Z
  Z)), ((0%Z <= a)%Z /\ ((n = a) /\ forall (i:Z), ((0%Z <= i)%Z /\
  (i < n)%Z) -> (0%Z <= (map.Map.get a1 i))%Z)) -> let o := (n - 1%Z)%Z in
  ((0%Z <= o)%Z -> forall (m:Z) (s:Z), forall (i:Z), ((0%Z <= i)%Z /\
  (i <= o)%Z) -> (((s = (sum a1 0%Z i)) /\ ((is_max (mk_array a a1) 0%Z i
  m) /\ (s <= (i * m)%Z)%Z)) -> (((0%Z <= i)%Z /\ (i < a)%Z) ->
  ((m < (map.Map.get a1 i))%Z -> (((0%Z <= i)%Z /\ (i < a)%Z) ->
  forall (m1:Z), (m1 = (map.Map.get a1 i)) -> (((0%Z <= i)%Z /\ (i < a)%Z) ->
  forall (s1:Z), (s1 = (s + (map.Map.get a1 i))%Z) ->
  (s1 <= ((i + 1%Z)%Z * m1)%Z)%Z)))))).
intros a n a1 (h1,(h2,h3)) o h4 m s i (h5,h6) (h7,(h8,h9)) (h10,h11)
        h12 (h13,h14) m1 h15 (h16,h17) s1 h18.
subst o.
ring_simplify.
subst.
apply Zplus_le_compat_r.
apply Zle_trans with (i * m)%Z; auto.
auto with *.
Qed.


