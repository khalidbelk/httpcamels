module Make (Stack : Tcpip.Stack.V4V6) = struct
  include Server.Make (Stack) (Restapi)
end
