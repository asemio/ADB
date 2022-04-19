open! Core

(** Corresponds to a Postgresql UUID column *)
type t = Uuidm.t [@@deriving sexp, compare, equal, yojson]

include S.Storable with type t := Uuidm.t and type encoding := string

val random_v4 : unit -> t
