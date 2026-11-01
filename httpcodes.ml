
let getrand () = Random.int 1000

let route _method path : App.response =
  match _method, path with
  | `GET, "/" ->  { status = `OK; body = Int.to_string (getrand ()) }
  | `GET, "/khello" -> { status = `OK; body = "Khello !" }
  | _ ->  { status = `Not_found; body = "not found" }

let validate path : (string, App.response) result =
  if String.length path > 256 then
    Error { status = `Uri_too_long; body = "path too long" }
  else if path = "" || path.[0] <> '/' then
    Error { status = `Bad_request; body = "bad path" }
  else Ok path

(** Takes the request descripton and return a response accordingly *)
let handle (request: H1.Request.t) : App.response =
  let m = request.meth and p = request.target in
  match validate p with
  | Error response -> response
  | Ok path -> route m path
