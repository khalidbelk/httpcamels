(* mirage >= 4.9.0 & < 4.12.0 *)
open Mirage

let main =
  main "Unikernel.Make"
    (stackv4v6 @-> kv_ro @-> job)
    ~packages:
      [ package "h1"; package "paf" ~sublibs:[ "mirage" ]; package "tyxml" ]

let stack = generic_stackv4v6 default_network
let assets = crunch "static/assets"
let () = register "httpcamels" [ main $ stack $ assets ]
