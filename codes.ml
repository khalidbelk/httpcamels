type t = { code : int; name : string; description : string; official : bool }
(** An HTTP status code.

    [official] is true for codes that are present in the IANA registry. The
    others are unofficial or reserved codes, they exist in the wild. *)

(** [c ?official code name description] builds a record of type {!t}.

    [official] is [true] by default. *)
let c ?(official = true) code name description =
  { code; name; description; official }

let all =
  [
    (* 1xx Informational *)
    c 100 "Continue" "The client should continue with its request.";
    c 101 "Switching Protocols"
      "The server is switching to the requested protocol.";
    c 102 "Processing"
      "The server has received the request and is still processing it (WebDAV).";
    c 103 "Early Hints" "Preliminary headers sent before the final response.";
    c ~official:false 122 "Request-URI Too Long"
      "Legacy code for a URI longer than 2083 characters. Use 414.";
    (* 2xx Success *)
    c 200 "OK" "The request succeeded.";
    c 201 "Created" "The request succeeded and a new resource was created.";
    c 202 "Accepted" "The request was accepted but processing is not complete.";
    c 203 "Non-Authoritative Information"
      "The response comes from a transforming proxy, not the origin.";
    c 204 "No Content" "The request succeeded and there is no body to send.";
    c 205 "Reset Content"
      "The request succeeded; the client should reset its document view.";
    c 206 "Partial Content"
      "Only part of the resource is returned, as requested by a Range header.";
    c 207 "Multi-Status"
      "Multiple independent results in one response (WebDAV).";
    c 208 "Already Reported"
      "Members of a binding were already listed in a previous reply (WebDAV).";
    c 226 "IM Used"
      "The response is the result of instance manipulations applied to the \
       resource.";
    (* 3xx Redirection *)
    c 300 "Multiple Choices"
      "The request has several possible responses; the client should pick one.";
    c 301 "Moved Permanently" "The resource has a new permanent URI.";
    c 302 "Found" "The resource is temporarily at a different URI.";
    c 303 "See Other" "Fetch the response from another URI using GET.";
    c 304 "Not Modified" "The cached version is still valid.";
    c 305 "Use Proxy"
      "The resource must be accessed through a proxy (deprecated).";
    c ~official:false 306 "Switch Proxy" "Reserved and no longer used.";
    c 307 "Temporary Redirect"
      "Repeat the request at another URI, keeping the same method.";
    c 308 "Permanent Redirect"
      "The resource moved permanently; keep the same method.";
    (* 4xx Client errors *)
    c 400 "Bad Request"
      "The server cannot process the request because of malformed syntax.";
    c 401 "Unauthorized" "Authentication is required or has failed.";
    c 402 "Payment Required" "Reserved for future use.";
    c 403 "Forbidden"
      "The server understood the request but refuses to authorize it.";
    c 404 "Not Found" "The server has nothing at the requested URI.";
    c 405 "Method Not Allowed" "The method is not supported for this resource.";
    c 406 "Not Acceptable"
      "No content matches the Accept headers of the request.";
    c 407 "Proxy Authentication Required"
      "The client must first authenticate with the proxy.";
    c 408 "Request Timeout" "The server timed out waiting for the request.";
    c 409 "Conflict"
      "The request conflicts with the current state of the resource.";
    c 410 "Gone" "The resource is permanently gone.";
    c 411 "Length Required" "The request must specify a Content-Length.";
    c 412 "Precondition Failed"
      "A precondition in the request headers was not met.";
    c 413 "Content Too Large"
      "The request body is larger than the server accepts.";
    c 414 "URI Too Long" "The request URI is longer than the server accepts.";
    c 415 "Unsupported Media Type"
      "The request body has a media type the server does not support.";
    c 416 "Range Not Satisfiable" "The requested range cannot be served.";
    c 417 "Expectation Failed"
      "The server cannot meet the Expect header requirement.";
    c ~official:false 418 "I'm a teapot"
      "The server refuses to brew coffee because it is a teapot.";
    c ~official:false 420 "Enhance Your Calm"
      "Unofficial: rate limiting (Twitter).";
    c 421 "Misdirected Request"
      "The request was sent to a server that cannot produce a response.";
    c 422 "Unprocessable Content"
      "The request is well-formed but semantically invalid.";
    c 423 "Locked" "The resource is locked (WebDAV).";
    c 424 "Failed Dependency"
      "The request failed because a previous request failed (WebDAV).";
    c 425 "Too Early"
      "The server will not risk processing a request that might be replayed.";
    c 426 "Upgrade Required" "The client should switch to another protocol.";
    c 428 "Precondition Required"
      "The server requires the request to be conditional.";
    c 429 "Too Many Requests"
      "The client has sent too many requests in a given time.";
    c 431 "Request Header Fields Too Large" "The request headers are too large.";
    c ~official:false 444 "No Response"
      "Unofficial: the server closed the connection without a response (nginx).";
    c ~official:false 449 "Retry With"
      "Unofficial: retry after performing an action (Microsoft).";
    c ~official:false 450 "Blocked by Windows Parental Controls"
      "Unofficial (Microsoft).";
    c 451 "Unavailable For Legal Reasons"
      "The resource is unavailable for legal reasons.";
    c ~official:false 499 "Client Closed Request"
      "Unofficial: the client closed the connection first (nginx).";
    (* 5xx Server errors *)
    c 500 "Internal Server Error" "The server hit an unexpected condition.";
    c 501 "Not Implemented"
      "The server does not support the requested functionality.";
    c 502 "Bad Gateway"
      "The gateway got an invalid response from the upstream server.";
    c 503 "Service Unavailable"
      "The server is overloaded or down for maintenance.";
    c 504 "Gateway Timeout"
      "The gateway did not get a response from upstream in time.";
    c 505 "HTTP Version Not Supported"
      "The server does not support the HTTP version used.";
    c 506 "Variant Also Negotiates"
      "Content negotiation resulted in a circular reference.";
    c 507 "Insufficient Storage"
      "The server cannot store the representation (WebDAV).";
    c 508 "Loop Detected" "The server detected an infinite loop (WebDAV).";
    c ~official:false 509 "Bandwidth Limit Exceeded"
      "Unofficial: bandwidth limit exceeded.";
    c 510 "Not Extended" "Further extensions to the request are required.";
    c 511 "Network Authentication Required"
      "The client must authenticate to gain network access.";
    c ~official:false 520 "Web Server Returned an Unknown Error"
      "Unofficial (Cloudflare).";
    c ~official:false 521 "Web Server Is Down" "Unofficial (Cloudflare).";
    c ~official:false 522 "Connection Timed Out" "Unofficial (Cloudflare).";
    c ~official:false 523 "Origin Is Unreachable" "Unofficial (Cloudflare).";
    c ~official:false 524 "A Timeout Occurred" "Unofficial (Cloudflare).";
    c ~official:false 598 "Network Read Timeout Error"
      "Unofficial: read timeout behind a proxy.";
    c ~official:false 599 "Network Connect Timeout Error"
      "Unofficial: connect timeout behind a proxy.";
  ]

let table : (int, t) Hashtbl.t =
  let ht = Hashtbl.create 128 in
  List.iter (fun item -> Hashtbl.replace ht item.code item) all;
  ht

let find code = Hashtbl.find_opt table code
