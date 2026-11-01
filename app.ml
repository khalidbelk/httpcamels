type response = { status : H1.Status.t; body : string }

module type S = sig
  val handle : H1.Request.t -> response
end
