open! Core

type t = Time_float.t [@@deriving compare, equal]

let sexp_of_t time = Sexp.Atom (Time_float.to_string_iso8601_basic ~zone:Time_float.Zone.utc time)

let t_of_sexp = function
| Sexp.Atom s -> Time_float.of_string_with_utc_offset s
| sexp -> failwithf "Invalid serialized Time: %s" (Sexp.to_string sexp) ()

let to_yojson time =
  let iso = Time_float.to_string_iso8601_basic ~zone:Time_float.Zone.utc time in
  `String (String.slice iso 0 (-4) |> sprintf "%sZ")

let of_yojson = function
| `String s -> Ok (Time_float.of_string_with_utc_offset s)
| _ -> Error (Format.sprintf "Invalid JSON for Time, expected String")

let encode x =
  let date, ofday = Time_float.to_date_ofday ~zone:Time_float.Zone.utc x in
  let days_epoch = Date.diff date Date.unix_epoch in
  let picos_midnight =
    Time_float.Ofday.to_span_since_start_of_day ofday
    |> Time_float.Span.to_ns
    |> Int64.of_float
    |> Int64.( * ) 1000L
  in
  match Ptime.Span.of_d_ps (days_epoch, picos_midnight) with
  | None -> Error "Ptime encoding error"
  | Some span -> Ptime.of_span span |> Result.of_option ~error:"Ptime span encoding error"

let decode x =
  let days_epoch, picos_midnight = Ptime.to_span x |> Ptime.Span.to_d_ps in
  let date = Date.(add_days unix_epoch days_epoch) in
  let span_ofday =
    picos_midnight |> fun i -> Int64.(i / 1000L) |> Int64.to_float |> Time_float.Span.of_ns
  in
  Time_float.Ofday.(add start_of_day span_ofday)
  |> Result.of_option ~error:"Ptime decoding error"
  |> Result.map ~f:(Time_float.of_date_ofday ~zone:Time_float.Zone.utc date)

let t = Caqti_type.(custom ~encode ~decode ptime)

let now () = Time_ns.(now () |> to_time_float_round_nearest_microsecond)

let to_ptime_exn x = encode x |> Result.ok_or_failwith

let of_ptime_exn x = decode x |> Result.ok_or_failwith
