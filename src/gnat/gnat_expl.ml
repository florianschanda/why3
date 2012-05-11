open Why3

type reason =
   | VC_Division_Check
   | VC_Index_Check
   | VC_Overflow_Check
   | VC_Range_Check
   | VC_Precondition
   | VC_Postcondition
   | VC_Loop_Invariant
   | VC_Loop_Invariant_Init
   | VC_Loop_Invariant_Preserv
   | VC_Assert

type simple_loc  = { file : string; line : int ; col : int }
type loc = simple_loc list

type expl = { loc : loc ; reason : reason ; subp : loc }
(* The subp field should not differentiate two otherwise equal explanations *)

let expl_compare e1 e2 =
   let c = Pervasives.compare e1.loc e2.loc in
   if c = 0 then Pervasives.compare e1.reason e2.reason
   else c

let expl_equal e1 e2 =
   e1.loc = e2.loc && e1.reason = e2.reason

let expl_hash e =
   Hashcons.combine (Hashtbl.hash e.loc) (Hashtbl.hash e.reason)

let mk_expl reason sloc subp_sloc =
   { reason = reason; loc = sloc; subp = subp_sloc }

let reason_from_string s =
   match s with
   | "VC_DIVISION_CHECK"          -> VC_Division_Check
   | "VC_INDEX_CHECK"             -> VC_Index_Check
   | "VC_OVERFLOW_CHECK"          -> VC_Overflow_Check
   | "VC_RANGE_CHECK"             -> VC_Range_Check
   | "VC_PRECONDITION"            -> VC_Precondition
   | "VC_POSTCONDITION"           -> VC_Postcondition
   | "VC_LOOP_INVARIANT"          -> VC_Loop_Invariant
   | "VC_LOOP_INVARIANT_INIT"     -> VC_Loop_Invariant_Init
   | "VC_LOOP_INVARIANT_PRESERV"  -> VC_Loop_Invariant_Preserv
   | "VC_ASSERT"                  -> VC_Assert
   | _                            -> assert false

let string_of_reason s =
   match s with
   | VC_Division_Check            -> "division check"
   | VC_Index_Check               -> "index check"
   | VC_Overflow_Check            -> "overflow check"
   | VC_Range_Check               -> "range check"
   | VC_Precondition              -> "precondition"
   | VC_Postcondition             -> "postcondition"
   | VC_Loop_Invariant            -> "loop invariant"
   | VC_Loop_Invariant_Init       -> "loop invariant initialization"
   | VC_Loop_Invariant_Preserv    -> "loop invariant preservation"
   | VC_Assert                    -> "assertion"

let mk_simple_loc fn l c =
   { file = fn; line = l; col = c }
let mk_loc fn l c =
   [mk_simple_loc fn l c]

let mk_loc_line fn l = mk_loc fn l 0

let equal_line l1 l2 =
   let l1 = List.hd l1 and l2 = List.hd l2 in
   l1.line = l2.line && l1.file = l2.file

let get_loc e = e.loc
let get_subp_loc e = e.subp

let parse_loc =
   let rec parse_loc_list acc l =
      match l with
      | file::line::col::rest ->
            let new_loc =
               mk_simple_loc file (int_of_string line) (int_of_string col) in
            parse_loc_list (new_loc :: acc) rest
      | [] -> acc
      | _ -> Gnat_util.abort_with_message "location list malformed."
   in
   fun l -> List.rev (parse_loc_list [] l)

let orig_loc l =
   (* the original source is always the last source location *)
   List.hd (List.rev l)

let to_filename expl =
   let s = String.copy (string_of_reason expl.reason) in
   for i = 0 to String.length s - 1 do
      if s.[i] = ' ' then s.[i] <- '_'
   done;
   let l = List.hd expl.loc in
   Format.sprintf "%s_%d_%d_%s" l.file l.line l.col s

let loc_of_pos l =
   let f,l,c,_ = Loc.get l in
   { file = f; line = l; col = c }

let simple_print_loc fmt l =
   Format.fprintf fmt "%s:%d:%d" l.file l.line l.col

let print_line_loc fmt l =
   Format.fprintf fmt "%s:%d" l.file l.line

let print_loc _ _ =
   assert false

let print_reason fmt r =
   Format.fprintf fmt "%s" (string_of_reason r)

let print_expl proven fmt p =
   if proven then
      Format.fprintf fmt "%a: info: %a proved"
        simple_print_loc (List.hd p.loc) print_reason p.reason
   else
      Format.fprintf fmt "%a: %a not proved"
        simple_print_loc (List.hd p.loc) print_reason p.reason;
   match p.loc with
   | [] -> assert false
   | [_] -> ()
   | hd :: rest ->
         List.iter (fun secondary_sloc ->
            Format.fprintf fmt "@.%a:   instantiated from %a"
              simple_print_loc hd
              print_line_loc secondary_sloc) rest

let print_skipped fmt p =
   Format.fprintf fmt "%a: %a skipped"
     simple_print_loc (List.hd p.loc) print_reason p.reason

module ExplCmp = struct
   type t = expl
   let compare = expl_compare
end

module MExpl = Stdlib.Map.Make(ExplCmp)
module SExpl = MExpl.Set
module HExpl = Hashtbl.Make (struct
   type t = expl
   let equal = expl_equal

   let hash = expl_hash
end)
