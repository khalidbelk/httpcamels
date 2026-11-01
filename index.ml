open Tyxml.Html

let getrand () = Random.int 1000

let doc ~numbah =
  html
    (head (title (txt "Http Codes API")) [])
    (body
       [
         txt "Hello world !";
         br ();
         txt ("This is the random number " ^ Int.to_string numbah);
       ])

let render doc = Format.asprintf "%a" (Tyxml.Html.pp ()) doc
let render_index ~numbah = render (doc ~numbah)
