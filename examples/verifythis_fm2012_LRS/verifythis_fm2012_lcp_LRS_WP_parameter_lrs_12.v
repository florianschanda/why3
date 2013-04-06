(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require map.Map.
Require map.MapPermut.

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
Definition injective (a:(map.Map.map Z Z)) (n:Z): Prop := forall (i:Z) (j:Z),
  ((0%Z <= i)%Z /\ (i < n)%Z) -> (((0%Z <= j)%Z /\ (j < n)%Z) ->
  ((~ (i = j)) -> ~ ((map.Map.get a i) = (map.Map.get a j)))).

(* Why3 assumption *)
Definition surjective (a:(map.Map.map Z Z)) (n:Z): Prop := forall (i:Z),
  ((0%Z <= i)%Z /\ (i < n)%Z) -> exists j:Z, ((0%Z <= j)%Z /\ (j < n)%Z) /\
  ((map.Map.get a j) = i).

(* Why3 assumption *)
Definition range (a:(map.Map.map Z Z)) (n:Z): Prop := forall (i:Z),
  ((0%Z <= i)%Z /\ (i < n)%Z) -> ((0%Z <= (map.Map.get a i))%Z /\
  ((map.Map.get a i) < n)%Z).

Axiom injective_surjective : forall (a:(map.Map.map Z Z)) (n:Z), (injective a
  n) -> ((range a n) -> (surjective a n)).

(* Why3 assumption *)
Definition is_common_prefix (a:(array Z)) (x:Z) (y:Z) (l:Z): Prop :=
  (0%Z <= l)%Z /\ (((x + l)%Z <= (length a))%Z /\
  (((y + l)%Z <= (length a))%Z /\ forall (i:Z), ((0%Z <= i)%Z /\
  (i < l)%Z) -> ((get a (x + i)%Z) = (get a (y + i)%Z)))).

Axiom not_common_prefix_if_last_char_are_different : forall (a:(array Z))
  (x:Z) (y:Z) (l:Z), ((0%Z <= l)%Z /\ (((x + l)%Z < (length a))%Z /\
  (((y + l)%Z < (length a))%Z /\ ~ ((get a (x + l)%Z) = (get a
  (y + l)%Z))))) -> ~ (is_common_prefix a x y (l + 1%Z)%Z).

(* Why3 assumption *)
Definition is_longest_common_prefix (a:(array Z)) (x:Z) (y:Z) (l:Z): Prop :=
  (is_common_prefix a x y l) /\ forall (m:Z), (l < m)%Z ->
  ~ (is_common_prefix a x y m).

Axiom longest_common_prefix_succ : forall (a:(array Z)) (x:Z) (y:Z) (l:Z),
  ((is_common_prefix a x y l) /\ ~ (is_common_prefix a x y (l + 1%Z)%Z)) ->
  (is_longest_common_prefix a x y l).

(* Why3 assumption *)
Definition lt (a:(array Z)) (x:Z) (y:Z): Prop := let n := (length a) in
  (((0%Z <= x)%Z /\ (x <= n)%Z) /\ (((0%Z <= y)%Z /\ (y <= n)%Z) /\
  exists l:Z, (is_common_prefix a x y l) /\ (((y + l)%Z < n)%Z /\
  (((x + l)%Z = n) \/ ((get a (x + l)%Z) < (get a (y + l)%Z))%Z)))).

(* Why3 assumption *)
Definition range1 (a:(array Z)): Prop := (range (elts a) (length a)).

(* Why3 assumption *)
Definition exchange {a:Type} {a_WT:WhyType a} (a1:(array a)) (a2:(array a))
  (i:Z) (j:Z): Prop := (map.MapPermut.exchange (elts a1) (elts a2) i j).

(* Why3 assumption *)
Definition permut_sub {a:Type} {a_WT:WhyType a} (a1:(array a)) (a2:(array a))
  (l:Z) (u:Z): Prop := (map.MapPermut.permut_sub (elts a1) (elts a2) l u).

(* Why3 assumption *)
Definition permut {a:Type} {a_WT:WhyType a} (a1:(array a)) (a2:(array
  a)): Prop := ((length a1) = (length a2)) /\ (map.MapPermut.permut_sub
  (elts a1) (elts a2) 0%Z (length a1)).

Axiom exchange_permut : forall {a:Type} {a_WT:WhyType a}, forall (a1:(array
  a)) (a2:(array a)) (i:Z) (j:Z), (exchange a1 a2 i j) ->
  (((length a1) = (length a2)) -> (((0%Z <= i)%Z /\ (i < (length a1))%Z) ->
  (((0%Z <= j)%Z /\ (j < (length a1))%Z) -> (permut a1 a2)))).

Axiom permut_sym : forall {a:Type} {a_WT:WhyType a}, forall (a1:(array a))
  (a2:(array a)), (permut a1 a2) -> (permut a2 a1).

Axiom permut_trans : forall {a:Type} {a_WT:WhyType a}, forall (a1:(array a))
  (a2:(array a)) (a3:(array a)), (permut a1 a2) -> ((permut a2 a3) -> (permut
  a1 a3)).

(* Why3 assumption *)
Definition map_eq_sub {a:Type} {a_WT:WhyType a} (a1:(map.Map.map Z a))
  (a2:(map.Map.map Z a)) (l:Z) (u:Z): Prop := forall (i:Z), ((l <= i)%Z /\
  (i < u)%Z) -> ((map.Map.get a1 i) = (map.Map.get a2 i)).

(* Why3 assumption *)
Definition array_eq_sub {a:Type} {a_WT:WhyType a} (a1:(array a)) (a2:(array
  a)) (l:Z) (u:Z): Prop := (map_eq_sub (elts a1) (elts a2) l u).

(* Why3 assumption *)
Definition array_eq {a:Type} {a_WT:WhyType a} (a1:(array a)) (a2:(array
  a)): Prop := ((length a1) = (length a2)) /\ (array_eq_sub a1 a2 0%Z
  (length a1)).

Axiom array_eq_sub_permut : forall {a:Type} {a_WT:WhyType a},
  forall (a1:(array a)) (a2:(array a)) (l:Z) (u:Z), (array_eq_sub a1 a2 l
  u) -> (permut_sub a1 a2 l u).

Axiom array_eq_permut : forall {a:Type} {a_WT:WhyType a}, forall (a1:(array
  a)) (a2:(array a)), (array_eq a1 a2) -> (permut a1 a2).

(* Why3 assumption *)
Definition le (a:(array Z)) (x:Z) (y:Z): Prop := (x = y) \/ (lt a x y).

Axiom lcp_same_index : forall (a:(array Z)) (x:Z), ((0%Z <= x)%Z /\
  (x <= (length a))%Z) -> (is_longest_common_prefix a x x
  ((length a) - x)%Z).

Axiom le_trans : forall (a:(array Z)) (x:Z) (y:Z) (z:Z), ((le a x y) /\ (le a
  y z)) -> (le a x z).

(* Why3 assumption *)
Definition sorted_sub (a:(array Z)) (data:(map.Map.map Z Z)) (l:Z)
  (u:Z): Prop := forall (i1:Z) (i2:Z), (((l <= i1)%Z /\ (i1 <= i2)%Z) /\
  (i2 < u)%Z) -> (le a (map.Map.get data i1) (map.Map.get data i2)).

(* Why3 assumption *)
Definition sorted (a:(array Z)) (data:(array Z)): Prop := (sorted_sub a
  (elts data) 0%Z (length data)).

(* Why3 assumption *)
Definition permutation (m:(map.Map.map Z Z)) (u:Z): Prop := (range m u) /\
  (injective m u).

(* Why3 assumption *)
Inductive suffixArray :=
  | mk_suffixArray : (array Z) -> (array Z) -> suffixArray.
Axiom suffixArray_WhyType : WhyType suffixArray.
Existing Instance suffixArray_WhyType.

(* Why3 assumption *)
Definition suffixes (v:suffixArray): (array Z) :=
  match v with
  | (mk_suffixArray x x1) => x1
  end.

(* Why3 assumption *)
Definition values (v:suffixArray): (array Z) :=
  match v with
  | (mk_suffixArray x x1) => x
  end.

Axiom permut_permutation : forall (a1:(array Z)) (a2:(array Z)), ((permut a1
  a2) /\ (permutation (elts a1) (length a1))) -> (permutation (elts a2)
  (length a2)).

Axiom lcp_sym : forall (a:(array Z)) (x:Z) (y:Z) (l:Z), (((0%Z <= x)%Z /\
  (x <= (length a))%Z) /\ ((0%Z <= y)%Z /\ (y <= (length a))%Z)) ->
  ((is_longest_common_prefix a x y l) -> (is_longest_common_prefix a y x l)).

Axiom le_le_common_prefix : forall (a:(array Z)) (x:Z) (y:Z) (z:Z) (l:Z),
  ((le a x y) /\ (le a y z)) -> ((is_common_prefix a x z l) ->
  (is_common_prefix a y z l)).

Axiom le_le_longest_common_prefix : forall (a:(array Z)) (x:Z) (y:Z) (z:Z)
  (l:Z) (m:Z), ((le a x y) /\ (le a y z)) -> (((is_longest_common_prefix a x
  z l) /\ (is_longest_common_prefix a y z m)) -> (l <= m)%Z).

Require Import Why3.
Ltac ae := why3 "alt-ergo" timelimit 3.

(* Why3 goal *)
Theorem WP_parameter_lrs : forall (a:Z), forall (a1:(map.Map.map Z Z)),
  let a2 := (mk_array a a1) in (((0%Z <= a)%Z /\ (0%Z < a)%Z) ->
  forall (sa:Z) (sa1:(map.Map.map Z Z)) (sa2:Z) (sa3:(map.Map.map Z Z)),
  ((((sa = sa2) /\ ((permutation sa3 sa2) /\ (sorted_sub (mk_array sa sa1)
  sa3 0%Z sa2))) /\ ((0%Z <= sa)%Z /\ (0%Z <= sa2)%Z)) /\ ((sa = a) /\
  (sa1 = a1))) -> forall (solStart:Z), (solStart = 0%Z) ->
  forall (solLength:Z), (solLength = 0%Z) -> forall (solStart2:Z),
  (solStart2 = a) -> let o := (a - 1%Z)%Z in ((1%Z <= o)%Z ->
  forall (solStart21:Z) (solLength1:Z) (solStart1:Z),
  (((((0%Z <= solLength1)%Z /\ (solLength1 <= a)%Z) /\
  ((0%Z <= solStart1)%Z /\ (solStart1 <= a)%Z)) /\ (((0%Z <= solStart21)%Z /\
  (solStart21 <= a)%Z) /\ ((~ (solStart1 = solStart21)) /\
  (is_longest_common_prefix a2 solStart1 solStart21 solLength1)))) /\
  forall (j:Z) (k:Z) (l:Z), ((((0%Z <= j)%Z /\ (j < k)%Z) /\
  (k < (o + 1%Z)%Z)%Z) /\ (is_longest_common_prefix a2 (map.Map.get sa3 j)
  (map.Map.get sa3 k) l)) -> (l <= solLength1)%Z) -> ((forall (j:Z) (k:Z)
  (l:Z), (((0%Z <= j)%Z /\ (j < a)%Z) /\ (((0%Z <= k)%Z /\ (k < a)%Z) /\
  ((~ (j = k)) /\ (is_longest_common_prefix a2 (map.Map.get sa3 j)
  (map.Map.get sa3 k) l)))) -> (l <= solLength1)%Z) -> ((forall (x:Z) (y:Z),
  (((0%Z <= x)%Z /\ (x < y)%Z) /\ (y < a)%Z) -> exists j:Z, exists k:Z,
  ((0%Z <= j)%Z /\ (j < a)%Z) /\ (((0%Z <= k)%Z /\ (k < a)%Z) /\
  ((~ (j = k)) /\ ((x = (map.Map.get sa3 j)) /\ (y = (map.Map.get sa3
  k)))))) -> forall (x:Z) (y:Z) (l:Z), ((((0%Z <= x)%Z /\ (x < y)%Z) /\
  (y < a)%Z) /\ (is_longest_common_prefix a2 x y l)) ->
  (l <= solLength1)%Z)))).
intros a a1 a2 (h1,h2) sa sa1 sa2 sa3
        (((h3,(h4,h5)),(h6,h7)),(h8,h9)) solStart h10 solLength h11 solStart2
        h12 o h13 solStart21 solLength1 solStart1
        ((((h14,h15),(h16,h17)),((h18,h19),(h20,h21))),h22) h23 h24 x y l
        (h25,h28).
elim (h24 _ _ h25).
ae.
Qed.


