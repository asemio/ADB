open! Core

type t = Yojson.Safe.t [@@deriving sexp_of, equal, yojson]

include S.Storable with type t := Yojson.Safe.t and type encoding := string
