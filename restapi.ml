module Make (Assets : Mirage_kv.RO) = struct
  open Lwt.Syntax

  type ctx = Assets.t

  let src = Logs.Src.create "httpcamels.restapi"
  module Logger = (val Logs.src_log src : Logs.LOG)

  let getrand () = Random.int 1000
  let image_headers = [ ("content-type", "image/jpeg") ]

  let not_found_response =
    { App.status = `Not_found; headers = []; body = "not found" }

  let async_serve_asset assets name : App.response Lwt.t =
    let* result = Assets.get assets (Mirage_kv.Key.v name) in
    match result with
    | Ok "" -> Lwt.return not_found_response
    | Ok body -> Lwt.return { App.status = `OK; headers = image_headers; body }
    | Error e ->
        Logger.warn (fun f ->
            f "Couldn't get asset %s: %a" name Assets.pp_error e);
        Lwt.return
          {
            App.status = `Internal_server_error;
            headers = [];
            body = "An error ocurred while fetching the asset.";
          }

  let route assets method' path : App.response Lwt.t =
    match (method', path) with
    | `GET, "/" ->
        Lwt.return
          {
            App.status = `OK;
            headers = [];
            body = Index.render_index ~numbah:(getrand ());
          }
    | `GET, "/khello" ->
        Lwt.return { App.status = `OK; headers = []; body = "Khello !" }
    | `GET, "/404" -> async_serve_asset assets "404.jpg"
    | _ -> Lwt.return not_found_response

  let validate path : (string, App.response) result =
    if String.length path > 256 then
      Error { status = `Uri_too_long; headers = []; body = "path too long" }
    else if path = "" || path.[0] <> '/' then
      Error { status = `Bad_request; headers = []; body = "bad path" }
    else Ok path

  (** Takes the request descripton and return a response accordingly *)
  let handle assets (request : H1.Request.t) : App.response Lwt.t =
    let m = request.meth and p = request.target in
    match validate p with
    | Error response -> Lwt.return response
    | Ok path -> route assets m path
end
