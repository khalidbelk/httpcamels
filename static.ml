type mime_type = [ `Png | `Jpeg | `Svg | `Ico | `Css | `Ttf | `Js | `Json ]
type header = string * string

let default_maxage_secs = 3600 (* 1hour *)
let max_age secs = Fmt.str "max-age=%d" secs

let cache_control ~seconds =
  ("cache-control", Fmt.str "public, %s" (max_age seconds))

let maxage_of_mime_type = function
  | `Jpeg
  | `Ico
  | `Ttf ->
      604800 (* 7days *)
  | `Png
  | `Svg
  | `Css
  | `Js
  | `Json ->
      default_maxage_secs

let header_of_mime_type (mime : mime_type) : header =
  let m =
    match mime with
    | `Png -> "image/png"
    | `Ico -> "image/x-icon"
    | `Jpeg -> "image/jpeg"
    | `Svg -> "image/svg+xml"
    | `Css -> "text/css"
    | `Ttf -> "font/ttf"
    | `Js -> "text/javascript"
    | `Json -> "application/json"
  in
  ("content-type", m)

type t = { route : string; mime_type : mime_type }

let v route mime_type = { route; mime_type }

let all =
  [
    v "/index.css" `Css;
    v "/SpaceGrotesk-Regular.ttf" `Ttf;
    v "/dunes.svg" `Svg;
    v "/logo.ico" `Ico;
    v "/logo.png" `Png;
    v "/search.svg" `Svg;
    v "/clipboard.svg" `Svg;
    v "/check.svg" `Svg;
    v "/octocat.svg" `Svg;
    v "/client.js" `Js;
  ]

let find route = List.find_opt (fun a -> a.route = route) all

let default_headers_of_mime_type ~mt:t =
  [ header_of_mime_type t; cache_control ~seconds:(maxage_of_mime_type t) ]

let headers_of_asset a = default_headers_of_mime_type ~mt:a.mime_type
