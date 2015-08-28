(* This file is generated by Why3's Coq 8.4 driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Import ZOdiv.
Require BuiltIn.
Require int.Int.
Require int.Abs.
Require int.ComputerDivision.
Require option.Option.
Require list.List.
Require list.Mem.
Require map.Map.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 assumption *)
Inductive array
  (a:Type) {a_WT:WhyType a} :=
  | mk_array : Z -> (@map.Map.map Z _ a a_WT) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a] [a_WT]].

(* Why3 assumption *)
Definition elts {a:Type} {a_WT:WhyType a} (v:(@array a a_WT)): (@map.Map.map
  Z _ a a_WT) := match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length {a:Type} {a_WT:WhyType a} (v:(@array a a_WT)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get {a:Type} {a_WT:WhyType a} (a1:(@array a a_WT)) (i:Z): a :=
  (map.Map.get (elts a1) i).

(* Why3 assumption *)
Definition set {a:Type} {a_WT:WhyType a} (a1:(@array a a_WT)) (i:Z)
  (v:a): (@array a a_WT) := (mk_array (length a1) (map.Map.set (elts a1) i
  v)).

(* Why3 assumption *)
Definition make {a:Type} {a_WT:WhyType a} (n:Z) (v:a): (@array a a_WT) :=
  (mk_array n (map.Map.const v:(@map.Map.map Z _ a a_WT))).

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
Definition in_data {a:Type} {a_WT:WhyType a} (k:key) (v:a) (d:(@array
  (list (key* a)%type) _)): Prop := (list.Mem.mem (k, v) (get d (bucket k
  (length d)))).

(* Why3 assumption *)
Definition good_data {a:Type} {a_WT:WhyType a} (k:key) (v:a) (m:(@map.Map.map
  key key_WhyType (option a) _)) (d:(@array (list (key* a)%type) _)): Prop :=
  ((map.Map.get m k) = (Some v)) <-> (in_data k v d).

(* Why3 assumption *)
Definition good_hash {a:Type} {a_WT:WhyType a} (d:(@array (list (key*
  a)%type) _)) (i:Z): Prop := forall (k:key) (v:a), (list.Mem.mem (k, v)
  (get d i)) -> ((bucket k (length d)) = i).

(* Why3 assumption *)
Inductive t
  (a:Type) {a_WT:WhyType a} :=
  | mk_t : Z -> (@array (list (key* a)%type) _) -> (@map.Map.map
      key key_WhyType (option a) _) -> t a.
Axiom t_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (t a).
Existing Instance t_WhyType.
Implicit Arguments mk_t [[a] [a_WT]].

(* Why3 assumption *)
Definition view {a:Type} {a_WT:WhyType a} (v:(@t a a_WT)): (@map.Map.map
  key key_WhyType (option a) _) := match v with
  | (mk_t x x1 x2) => x2
  end.

(* Why3 assumption *)
Definition data {a:Type} {a_WT:WhyType a} (v:(@t a a_WT)): (@array
  (list (key* a)%type) _) := match v with
  | (mk_t x x1 x2) => x1
  end.

(* Why3 assumption *)
Definition size {a:Type} {a_WT:WhyType a} (v:(@t a a_WT)): Z :=
  match v with
  | (mk_t x x1 x2) => x
  end.

Require Import Why3. Ltac ae := why3 "Alt-Ergo,0.95.2," timelimit 3.

(* Why3 goal *)
Theorem WP_parameter_add : forall {a:Type} {a_WT:WhyType a}, forall (h:Z)
  (h1:(@map.Map.map Z _ (list (key* a)%type) _)) (h2:(@map.Map.map
  key key_WhyType (option a) _)) (k:key) (v:a), (((0%Z < h)%Z /\
  ((forall (i:Z), ((0%Z <= i)%Z /\ (i < h)%Z) -> (good_hash (mk_array h h1)
  i)) /\ forall (k1:key) (v1:a), (good_data k1 v1 h2 (mk_array h h1)))) /\
  (0%Z <= h)%Z) -> forall (rho:Z) (rho1:(@map.Map.map Z _ (list (key*
  a)%type) _)), (((0%Z < rho)%Z /\ ((forall (i:Z), ((0%Z <= i)%Z /\
  (i < rho)%Z) -> (good_hash (mk_array rho rho1) i)) /\ forall (k1:key)
  (v1:a), (good_data k1 v1 h2 (mk_array rho rho1)))) /\ (0%Z <= rho)%Z) ->
  forall (rho2:(@map.Map.map key key_WhyType (option a) _))
  (rho3:(@map.Map.map Z _ (list (key* a)%type) _)) (rho4:Z),
  ((((0%Z < rho)%Z /\ ((forall (i:Z), ((0%Z <= i)%Z /\ (i < rho)%Z) ->
  (good_hash (mk_array rho rho3) i)) /\ forall (k1:key) (v1:a), (good_data k1
  v1 rho2 (mk_array rho rho3)))) /\ (0%Z <= rho)%Z) /\ (((map.Map.get rho2
  k) = None) /\ forall (k':key), (~ (k' = k)) -> ((map.Map.get rho2
  k') = (map.Map.get h2 k')))) -> let i := (bucket k rho) in
  (((0%Z <= i)%Z /\ (i < rho)%Z) -> (((0%Z <= i)%Z /\ (i < rho)%Z) ->
  forall (o:(@map.Map.map Z _ (list (key* a)%type) _)), ((0%Z <= rho)%Z /\
  (o = (map.Map.set rho3 i (cons (k, v) (map.Map.get rho3 i))))) ->
  forall (rho5:Z), (rho5 = (rho4 + 1%Z)%Z) -> forall (rho6:(@map.Map.map
  key key_WhyType (option a) _)), (rho6 = (map.Map.set rho2 k (Some v))) ->
  forall (i1:Z), ((0%Z <= i1)%Z /\ (i1 < rho)%Z) -> (good_hash (mk_array rho
  o) i1))).
intros a a_WT rho rho1 rho2 k v ((h1,(h2,h3)),h4) rho3 rho4 ((h5,(h6,h7)),h8)
rho5 rho6 rho7 (((h9,(h10,h11)),h12),(h13,h14)) i1 (h15,h16) (h17,h18) o
(h19,h20) rho8 h21 rho9 h22 i (h23,h24).
subst i1.
unfold good_hash in *.
clear h11.
generalize (h10 i (conj h23 h24)); clear h10; intro h10.
subst o; unfold get; simpl.
intros k0 v0.
assert (h: (i = bucket k rho3) \/ (i <> bucket k rho3)%Z) by omega.
destruct h.
ae.
ae.
Qed.
