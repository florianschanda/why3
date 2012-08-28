(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.
Require int.MinMax.

(* Why3 assumption *)
Inductive list (a:Type) :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Implicit Arguments Nil [[a]].
Implicit Arguments Cons [[a]].

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
Inductive datatype  :=
  | TYunit : datatype 
  | TYint : datatype 
  | TYbool : datatype .

(* Why3 assumption *)
Inductive value  :=
  | Vvoid : value 
  | Vint : Z -> value 
  | Vbool : bool -> value .

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .

Parameter mident : Type.

(* Why3 assumption *)
Inductive ident  :=
  | mk_ident : Z -> ident .

(* Why3 assumption *)
Definition ident_index(v:ident): Z := match v with
  | (mk_ident x) => x
  end.

Parameter result: ident.

(* Why3 assumption *)
Inductive term_node  :=
  | Tvalue : value -> term_node 
  | Tvar : ident -> term_node 
  | Tderef : mident -> term_node 
  | Tbin : term -> operator -> term -> term_node .

(* Why3 assumption *)
Inductive term  :=
  | mk_term : term_node -> Z -> term .

(* Why3 assumption *)
Definition term_maxvar(v:term): Z := match v with
  | (mk_term x x1) => x1
  end.

(* Why3 assumption *)
Definition term_node1(v:term): term_node :=
  match v with
  | (mk_term x x1) => x
  end.

(* Why3 assumption *)
Fixpoint var_occurs_in_term(x:ident) (t:term) {struct t}: Prop :=
  match t with
  | (mk_term (Tvalue _) _) => False
  | (mk_term (Tvar i) _) => (x = i)
  | (mk_term (Tderef _) _) => False
  | (mk_term (Tbin t1 _ t2) _) => (var_occurs_in_term x t1) \/
      (var_occurs_in_term x t2)
  end.

(* Why3 assumption *)
Definition term_inv(t:term): Prop := forall (x:ident), (var_occurs_in_term x
  t) -> ((ident_index x) <= (term_maxvar t))%Z.

(* Why3 assumption *)
Definition mk_tvalue(v:value): term := (mk_term (Tvalue v) (-1%Z)%Z).

Axiom mk_tvalue_inv : forall (v:value), (term_inv (mk_tvalue v)).

(* Why3 assumption *)
Definition mk_tvar(i:ident): term := (mk_term (Tvar i) (ident_index i)).

Axiom mk_tvar_inv : forall (i:ident), (term_inv (mk_tvar i)).

(* Why3 assumption *)
Definition mk_tderef(r:mident): term := (mk_term (Tderef r) (-1%Z)%Z).

Axiom mk_tderef_inv : forall (r:mident), (term_inv (mk_tderef r)).

(* Why3 assumption *)
Definition mk_tbin(t1:term) (o:operator) (t2:term): term := (mk_term (Tbin t1
  o t2) (Zmax (term_maxvar t1) (term_maxvar t2))).

Axiom mk_tbin_inv : forall (t1:term) (t2:term) (o:operator),
  ((term_inv t1) /\ (term_inv t2)) -> (term_inv (mk_tbin t1 o t2)).

(* Why3 assumption *)
Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla 
  | Flet : ident -> term -> fmla -> fmla 
  | Fforall : ident -> datatype -> fmla -> fmla .

(* Why3 assumption *)
Inductive expr  :=
  | Evalue : value -> expr 
  | Ebin : expr -> operator -> expr -> expr 
  | Evar : ident -> expr 
  | Ederef : mident -> expr 
  | Eassign : mident -> expr -> expr 
  | Eseq : expr -> expr -> expr 
  | Elet : ident -> expr -> expr -> expr 
  | Eif : expr -> expr -> expr -> expr 
  | Eassert : fmla -> expr 
  | Ewhile : expr -> fmla -> expr -> expr .

(* Why3 assumption *)
Definition type_value(v:value): datatype :=
  match v with
  | Vvoid => TYunit
  | (Vint int1) => TYint
  | (Vbool bool1) => TYbool
  end.

(* Why3 assumption *)
Inductive type_operator : operator -> datatype -> datatype
  -> datatype -> Prop :=
  | Type_plus : (type_operator Oplus TYint TYint TYint)
  | Type_minus : (type_operator Ominus TYint TYint TYint)
  | Type_mult : (type_operator Omult TYint TYint TYint)
  | Type_le : (type_operator Ole TYint TYint TYbool).

(* Why3 assumption *)
Definition type_stack  := (list (ident* datatype)%type).

Parameter get_vartype: ident -> (list (ident* datatype)%type) -> datatype.

Axiom get_vartype_def : forall (i:ident) (pi:(list (ident* datatype)%type)),
  match pi with
  | Nil => ((get_vartype i pi) = TYunit)
  | (Cons (x, ty) r) => ((x = i) -> ((get_vartype i pi) = ty)) /\
      ((~ (x = i)) -> ((get_vartype i pi) = (get_vartype i r)))
  end.

(* Why3 assumption *)
Definition type_env  := (map mident datatype).

(* Why3 assumption *)
Inductive type_term : (map mident datatype) -> (list (ident* datatype)%type)
  -> term -> datatype -> Prop :=
  | Type_value : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:value) (m:Z), (type_term sigma pi
      (mk_term (Tvalue v) m) (type_value v))
  | Type_var : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:ident) (m:Z) (ty:datatype), ((get_vartype v
      pi) = ty) -> (type_term sigma pi (mk_term (Tvar v) m) ty)
  | Type_deref : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:mident) (m:Z) (ty:datatype), ((get sigma
      v) = ty) -> (type_term sigma pi (mk_term (Tderef v) m) ty)
  | Type_bin : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t1:term) (t2:term) (op:operator) (m:Z) (ty1:datatype)
      (ty2:datatype) (ty:datatype), (type_term sigma pi t1 ty1) ->
      ((type_term sigma pi t2 ty2) -> ((type_operator op ty1 ty2 ty) ->
      (type_term sigma pi (mk_term (Tbin t1 op t2) m) ty))).

(* Why3 assumption *)
Inductive type_fmla : (map mident datatype) -> (list (ident* datatype)%type)
  -> fmla -> Prop :=
  | Type_term : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t:term), (type_term sigma pi t TYbool) ->
      (type_fmla sigma pi (Fterm t))
  | Type_conj : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f1:fmla) (f2:fmla), (type_fmla sigma pi f1) ->
      ((type_fmla sigma pi f2) -> (type_fmla sigma pi (Fand f1 f2)))
  | Type_neg : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f:fmla), (type_fmla sigma pi f) -> (type_fmla sigma
      pi (Fnot f))
  | Type_implies : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f1:fmla) (f2:fmla), (type_fmla sigma pi f1) ->
      ((type_fmla sigma pi f2) -> (type_fmla sigma pi (Fimplies f1 f2)))
  | Type_let : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (t:term) (f:fmla) (ty:datatype),
      (type_term sigma pi t ty) -> ((type_fmla sigma (Cons (x, ty) pi) f) ->
      (type_fmla sigma pi (Flet x t f)))
  | Type_forall1 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYint)
      pi) f) -> (type_fmla sigma pi (Fforall x TYint f))
  | Type_forall2 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYbool)
      pi) f) -> (type_fmla sigma pi (Fforall x TYbool f))
  | Type_forall3 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYunit)
      pi) f) -> (type_fmla sigma pi (Fforall x TYunit f)).

(* Why3 assumption *)
Inductive type_expr : (map mident datatype) -> (list (ident* datatype)%type)
  -> expr -> datatype -> Prop :=
  | Type_evalue : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:value), (type_expr sigma pi (Evalue v)
      (type_value v))
  | Type_evar : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:ident) (ty:datatype), ((get_vartype v pi) = ty) ->
      (type_expr sigma pi (Evar v) ty)
  | Type_ederef : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:mident) (ty:datatype), ((get sigma v) = ty) ->
      (type_expr sigma pi (Ederef v) ty)
  | Type_ebin : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (e1:expr) (e2:expr) (op:operator) (ty1:datatype)
      (ty2:datatype) (ty:datatype), (type_expr sigma pi e1 ty1) ->
      ((type_expr sigma pi e2 ty2) -> ((type_operator op ty1 ty2 ty) ->
      (type_expr sigma pi (Ebin e1 op e2) ty)))
  | Type_eseq : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (e1:expr) (e2:expr) (ty:datatype), (type_expr sigma pi
      e1 TYunit) -> ((type_expr sigma pi e2 ty) -> (type_expr sigma pi
      (Eseq e1 e2) ty))
  | Type_eassigns : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:mident) (e:expr) (ty:datatype), ((get sigma
      x) = ty) -> ((type_expr sigma pi e ty) -> (type_expr sigma pi
      (Eassign x e) TYunit))
  | Type_elet : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (e1:expr) (e2:expr) (ty1:datatype)
      (ty2:datatype), (type_expr sigma pi e1 ty1) -> ((type_expr sigma
      (Cons (x, ty2) pi) e2 ty2) -> (type_expr sigma pi (Elet x e1 e2) ty2))
  | Type_eif : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (e1:expr) (e2:expr) (e3:expr) (ty:datatype),
      (type_expr sigma pi e1 TYbool) -> ((type_expr sigma pi e2 ty) ->
      ((type_expr sigma pi e3 ty) -> (type_expr sigma pi (Eif e1 e2 e3) ty)))
  | Type_eassert : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (p:fmla), (type_fmla sigma pi p) -> (type_expr sigma
      pi (Eassert p) TYbool)
  | Type_ewhile : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (guard:expr) (body:expr) (inv:fmla), (type_fmla sigma
      pi inv) -> ((type_expr sigma pi guard TYbool) -> ((type_expr sigma pi
      body TYunit) -> (type_expr sigma pi (Ewhile guard inv body) TYunit))).

(* Why3 assumption *)
Definition env  := (map mident value).

(* Why3 assumption *)
Definition stack  := (list (ident* value)%type).

Parameter get_stack: ident -> (list (ident* value)%type) -> value.

Axiom get_stack_def : forall (i:ident) (pi:(list (ident* value)%type)),
  match pi with
  | Nil => ((get_stack i pi) = Vvoid)
  | (Cons (x, v) r) => ((x = i) -> ((get_stack i pi) = v)) /\ ((~ (x = i)) ->
      ((get_stack i pi) = (get_stack i r)))
  end.

Axiom get_stack_eq : forall (x:ident) (v:value) (r:(list (ident*
  value)%type)), ((get_stack x (Cons (x, v) r)) = v).

Axiom get_stack_neq : forall (x:ident) (i:ident) (v:value) (r:(list (ident*
  value)%type)), (~ (x = i)) -> ((get_stack i (Cons (x, v) r)) = (get_stack i
  r)).

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
  | (_, _) => ((eval_bin x op y) = Vvoid)
  end.

(* Why3 assumption *)
Fixpoint eval_term(sigma:(map mident value)) (pi:(list (ident* value)%type))
  (t:term) {struct t}: value :=
  match t with
  | (mk_term (Tvalue v) _) => v
  | (mk_term (Tvar id) _) => (get_stack id pi)
  | (mk_term (Tderef id) _) => (get sigma id)
  | (mk_term (Tbin t1 op t2) _) => (eval_bin (eval_term sigma pi t1) op
      (eval_term sigma pi t2))
  end.

(* Why3 assumption *)
Fixpoint eval_fmla(sigma:(map mident value)) (pi:(list (ident* value)%type))
  (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term sigma pi t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla sigma pi f1) /\ (eval_fmla sigma pi f2)
  | (Fnot f1) => ~ (eval_fmla sigma pi f1)
  | (Fimplies f1 f2) => (eval_fmla sigma pi f1) -> (eval_fmla sigma pi f2)
  | (Flet x t f1) => (eval_fmla sigma (Cons (x, (eval_term sigma pi t)) pi)
      f1)
  | (Fforall x TYint f1) => forall (n:Z), (eval_fmla sigma (Cons (x,
      (Vint n)) pi) f1)
  | (Fforall x TYbool f1) => forall (b:bool), (eval_fmla sigma (Cons (x,
      (Vbool b)) pi) f1)
  | (Fforall x TYunit f1) => (eval_fmla sigma (Cons (x, Vvoid) pi) f1)
  end.

Parameter msubst_term: term -> mident -> ident -> term.

Axiom msubst_term_def : forall (t:term) (r:mident) (v:ident),
  match t with
  | (mk_term ((Tvalue _)|(Tvar _)) _) => ((msubst_term t r v) = t)
  | (mk_term (Tderef x) _) => ((r = x) -> ((msubst_term t r
      v) = (mk_tvar v))) /\ ((~ (r = x)) -> ((msubst_term t r v) = t))
  | (mk_term (Tbin t1 op t2) _) => ((msubst_term t r
      v) = (mk_tbin (msubst_term t1 r v) op (msubst_term t2 r v)))
  end.

Parameter subst_term: term -> ident -> ident -> term.

Axiom subst_term_def : forall (t:term) (r:ident) (v:ident),
  match t with
  | (mk_term ((Tvalue _)|(Tderef _)) _) => ((subst_term t r v) = t)
  | (mk_term (Tvar x) _) => ((r = x) -> ((subst_term t r
      v) = (mk_tvar v))) /\ ((~ (r = x)) -> ((subst_term t r v) = t))
  | (mk_term (Tbin t1 op t2) _) => ((subst_term t r
      v) = (mk_tbin (subst_term t1 r v) op (subst_term t2 r v)))
  end.

(* Why3 assumption *)
Definition fresh_in_term(id:ident) (t:term): Prop :=
  ((term_maxvar t) < (ident_index id))%Z.

Axiom eval_msubst_term : forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)) (e:term) (x:mident) (v:ident), (fresh_in_term v e) ->
  ((eval_term sigma pi (msubst_term e x v)) = (eval_term (set sigma x
  (get_stack v pi)) pi e)).

Axiom eval_subst_term : forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)) (e:term) (x:ident) (v:ident), (fresh_in_term v e) ->
  ((eval_term sigma pi (subst_term e x v)) = (eval_term sigma (Cons (x,
  (get_stack v pi)) pi) e)).

Axiom eval_term_change_free : forall (t:term) (sigma:(map mident value))
  (pi:(list (ident* value)%type)) (id:ident) (v:value), (fresh_in_term id
  t) -> ((eval_term sigma (Cons (id, v) pi) t) = (eval_term sigma pi t)).

(* Why3 assumption *)
Fixpoint fresh_in_fmla(id:ident) (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm e) => (fresh_in_term id e)
  | ((Fand f1 f2)|(Fimplies f1 f2)) => (fresh_in_fmla id f1) /\
      (fresh_in_fmla id f2)
  | (Fnot f1) => (fresh_in_fmla id f1)
  | (Flet y t f1) => (~ (id = y)) /\ ((fresh_in_term id t) /\
      (fresh_in_fmla id f1))
  | (Fforall y ty f1) => (~ (id = y)) /\ (fresh_in_fmla id f1)
  end.

(* Why3 assumption *)
Fixpoint subst(f:fmla) (x:ident) (v:ident) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_term e x v))
  | (Fand f1 f2) => (Fand (subst f1 x v) (subst f2 x v))
  | (Fnot f1) => (Fnot (subst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x v) (subst f2 x v))
  | (Flet y t f1) => (Flet y (subst_term t x v) (subst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (subst f1 x v))
  end.

(* Why3 assumption *)
Fixpoint msubst(f:fmla) (x:mident) (v:ident) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (msubst_term e x v))
  | (Fand f1 f2) => (Fand (msubst f1 x v) (msubst f2 x v))
  | (Fnot f1) => (Fnot (msubst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (msubst f1 x v) (msubst f2 x v))
  | (Flet y t f1) => (Flet y (msubst_term t x v) (msubst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (msubst f1 x v))
  end.

(* Why3 goal *)
Theorem subst_fresh : forall (f:fmla) (x:ident) (v:ident), (fresh_in_fmla x
  f) -> ((subst f x v) = f).
intros f x v h1.

Qed.


