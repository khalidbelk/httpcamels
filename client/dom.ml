(* Helpers shared by the scripts of the page *)

open Brr

module Syntax = struct
  let ( let+ ) option f = Option.map f option

  let ( and+ ) a b =
    match (a, b) with
    | Some a, Some b -> Some (a, b)
    | _ -> None
end

let log_error message = Console.(error [ str ("client.js: " ^ message) ])
let error_message error = Jstr.to_string (Jv.Error.message error)

let find id =
  let element = Document.find_el_by_id G.document (Jstr.v id) in
  if Option.is_none element then log_error ("no element with id " ^ id);
  element
