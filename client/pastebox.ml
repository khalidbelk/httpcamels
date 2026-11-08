open Brr

let copy_icon = "/clipboard.svg"
let copied_icon = "/check.svg"
let copied_icon_ms = 2000

let site_origin () =
  let location = Window.location G.window in
  let port =
    match Uri.port location with
    | Some port -> ":" ^ string_of_int port
    | None -> ""
  in
  Jstr.to_string (Uri.scheme location)
  ^ "://"
  ^ Jstr.to_string (Uri.host location)
  ^ port

let show_tick icon =
  let set_icon src = El.set_at At.Name.src (Some (Jstr.v src)) icon in
  let restore_timer = ref None in
  fun () ->
    Option.iter G.stop_timer !restore_timer;
    set_icon copied_icon;
    restore_timer :=
      Some
        (G.set_timeout ~ms:copied_icon_ms (fun () ->
             set_icon copy_icon;
             restore_timer := None))

let copy_to_clipboard text ~on_copied =
  let clipboard = Brr_io.Clipboard.of_navigator G.navigator in
  Fut.await
    (Brr_io.Clipboard.write_text clipboard (Jstr.v text))
    (function
      | Ok () -> on_copied ()
      | Error error ->
          Dom.log_error ("could not copy the link: " ^ Dom.error_message error))

let start ~url ~button ~icon =
  let link = site_origin () ^ "/<code>" in
  El.set_children url [ El.txt' link ];
  let on_copied = show_tick icon in
  let copy _ = copy_to_clipboard link ~on_copied in
  ignore (Ev.listen Ev.click copy (El.as_target button))

let init () =
  let open Dom.Syntax in
  let started =
    let+ url = Dom.find Ids.paste_url
    and+ button = Dom.find Ids.paste_copy
    and+ icon = Dom.find Ids.paste_icon in
    start ~url ~button ~icon
  in
  Option.value started ~default:()
