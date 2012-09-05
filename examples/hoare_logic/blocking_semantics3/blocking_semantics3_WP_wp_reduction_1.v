(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require int.MinMax.

(* Why3 assumption *)
Inductive list (a:Type) {a_WT:WhyType a} :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Axiom list_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (list a).
Existing Instance list_WhyType.
Implicit Arguments Nil [[a] [a_WT]].
Implicit Arguments Cons [[a] [a_WT]].

Axiom map : forall (a:Type) {a_WT:WhyType a} (b:Type) {b_WT:WhyType b}, Type.
Parameter map_WhyType : forall (a:Type) {a_WT:WhyType a}
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
Inductive datatype  :=
  | TYunit : datatype 
  | TYint : datatype 
  | TYbool : datatype .
Axiom datatype_WhyType : WhyType datatype.
Existing Instance datatype_WhyType.

(* Why3 assumption *)
Inductive value  :=
  | Vvoid : value 
  | Vint : Z -> value 
  | Vbool : bool -> value .
Axiom value_WhyType : WhyType value.
Existing Instance value_WhyType.

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .
Axiom operator_WhyType : WhyType operator.
Existing Instance operator_WhyType.

Axiom mident : Type.
Parameter mident_WhyType : WhyType mident.
Existing Instance mident_WhyType.

(* Why3 assumption *)
Inductive ident  :=
  | mk_ident : Z -> ident .
Axiom ident_WhyType : WhyType ident.
Existing Instance ident_WhyType.

(* Why3 assumption *)
Definition ident_index(v:ident): Z := match v with
  | (mk_ident x) => x
  end.

(* Why3 assumption *)
Inductive term_node  :=
  | Tvalue : value -> term_node 
  | Tvar : ident -> term_node 
  | Tderef : mident -> term_node 
  | Tbin : term -> operator -> term -> term_node 
  with term  :=
  | mk_term : term_node -> Z -> term .
Axiom term_WhyType : WhyType term.
Existing Instance term_WhyType.

Axiom term_node_WhyType : WhyType term_node.
Existing Instance term_node_WhyType.

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
Axiom fmla_WhyType : WhyType fmla.
Existing Instance fmla_WhyType.

(* Why3 assumption *)
Inductive stmt  :=
  | Sskip : stmt 
  | Sassign : mident -> term -> stmt 
  | Sseq : stmt -> stmt -> stmt 
  | Sif : term -> stmt -> stmt -> stmt 
  | Sassert : fmla -> stmt 
  | Swhile : term -> fmla -> stmt -> stmt .
Axiom stmt_WhyType : WhyType stmt.
Existing Instance stmt_WhyType.

Axiom decide_is_skip : forall (s:stmt), (s = Sskip) \/ ~ (s = Sskip).

(* Why3 assumption *)
Definition type_value(v:value): datatype :=
  match v with
  | Vvoid => TYunit
  | (Vint int) => TYint
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
Inductive type_stmt : (map mident datatype) -> (list (ident* datatype)%type)
  -> stmt -> Prop :=
  | Type_skip : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)), (type_stmt sigma pi Sskip)
  | Type_seq : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (s1:stmt) (s2:stmt), (type_stmt sigma pi s1) ->
      ((type_stmt sigma pi s2) -> (type_stmt sigma pi (Sseq s1 s2)))
  | Type_assigns : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:mident) (t:term) (ty:datatype), ((get sigma
      x) = ty) -> ((type_term sigma pi t ty) -> (type_stmt sigma pi
      (Sassign x t)))
  | Type_if : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t:term) (s1:stmt) (s2:stmt), (type_term sigma pi t
      TYbool) -> ((type_stmt sigma pi s1) -> ((type_stmt sigma pi s2) ->
      (type_stmt sigma pi (Sif t s1 s2))))
  | Type_assert : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (p:fmla), (type_fmla sigma pi p) -> (type_stmt sigma
      pi (Sassert p))
  | Type_while : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (guard:term) (body:stmt) (inv:fmla), (type_fmla sigma
      pi inv) -> ((type_term sigma pi guard TYbool) -> ((type_stmt sigma pi
      body) -> (type_stmt sigma pi (Swhile guard inv body)))).

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

Axiom eval_bool_term : forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)) (sigmat:(map mident datatype)) (pit:(list (ident*
  datatype)%type)) (t:term), (type_term sigmat pit t TYbool) ->
  exists b:bool, ((eval_term sigma pi t) = (Vbool b)).

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

Axiom subst_fresh : forall (f:fmla) (x:ident) (v:ident), (fresh_in_fmla x
  f) -> ((subst f x v) = f).

Axiom let_subst : forall (t:term) (f:fmla) (x:ident) (id':ident) (id:mident),
  ((msubst (Flet x t f) id id') = (Flet x (msubst_term t id id') (msubst f id
  id'))).

Axiom eval_msubst : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (x:mident) (v:ident), (fresh_in_fmla v f) ->
  ((eval_fmla sigma pi (msubst f x v)) <-> (eval_fmla (set sigma x
  (get_stack v pi)) pi f)).

Axiom eval_subst : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (x:ident) (v:ident), (fresh_in_fmla v f) ->
  ((eval_fmla sigma pi (subst f x v)) <-> (eval_fmla sigma (Cons (x,
  (get_stack v pi)) pi) f)).

Axiom eval_swap : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (id1:ident) (id2:ident) (v1:value) (v2:value),
  (~ (id1 = id2)) -> ((eval_fmla sigma (Cons (id1, v1) (Cons (id2, v2) pi))
  f) <-> (eval_fmla sigma (Cons (id2, v2) (Cons (id1, v1) pi)) f)).

Axiom eval_same_var : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (id:ident) (v1:value) (v2:value), (eval_fmla sigma
  (Cons (id, v1) (Cons (id, v2) pi)) f) <-> (eval_fmla sigma (Cons (id, v1)
  pi) f).

Axiom eval_change_free : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (id:ident) (v:value), (fresh_in_fmla id f) ->
  ((eval_fmla sigma (Cons (id, v) pi) f) <-> (eval_fmla sigma pi f)).

(* Why3 assumption *)
Definition valid_fmla(p:fmla): Prop := forall (sigma:(map mident value))
  (pi:(list (ident* value)%type)), (eval_fmla sigma pi p).

Axiom let_equiv : forall (id:ident) (id':ident) (t:term) (f:fmla),
  forall (sigma:(map mident value)) (pi:(list (ident* value)%type)),
  (fresh_in_fmla id' f) -> ((eval_fmla sigma pi (Flet id' t (subst f id
  id'))) -> (eval_fmla sigma pi (Flet id t f))).

Axiom let_equiv2 : forall (id:ident) (id':ident) (t:term) (f:fmla),
  forall (sigma:(map mident value)) (pi:(list (ident* value)%type)),
  (fresh_in_fmla id' f) -> ((eval_fmla sigma pi (Flet id' t (subst f id
  id'))) -> (eval_fmla sigma pi (Flet id t f))).

Axiom let_implies : forall (id:ident) (t:term) (p:fmla) (q:fmla),
  (valid_fmla (Fimplies p q)) -> (valid_fmla (Fimplies (Flet id t p) (Flet id
  t q))).

(* Why3 assumption *)
Fixpoint fresh_in_stmt(id:ident) (s:stmt) {struct s}: Prop :=
  match s with
  | Sskip => True
  | (Sseq s1 s2) => (fresh_in_stmt id s1) /\ (fresh_in_stmt id s2)
  | (Sassign _ t) => (fresh_in_term id t)
  | (Sif t s1 s2) => (fresh_in_term id t) /\ ((fresh_in_stmt id s1) /\
      (fresh_in_stmt id s2))
  | (Sassert f) => (fresh_in_fmla id f)
  | (Swhile cond inv body) => (fresh_in_term id cond) /\ ((fresh_in_fmla id
      inv) /\ (fresh_in_stmt id body))
  end.

(* Why3 assumption *)
Inductive one_step : (map mident value) -> (list (ident* value)%type) -> stmt
  -> (map mident value) -> (list (ident* value)%type) -> stmt -> Prop :=
  | one_step_assign : forall (sigma:(map mident value)) (sigma':(map mident
      value)) (pi:(list (ident* value)%type)) (x:mident) (t:term),
      (sigma' = (set sigma x (eval_term sigma pi t))) -> (one_step sigma pi
      (Sassign x t) sigma' pi Sskip)
  | one_step_seq_noskip : forall (sigma:(map mident value)) (sigma':(map
      mident value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (s1:stmt) (s1':stmt) (s2:stmt), (one_step sigma pi s1
      sigma' pi' s1') -> (one_step sigma pi (Sseq s1 s2) sigma' pi' (Sseq s1'
      s2))
  | one_step_seq_skip : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (s:stmt), (one_step sigma pi (Sseq Sskip s) sigma pi s)
  | one_step_if_true : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (t:term) (s1:stmt) (s2:stmt), ((eval_term sigma pi
      t) = (Vbool true)) -> (one_step sigma pi (Sif t s1 s2) sigma pi s1)
  | one_step_if_false : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (t:term) (s1:stmt) (s2:stmt), ((eval_term sigma pi
      t) = (Vbool false)) -> (one_step sigma pi (Sif t s1 s2) sigma pi s2)
  | one_step_assert : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (f:fmla), (eval_fmla sigma pi f) -> (one_step sigma pi
      (Sassert f) sigma pi Sskip)
  | one_step_while_true : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (cond:term) (inv:fmla) (body:stmt), (eval_fmla sigma pi
      inv) -> (((eval_term sigma pi cond) = (Vbool true)) -> (one_step sigma
      pi (Swhile cond inv body) sigma pi (Sseq body (Swhile cond inv body))))
  | one_step_while_false : forall (sigma:(map mident value)) (pi:(list
      (ident* value)%type)) (cond:term) (inv:fmla) (body:stmt),
      (eval_fmla sigma pi inv) -> (((eval_term sigma pi
      cond) = (Vbool false)) -> (one_step sigma pi (Swhile cond inv body)
      sigma pi Sskip)).

(* Why3 assumption *)
Inductive many_steps : (map mident value) -> (list (ident* value)%type)
  -> stmt -> (map mident value) -> (list (ident* value)%type) -> stmt
  -> Z -> Prop :=
  | many_steps_refl : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (s:stmt), (many_steps sigma pi s sigma pi s 0%Z)
  | many_steps_trans : forall (sigma1:(map mident value)) (sigma2:(map mident
      value)) (sigma3:(map mident value)) (pi1:(list (ident* value)%type))
      (pi2:(list (ident* value)%type)) (pi3:(list (ident* value)%type))
      (s1:stmt) (s2:stmt) (s3:stmt) (n:Z), (one_step sigma1 pi1 s1 sigma2 pi2
      s2) -> ((many_steps sigma2 pi2 s2 sigma3 pi3 s3 n) ->
      (many_steps sigma1 pi1 s1 sigma3 pi3 s3 (n + 1%Z)%Z)).

Axiom steps_non_neg : forall (sigma1:(map mident value)) (sigma2:(map mident
  value)) (pi1:(list (ident* value)%type)) (pi2:(list (ident* value)%type))
  (s1:stmt) (s2:stmt) (n:Z), (many_steps sigma1 pi1 s1 sigma2 pi2 s2 n) ->
  (0%Z <= n)%Z.

Axiom many_steps_seq : forall (sigma1:(map mident value)) (sigma3:(map mident
  value)) (pi1:(list (ident* value)%type)) (pi3:(list (ident* value)%type))
  (s1:stmt) (s2:stmt) (n:Z), (many_steps sigma1 pi1 (Sseq s1 s2) sigma3 pi3
  Sskip n) -> exists sigma2:(map mident value), exists pi2:(list (ident*
  value)%type), exists n1:Z, exists n2:Z, (many_steps sigma1 pi1 s1 sigma2
  pi2 Sskip n1) /\ ((many_steps sigma2 pi2 s2 sigma3 pi3 Sskip n2) /\
  (n = ((1%Z + n1)%Z + n2)%Z)).

Axiom one_step_change_free : forall (s:stmt) (s':stmt) (sigma:(map mident
  value)) (sigma':(map mident value)) (pi:(list (ident* value)%type))
  (pi':(list (ident* value)%type)) (id:ident) (v:value), (fresh_in_stmt id
  s) -> ((one_step sigma (Cons (id, v) pi) s sigma' pi' s') ->
  (one_step sigma pi s sigma' pi' s')).

(* Why3 assumption *)
Definition valid_triple(p:fmla) (s:stmt) (q:fmla): Prop := forall (sigma:(map
  mident value)) (pi:(list (ident* value)%type)), (eval_fmla sigma pi p) ->
  forall (sigma':(map mident value)) (pi':(list (ident* value)%type)) (n:Z),
  (many_steps sigma pi s sigma' pi' Sskip n) -> (eval_fmla sigma' pi' q).

(* Why3 assumption *)
Definition total_valid_triple(p:fmla) (s:stmt) (q:fmla): Prop :=
  forall (sigma:(map mident value)) (pi:(list (ident* value)%type)),
  (eval_fmla sigma pi p) -> exists sigma':(map mident value),
  exists pi':(list (ident* value)%type), exists n:Z, (many_steps sigma pi s
  sigma' pi' Sskip n) /\ (eval_fmla sigma' pi' q).

Axiom set1 : forall (a:Type) {a_WT:WhyType a}, Type.
Parameter set1_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (set1 a).
Existing Instance set1_WhyType.

Parameter mem: forall {a:Type} {a_WT:WhyType a}, a -> (set1 a) -> Prop.

(* Why3 assumption *)
Definition infix_eqeq {a:Type} {a_WT:WhyType a}(s1:(set1 a)) (s2:(set1
  a)): Prop := forall (x:a), (mem x s1) <-> (mem x s2).

Axiom extensionality : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)), (infix_eqeq s1 s2) -> (s1 = s2).

(* Why3 assumption *)
Definition subset {a:Type} {a_WT:WhyType a}(s1:(set1 a)) (s2:(set1
  a)): Prop := forall (x:a), (mem x s1) -> (mem x s2).

Axiom subset_trans : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (s3:(set1 a)), (subset s1 s2) -> ((subset s2 s3) ->
  (subset s1 s3)).

Parameter empty: forall {a:Type} {a_WT:WhyType a}, (set1 a).

(* Why3 assumption *)
Definition is_empty {a:Type} {a_WT:WhyType a}(s:(set1 a)): Prop :=
  forall (x:a), ~ (mem x s).

Axiom empty_def1 : forall {a:Type} {a_WT:WhyType a}, (is_empty (empty :(set1
  a))).

Parameter add: forall {a:Type} {a_WT:WhyType a}, a -> (set1 a) -> (set1 a).

Axiom add_def1 : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (y:a),
  forall (s:(set1 a)), (mem x (add y s)) <-> ((x = y) \/ (mem x s)).

Parameter remove: forall {a:Type} {a_WT:WhyType a}, a -> (set1 a) -> (set1
  a).

Axiom remove_def1 : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (y:a)
  (s:(set1 a)), (mem x (remove y s)) <-> ((~ (x = y)) /\ (mem x s)).

Axiom subset_remove : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (s:(set1
  a)), (subset (remove x s) s).

Parameter union: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> (set1 a) ->
  (set1 a).

Axiom union_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (x:a), (mem x (union s1 s2)) <-> ((mem x s1) \/ (mem x s2)).

Parameter inter: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> (set1 a) ->
  (set1 a).

Axiom inter_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (x:a), (mem x (inter s1 s2)) <-> ((mem x s1) /\ (mem x s2)).

Parameter diff: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> (set1 a) ->
  (set1 a).

Axiom diff_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (x:a), (mem x (diff s1 s2)) <-> ((mem x s1) /\ ~ (mem x s2)).

Axiom subset_diff : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)), (subset (diff s1 s2) s1).

Parameter choose: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> a.

Axiom choose_def : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1 a)),
  (~ (is_empty s)) -> (mem (choose s) s).

Parameter all: forall {a:Type} {a_WT:WhyType a}, (set1 a).

Axiom all_def : forall {a:Type} {a_WT:WhyType a}, forall (x:a), (mem x
  (all :(set1 a))).

(* Why3 assumption *)
Definition assigns(sigma:(map mident value)) (a:(set1 mident)) (sigma':(map
  mident value)): Prop := forall (i:mident), (~ (mem i a)) -> ((get sigma
  i) = (get sigma' i)).

Axiom assigns_refl : forall (sigma:(map mident value)) (a:(set1 mident)),
  (assigns sigma a sigma).

Axiom assigns_trans : forall (sigma1:(map mident value)) (sigma2:(map mident
  value)) (sigma3:(map mident value)) (a:(set1 mident)), ((assigns sigma1 a
  sigma2) /\ (assigns sigma2 a sigma3)) -> (assigns sigma1 a sigma3).

Axiom assigns_union_left : forall (sigma:(map mident value)) (sigma':(map
  mident value)) (s1:(set1 mident)) (s2:(set1 mident)), (assigns sigma s1
  sigma') -> (assigns sigma (union s1 s2) sigma').

Axiom assigns_union_right : forall (sigma:(map mident value)) (sigma':(map
  mident value)) (s1:(set1 mident)) (s2:(set1 mident)), (assigns sigma s2
  sigma') -> (assigns sigma (union s1 s2) sigma').

(* Why3 assumption *)
Fixpoint stmt_writes(s:stmt) (w:(set1 mident)) {struct s}: Prop :=
  match s with
  | (Sskip|(Sassert _)) => True
  | (Sassign id _) => (mem id w)
  | (Sseq s1 s2) => (stmt_writes s1 w) /\ (stmt_writes s2 w)
  | (Sif t s1 s2) => (stmt_writes s1 w) /\ (stmt_writes s2 w)
  | (Swhile _ _ body) => (stmt_writes body w)
  end.

Parameter fresh_from: fmla -> stmt -> ident.

Axiom fresh_from_fmla : forall (s:stmt) (f:fmla),
  (fresh_in_fmla (fresh_from f s) f).

Axiom fresh_from_stmt : forall (s:stmt) (f:fmla),
  (fresh_in_stmt (fresh_from f s) s).

Parameter abstract_effects: stmt -> fmla -> fmla.

Axiom abstract_effects_generalize : forall (sigma:(map mident value))
  (pi:(list (ident* value)%type)) (s:stmt) (f:fmla), (eval_fmla sigma pi
  (abstract_effects s f)) -> (eval_fmla sigma pi f).

(* Why3 assumption *)
Fixpoint wp(s:stmt) (q:fmla) {struct s}: fmla :=
  match s with
  | Sskip => q
  | (Sassert f) => (Fand f (Fimplies f q))
  | (Sseq s1 s2) => (wp s1 (wp s2 q))
  | (Sassign x t) => let id := (fresh_from q s) in (Flet id t (msubst q x
      id))
  | (Sif t s1 s2) => (Fand (Fimplies (Fterm t) (wp s1 q))
      (Fimplies (Fnot (Fterm t)) (wp s2 q)))
  | (Swhile cond inv body) => (Fand inv (abstract_effects body
      (Fand (Fimplies (Fand (Fterm cond) inv) (wp body inv))
      (Fimplies (Fand (Fnot (Fterm cond)) inv) q))))
  end.

Axiom abstract_effects_writes : forall (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (s:stmt) (q:fmla), (eval_fmla sigma pi
  (abstract_effects s q)) -> (eval_fmla sigma pi (wp s (abstract_effects s
  q))).

Axiom distrib_conj : forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)) (s:stmt) (p:fmla) (q:fmla), (eval_fmla sigma pi (wp s (Fand p
  q))) <-> ((eval_fmla sigma pi (wp s p)) /\ (eval_fmla sigma pi (wp s q))).

(* Why3 goal *)
Theorem wp_reduction : forall (sigma:(map mident value)) (sigma':(map mident
  value)) (pi:(list (ident* value)%type)) (pi':(list (ident* value)%type))
  (s:stmt) (s':stmt), (one_step sigma pi s sigma' pi' s') -> forall (q:fmla),
  (eval_fmla sigma pi (wp s q)) -> (eval_fmla sigma' pi' (wp s' q)).
induction 1; intros q Hq.
(* case Sassign *)
simpl.
simpl in Hq.
noadmit. 
(*
rewrite eval_msubst in Hq.

TODO *)

(* case Sseq *)
simpl.
apply IHone_step.
apply Hq.

(* case Skip ; s2 *)
simpl in Hq; auto.

(* case if true *)
simpl in Hq.
intuition.

(* case if false *)
simpl in Hq.
destruct Hq as (_ & h2).
apply h2.
rewrite H; discriminate.

(* case assert *)
simpl.
simpl in Hq.
intuition.

(* case While true *)
simpl.
simpl in Hq.
destruct Hq as (h1 & h2).
rewrite distrib_conj; split.
generalize (abstract_effects_generalize _ _ _ _ h2).
intros h3.
simpl in h3.
intuition.

apply abstract_effects_writes; auto.

(* case While False *)
simpl.
simpl in Hq.
destruct Hq as (h1 & h2).
generalize (abstract_effects_generalize _ _ _ _ h2).
intros h3.
simpl in h3.
destruct h3 as (_ & h4). 
apply h4.
split; auto.
rewrite H0; discriminate.

Qed.


