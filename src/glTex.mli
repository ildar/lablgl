(* $Id: glTex.mli,v 1.2 1999-11-15 09:55:11 garrigue Exp $ *)

open Gl

val coord : s:float -> ?t:float -> ?r:float -> ?q:float -> unit -> unit
val coord2 : float * float -> unit
val coord3 : float * float * float -> unit
val coord4 : float * float * float * float -> unit

type env_param = [`mode [`modulate|`decal|`blend|`replace] | `color rgba]
val env : env_param -> unit

type coord = [`s|`t|`r|`q]
type gen_param = [
    `mode [`object_linear|`eye_linear|`sphere_map]
  | `object_plane point4
  | `eye_plane point4
]
val gen : coord:coord -> gen_param -> unit

type format =
    [`color_index|`red|`green|`blue|`alpha|`rgb|`rgba
    |`luminance|`luminance_alpha]
val image1d :
  ?proxy:bool -> ?level:int -> ?internal:int -> ?border:bool ->
  (#format, #kind) GlPix.t -> unit
val image2d :
  ?proxy:bool -> ?level:int -> ?internal:int -> ?border:bool ->
  (#format, #kind) GlPix.t -> unit

type filter =
    [`nearest|`linear|`nearest_mipmap_nearest|`linear_mipmap_nearest
    |`nearest_mipmap_linear|`linear_mipmap_linear]
type wrap = [`clamp|`repeat]
type parameter = [
    `min_filter filter
  | `mag_filter [`nearest|`linear]
  | `wrap_s wrap
  | `wrap_t wrap
  | `border_color rgba
  | `priority clampf
] 
val parameter : target:[`texture_1d|`texture_2d] -> parameter -> unit
