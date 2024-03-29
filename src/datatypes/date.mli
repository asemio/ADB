open! Core

(** Corresponds to a Postgresql DATE column *)
type t = Date.t [@@deriving sexp, compare, equal, yojson]

include S.Storable with type t := Date.t and type encoding := Ptime.t

val to_ptime_exn : t -> Ptime.t

val of_ptime_exn : Ptime.t -> t
