(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2018   --   Inria - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

open Stdlib

(** Labels *)

type label = {
  lab_string : string;
  lab_tag    : int;
}

module Lab = MakeMSH (struct
  type t = label
  let tag lab = lab.lab_tag
end)

module Slab = Lab.S
module Mlab = Lab.M

module Hslab = Hashcons.Make (struct
  type t = label
  let equal lab1 lab2 = lab1.lab_string = lab2.lab_string
  let hash lab = Hashtbl.hash lab.lab_string
  let tag n lab = { lab with lab_tag = n }
end)

let create_label s = Hslab.hashcons {
  lab_string = s;
  lab_tag    = -1
}

let list_label () =
  let acc = ref [] in
  Hslab.iter (fun label -> acc := label.lab_string :: !acc);
  !acc

let lab_equal : label -> label -> bool = (==)
let lab_hash lab = lab.lab_tag
let lab_compare l1 l2 = Pervasives.compare l1.lab_tag l2.lab_tag

(** Naming convention *)

let infix  s = "infix "  ^ s
let prefix s = "prefix " ^ s
let mixfix s = "mixfix " ^ s

let kind_of_fix s =
  let len = String.length s in
  if len < 7 then `None else
  let inf = String.sub s 0 6 in
  if inf = "infix "  then `Infix (String.sub s 6 (len - 6)) else
  let prf = String.sub s 0 7 in
  if prf = "prefix " then `Prefix (String.sub s 7 (len - 7)) else
  let prf = String.sub s 0 7 in
  if prf = "mixfix " then `Mixfix (String.sub s 7 (len - 7)) else
  `None


(** Identifiers *)

type ident = {
  id_string : string;               (* non-unique name *)
  id_label  : Slab.t;               (* identifier labels *)
  id_loc    : Loc.position option;  (* optional location *)
  id_tag    : Weakhtbl.tag;         (* unique magical tag *)
}

module Id = MakeMSHW (struct
  type t = ident
  let tag id = id.id_tag
end)

module Sid = Id.S
module Mid = Id.M
module Hid = Id.H
module Wid = Id.W

type preid = {
  pre_name  : string;
  pre_label : Slab.t;
  pre_loc   : Loc.position option;
}

let id_equal : ident -> ident -> bool = (==)
let id_hash id = Weakhtbl.tag_hash id.id_tag
let id_compare id1 id2 = Pervasives.compare (id_hash id1) (id_hash id2)

(* constructors *)

let id_register = let r = ref 0 in fun id -> {
  id_string = id.pre_name;
  id_label  = id.pre_label;
  id_loc    = id.pre_loc;
  id_tag    = (incr r; Weakhtbl.create_tag !r);
}

let create_ident name labels loc = {
  pre_name  = name;
  pre_label = labels;
  pre_loc   = loc;
}

let id_fresh ?(label = Slab.empty) ?loc nm =
  create_ident nm label loc

let id_user ?(label = Slab.empty) nm loc =
  create_ident nm label (Some loc)

let id_lab label id =
  create_ident id.id_string label id.id_loc

let id_clone ?(label = Slab.empty) id =
  let ll = Slab.union label id.id_label in
  create_ident id.id_string ll id.id_loc

let id_derive ?(label = Slab.empty) nm id =
  let ll = Slab.union label id.id_label in
  create_ident nm ll id.id_loc

let preid_name id = id.pre_name

(** Unique names for pretty printing *)

type ident_printer = {
  indices   : int Hstr.t;
  values    : string Hid.t;
  sanitizer : string -> string;
  blacklist : string list;
}

(* name is already sanitized *)
let find_unique indices name =
  let specname ind =
    let rec repeat n s =
      if n <= 0 then s else repeat (n-1) (s ^ "^")
    in
    (* In the case, the symbol is infix/prefix *and* the name has not been
       sanitized for provers (the space " " is still there), we don't want to
       disambiguate with a number but with a symbol: "+" becomes "+." "+.." etc.
       It allows to parse the ident again (for transformations).
    *)
    if Strings.has_prefix "infix " name ||
       Strings.has_prefix "prefix " name then
      (repeat ind name)
    else
      if ind < 0 then
        name
      else
        name ^ string_of_int ind
  in
  let testname ind = Hstr.mem indices (specname ind) in
  let rec advance ind =
    if testname ind then advance (succ ind) else ind in
  let rec retreat ind =
    if ind = 1 || testname (pred ind) then ind else retreat (pred ind) in
  let fetch ind =
    if testname ind then advance (succ ind) else retreat ind in
  let name = try
    let ind = fetch (succ (Hstr.find indices name)) in
    Hstr.replace indices name ind;
    specname ind
  with Not_found -> name in
  Hstr.replace indices name 0;
  name

let reserve indices name = ignore (find_unique indices name)

let same x = x

let create_ident_printer ?(sanitizer = same) sl =
  let indices = Hstr.create 1997 in
  List.iter (reserve indices) sl;
  { indices   = indices;
    values    = Hid.create 1997;
    sanitizer = sanitizer;
    blacklist = sl }

let known_id printer id =
  try
    (let _ = Hid.find printer.values id in true)
  with Not_found ->
    false

let id_unique printer ?(sanitizer = same) id =
  try
    Hid.find printer.values id
  with Not_found ->
    let name = sanitizer (printer.sanitizer id.id_string) in
    let name = find_unique printer.indices name in
    Hid.replace printer.values id name;
    name

let string_unique printer s = find_unique printer.indices s

let forget_id printer id =
  try
    let name = Hid.find printer.values id in
    Hstr.remove printer.indices name;
    Hid.remove printer.values id
  with Not_found -> ()

let forget_all printer =
  Hid.clear printer.values;
  Hstr.clear printer.indices;
  List.iter (reserve printer.indices) printer.blacklist

(** Sanitizers *)

let char_to_alpha c = match c with
  | 'a'..'z' | 'A'..'Z' -> String.make 1 c
  | ' ' -> "sp" | '_'  -> "us" | '#' -> "sh"
  | '`' -> "bq" | '~'  -> "tl" | '!' -> "ex"
  | '@' -> "at" | '$'  -> "dl" | '%' -> "pc"
  | '^' -> "cf" | '&'  -> "et" | '*' -> "as"
  | '(' -> "lp" | ')'  -> "rp" | '-' -> "mn"
  | '+' -> "pl" | '='  -> "eq" | '[' -> "lb"
  | ']' -> "rb" | '{'  -> "lc" | '}' -> "rc"
  | ':' -> "cl" | '\'' -> "qt" | '"' -> "dq"
  | '<' -> "ls" | '>'  -> "gt" | '/' -> "sl"
  | '?' -> "qu" | '\\' -> "bs" | '|' -> "br"
  | ';' -> "sc" | ','  -> "cm" | '.' -> "dt"
  | '0' -> "zr" | '1'  -> "un" | '2' -> "du"
  | '3' -> "tr" | '4'  -> "qr" | '5' -> "qn"
  | '6' -> "sx" | '7'  -> "st" | '8' -> "oc"
  | '9' -> "nn" | '\n' -> "br" |  _  -> "zz"

let char_to_lalpha c = Strings.uncapitalize (char_to_alpha c)
let char_to_ualpha c = Strings.capitalize (char_to_alpha c)

let char_to_alnum c =
  match c with '0'..'9' -> String.make 1 c | _ -> char_to_alpha c

let char_to_lalnum c =
  match c with '0'..'9' -> String.make 1 c | _ -> char_to_lalpha c

let char_to_alnumus c =
  match c with '_' | ' ' -> "_" | _ -> char_to_alnum c

let char_to_lalnumus c =
  match c with '_' | ' ' -> "_" | _ -> char_to_lalnum c

let sanitizer' head rest last n =
  let lst = ref [] in
  let code i c = lst :=
    (if i = 0 then head
     else if i = String.length n - 1 then last
     else rest) c :: !lst in
  let n = if n = "" then "zilch" else n in
  String.iteri code n;
  String.concat "" (List.rev !lst)

let sanitizer head rest n = sanitizer' head rest rest n



(** {2 functions for working with counterexample model labels} *)

let model_label = create_label "model"
let model_projected_label = create_label "model_projected"
let model_vc_label = create_label "model_vc"
let model_vc_post_label = create_label "model_vc_post"

let create_model_trace_label s = create_label ("model_trace:" ^ s)

let is_counterexample_label l =
  l = model_label || l = model_projected_label

let has_a_model_label id =
  Slab.exists is_counterexample_label id.id_label

let remove_model_labels ~labels =
  Slab.filter (fun l -> not (is_counterexample_label l)) labels

let is_model_trace_label label =
  Strings.has_prefix "model_trace:" label.lab_string

let get_model_trace_label ~labels =
  Slab.choose (Slab.filter is_model_trace_label labels)

let transform_model_trace_label labels trans_fun =
  try
    let trace_label = get_model_trace_label ~labels in
    let labels_without_trace = Slab.remove trace_label labels in
    let new_trace_label = create_label (trans_fun trace_label.lab_string) in
    Slab.add new_trace_label labels_without_trace
  with Not_found -> labels

let append_to_model_element_name ~labels ~to_append =
  let trans lab_str =
    let splitted = Strings.bounded_split '@' lab_str 2 in
    match splitted with
    | [before; after] -> before ^ to_append ^ "@" ^ after
    | _ -> lab_str^to_append in
  transform_model_trace_label labels trans

let append_to_model_trace_label ~labels ~to_append =
    let trans lab_str = lab_str ^ to_append in
    transform_model_trace_label labels trans

let get_model_element_name ~labels =
  let trace_label = get_model_trace_label ~labels in
  let splitted1 = Strings.bounded_split ':' trace_label.lab_string 2 in
  match splitted1 with
  | [_; content] ->
    begin
      let splitted2 = Strings.bounded_split '@' content 2 in
      match splitted2 with
      | [el_name; _] -> el_name
      | [el_name] -> el_name
      | _ -> raise Not_found
    end;
  | [_] -> ""
  | _ -> assert false

let get_model_trace_string ~labels =
  let tl = get_model_trace_label ~labels in
  let splitted = Strings.bounded_split ':' tl.lab_string 2 in
  match splitted with
  | [_; t_str] -> t_str
  | _ -> ""


(* Functions for working with ITP labels *)

let is_name_label label =
  Strings.has_prefix "name:" label.lab_string

let get_name_label ~labels =
  try Some (Slab.choose (Slab.filter is_name_label labels))
  with Not_found -> None

let get_element_name ~labels =
  match get_name_label ~labels with
  | None -> None
  | Some name_label ->
    let splitted1 = Strings.bounded_split ':' name_label.lab_string 2 in
    let correct_word = Str.regexp "^\\([A-Za-z]+\\)\\([A-Za-z0-9_']*\\)$" in
    match splitted1 with
    | ["name"; content] when Str.string_match correct_word content 0 ->
        Some content
    | _ -> None

let id_unique_label printer ?(sanitizer = same) id =
  try
    Hid.find printer.values id
  with Not_found ->
    let labels = id.id_label in
    let name =
      match (get_element_name ~labels) with
      | Some x -> x
      | None -> printer.sanitizer id.id_string
    in
    let name = sanitizer name in
    let name = find_unique printer.indices name in
    Hid.replace printer.values id name;
    name
