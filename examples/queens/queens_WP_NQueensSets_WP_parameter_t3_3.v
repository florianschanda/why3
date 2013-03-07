(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require map.Map.

(* Why3 assumption *)
Definition unit  := unit.

Axiom set : forall (a:Type) {a_WT:WhyType a}, Type.
Parameter set_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (set a).
Existing Instance set_WhyType.

Parameter mem: forall {a:Type} {a_WT:WhyType a}, a -> (set a) -> Prop.

(* Why3 assumption *)
Definition infix_eqeq {a:Type} {a_WT:WhyType a}(s1:(set a)) (s2:(set
  a)): Prop := forall (x:a), (mem x s1) <-> (mem x s2).

Axiom extensionality : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)), (infix_eqeq s1 s2) -> (s1 = s2).

(* Why3 assumption *)
Definition subset {a:Type} {a_WT:WhyType a}(s1:(set a)) (s2:(set a)): Prop :=
  forall (x:a), (mem x s1) -> (mem x s2).

Axiom subset_refl : forall {a:Type} {a_WT:WhyType a}, forall (s:(set a)),
  (subset s s).

Axiom subset_trans : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)) (s3:(set a)), (subset s1 s2) -> ((subset s2 s3) -> (subset s1
  s3)).

Parameter empty: forall {a:Type} {a_WT:WhyType a}, (set a).

(* Why3 assumption *)
Definition is_empty {a:Type} {a_WT:WhyType a}(s:(set a)): Prop :=
  forall (x:a), ~ (mem x s).

Axiom empty_def1 : forall {a:Type} {a_WT:WhyType a}, (is_empty (empty :(set
  a))).

Axiom mem_empty : forall {a:Type} {a_WT:WhyType a}, forall (x:a), ~ (mem x
  (empty :(set a))).

Parameter add: forall {a:Type} {a_WT:WhyType a}, a -> (set a) -> (set a).

Axiom add_def1 : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (y:a),
  forall (s:(set a)), (mem x (add y s)) <-> ((x = y) \/ (mem x s)).

Parameter remove: forall {a:Type} {a_WT:WhyType a}, a -> (set a) -> (set a).

Axiom remove_def1 : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (y:a)
  (s:(set a)), (mem x (remove y s)) <-> ((~ (x = y)) /\ (mem x s)).

Axiom subset_remove : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (s:(set
  a)), (subset (remove x s) s).

Parameter union: forall {a:Type} {a_WT:WhyType a}, (set a) -> (set a) -> (set
  a).

Axiom union_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)) (x:a), (mem x (union s1 s2)) <-> ((mem x s1) \/ (mem x s2)).

Parameter inter: forall {a:Type} {a_WT:WhyType a}, (set a) -> (set a) -> (set
  a).

Axiom inter_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)) (x:a), (mem x (inter s1 s2)) <-> ((mem x s1) /\ (mem x s2)).

Parameter diff: forall {a:Type} {a_WT:WhyType a}, (set a) -> (set a) -> (set
  a).

Axiom diff_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)) (x:a), (mem x (diff s1 s2)) <-> ((mem x s1) /\ ~ (mem x s2)).

Axiom subset_diff : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)), (subset (diff s1 s2) s1).

Parameter choose: forall {a:Type} {a_WT:WhyType a}, (set a) -> a.

Axiom choose_def : forall {a:Type} {a_WT:WhyType a}, forall (s:(set a)),
  (~ (is_empty s)) -> (mem (choose s) s).

Parameter cardinal: forall {a:Type} {a_WT:WhyType a}, (set a) -> Z.

Axiom cardinal_nonneg : forall {a:Type} {a_WT:WhyType a}, forall (s:(set a)),
  (0%Z <= (cardinal s))%Z.

Axiom cardinal_empty : forall {a:Type} {a_WT:WhyType a}, forall (s:(set a)),
  ((cardinal s) = 0%Z) <-> (is_empty s).

Axiom cardinal_add : forall {a:Type} {a_WT:WhyType a}, forall (x:a),
  forall (s:(set a)), (~ (mem x s)) -> ((cardinal (add x
  s)) = (1%Z + (cardinal s))%Z).

Axiom cardinal_remove : forall {a:Type} {a_WT:WhyType a}, forall (x:a),
  forall (s:(set a)), (mem x s) -> ((cardinal s) = (1%Z + (cardinal (remove x
  s)))%Z).

Axiom cardinal_subset : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set a))
  (s2:(set a)), (subset s1 s2) -> ((cardinal s1) <= (cardinal s2))%Z.

Axiom cardinal1 : forall {a:Type} {a_WT:WhyType a}, forall (s:(set a)),
  ((cardinal s) = 1%Z) -> forall (x:a), (mem x s) -> (x = (choose s)).

Parameter min_elt: (set Z) -> Z.

Axiom min_elt_def1 : forall (s:(set Z)), (~ (is_empty s)) -> (mem (min_elt s)
  s).

Axiom min_elt_def2 : forall (s:(set Z)), (~ (is_empty s)) -> forall (x:Z),
  (mem x s) -> ((min_elt s) <= x)%Z.

Parameter max_elt: (set Z) -> Z.

Axiom max_elt_def1 : forall (s:(set Z)), (~ (is_empty s)) -> (mem (max_elt s)
  s).

Axiom max_elt_def2 : forall (s:(set Z)), (~ (is_empty s)) -> forall (x:Z),
  (mem x s) -> (x <= (max_elt s))%Z.

Parameter below: Z -> (set Z).

Axiom below_def : forall (x:Z) (n:Z), (mem x (below n)) <-> ((0%Z <= x)%Z /\
  (x < n)%Z).

Axiom cardinal_below : forall (n:Z), ((0%Z <= n)%Z ->
  ((cardinal (below n)) = n)) /\ ((~ (0%Z <= n)%Z) ->
  ((cardinal (below n)) = 0%Z)).

Parameter succ: (set Z) -> (set Z).

Axiom succ_def : forall (s:(set Z)) (i:Z), (mem i (succ s)) <->
  ((1%Z <= i)%Z /\ (mem (i - 1%Z)%Z s)).

Parameter pred: (set Z) -> (set Z).

Axiom pred_def : forall (s:(set Z)) (i:Z), (mem i (pred s)) <->
  ((0%Z <= i)%Z /\ (mem (i + 1%Z)%Z s)).

(* Why3 assumption *)
Inductive ref (a:Type) {a_WT:WhyType a} :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Implicit Arguments mk_ref [[a] [a_WT]].

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a}(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.

Parameter n: Z.

(* Why3 assumption *)
Definition solution  := (map.Map.map Z Z).

(* Why3 assumption *)
Definition eq_prefix {a:Type} {a_WT:WhyType a}(t:(map.Map.map Z a))
  (u:(map.Map.map Z a)) (i:Z): Prop := forall (k:Z), ((0%Z <= k)%Z /\
  (k < i)%Z) -> ((map.Map.get t k) = (map.Map.get u k)).

(* Why3 assumption *)
Definition partial_solution(k:Z) (s:(map.Map.map Z Z)): Prop := forall (i:Z),
  ((0%Z <= i)%Z /\ (i < k)%Z) -> (((0%Z <= (map.Map.get s i))%Z /\
  ((map.Map.get s i) < n)%Z) /\ forall (j:Z), ((0%Z <= j)%Z /\ (j < i)%Z) ->
  ((~ ((map.Map.get s i) = (map.Map.get s j))) /\ ((~ (((map.Map.get s
  i) - (map.Map.get s j))%Z = (i - j)%Z)) /\ ~ (((map.Map.get s
  i) - (map.Map.get s j))%Z = (j - i)%Z)))).

Axiom partial_solution_eq_prefix : forall (u:(map.Map.map Z Z))
  (t:(map.Map.map Z Z)) (k:Z), (partial_solution k t) -> ((eq_prefix t u
  k) -> (partial_solution k u)).

(* Why3 assumption *)
Definition lt_sol(s1:(map.Map.map Z Z)) (s2:(map.Map.map Z Z)): Prop :=
  exists i:Z, ((0%Z <= i)%Z /\ (i < n)%Z) /\ ((eq_prefix s1 s2 i) /\
  ((map.Map.get s1 i) < (map.Map.get s2 i))%Z).

(* Why3 assumption *)
Definition solutions  := (map.Map.map Z (map.Map.map Z Z)).

(* Why3 assumption *)
Definition sorted(s:(map.Map.map Z (map.Map.map Z Z))) (a:Z) (b:Z): Prop :=
  forall (i:Z) (j:Z), (((a <= i)%Z /\ (i < j)%Z) /\ (j < b)%Z) ->
  (lt_sol (map.Map.get s i) (map.Map.get s j)).

Axiom no_duplicate : forall (s:(map.Map.map Z (map.Map.map Z Z))) (a:Z)
  (b:Z), (sorted s a b) -> forall (i:Z) (j:Z), (((a <= i)%Z /\ (i < j)%Z) /\
  (j < b)%Z) -> ~ (eq_prefix (map.Map.get s i) (map.Map.get s j) n).

(* Why3 goal *)
Theorem WP_parameter_t3 : forall (a:(set Z)) (b:(set Z)) (c:(set Z)),
  forall (s:Z) (sol:(map.Map.map Z (map.Map.map Z Z))) (k:Z)
  (col:(map.Map.map Z Z)), ((0%Z <= k)%Z /\ (((k + (cardinal a))%Z = n) /\
  ((0%Z <= s)%Z /\ ((forall (i:Z), (mem i a) <-> (((0%Z <= i)%Z /\
  (i < n)%Z) /\ forall (j:Z), ((0%Z <= j)%Z /\ (j < k)%Z) ->
  ~ ((map.Map.get col j) = i))) /\ ((forall (i:Z), (0%Z <= i)%Z -> ((~ (mem i
  b)) <-> forall (j:Z), ((0%Z <= j)%Z /\ (j < k)%Z) -> ~ ((map.Map.get col
  j) = ((i + j)%Z - k)%Z))) /\ ((forall (i:Z), (0%Z <= i)%Z -> ((~ (mem i
  c)) <-> forall (j:Z), ((0%Z <= j)%Z /\ (j < k)%Z) -> ~ ((map.Map.get col
  j) = ((i + k)%Z - j)%Z))) /\ (partial_solution k col))))))) ->
  ((~ (is_empty a)) -> forall (f:Z) (e:(set Z)) (s1:Z) (sol1:(map.Map.map Z
  (map.Map.map Z Z))) (k1:Z) (col1:(map.Map.map Z Z)), (((f = (s1 - s)%Z) /\
  (0%Z <= (s1 - s)%Z)%Z) /\ ((k1 = k) /\ ((subset e (diff (diff a b) c)) /\
  ((partial_solution k1 col1) /\ ((sorted sol1 s s1) /\ ((forall (i:Z) (j:Z),
  (mem i (diff (diff (diff a b) c) e)) -> ((mem j e) -> (i < j)%Z)) /\
  ((forall (t:(map.Map.map Z Z)), ((partial_solution n t) /\ ((eq_prefix col1
  t k1) /\ (mem (map.Map.get t k1) (diff (diff (diff a b) c) e)))) <->
  exists i:Z, ((s <= i)%Z /\ (i < s1)%Z) /\ (eq_prefix t (map.Map.get sol1 i)
  n)) /\ ((eq_prefix col col1 k1) /\ (eq_prefix sol sol1 s))))))))) ->
  ((~ (is_empty e)) -> forall (col2:(map.Map.map Z Z)),
  (col2 = (map.Map.set col1 k1 (min_elt e))) -> forall (k2:Z),
  (k2 = (k1 + 1%Z)%Z) -> forall (i:Z), (0%Z <= i)%Z -> ((forall (j:Z),
  ((0%Z <= j)%Z /\ (j < k2)%Z) -> ~ ((map.Map.get col2
  j) = ((i + j)%Z - k2)%Z)) -> ~ (mem i (succ (add (min_elt e) b)))))).
Proof.
intuition.
generalize (succ_def (add (min_elt e) b) i); intuition.
clear H23.
generalize (add_def1 (i-1)%Z (min_elt e) b); intuition.
apply H21 with k1; try omega.
subst col2; rewrite Map.Select_eq; omega.
destruct (H4 (i-1)%Z) as (_,h); try omega.
apply h; intuition.
apply (H21 j); try omega.
subst col2; rewrite Map.Select_neq; try omega.
rewrite <- H16; try omega.
Qed.


