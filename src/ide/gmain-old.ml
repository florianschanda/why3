(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    Francois Bobot                                                      *)
(*    Jean-Christophe Filliatre                                           *)
(*    Johannes Kanig                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

open Format

let () = 
  eprintf "Init the GTK interface...@?";
  ignore (GtkMain.Main.init ());
  eprintf " done.@."

open Why
open Whyconf
open Gconfig


(************************)
(* parsing command line *)
(************************)

let includes = ref []

let spec = Arg.align [
  "-I", Arg.String (fun s -> includes := s :: !includes), "<s> add s to loadpath" ;
]

let usage_str = "whyide [options] <file>.why"
let file = ref None
let set_file f = match !file with
  | Some _ -> 
      raise (Arg.Bad "only one file")
  | None -> 
      if not (Sys.file_exists f) then begin
	Format.eprintf "%s: no such file@." f; 
        exit 1
      end;
      file := Some f

let () = 
  eprintf "Parsing command line...@?";
  Arg.parse spec set_file usage_str;
  eprintf " done.@."


let fname = match !file with
  | None -> 
      Arg.usage spec usage_str; 
      exit 1
  | Some f -> 
      f

let lang =
  let main = get_main () in
  let load_path = Filename.concat (datadir main) "lang" in
  let languages_manager = 
    GSourceView2.source_language_manager ~default:true 
  in
  languages_manager#set_search_path 
    (load_path :: languages_manager#search_path);
  match languages_manager#language "why" with
    | None -> 
        Format.eprintf "language file for 'why' not found in directory %s@." 
          load_path; 
        exit 1
    | Some _ as l -> l

let source_text fname = 
  let ic = open_in fname in
  let size = in_channel_length ic in
  let buf = String.create size in
  really_input ic buf 0 size;
  close_in ic;
  buf

(********************************)
(* loading WhyIDE configuration *)
(********************************)

let gconfig = 
  let c = Gconfig.config in
  let loadpath = (get_main ()).loadpath @ List.rev !includes in
  c.env <- Env.create_env (Lexer.retrieve loadpath);
  let provers = Whyconf.get_provers c.Gconfig.config in
  c.provers <- Util.Mstr.fold (Gconfig.get_prover_data c.env) provers Util.Mstr.empty;
  c

(***********************)
(* Parsing input file  *)
(***********************)

let theories : Theory.theory Theory.Mnm.t =
  try
    let m = Env.read_file gconfig.env fname in
    eprintf "Parsing/Typing Ok@.";
    m
  with e -> 
    eprintf "%a@." Exn_printer.exn_printer e;
    exit 1

(********************)
(* opening database *)
(********************)

(*
let () = Db.init_base (fname ^ ".db")
*)


(*
let find_prover s = 
  match
    List.fold_left
      (fun acc p ->
        if (* Db.prover_name *) p.prover_id = s then Some p else acc)
      None gconfig.provers
  with
    | None -> 
      eprintf "prover id '%s' not found in Why config file@." s;
      raise Not_found
    | Some p -> p
*)

(*
let alt_ergo = find_prover "alt-ergo"
let simplify = find_prover "simplify"
let z3 = find_prover "Z3"
*)

   
(*
let () = 
  printf "previously known goals:@\n";
  List.iter (fun s -> printf "%s@\n" (Db.goal_task_checksum s))
  (Db.root_goals ());
  printf "@."
*)


(****************)
(* goals widget *)
(****************)


module Model = struct


  type proof_attempt =
      { prover : prover_data;
        proof_goal : goal;
        proof_row : Gtk.tree_iter;
        mutable status : Scheduler.proof_attempt_status;
        mutable proof_obsolete : bool;
        mutable time : float;
        mutable output : string;
        mutable edited_as : string;
      }

  and goal_parent =
    | Theory of theory
    | Transf of transf

  and goal =
      { parent : goal_parent;
        task: Task.task;
        goal_row : Gtk.tree_iter;
        mutable proved : bool;
        external_proofs: (string, proof_attempt) Hashtbl.t;
        mutable transformations : transf list;
      }

  and transf =
      { parent_goal : goal;
(*
        transf : Task.task Trans.trans;
*)
        transf_row : Gtk.tree_iter;
        mutable subgoals : goal list;
      }
        
  and theory =
      { theory : Theory.theory;
        theory_row : Gtk.tree_iter;
        mutable goals : goal list;
        mutable verified : bool;
      }

  type any_row =
    | Row_theory of theory
    | Row_goal of goal
    | Row_proof_attempt of proof_attempt
    | Row_transformation of transf

  let all : theory list ref = ref [] 

  let toggle_hide_proved_goals = ref false

  let cols = new GTree.column_list
  let name_column = cols#add Gobject.Data.string
  let icon_column = cols#add Gobject.Data.gobject
  let index_column : any_row GTree.column = cols#add Gobject.Data.caml 
  let status_column = cols#add Gobject.Data.gobject
  let time_column = cols#add Gobject.Data.string
  let visible_column = cols#add Gobject.Data.boolean
(*
  let bg_column = cols#add (Gobject.Data.unsafe_boxed 
  (Gobject.Type.from_name "GdkColor"))
*)

  let name_renderer = GTree.cell_renderer_text [`XALIGN 0.] 
  let renderer = GTree.cell_renderer_text [`XALIGN 0.] 
  let image_renderer = GTree.cell_renderer_pixbuf [ ] 
  let icon_renderer = GTree.cell_renderer_pixbuf [ ]

  let view_name_column = 
    GTree.view_column ~title:"Theories/Goals" ()

  let () = 
    view_name_column#pack icon_renderer ;
    view_name_column#add_attribute icon_renderer "pixbuf" icon_column ;
    view_name_column#pack name_renderer;
    view_name_column#add_attribute name_renderer "text" name_column;
    view_name_column#set_resizable true;
    view_name_column#set_max_width 400;
(*
    view_name_column#add_attribute name_renderer "background-gdk" bg_column
*)
    ()

  let view_status_column = 
    GTree.view_column ~title:"Status" 
      ~renderer:(image_renderer, ["pixbuf", status_column]) 
      ()

  let view_time_column = 
    GTree.view_column ~title:"Time" 
      ~renderer:(renderer, ["text", time_column]) ()

  let () = 
    view_status_column#set_resizable false;
    view_status_column#set_visible true;
    view_time_column#set_resizable false;
    view_time_column#set_visible true


  let create ~packing () =
    let model = GTree.tree_store cols in
    let model_filter = GTree.model_filter model in
    model_filter#set_visible_column visible_column;
    let view = GTree.view ~model:model_filter ~packing () in
    let _ = view#selection#set_mode `SINGLE in
    let _ = view#set_rules_hint true in
    ignore (view#append_column view_name_column);
    ignore (view#append_column view_status_column);
    ignore (view#append_column view_time_column);
    model,model_filter,view

  let clear model = model#clear ()

end

(***************)
(* Main window *)
(***************)

let exit_function () =
  eprintf "saving IDE config file@.";
  save_config ();
  GMain.quit ()

let w = GWindow.window
  ~allow_grow:true ~allow_shrink:true
  ~width:gconfig.window_width
  ~height:gconfig.window_height
  ~title:"why-ide" ()

let (_ : GtkSignal.id) = w#connect#destroy ~callback:exit_function

let (_ : GtkSignal.id) =
  w#misc#connect#size_allocate
    ~callback:
    (fun {Gtk.width=w;Gtk.height=h} ->
       gconfig.window_height <- h;
       gconfig.window_width <- w)

let vbox = GPack.vbox ~homogeneous:false ~packing:w#add ()

(* Menu *)

let menubar = GMenu.menu_bar ~packing:vbox#pack ()

let factory = new GMenu.factory menubar

let accel_group = factory#accel_group

(* horizontal paned *)

let hp = GPack.paned `HORIZONTAL  ~border_width:3 ~packing:vbox#add ()

(* tree view *)
let scrollview =
  GBin.scrolled_window ~hpolicy:`AUTOMATIC ~vpolicy:`AUTOMATIC
    ~width:gconfig.tree_width
    ~packing:hp#add ()

let () = scrollview#set_shadow_type `ETCHED_OUT
let (_ : GtkSignal.id) =
  scrollview#misc#connect#size_allocate
    ~callback:
    (fun {Gtk.width=w;Gtk.height=_h} ->
       gconfig.tree_width <- w)

let goals_model,filter_model,goals_view =
  Model.create ~packing:scrollview#add ()

let new_row ?(dir=`Append) ?(visible=true) ?parent ~icon name index =
  let row =
    match dir with
    | `Append -> goals_model#append ?parent ()
    | `Prepend -> goals_model#prepend ?parent () in
  goals_model#set ~row ~column:Model.visible_column visible;
  goals_model#set ~row ~column:Model.name_column name;
  goals_model#set ~row ~column:Model.icon_column icon;
  let block, index = index row in
  goals_model#set ~row ~column:Model.index_column index;
  row, block

module Helpers = struct

  let image_of_result = function
    | Scheduler.Scheduled -> !image_scheduled
    | Scheduler.Running -> !image_running
    | Scheduler.Success -> !image_valid
    | Scheduler.Timeout -> !image_timeout
    | Scheduler.Unknown -> !image_unknown
    | Scheduler.HighFailure -> !image_failure
        
  open Model

  let set_theory_proved t =
    t.verified <- true;
    let row = t.theory_row in
    goals_view#collapse_row (goals_model#get_path row);
    goals_model#set ~row ~column:Model.status_column !image_yes;
    if !Model.toggle_hide_proved_goals then
      goals_model#set ~row ~column:Model.visible_column false
         
  let rec set_proved g =
    let row = g.goal_row in
    g.proved <- true;
    goals_view#collapse_row (goals_model#get_path row);
    goals_model#set ~row ~column:Model.status_column !image_yes;
    if !Model.toggle_hide_proved_goals then
      goals_model#set ~row ~column:Model.visible_column false;
    match g.parent with
      | Theory t ->
          if List.for_all (fun g -> g.proved) t.goals then
            set_theory_proved t
      | Transf t ->
          if List.for_all (fun g -> g.proved) t.subgoals then
            begin
              set_proved t.parent_goal;
            end

  let set_proof_status a s =
    a.status <- s;
    let row = a.proof_row in
    goals_model#set ~row ~column:Model.status_column
      (image_of_result s);
    if s = Scheduler.Success then set_proved a.proof_goal

  let add_theory th =
    let tname = th.Theory.th_name.Ident.id_string in
    let parent, mth = new_row ~icon:!image_directory tname
    (fun r ->
      let mth = { theory = th; theory_row = r;
                  goals = [] ; verified = false } in
      mth, Row_theory mth) in
    all := !all @ [mth];
    let tasks = Task.split_theory th None None in
    let goals =
      List.fold_left (fun acc t ->
         let id = (Task.task_goal t).Decl.pr_name in
         let name = id.Ident.id_string in
         let _, goal = new_row ~parent ~icon:!image_file name
           (fun r ->
             let goal = { parent = Theory mth; task = t ;
                          goal_row = r;
                          external_proofs = Hashtbl.create 7;
                          transformations = []; proved = false; } in
             goal, Row_goal goal) in
         goal :: acc) [] (List.rev tasks)
    in
    mth.goals <- List.rev goals;
    if goals = [] then set_theory_proved mth
end

let () =
  Theory.Mnm.iter (fun _ th -> Helpers.add_theory th) theories;
  goals_view#expand_all ()



let () =
  begin
    Scheduler.async := GtkThread.async;
(*
    match config.running_provers_max with
      | None -> ()
      | Some n ->
          if n >= 1 then Scheduler.maximum_running_proofs := n
*)
    Scheduler.maximum_running_proofs := gconfig.max_running_processes
  end

(*****************************************************)
(* method: run a given prover on each unproved goals *)
(*****************************************************)

let redo_external_proof g a =
  let p = a.Model.prover in
  let callback result time output =
    a.Model.output <- output;
    Helpers.set_proof_status a result;
    let t = if time > 0.0 then 
      begin
        a.Model.time <- time;
        Format.sprintf "%.2f" time 
      end
    else "" 
    in
    goals_model#set ~row:a.Model.proof_row ~column:Model.time_column t
  in
  callback Scheduler.Scheduled 0.0 "";
  let old = if a.Model.edited_as = "" then None else
    (Some (open_in a.Model.edited_as))
  in
  Scheduler.schedule_proof_attempt
    ~debug:(gconfig.verbose > 0) ~timelimit:gconfig.time_limit ~memlimit:0
    ?old ~command:p.command ~driver:p.driver
    ~callback
    g.Model.task

let rec prover_on_goal p g =
  let row = g.Model.goal_row in
  let id = p.prover_id in
  let a =
    try Hashtbl.find g.Model.external_proofs id
    with Not_found ->
      (* creating a new row *)
      let name = p.prover_name in
      let _, a =
        new_row ~dir:`Prepend ~parent:row ~icon:!image_prover
          (name ^ " " ^ p.prover_version)
          (fun r ->
            let a = { Model.prover = p;
                      Model.proof_goal = g;
                      Model.proof_row = r;
                      Model.status = Scheduler.Scheduled;
                      Model.proof_obsolete = false;
                      Model.time = 0.0;
                      Model.output = "";
                      Model.edited_as = ""; } in
            a, Model.Row_proof_attempt a) in
      goals_view#expand_row (goals_model#get_path row);
      Hashtbl.add g.Model.external_proofs id a;
      a
  in
  redo_external_proof g a;
  List.iter
    (fun t -> List.iter (prover_on_goal p) t.Model.subgoals)
    g.Model.transformations
    
let prover_on_unproved_goals p =
  List.iter
    (fun th ->
       List.iter
         (fun g -> if not g.Model.proved then prover_on_goal p g)
         th.Model.goals;
    )
    !Model.all

let rec prover_on_goal_or_children p g =
  if not g.Model.proved then 
    begin
      match g.Model.transformations with
	| [] -> prover_on_goal p g
	| l ->
	    List.iter (fun t -> 
			 List.iter (prover_on_goal_or_children p) 
			   t.Model.subgoals) l
    end

let prover_on_selected_goal_or_children pr row =
  let row = filter_model#get_iter row in
  match filter_model#get ~row ~column:Model.index_column with
    | Model.Row_goal g ->
	prover_on_goal_or_children pr g
    | Model.Row_theory th -> 
	List.iter (prover_on_goal_or_children pr) th.Model.goals
    | Model.Row_proof_attempt a ->
	prover_on_goal_or_children pr a.Model.proof_goal
    | Model.Row_transformation tr ->
	List.iter (prover_on_goal_or_children pr) tr.Model.subgoals

let prover_on_selected_goals pr =
  List.iter
    (prover_on_selected_goal_or_children pr)
    goals_view#selection#get_selected_rows 

(*****************************************************)
(* method: split all unproved goals *)
(*****************************************************)

let split_transformation = Trans.lookup_transform_l "split_goal" gconfig.env
let intro_transformation = Trans.lookup_transform "introduce_premises" gconfig.env
let lookup_transform s = Trans.lookup_transform s gconfig.env
let lookup_transform_l s = Trans.lookup_transform_l s gconfig.env
let split_transformation = lookup_transform_l "split_goal"
let intro_transformation = lookup_transform "introduce_premises"

let build_subtree g row name abort_cond subgoals =
  let goal_name = goals_model#get ~row ~column:Model.name_column in
  if not (abort_cond subgoals) then
    let nrow, tr = new_row ~parent:row ~icon:!image_transf name
      (fun r ->
        let tr =
          { Model.parent_goal = g; Model.transf_row = r; subgoals = []; } in
        tr, Model.Row_transformation tr) in
    g.Model.transformations <- tr :: g.Model.transformations;
    let goals,_ = List.fold_left
      (fun (acc,count) subtask ->
         let _id = (Task.task_goal subtask).Decl.pr_name in
         let _, goal =
           new_row ~parent:nrow ~icon:!image_file
                   (goal_name ^ "." ^ (string_of_int count))
                   (fun r ->
                     let goal =
                       { Model.parent = Model.Transf tr;
                         Model.task = subtask ;
                         Model.goal_row = r;
                         Model.external_proofs = Hashtbl.create 7;
                         Model.transformations = [];
                         Model.proved = false; } in
                     goal, Model.Row_goal goal) in
         (goal :: acc, count+1))
      ([],1) subgoals
    in
    tr.Model.subgoals <- List.rev goals;
    goals_view#expand_row (goals_model#get_path row);
    goals_view#expand_row (goals_model#get_path nrow)

 let split_unproved_goals () =
  List.iter (fun th ->
    List.iter (fun g ->
      if not g.Model.proved then
        let row = g.Model.goal_row in
        let callback =
          build_subtree g row "split" (fun l -> List.length l < 2) in
        Scheduler.apply_transformation_l ~callback
          split_transformation g.Model.task
      ) th.Model.goals
    ) !Model.all

(*************)
(* File menu *)
(*************)

let file_menu = factory#add_submenu "_File" 
let file_factory = new GMenu.factory file_menu ~accel_group 

let (_ : GMenu.image_menu_item) = 
  file_factory#add_image_item ~label:"_Preferences" ~callback:
    (fun () ->
       Gconfig.preferences gconfig;
       Scheduler.maximum_running_proofs := gconfig.max_running_processes)
    () 

let refresh_provers = ref (fun () -> ())

let (_ : GMenu.image_menu_item) = 
  file_factory#add_image_item ~label:"_Detect provers" ~callback:
    (fun () -> Gconfig.run_auto_detection gconfig; !refresh_provers () )
    () 

let (_ : GMenu.image_menu_item) = 
  file_factory#add_image_item ~key:GdkKeysyms._Q ~label:"_Quit" 
    ~callback:exit_function () 

(*************)
(* View menu *)
(*************)

let view_menu = factory#add_submenu "_View" 
let view_factory = new GMenu.factory view_menu ~accel_group 
let (_ : GMenu.image_menu_item) = 
  view_factory#add_image_item ~key:GdkKeysyms._E 
    ~label:"Expand all" ~callback:(fun () -> goals_view#expand_all ()) () 

let rec collapse_proved_goal g =
  if g.Model.proved then
    begin
      let row = g.Model.goal_row in
      goals_view#collapse_row (goals_model#get_path row);
    end
  else
    List.iter
      (fun t -> List.iter collapse_proved_goal t.Model.subgoals)
      g.Model.transformations

let collapse_verified_theories () =
  List.iter
    (fun th ->
       if th.Model.verified then
         begin
           let row = th.Model.theory_row in
           goals_view#collapse_row (goals_model#get_path row);
         end
       else
         List.iter collapse_proved_goal th.Model.goals)
    !Model.all

let (_ : GMenu.image_menu_item) = 
  view_factory#add_image_item ~key:GdkKeysyms._C
    ~label:"Collapse proved goals" 
    ~callback:collapse_verified_theories 
    () 
  
let rec hide_proved_goal g =
  if g.Model.proved then
    begin
      let row = g.Model.goal_row in
      goals_view#collapse_row (goals_model#get_path row);
      goals_model#set ~row ~column:Model.visible_column false
    end
  else
    List.iter 
      (fun t -> List.iter hide_proved_goal t.Model.subgoals)
      g.Model.transformations

let hide_verified_theories () =
  List.iter
    (fun th ->
       if th.Model.verified then
         begin
           let row = th.Model.theory_row in
           goals_view#collapse_row (goals_model#get_path row);
           goals_model#set ~row ~column:Model.visible_column false
         end
       else
         List.iter hide_proved_goal th.Model.goals)
    !Model.all
    

let rec show_all_goals g =
  let row = g.Model.goal_row in
  goals_model#set ~row ~column:Model.visible_column true;
  if g.Model.proved then
    goals_view#collapse_row (goals_model#get_path row)
  else
    goals_view#expand_row (goals_model#get_path row);
  List.iter 
    (fun t -> List.iter show_all_goals t.Model.subgoals)
    g.Model.transformations

let show_all_theories () = 
  List.iter
    (fun th ->
       let row = th.Model.theory_row in
       goals_model#set ~row ~column:Model.visible_column true;
       if th.Model.verified then
         goals_view#collapse_row (goals_model#get_path row)
       else
         goals_view#expand_row (goals_model#get_path row);
       List.iter show_all_goals th.Model.goals)
    !Model.all
    


let (_ : GMenu.check_menu_item) = view_factory#add_check_item 
  ~callback:(fun b ->
               Model.toggle_hide_proved_goals := b;
               if b then hide_verified_theories ()
               else show_all_theories ())
  "Hide proved goals"
  

(**************)
(* Tools menu *)
(**************)

let add_refresh_provers f =
  let rp = !refresh_provers in
  refresh_provers := (fun () -> rp (); f ())


let tools_menu = factory#add_submenu "_Tools" 
let tools_factory = new GMenu.factory tools_menu ~accel_group 

let () = add_refresh_provers (fun () ->
  List.iter (fun item -> item#destroy ()) tools_menu#all_children)

let () =
  let add_item_provers () =
    Util.Mstr.iter 
      (fun _ p ->
	 let n = p.prover_name ^ " " ^ p.prover_version in
	 let (_ : GMenu.image_menu_item) =
           tools_factory#add_image_item ~label:(n ^ " on all unproved goals")
	     ~callback:(fun () -> prover_on_unproved_goals p)
	     ()
	 in
	 let (_ : GMenu.image_menu_item) =
           tools_factory#add_image_item ~label:(n ^ " on selection")
	     ~callback:(fun () -> prover_on_selected_goals p)
	     ()
	 in ()) 
      gconfig.provers 
  in
  add_refresh_provers add_item_provers;
  add_item_provers ()

let add_transformation_entry label callback =
  let add_item () =
    ignore(tools_factory#add_image_item ~label ~callback ()) in
  add_refresh_provers add_item;
  add_item ()

let () =
  add_transformation_entry "Split unproved goals" split_unproved_goals


(*************)
(* Help menu *)
(*************)

(*
let info_window t s () =
  let d = GWindow.message_dialog
    ~message:s
    ~message_type:`INFO
    ~buttons:GWindow.Buttons.close
    ~title:t
    ~show:true () 
  in
  let (_ : GtkSignal.id) =
    d#connect#response 
      ~callback:(function `CLOSE | `DELETE_EVENT -> d#destroy ())
  in
  ()
*)

let help_menu = factory#add_submenu "_Help" 
let help_factory = new GMenu.factory help_menu ~accel_group 

let (_ : GMenu.image_menu_item) = 
  help_factory#add_image_item 
    ~label:"Legend" 
    ~callback:show_legend_window
    () 

let (_ : GMenu.image_menu_item) = 
  help_factory#add_image_item 
    ~label:"About" 
    ~callback:show_about_window
    () 


(******************************)
(* vertical paned on the right*)
(******************************)

let vp = GPack.paned `VERTICAL  ~border_width:3 ~packing:hp#add () 

(******************)
(* goal text view *)
(******************)

let scrolled_task_view = GBin.scrolled_window
  ~hpolicy: `AUTOMATIC ~vpolicy: `AUTOMATIC
  ~packing:vp#add ()
  
let (_ : GtkSignal.id) = 
  scrolled_task_view#misc#connect#size_allocate 
    ~callback:
    (fun {Gtk.width=_w;Gtk.height=h} -> 
       gconfig.task_height <- h)

let task_view =
  GSourceView2.source_view
    ~editable:false
    ~show_line_numbers:true
    ~packing:scrolled_task_view#add 
    ~height:gconfig.task_height
    ()

let () = task_view#source_buffer#set_language lang
let () = task_view#set_highlight_current_line true

(***************)
(* source view *)
(***************)

let scrolled_source_view = GBin.scrolled_window
  ~hpolicy: `AUTOMATIC ~vpolicy: `AUTOMATIC
  ~packing:vp#add 
  ()
  
let source_view =
  GSourceView2.source_view
    ~auto_indent:true
    ~insert_spaces_instead_of_tabs:true ~tab_width:2
    ~show_line_numbers:true
    ~right_margin_position:80 ~show_right_margin:true
    (* ~smart_home_end:true *)
    ~packing:scrolled_source_view#add 
    ()

let current_file = ref ""

(*
  source_view#misc#modify_font_by_name font_name;
*)
let () = source_view#source_buffer#set_language lang
let () = source_view#set_highlight_current_line true
(*
let () = source_view#source_buffer#set_text (source_text fname)
*)

let move_to_line (v : GSourceView2.source_view) line = 
  if line <= v#buffer#line_count && line <> 0 then begin
    let it = v#buffer#get_iter (`LINE line) in 
    let mark = `MARK (v#buffer#create_mark it) in
    v#scroll_to_mark ~use_align:true ~yalign:0.0 mark
  end

let orange_bg = source_view#buffer#create_tag 
  ~name:"orange_bg" [`BACKGROUND "orange"] 

let erase_color_loc (v:GSourceView2.source_view) =
  let buf = v#buffer in
  buf#remove_tag orange_bg ~start:buf#start_iter ~stop:buf#end_iter

let color_loc (v:GSourceView2.source_view) l b e =
  let buf = v#buffer in
  let top = buf#start_iter in
  let start = top#forward_lines (l-1) in
  let start = start#forward_chars b in
  let stop = start#forward_chars (e-b) in
  buf#apply_tag ~start ~stop orange_bg

let scroll_to_id id =
  match id.Ident.id_origin with
    | Ident.User loc -> 
	let (f,l,b,e) = Loc.extract loc in
	if f <> !current_file then
	  begin
	    source_view#source_buffer#set_text (source_text f);
	    current_file := f;
	  end;
	move_to_line source_view (l-1);
	erase_color_loc source_view;
	color_loc source_view l b e
    | Ident.Fresh -> 
	source_view#source_buffer#set_text "Fresh ident (no position available)\n";
	current_file := ""
    | Ident.Derived _ -> 
	source_view#source_buffer#set_text "Derived ident (no position available)\n";
	current_file := ""

let color_label = function
  | _, Some loc when (fst loc).Lexing.pos_fname = !current_file ->
      let _, l, b, e = Loc.extract loc in
      color_loc source_view l b e
  | _ ->
      ()

let rec color_f_labels () f =
  List.iter color_label f.Term.f_label;
  Term.f_fold color_t_labels color_f_labels () f

and color_t_labels () t =
  List.iter color_label t.Term.t_label;
  Term.t_fold color_t_labels color_f_labels () t

let scroll_to_source_goal g =
  let t = g.Model.task in
  let id = (Task.task_goal t).Decl.pr_name in
  scroll_to_id id;
  match t with
    | Some 
	{ Task.task_decl = 
	    { Theory.td_node = 
		Theory.Decl { Decl.d_node = Decl.Dprop (Decl.Pgoal, _, f) }}} ->
	color_f_labels () f
    | _ ->
	assert false

let scroll_to_theory th = 
  let t = th.Model.theory in
  let id = t.Theory.th_name in
  scroll_to_id id

(* to be run when a row in the tree view is selected *)
let select_row p = 
  let row = filter_model#get_iter p in
  match filter_model#get ~row ~column:Model.index_column with
    | Model.Row_goal g ->
        let t = g.Model.task in
        let t = Trans.apply intro_transformation t in 
        let task_text = Pp.string_of Pretty.print_task t in
        task_view#source_buffer#set_text task_text;
        task_view#scroll_to_mark `INSERT;
	scroll_to_source_goal g
    | Model.Row_theory th ->
        task_view#source_buffer#set_text ""; 
	scroll_to_theory th
    | Model.Row_proof_attempt a ->
        task_view#source_buffer#set_text a.Model.output;
	scroll_to_source_goal a.Model.proof_goal
    | Model.Row_transformation tr ->
        task_view#source_buffer#set_text "";
	scroll_to_source_goal tr.Model.parent_goal


  

(*****************************)
(* method: edit current goal *)
(*****************************)

let edit_selected_row p =
  let row = filter_model#get_iter p in
  match filter_model#get ~row ~column:Model.index_column with
    | Model.Row_goal _g ->
        ()
    | Model.Row_theory _th ->
        ()
    | Model.Row_proof_attempt a ->
        let g = a.Model.proof_goal in
        let t = g.Model.task in
        let driver = a.Model.prover.driver in
        let file = Driver.file_of_task driver fname "" t in
        a.Model.edited_as <- file;
        let old_status = a.Model.status in
        Helpers.set_proof_status a Scheduler.Running;
        let callback () =
          Helpers.set_proof_status a old_status;
        in
        let editor = 
          match a.Model.prover.editor with
            | "" -> gconfig.default_editor
            | _ -> a.Model.prover.editor
        in
        Scheduler.edit_proof ~debug:false ~editor
          ~file
          ~driver
          ~callback
          t
    | Model.Row_transformation _tr ->
        ()

let edit_current_proof () =
  match goals_view#selection#get_selected_rows with
    | [] -> ()
    | [r] -> edit_selected_row r
    | _ -> assert false (* multi-selection is disabled *)

let add_item_edit () =
  ignore (tools_factory#add_image_item
            ~label:"Edit current proof"
            ~callback:edit_current_proof
            () : GMenu.image_menu_item)

let () =
  add_refresh_provers add_item_edit;
  add_item_edit ()



  
(***************)
(* Bind events *)
(***************)

(* row selection on tree view on the left *) 
let (_ : GtkSignal.id) =
  goals_view#selection#connect#after#changed ~callback:
    begin fun () ->
      match goals_view#selection#get_selected_rows with
        | [p] -> select_row p
        | [] -> ()
        | _ -> () 
    end

let () = w#add_accel_group accel_group
let () = w#show () 
let () = GtkThread.main ()

(*
Local Variables: 
compile-command: "unset LANG; make -C ../.. bin/whyide.opt"
End: 
*)