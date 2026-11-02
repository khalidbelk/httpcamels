module Make (Stack : Tcpip.Stack.V4V6) (Assets : Mirage_kv.RO) = struct
  module R = Restapi.Make (Assets)
  module S = Server.Make (Stack) (R)

  let start = S.start
end
