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

let fetch_text url =
  let* response = Brr_io.Fetch.url (Jstr.v url) in
  match response with
  | Error error -> Fut.return (Error (Dom.error_message error))
  | Ok response when not (Brr_io.Fetch.Response.ok response) ->
      let status = Brr_io.Fetch.Response.status response in
      Fut.return (Error (Printf.sprintf "%s answered HTTP %d" url status))
  | Ok response ->
      let+ body =
        Brr_io.Fetch.Body.text (Brr_io.Fetch.Response.as_body response)
      in
      body |> Result.map Jstr.to_string |> Result.map_error Dom.error_message

let decode_codes text =
  match Yojson.Safe.from_string text with
  | exception Yojson.Json_error message -> Error message
  | `List items ->
      Ok
        (List.filter_map
           (fun item -> Result.to_option (Codes.of_yojson item))
           items)
  | _ -> Error "expected a JSON array"

let fetch_codes () =
  let+ text = fetch_text "/codes.json" in
  Result.bind text decode_codes

let typed_query input =
  El.prop El.Prop.value input
  |> Jstr.to_string
  |> String.trim
  |> String.lowercase_ascii

let start ~input ~results ~grid =
  let codes = ref [] in
  let refresh () =
    let query = typed_query input in
    let found = if query = "" then [] else List.filter (matches query) !codes in
    El.set_children results (List.map render found);

    let grid_display = if query = "" then "" else "none" in
    El.set_inline_style El.Style.display (Jstr.v grid_display) grid
  in
  ignore (Ev.listen Ev.input (fun _ -> refresh ()) (El.as_target input));
  Fut.await (fetch_codes ()) (function
    | Ok fetched ->
        codes := fetched;
        refresh ()
    | Error message -> Dom.log_error ("could not load /codes.json: " ^ message))

(* Does nothing if the page lacks one of the elements,
  which [Dom.find] has already reported *)
let init () =
  let open Dom.Syntax in
  let started =
    let+ input = Dom.find Ids.search_input
    and+ results = Dom.find Ids.results
    and+ grid = Dom.find Ids.grid in
    start ~input ~results ~grid
  in
  Option.value started ~default:()
