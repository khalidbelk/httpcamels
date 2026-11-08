open Tyxml.Html

let paste_box =
  div
    ~a:[ a_class [ "paste" ] ]
    [
      code ~a:[ a_id Ids.paste_url ] [ txt "https://host/<code>" ];
      button
        ~a:
          [
            a_id Ids.paste_copy; a_button_type `Button; a_title "Copy link";
          ]
        [ img ~src:"/clipboard.svg" ~alt:"Copy" ~a:[ a_id Ids.paste_icon ] () ];
    ]

let pick n =
  Codes.all
  |> List.map (fun c -> (Random.bits (), c.Codes.code))
  |> List.sort (fun (a, _) (b, _) -> compare a b)
  |> List.filteri (fun i _ -> i < n)
  |> List.map snd

let handle_input ~query =
  Printf.sprintf "location.href='/' + encodeURIComponent(%s); return false"
    query

let handle_click ~code = Printf.sprintf "location.href='/%s'" code
let code_pattern = "[1-5][0-9]{2}"

let search_bar =
  form
    ~a:[ a_onsubmit (handle_input ~query:"this.q.value") ]
    [
      input
        ~a:
          [
            a_id Ids.search_input;
            a_input_type `Search;
            a_autocomplete `Off;
            a_name "q";
            a_required ();
            a_pattern code_pattern;
            a_title "A valid HTTP status code, e.g. 404";
            a_placeholder "Search a status code, e.g. 404";
          ]
        ();
    ]

let search_results = ul ~a:[ a_id Ids.results ] []

let unikernel_signature_html =
  footer
    ~a:[ a_class [ "signature" ] ]
    [
      txt "This website is implemented as an ";
      a
        ~a:
          [
            a_href "https://ocaml.org/tools/unikernel-target"; a_target "_blank";
          ]
        [ txt "OCaml unikernel" ];
      txt " - ";
      a
        ~a:[ a_href "https://github.com/khalidbelk"; a_target "_blank" ]
        [ b [ txt "@khalidbelk" ]; txt ", 2026" ];
    ]

let camel code =
  let code = Int.to_string code in
  button
    ~a:[ a_button_type `Button; a_onclick (handle_click ~code) ]
    [ img ~src:("/" ^ code) ~alt:("HTTP " ^ code) () ]

let doc () =
  html
    (head
       (title (txt "HttpCamels"))
       [
         link ~rel:[ `Stylesheet ] ~href:"/index.css" ();
         link ~rel:[ `Icon ] ~href:"/logo.png" ();
         script ~a:[ a_src "/client.js"; a_defer () ] (txt "");
       ])
    (body
       [
         h1 [ txt "HttpCamels"; img ~src:"/logo.png" ~alt:"" () ];
         search_bar;
         paste_box;
         search_results;
         div ~a:[ a_class [ "grid" ]; a_id Ids.grid ] (List.map camel (pick 8));
         unikernel_signature_html;
       ])

let render_index () = Format.asprintf "%a" (pp ()) (doc ())
