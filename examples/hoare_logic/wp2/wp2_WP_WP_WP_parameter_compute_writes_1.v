(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

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
Inductive datatype  :=
  | Tint : datatype 
  | Tbool : datatype .

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .

(* Why3 assumption *)
Definition ident  := Z.

(* Why3 assumption *)
Inductive term  :=
  | Tconst : Z -> term 
  | Tvar : Z -> term 
  | Tderef : Z -> term 
  | Tbin : term -> operator -> term -> term .

(* Why3 assumption *)
Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla 
  | Flet : Z -> term -> fmla -> fmla 
  | Fforall : Z -> datatype -> fmla -> fmla .

(* Why3 assumption *)
Inductive value  :=
  | Vint : Z -> value 
  | Vbool : bool -> value .

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a -> b.
Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b -> (map a b).
Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (b:Type) (a:Type), b -> (map a b).
Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Definition env  := (map Z value).

Parameter eval_bin: value -> operator -> value -> value.

Axiom eval_bin_def : forall (x:value) (op:operator) (y:value), match (x,
  y) with
  | ((Vint x1), (Vint y1)) =>
      match op with
      | Oplus => ((eval_bin x op y) = (Vint (x1 + y1)%Z))
      | Ominus => ((eval_bin x op y) = (Vint (x1 - y1)%Z))
      | Omult => ((eval_bin x op y) = (Vint (x1 * y1)%Z))
      | Ole => ((x1 <= y1)%Z -> ((eval_bin x op y) = (Vbool true))) /\
          ((~ (x1 <= y1)%Z) -> ((eval_bin x op y) = (Vbool false)))
      end
  | (_, _) => ((eval_bin x op y) = (Vbool false))
  end.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint eval_term(sigma:(map Z value)) (pi:(map Z value))
  (t:term) {struct t}: value :=
  match t with
  | (Tconst n) => (Vint n)
  | (Tvar id) => (get pi id)
  | (Tderef id) => (get sigma id)
  | (Tbin t1 op t2) => (eval_bin (eval_term sigma pi t1) op (eval_term sigma
      pi t2))
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint eval_fmla(sigma:(map Z value)) (pi:(map Z value))
  (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term sigma pi t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla sigma pi f1) /\ (eval_fmla sigma pi f2)
  | (Fnot f1) => ~ (eval_fmla sigma pi f1)
  | (Fimplies f1 f2) => (eval_fmla sigma pi f1) -> (eval_fmla sigma pi f2)
  | (Flet x t f1) => (eval_fmla sigma (set pi x (eval_term sigma pi t)) f1)
  | (Fforall x Tint f1) => forall (n:Z), (eval_fmla sigma (set pi x (Vint n))
      f1)
  | (Fforall x Tbool f1) => forall (b:bool), (eval_fmla sigma (set pi x
      (Vbool b)) f1)
  end.
Unset Implicit Arguments.

Parameter subst_term: term -> Z -> Z -> term.

Axiom subst_term_def : forall (e:term) (r:Z) (v:Z),
  match e with
  | (Tconst _) => ((subst_term e r v) = e)
  | (Tvar _) => ((subst_term e r v) = e)
  | (Tderef x) => ((r = x) -> ((subst_term e r v) = (Tvar v))) /\
      ((~ (r = x)) -> ((subst_term e r v) = e))
  | (Tbin e1 op e2) => ((subst_term e r v) = (Tbin (subst_term e1 r v) op
      (subst_term e2 r v)))
  end.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint fresh_in_term(id:Z) (t:term) {struct t}: Prop :=
  match t with
  | (Tconst _) => True
  | (Tvar v) => ~ (id = v)
  | (Tderef _) => True
  | (Tbin t1 _ t2) => (fresh_in_term id t1) /\ (fresh_in_term id t2)
  end.
Unset Implicit Arguments.

Axiom eval_subst_term : forall (sigma:(map Z value)) (pi:(map Z value))
  (e:term) (x:Z) (v:Z), (fresh_in_term v e) -> ((eval_term sigma pi
  (subst_term e x v)) = (eval_term (set sigma x (get pi v)) pi e)).

Axiom eval_term_change_free : forall (t:term) (sigma:(map Z value)) (pi:(map
  Z value)) (id:Z) (v:value), (fresh_in_term id t) -> ((eval_term sigma
  (set pi id v) t) = (eval_term sigma pi t)).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint fresh_in_fmla(id:Z) (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm e) => (fresh_in_term id e)
  | ((Fand f1 f2)|(Fimplies f1 f2)) => (fresh_in_fmla id f1) /\
      (fresh_in_fmla id f2)
  | (Fnot f1) => (fresh_in_fmla id f1)
  | (Flet y t f1) => (~ (id = y)) /\ ((fresh_in_term id t) /\
      (fresh_in_fmla id f1))
  | (Fforall y ty f1) => (~ (id = y)) /\ (fresh_in_fmla id f1)
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint subst(f:fmla) (x:Z) (v:Z) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_term e x v))
  | (Fand f1 f2) => (Fand (subst f1 x v) (subst f2 x v))
  | (Fnot f1) => (Fnot (subst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x v) (subst f2 x v))
  | (Flet y t f1) => (Flet y t (subst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (subst f1 x v))
  end.
Unset Implicit Arguments.

Axiom eval_subst : forall (f:fmla) (sigma:(map Z value)) (pi:(map Z value))
  (x:Z) (v:Z), (fresh_in_fmla v f) -> ((eval_fmla sigma pi (subst f x v)) <->
  (eval_fmla (set sigma x (get pi v)) pi f)).

Axiom eval_swap : forall (f:fmla) (sigma:(map Z value)) (pi:(map Z value))
  (id1:Z) (id2:Z) (v1:value) (v2:value), (~ (id1 = id2)) -> ((eval_fmla sigma
  (set (set pi id1 v1) id2 v2) f) <-> (eval_fmla sigma (set (set pi id2 v2)
  id1 v1) f)).

Axiom eval_change_free : forall (f:fmla) (sigma:(map Z value)) (pi:(map Z
  value)) (id:Z) (v:value), (fresh_in_fmla id f) -> ((eval_fmla sigma (set pi
  id v) f) <-> (eval_fmla sigma pi f)).

(* Why3 assumption *)
Inductive stmt  :=
  | Sskip : stmt 
  | Sassign : Z -> term -> stmt 
  | Sseq : stmt -> stmt -> stmt 
  | Sif : term -> stmt -> stmt -> stmt 
  | Sassert : fmla -> stmt 
  | Swhile : term -> fmla -> stmt -> stmt .

Axiom check_skip : forall (s:stmt), (s = Sskip) \/ ~ (s = Sskip).

(* Why3 assumption *)
Inductive one_step : (map Z value) -> (map Z value) -> stmt -> (map Z value)
  -> (map Z value) -> stmt -> Prop :=
  | one_step_assign : forall (sigma:(map Z value)) (pi:(map Z value)) (x:Z)
      (e:term), (one_step sigma pi (Sassign x e) (set sigma x
      (eval_term sigma pi e)) pi Sskip)
  | one_step_seq : forall (sigma:(map Z value)) (pi:(map Z value))
      (sigmaqt:(map Z value)) (piqt:(map Z value)) (i1:stmt) (i1qt:stmt)
      (i2:stmt), (one_step sigma pi i1 sigmaqt piqt i1qt) -> (one_step sigma
      pi (Sseq i1 i2) sigmaqt piqt (Sseq i1qt i2))
  | one_step_seq_skip : forall (sigma:(map Z value)) (pi:(map Z value))
      (i:stmt), (one_step sigma pi (Sseq Sskip i) sigma pi i)
  | one_step_if_true : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (i1:stmt) (i2:stmt), ((eval_term sigma pi
      e) = (Vbool true)) -> (one_step sigma pi (Sif e i1 i2) sigma pi i1)
  | one_step_if_false : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (i1:stmt) (i2:stmt), ((eval_term sigma pi
      e) = (Vbool false)) -> (one_step sigma pi (Sif e i1 i2) sigma pi i2)
  | one_step_assert : forall (sigma:(map Z value)) (pi:(map Z value))
      (f:fmla), (eval_fmla sigma pi f) -> (one_step sigma pi (Sassert f)
      sigma pi Sskip)
  | one_step_while_true : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (inv:fmla) (i:stmt), (eval_fmla sigma pi inv) ->
      (((eval_term sigma pi e) = (Vbool true)) -> (one_step sigma pi
      (Swhile e inv i) sigma pi (Sseq i (Swhile e inv i))))
  | one_step_while_false : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (inv:fmla) (i:stmt), (eval_fmla sigma pi inv) ->
      (((eval_term sigma pi e) = (Vbool false)) -> (one_step sigma pi
      (Swhile e inv i) sigma pi Sskip)).

(* Why3 assumption *)
Inductive many_steps : (map Z value) -> (map Z value) -> stmt -> (map Z
  value) -> (map Z value) -> stmt -> Z -> Prop :=
  | many_steps_refl : forall (sigma:(map Z value)) (pi:(map Z value))
      (i:stmt), (many_steps sigma pi i sigma pi i 0%Z)
  | many_steps_trans : forall (sigma1:(map Z value)) (pi1:(map Z value))
      (sigma2:(map Z value)) (pi2:(map Z value)) (sigma3:(map Z value))
      (pi3:(map Z value)) (i1:stmt) (i2:stmt) (i3:stmt) (n:Z),
      (one_step sigma1 pi1 i1 sigma2 pi2 i2) -> ((many_steps sigma2 pi2 i2
      sigma3 pi3 i3 n) -> (many_steps sigma1 pi1 i1 sigma3 pi3 i3
      (n + 1%Z)%Z)).

Axiom steps_non_neg : forall (sigma1:(map Z value)) (pi1:(map Z value))
  (sigma2:(map Z value)) (pi2:(map Z value)) (i1:stmt) (i2:stmt) (n:Z),
  (many_steps sigma1 pi1 i1 sigma2 pi2 i2 n) -> (0%Z <= n)%Z.

Axiom many_steps_seq : forall (sigma1:(map Z value)) (pi1:(map Z value))
  (sigma3:(map Z value)) (pi3:(map Z value)) (i1:stmt) (i2:stmt) (n:Z),
  (many_steps sigma1 pi1 (Sseq i1 i2) sigma3 pi3 Sskip n) ->
  exists sigma2:(map Z value), exists pi2:(map Z value), exists n1:Z,
  exists n2:Z, (many_steps sigma1 pi1 i1 sigma2 pi2 Sskip n1) /\
  ((many_steps sigma2 pi2 i2 sigma3 pi3 Sskip n2) /\
  (n = ((1%Z + n1)%Z + n2)%Z)).

(* Why3 assumption *)
Definition valid_fmla(p:fmla): Prop := forall (sigma:(map Z value)) (pi:(map
  Z value)), (eval_fmla sigma pi p).

(* Why3 assumption *)
Definition valid_triple(p:fmla) (i:stmt) (q:fmla): Prop := forall (sigma:(map
  Z value)) (pi:(map Z value)), (eval_fmla sigma pi p) ->
  forall (sigmaqt:(map Z value)) (piqt:(map Z value)) (n:Z),
  (many_steps sigma pi i sigmaqt piqt Sskip n) -> (eval_fmla sigmaqt piqt q).

Axiom skip_rule : forall (q:fmla), (valid_triple q Sskip q).

Axiom assign_rule : forall (q:fmla) (x:Z) (id:Z) (e:term), (fresh_in_fmla id
  q) -> (valid_triple (Flet id e (subst q x id)) (Sassign x e) q).

Axiom seq_rule : forall (p:fmla) (q:fmla) (r:fmla) (i1:stmt) (i2:stmt),
  ((valid_triple p i1 r) /\ (valid_triple r i2 q)) -> (valid_triple p
  (Sseq i1 i2) q).

Axiom if_rule : forall (e:term) (p:fmla) (q:fmla) (i1:stmt) (i2:stmt),
  ((valid_triple (Fand p (Fterm e)) i1 q) /\ (valid_triple (Fand p
  (Fnot (Fterm e))) i2 q)) -> (valid_triple p (Sif e i1 i2) q).

Axiom assert_rule : forall (f:fmla) (p:fmla), (valid_fmla (Fimplies p f)) ->
  (valid_triple p (Sassert f) p).

Axiom assert_rule_ext : forall (f:fmla) (p:fmla), (valid_triple (Fimplies f
  p) (Sassert f) p).

Axiom while_rule : forall (e:term) (inv:fmla) (i:stmt),
  (valid_triple (Fand (Fterm e) inv) i inv) -> (valid_triple inv (Swhile e
  inv i) (Fand (Fnot (Fterm e)) inv)).

Axiom while_rule_ext : forall (e:term) (inv:fmla) (invqt:fmla) (i:stmt),
  (valid_fmla (Fimplies invqt inv)) -> ((valid_triple (Fand (Fterm e) invqt)
  i invqt) -> (valid_triple invqt (Swhile e inv i) (Fand (Fnot (Fterm e))
  invqt))).

Axiom consequence_rule : forall (p:fmla) (pqt:fmla) (q:fmla) (qqt:fmla)
  (i:stmt), (valid_fmla (Fimplies pqt p)) -> ((valid_triple p i q) ->
  ((valid_fmla (Fimplies q qqt)) -> (valid_triple pqt i qqt))).

Parameter set1 : forall (a:Type), Type.

Parameter mem: forall (a:Type), a -> (set1 a) -> Prop.
Implicit Arguments mem.

(* Why3 assumption *)
Definition infix_eqeq (a:Type)(s1:(set1 a)) (s2:(set1 a)): Prop :=
  forall (x:a), (mem x s1) <-> (mem x s2).
Implicit Arguments infix_eqeq.

Axiom extensionality : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)),
  (infix_eqeq s1 s2) -> (s1 = s2).

(* Why3 assumption *)
Definition subset (a:Type)(s1:(set1 a)) (s2:(set1 a)): Prop := forall (x:a),
  (mem x s1) -> (mem x s2).
Implicit Arguments subset.

Axiom subset_trans : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a))
  (s3:(set1 a)), (subset s1 s2) -> ((subset s2 s3) -> (subset s1 s3)).

Parameter empty: forall (a:Type), (set1 a).
Set Contextual Implicit.
Implicit Arguments empty.
Unset Contextual Implicit.

(* Why3 assumption *)
Definition is_empty (a:Type)(s:(set1 a)): Prop := forall (x:a), ~ (mem x s).
Implicit Arguments is_empty.

Axiom empty_def1 : forall (a:Type), (is_empty (empty :(set1 a))).

Parameter add: forall (a:Type), a -> (set1 a) -> (set1 a).
Implicit Arguments add.

Axiom add_def1 : forall (a:Type), forall (x:a) (y:a), forall (s:(set1 a)),
  (mem x (add y s)) <-> ((x = y) \/ (mem x s)).

Parameter remove: forall (a:Type), a -> (set1 a) -> (set1 a).
Implicit Arguments remove.

Axiom remove_def1 : forall (a:Type), forall (x:a) (y:a) (s:(set1 a)), (mem x
  (remove y s)) <-> ((~ (x = y)) /\ (mem x s)).

Axiom subset_remove : forall (a:Type), forall (x:a) (s:(set1 a)),
  (subset (remove x s) s).

Parameter union: forall (a:Type), (set1 a) -> (set1 a) -> (set1 a).
Implicit Arguments union.

Axiom union_def1 : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)) (x:a),
  (mem x (union s1 s2)) <-> ((mem x s1) \/ (mem x s2)).

Parameter inter: forall (a:Type), (set1 a) -> (set1 a) -> (set1 a).
Implicit Arguments inter.

Axiom inter_def1 : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)) (x:a),
  (mem x (inter s1 s2)) <-> ((mem x s1) /\ (mem x s2)).

Parameter diff: forall (a:Type), (set1 a) -> (set1 a) -> (set1 a).
Implicit Arguments diff.

Axiom diff_def1 : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)) (x:a),
  (mem x (diff s1 s2)) <-> ((mem x s1) /\ ~ (mem x s2)).

Axiom subset_diff : forall (a:Type), forall (s1:(set1 a)) (s2:(set1 a)),
  (subset (diff s1 s2) s1).

Parameter all: forall (a:Type), (set1 a).
Set Contextual Implicit.
Implicit Arguments all.
Unset Contextual Implicit.

Axiom all_def : forall (a:Type), forall (x:a), (mem x (all :(set1 a))).

(* Why3 assumption *)
Definition assigns(sigma:(map Z value)) (a:(set1 Z)) (sigmaqt:(map Z
  value)): Prop := forall (i:Z), (~ (mem i a)) -> ((get sigma
  i) = (get sigmaqt i)).

Axiom assigns_empty : forall (sigma:(map Z value)), (assigns sigma
  (empty :(set1 Z)) sigma).

Axiom assigns_union_left : forall (sigma:(map Z value)) (sigmaqt:(map Z
  value)) (s1:(set1 Z)) (s2:(set1 Z)), (assigns sigma s1 sigmaqt) ->
  (assigns sigma (union s1 s2) sigmaqt).

Axiom assigns_union_right : forall (sigma:(map Z value)) (sigmaqt:(map Z
  value)) (s1:(set1 Z)) (s2:(set1 Z)), (assigns sigma s2 sigmaqt) ->
  (assigns sigma (union s1 s2) sigmaqt).

(* Why3 goal *)
Theorem WP_parameter_compute_writes : forall (s:stmt),
  match s with
  | Sskip => True
  | (Sassign i _) => forall (sigma:(map Z value)) (pi:(map Z value))
      (sigmaqt:(map Z value)) (piqt:(map Z value)) (n:Z), (many_steps sigma
      pi s sigmaqt piqt Sskip n) -> (assigns sigma (add i (empty :(set1 Z)))
      sigmaqt)
  | (Sseq s1 s2) => True
  | (Sif _ s1 s2) => True
  | (Swhile _ _ s1) => True
  | (Sassert _) => True
  end.
destruct s; intuition.
red; intros.
inversion H; subst; clear H.
inversion H1; subst; clear H1.
inversion H2; subst; clear H2.
rewrite add_def1 in H0.
rewrite Select_neq; auto.
inversion H.
Qed.


