(*
   Expose all the pattern parsers as one.
*)

(* Parse a string representing a pattern for a given language. *)
val parse: Lang.t -> string -> Pattern.t
