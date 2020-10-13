(*s: semgrep/matching/Unit_matcher.ml *)
open Common
open OUnit

module A = AST_generic
module PPG = Pretty_print_generic

(*****************************************************************************)
(* Semgrep Unit tests *)
(*****************************************************************************)
let test_path = "../../../tests/OTHER/SYNTHESIZING/"

(* Format: file, range of code to infer, expected patterns *)
let python_tests = [
  "arrays_and_funcs.py", "3:3-3:23",
  ["exact match", "a.bar(f(x), y == f(x))";
   "dots", "a.bar(...)";
   "metavars", "a.bar($X, $Y, ...)";
   "exact metavars", "a.bar($X, $Y)";
   "deep metavars", "a.bar(f($X), $Y == f($X))"
  ];

  "arrays_and_funcs.py", "4:9-4:29",
  ["exact match", "metrics.send('my-report-id')";
   "dots", "metrics.send(...)";
   "metavars", "metrics.send('...', ...)";
   "exact metavars", "metrics.send('...')"
  ];

  "arrays_and_funcs.py", "5:4-5:11",
  ["exact match", "(hi, my)"];

  "arrays_and_funcs.py", "6:1-6:14",
  ["exact match", "(hi, my, bye)"];

  "arrays_and_funcs.py", "7:3-7:7",
  ["exact match", "A[1]"];

  "arrays_and_funcs.py", "8:3-8:8",
  ["exact match", "A[-(1)]"];

  "arrays_and_funcs.py", "9:3-9:9",
  ["exact match", "A[1:4]"];

  "arrays_and_funcs.py", "10:3-10:12",
  ["exact match", "A[1:4:-(1)]"];

  "arrays_and_funcs.py", "11:3-11:10",
  ["exact match", "A[::-(1)]"];

  "arrays_and_funcs.py", "12:3-12:8",
  ["exact match", "A[1:]"];

  "arrays_and_funcs.py", "13:3-13:14",
  ["exact match", "1 == 1";
   "exact metavars", "$X == $X"];

  "arrays_and_funcs.py", "14:3-14:7",
  ["exact match", "true";
   "metavar", "$X"];

  "arrays_and_funcs.py", "15:3-15:6",
  ["exact match", "3.3";
   "metavar", "$X"];

  "arrays_and_funcs.py", "16:3-16:12",
  ["exact match", "self.data";
   "metavar", "$X"];

  "arrays_and_funcs.py", "17:3-17:36",
  ["exact match", "'nice' if is_nice else 'not nice'"];

  "arrays_and_funcs.py", "18:3-18:34",
  ["exact match", "f(a, b(g(a, k)), c, c(k), a, c)";
   "dots", "f(...)";
   "metavars", "f($X, $Y, $Z, $A, $X, $Z, ...)";
   "exact metavars", "f($X, $Y, $Z, $A, $X, $Z)";
   "deep metavars", "f($X, b(g($X, $Y)), $Z, c($Y), $X, $Z)"
  ];

  "arrays_and_funcs.py", "19:6-19:27",
  ["exact match", "node.id == node.id";
   "exact metavars", "$X == $X"];

   "set_cookie.py", "5:10-7:35",
   ["exact match", "flask.response.set_cookie('sessionid', generate_cookie_value('RANDOM-UUID'), secure=True)";
    "dots", "flask.response.set_cookie(...)";
    "metavars", "flask.response.set_cookie('...', $Y, secure=$Z, ...)";
    "exact metavars", "flask.response.set_cookie('...', $Y, secure=$Z)";
    "deep metavars", "flask.response.set_cookie('...', generate_cookie_value('...'), secure=$Z)"
   ];

   "set_cookie.py", "8:3-8:31",
   [
     "exact match", "a = set_cookie(1234, b, 123)";
     "dots", "a = ...";
     "metavars", "$X = $Y";
     "righthand dots", "$X = set_cookie(...)";
     "righthand metavars", "$X = set_cookie($Y, $Z, $A, ...)";
     "righthand exact metavars", "$X = set_cookie($Y, $Z, $A)"
   ];

   "import_as.py", "2:0-2:25",
   [
    "exact match", "exec(user_input)";
    "dots", "exec(...)";
    "metavars", "exec($X, ...)";
    "exact metavars", "exec($X)"
   ]
]

let java_tests = [
  "typed_funcs.java", "6:8-6:14",
  ["exact match", "this.foo(a);";
   "dots", "this.foo(...);";
   "metavars", "this.foo($X, ...);";
   "exact metavars", "this.foo($X);";
   "typed metavars", "this.foo((int $X));"
  ];

  "typed_funcs.java", "7:8-7:42",
  ["exact match", "this.foo(this.bar(this.car(a)), b, this.foo(b, c), d);";
   "dots", "this.foo(...);";
   "metavars", "this.foo($X, $Y, $Z, $A, ...);";
   "exact metavars", "this.foo($X, $Y, $Z, $A);";
   "typed metavars",
     "this.foo(this.bar(this.car((int $X))), (String $Y), this.foo((String $Y), (bool $Z)), $A);";
   "deep metavars", "this.foo(this.bar(this.car($X)), $Y, this.foo($Y, $Z), $A);"
  ];

  "typed_funcs.java", "8:8-8:26",
  ["exact match", "this.foo(this.foo(a, b), c);";
   "dots", "this.foo(...);";
   "metavars", "this.foo($X, $Y, ...);";
   "exact metavars", "this.foo($X, $Y);";
   "typed metavars", "this.foo(this.foo((int $X), (String $Y)), (bool $Z));";
   "deep metavars", "this.foo(this.foo($X, $Y), $Z);"
  ];

   "typed_funcs.java", "6:12-6:14",
   ["exact match", "a";
     "metavar", "$X";
     "typed metavar", "(int $X)"
   ];

  "typed_funcs.java", "10:8-10:30",
  ["exact match", "System.out.print(\"A\");";
   "dots", "System.out.print(...);";
   "metavars", "System.out.print(\"...\", ...);";
   "exact metavars", "System.out.print(\"...\");";
  ];

  "typed_funcs.java", "11:20-11:47",
  ["exact match", "new Scanner(new File(), 1)"];

  "typed_funcs.java", "12:10-12:38",
  ["exact match", "this.foo(this.bar(a)) == this.foo(this.bar(a))";
  "exact metavars", "$X == $X";
  "typed metavars", "this.foo(this.bar((int $X))) == this.foo(this.bar((int $X)))";
  "deep metavars", "this.foo(this.bar($X)) == this.foo(this.bar($X))";
  ];

  (* "exact_match.java", "4:15-4:42",
  ["exact match", "this.foo(this.bar(a)) == this.foo(this.bar(a))";
  "exact metavars", "$X == $X";
  "typed metavars", "this.foo(this.bar((int $X))) == this.foo(this.bar((int $X)))";
  "deep metavars", "this.foo(this.bar($X)) == this.foo(this.bar($X))";
  ]; *)
]

(* Cases splits up the test cases by language.
 * For each item in tests, this expects a filename, range, and solutions.
 * Patterns will be inferred from the file at filename in the given range.
 * The list of patterns will be checked against the expected solutions,
 * which they should match exactly.
 * They will then be matched against the code at the given range to make
 * sure semgrep actually correctly matches the pattern to the code.
 * Place test files in semgrep-core/tests/SYNTHESIZING
 *)

let unittest =
  "pattern inference features" >:: (fun () ->
    let cases = [Lang.Python, python_tests; Lang.Java, java_tests]
    in
    cases |> List.iter (fun (lang, tests) ->
    tests |> List.iter (fun (filename, range, sols) ->
        let file = test_path ^ filename in
        let pats = Synthesizer.synthesize_patterns range file in
        let code =
          Parse_program.parse_and_resolve_name_use_pfff_or_treesitter
            lang file in
        let code =
          match code with
          | Program.Semgrep x -> x
          | Program.Spacegrep _ -> failwith "not supported for spacegrep"
        in
        let r = Range.range_of_linecol_spec range file in
        Naming_AST.resolve lang code; (* wasn't it done already? *)
        let check_pats (str, pat) =
          try
            let pattern =
              match Parse_pattern.parse lang pat with
              | Pattern.Semgrep x -> x
              | Pattern.Spacegrep _ -> failwith "not supported for spacegrep"
            in
            let e_opt = Range_to_AST.any_at_range r code in
               match e_opt with
                 | Some any ->
                    let a = match (pattern, any) with
                              | (A.E _, A.S (A.ExprStmt (e, _))) -> A.E e
                              | (_, x) -> x in
                    let matches_with_env = Semgrep_generic.match_any_any
                          pattern a in
                    (* Debugging note: uses pattern_to_string for convenience,
                     * but really should match the code in the given file at
                     * the given range *)
                    if matches_with_env = []
                    then begin
                      pr2 str;
                      pr2 (AST_generic.show_any (pattern));
                      pr2 (AST_generic.show_any a);

                    end;
                    assert_bool (spf "pattern:|%s| should match |%s"
                              pat
                              (PPG.pattern_to_string lang a))
                           (matches_with_env <> [])

                 | None ->
                    failwith (spf "Couldn't find range %s in %s" range file)
          with
            Parsing.Parse_error ->
            failwith (spf "problem parsing %s" pat)
        in
        pats |> List.iter check_pats;
        let pats_str =
           List.fold_left (fun s (s1, s2) -> s^s1^": "^s2^"\n") "" pats in
        assert_bool ("Patterns do not match solution, where inferred patterns are:\n" ^ pats_str)
              (pats = sols)
    )
    )
  )
