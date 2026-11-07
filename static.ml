type mime_type = [ `Png | `Jpeg | `Svg | `Css | `Ttf ]
type header = string * string

let header_of_mime_type (mime : mime_type) : header =
  let m =
    match mime with
    | `Png -> "image/png"
    | `Jpeg -> "image/jpeg"
    | `Svg -> "image/svg+xml"
    | `Css -> "text/css"
    | `Ttf -> "font/ttf"
  in
  ("content-type", m)

type t = { route : string; mime_type : mime_type }

let v route mime_type = { route; mime_type }

let all =
  [
    v "/index.css" `Css;
    v "/SpaceGrotesk-Regular.ttf" `Ttf;
    v "/dunes.svg" `Svg;
    v "/logo.png" `Png;
    v "/search.svg" `Svg;
  ]

let find route = List.find_opt (fun a -> a.route = route) all
let headers a = [ header_of_mime_type a.mime_type ]
