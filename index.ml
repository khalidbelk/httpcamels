open Tyxml.Html

let css =
  {css|

@font-face {
  font-family: SpaceGrotesk;
  src: url(/font);
}

:root {
  --camlorange: #ee6a1a;
  --sandcolor: #f9e5d8;
}

body {
  background-color: var(--sandcolor);
  background-image: url(/dunes.svg);

  font-family: sans-serif;
  margin: 0;
  padding: 2rem 12vw;
  text-align: center;
  box-sizing: border-box;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

h1 {
  font-family: SpaceGrotesk, sans-serif;
  font-display: swap;
}

h1 img {
  height: 2em;
  vertical-align: middle;
  margin-right: 0.3em;
}

input {
  outline: none;
  width: 30%;
  min-width: 16rem;
  padding: 0.6rem 2.5rem 0.6rem 0.7rem;
  font-size: 1rem;
  border: 2px solid var(--camlorange);
  border-radius: 1rem;
  background: var(--sandcolor) url(/search.svg) no-repeat right 0.7rem center / 1.1rem;
}

input::placeholder {
  color: #353434;
  font-style: italic;
}

.grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 2rem 1.5rem;
  margin-top: 3rem;
}

button {
  aspect-ratio: 4 / 3;
  padding: 0;
  overflow: hidden;
  background: #f2f2f2;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
}

button img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.signature {
  font-style: italic;
  margin-top: auto;
  padding-top: 2rem;
  font-size: 0.85rem;
}

.signature a {
  color: inherit;
  text-decoration: underline;
  text-decoration-color: var(--camlorange);
  text-underline-offset: 0.2em;

  background: linear-gradient(rgba(238, 106, 26, 0.35),
    rgba(238, 106, 26, 0.35))
    no-repeat left / 0% 100%;

  transition: background-size 0.3s ease;
}

.signature a:hover {
  background-size: 100% 100%;
}

|css}

(* TODO: paste link "https://host/<code>" div *)

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
         style [ txt css ];
         link ~rel:[ `Icon ] ~href:"/logo.png" ~a:[ a_mime_type "image/png" ] ();
       ])
    (body
       [
         h1 [ txt "HttpCamels"; img ~src:"/logo.png" ~alt:"" () ];
         search_bar;
         div ~a:[ a_class [ "grid" ] ] (List.map camel (pick 8));
         unikernel_signature_html;
       ])

let render_index () = Format.asprintf "%a" (pp ()) (doc ())
