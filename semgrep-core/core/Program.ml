(*
   Similar to the Pattern module, this provides a unified type for representing
   a parsed program.
*)

type t =
  | Semgrep of Lang.t * AST_generic.program
  | Spacegrep of Spacegrep.Doc_AST.t
