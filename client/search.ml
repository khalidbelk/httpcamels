open Brr
open Fut.Syntax

let contains ~sub s =
  let n = String.length s and m = String.length sub in
  let rec go i = i + m <= n && (String.sub s i m = sub || go (i + 1)) in
  go 0

let matches query (entry : Codes.t) =
  String.starts_with ~prefix:query (string_of_int entry.code)
  || contains ~sub:query (String.lowercase_ascii entry.name)

let render (entry : Codes.t) =
  let code = string_of_int entry.code in
  El.li
    [
      El.a
        ~at:[ At.href (Jstr.v ("/" ^ code)) ]
        [
          El.strong [ El.txt' (code ^ " " ^ entry.name) ];
          El.span [ El.txt' entry.description ];
        ];
    ]

let fetch_codes () =
  let* response = Brr_io.Fetch.url (Jstr.v "/codes.json") in
  match response with
  | Error _ -> Fut.return []
  | Ok response -> (
      let* body =
        Brr_io.Fetch.Body.text (Brr_io.Fetch.Response.as_body response)
      in
      match body with
      | Error _ -> Fut.return []
      | Ok text -> (
          match Yojson.Safe.from_string (Jstr.to_string text) with
          | `List items ->
              Fut.return
                (List.filter_map
                   (fun item -> Result.to_option (Codes.of_yojson item))
                   items)
          | _ -> Fut.return []
          | exception Yojson.Json_error _ -> Fut.return []))

let () =
  let by_id id = Document.find_el_by_id G.document (Jstr.v id) in
  let by_selector sel = El.find_first_by_selector (Jstr.v sel) in
  match
    (by_selector {|input[name="q"]|}, by_id "results", by_selector ".grid")
  with
  | Some input, Some results, Some grid ->
      let codes = ref [] in
      ignore
        (let* all = fetch_codes () in
         codes := all;
         Fut.return ());
      let on_input _ =
        let query =
          El.prop El.Prop.value input
          |> Jstr.to_string
          |> String.trim
          |> String.lowercase_ascii
        in
        let found =
          if query = "" then []
          else List.filter (matches query) !codes
        in
        El.set_children results (List.map render found);
        El.set_inline_style El.Style.display
          (Jstr.v (if query = "" then "" else "none"))
          grid
      in
      ignore (Ev.listen Ev.input on_input (El.as_target input))
  | _ -> ()
