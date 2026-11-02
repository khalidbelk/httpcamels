type response = {
  status : H1.Status.t;
  headers : (string * string) list;
  body : string;
}

module type S = sig
  type ctx (* app-specific state passed to [handle], opaque to the server *)

  val handle : ctx -> H1.Request.t -> response Lwt.t
end
