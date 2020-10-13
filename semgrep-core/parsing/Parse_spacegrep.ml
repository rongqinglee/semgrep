(*
   Call the spacegrep parsers, taking of any translation that might
   be needed for semgrep.

   Note that spacegrep accepts any string as a valid pattern or program,
   so there shouldn't be parsing errors due to bad input.
*)

let parse_program file =
  Spacegrep.Src_file.of_file file
  |> Spacegrep.Parse_doc.of_src

let parse_pattern str =
  Spacegrep.Src_file.of_string str
  |> Spacegrep.Parse_pattern.of_src
