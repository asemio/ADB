open! Core

(** The second argument should look like [[(module Initial_schema : S.Migration)]] *)
val run : PG.pool -> Source_code_position.t -> (module S.Migration) list -> unit Core.Or_error.t Lwt.t
