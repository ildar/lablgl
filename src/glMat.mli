(* $Id: glMat.mli,v 1.2 1999-11-15 09:55:08 garrigue Exp $ *)

open Gl

type t

val of_raw : [`double] Raw.t -> t
external to_raw : t -> [`double] Raw.t = "%identity"
    (* Those two functions are just the identity, and keep sharing.
       [double] Raw.t is a raw array of 16 floating point values
       representing as 4x4 matrix *)
val of_array : float array array -> t
val to_array : t -> float array array

val load : t -> unit
val mult : t -> unit
val load_identity : unit -> unit

val push : unit -> unit
val pop : unit -> unit
    (* Push and pop the matrix on the stack *)

val mode : [`modelview|`projection|`texture] -> unit

val rotate : angle:float -> point3 -> unit
val scale : point3 -> unit
val translate : point3 -> unit

val ortho : x:float * float -> y:float * float -> z:float * float -> unit
val frustum : x:float * float -> y:float * float -> z:float * float -> unit
