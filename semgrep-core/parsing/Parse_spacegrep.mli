(*
   Parse a file using spacegrep, which is not compatible with semgrep's
   generic AST.

   This module mirrors Parse_generic.
*)

val parse_program: Common.filename -> Spacegrep.Doc_AST.t
val parse_pattern : string -> Spacegrep.Pattern_AST.t
