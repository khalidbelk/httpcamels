module Make (Stack : Tcpip.Stack.V4V6) (Handler : App.S) = struct
  open Lwt.Syntax
  module Paf = Paf_mirage.Make (Stack.TCP)

  (* TODO: remove the hardcoding of the name an the port, take them as param*)
  let src = Logs.Src.create "httpcamels" ~doc:"httpcamels unikernel"

  module Logger = (val Logs.src_log src : Logs.LOG)

  let error_handler _dst ?request:_ error start_response =
    (match error with
    | `Exn e ->
        Logger.warn (fun f -> f "connection error: %s" (Printexc.to_string e))
    | _ -> ());
    (* In case a client already disconnected but reaches this, we ignore it
        instead of crashing (e.g "cannot write to closed writer")*)
    try
      let out = start_response H1.Headers.empty in
      H1.Body.Writer.write_string out "error";
      H1.Body.Writer.close out
    with
    | _ -> ()

  let respond_to ctx (ip, port) reqd =
    let request = H1.Reqd.request reqd in
    let* { App.status; headers; body } = Handler.handle ctx request in
    let target = request.target in
    let body_len = String.length body in
    let content_length = ("content-length", string_of_int body_len) in
    let headers = H1.Headers.of_list (content_length :: headers) in
    Logger.info (fun f ->
        f "Request from %a:%d | %s %s | Response: %d (%d bytes)"
          Stack.IP.pp_ipaddr ip port
          (H1.Method.to_string request.meth)
          target (H1.Status.to_code status) body_len);
    H1.Reqd.respond_with_string reqd (H1.Response.create ~headers status) body;
    Lwt.return_unit

  (** Starts [respond_to] with [Lwt.async] and returns immediately, to match
      H1's [Reqd.t -> unit] request handler. *)
  let request_handler ctx _flow dst reqd =
    Lwt.async (fun () -> respond_to ctx dst reqd)

  let start stack (ctx : Handler.ctx) =
    let port = 8080 in
    let* socket = Paf.init ~port (Stack.tcp stack) in
    let service = Paf.http_service ~error_handler (request_handler ctx) in
    let (`Initialized th) = Paf.serve service socket in
    Logger.info (fun f -> f "Listening on port %d." port);
    th
end
