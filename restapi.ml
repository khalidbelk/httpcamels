module Make (Assets : Mirage_kv.RO) = struct
  open Lwt.Syntax

  type ctx = Assets.t

  let src = Logs.Src.create "httpcamels.restapi"

  module Logger = (val Logs.src_log src : Logs.LOG)

  (* TODO : make this typesafe + create str_of_mimetype func *)
  let ttf_headers = [ ("content-type", "font/ttf") ]
  let image_headers = [ ("content-type", "image/jpeg") ]
  let png_headers = [ ("content-type", "image/png") ]
  let svg_headers = [ ("content-type", "image/svg+xml") ]

  let not_found_response =
    { App.status = `Not_found; headers = []; body = "not found" }

  let async_serve_asset ?(headers = image_headers) assets name :
      App.response Lwt.t =
    let* result = Assets.get assets (Mirage_kv.Key.v name) in
    match result with
    | Ok "" -> Lwt.return not_found_response
    | Ok body -> Lwt.return { App.status = `OK; headers; body }
    | Error e ->
        Logger.warn (fun f ->
            f "Couldn't get asset %s: %a" name Assets.pp_error e);
        Lwt.return
          {
            App.status = `Internal_server_error;
            headers = [];
            body = "An error ocurred while fetching the asset.";
          }

  (** Returns [true] if the code is in the valid codes hashtable, or [false]
      otherwise. *)
  let is_valid_c code : bool = Option.is_some (Codes.find code)

  let code_of_path path =
    match String.split_on_char '/' path with
    | [ ""; code ] -> int_of_string_opt code
    | _ -> None

  let route assets method' path : App.response Lwt.t =
    match (method', path) with
    | `GET, "/" ->
        Lwt.return
          { App.status = `OK; headers = []; body = Index.render_index () }
    | `GET, "/khello" ->
        Lwt.return { App.status = `OK; headers = []; body = "Khello !" }
    | `GET, "/font" ->
        async_serve_asset ~headers:ttf_headers assets
          "app/SpaceGrotesk-Regular.ttf"
    | `GET, "/dunes.svg" ->
        async_serve_asset ~headers:svg_headers assets "app/dunes.svg"
    | `GET, "/logo.png" ->
        async_serve_asset ~headers:png_headers assets "app/logo.png"
    | `GET, "/search.svg" ->
        async_serve_asset ~headers:svg_headers assets "app/search.svg"
    | `GET, p -> (
        match code_of_path p with
        | Some code when is_valid_c code ->
            async_serve_asset assets (Int.to_string code ^ ".jpg")
        | _ -> Lwt.return not_found_response)
    | _ -> Lwt.return not_found_response

  let validate_p ~path : (string, App.response) result =
    if String.length path > 256 then
      Error { status = `Uri_too_long; headers = []; body = "path too long" }
    else if path = "" || path.[0] <> '/' then
      Error { status = `Bad_request; headers = []; body = "bad path" }
    else Ok path

  (** Takes the request descripton and return a response accordingly *)
  let handle assets (request : H1.Request.t) : App.response Lwt.t =
    let m = request.meth and p = request.target in
    match validate_p ~path:p with
    | Error response -> Lwt.return response
    | Ok path -> route assets m path
end
