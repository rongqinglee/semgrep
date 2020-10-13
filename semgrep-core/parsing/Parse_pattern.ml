(* Yoann Padioleau
 *
 * Copyright (C) 2020 r2c
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License (GPL)
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * file license.txt for more details.
 *)

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)
(* Expose all the pattern parsers as one.
 *)

(*****************************************************************************)
(* Entry point *)
(*****************************************************************************)
let parse lang string =
  match lang with
  | Lang.Spacegrep -> Pattern.Spacegrep (Parse_spacegrep.parse_program file)
  | lang -> Pattern.Semgrep (Check_semgrep.parse_check_pattern lang string)
