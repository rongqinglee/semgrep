(*
   Parse a program, any program, using the best parsers we have.
*)

(* This uses the pfff or tree-sitter parsers, possibly trying both if one
   fails. Also can use spacegrep.
 * This also resolve names and propagate constants.
 *)
val parse_and_resolve_name_use_pfff_or_treesitter:
  Lang.t -> Common.filename -> Program.t

(* used only for testing purpose *)
val just_parse_with_lang: Lang.t -> Common.filename -> Program.t
