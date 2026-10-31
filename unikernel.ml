open Lwt.Syntax

module Make (Stack: Tcpip.Stack.V4V6) = struct
  module Paf = Paf_mirage.Make (Stack.TCP)

  let src = Logs.Src.create "httpcodes" ~doc:"httpcodes unikernel"
  module Logger = (val Logs.src_log src : Logs.LOG)

  let error_handler _dst ?request:_ error start_response =
    (match error with
      | `Exn e -> Logger.warn (fun f -> f "connection error: %s" (Printexc.to_string e))
      | _ -> ()
    );
    (* In case a client already disconnected but reaches this, we ignore it
        instead of crashing (e.g "cannot write to closed writer")*)
    try
        let out = start_response H1.Headers.empty in
        H1.Body.Writer.write_string out "error";
        H1.Body.Writer.close out
    with _ -> ()

  let request_handler _flow (ip, port) reqd =
    let body = "hello" in
    let headers = H1.Headers.of_list [ "content-length", string_of_int (String.length body) ] in
    Logger.info (fun f -> f "Received request from %a:%d" Stack.IP.pp_ipaddr ip port);
    H1.Reqd.respond_with_string reqd (H1.Response.create ~headers `OK) body

  let start stack =
    let port = 8080 in
    let* socket = Paf.init ~port (Stack.tcp stack) in
    let service = Paf.http_service ~error_handler request_handler in
    let `Initialized th = Paf.serve service socket in
    Logger.info (fun f -> f "Listening on port %d." port);
    th
end

