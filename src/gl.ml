(* $Id: gl.ml,v 1.9 1998-01-13 11:07:11 garrigue Exp $ *)

(* Register an exception *)

exception GLerror of string

let _ = Callback.register_exception "glerror" (GLerror "")

(* Plenty of small C wrappers *)

external _clear_color :
    red:float -> green:float -> blue:float -> alpha:float -> unit
    = "ml_glClearColor"
let clear_color :red :green :blue ?:alpha [< 1. >] =
  _clear_color :red :green :blue :alpha

external _color :
    red:float -> green:float -> blue:float -> alpha:float -> unit
    = "ml_glColor4d"
let color :red :green :blue ?:alpha [< 1. >] =
  _color :red :green :blue :alpha

type buffer_bit = [color depth accum stencil]

external clear : buffer_bit list -> unit
    = "ml_glClear"

external flush : unit -> unit = "ml_glFlush"
external finish : unit -> unit = "ml_glFinish"

type point = float * float

external rect : point -> point -> unit
    = "ml_glRect"
external vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
    = "ml_glVertex"

type begin_enum = [
    points
    lines
    polygon
    triangles
    quads
    line_strip
    line_loop
    triangle_strip
    triangle_fan
    quad_strip     
  ]

external begin_block : begin_enum -> unit
    = "ml_glBegin"
external end_block : unit -> unit
    = "ml_glEnd"

external point_size : float -> unit
    = "ml_glPointSize"
external line_width : float -> unit
    = "ml_glLineWidth"
external line_stipple : factor:int -> pattern:int -> unit
    = "ml_glLineStipple"

type face = [front back both]

external polygon_mode :
    face:face -> mode:[point line fill] -> unit
    = "ml_glPolygonMode"
external front_face : [cw ccw] -> unit
    = "ml_glFrontFace"
external cull_face : [front back both] -> unit
    = "ml_glCullFace"
external polygon_stipple : mask:string -> unit
    = "ml_glPolygonStipple"

external edge_flag : bool -> unit
    = "ml_glEdgeFlag"

external _normal : x:float -> y:float -> z:float -> unit
    = "ml_glNormal3d"
let normal ?:x [< 0.0 >] ?:y [< 0.0 >] ?:z [< 0.0 >] = _normal :x :y :z

external matrix_mode : [modelview projection texture] -> unit
    = "ml_glMatrixMode"

external load_identity : unit -> unit
    = "ml_glLoadIdentity"

external _load_matrix : float array array -> unit
    = "ml_glLoadMatrix"
let load_matrix m =
  if Array.length m <> 4 then invalid_arg "Gl.load_matrix";
  Array.iter m fun:
    begin fun v ->
      if Array.length v <> 4 then invalid_arg "Gl.load_matrix"
    end;
  _load_matrix m

external _mult_matrix : float array array -> unit
    = "ml_glMultMatrix"
let mult_matrix m =
  if Array.length m <> 4 then invalid_arg "Gl.mult_matrix";
  Array.iter m fun:
    begin fun v ->
      if Array.length v <> 4 then invalid_arg "Gl.mult_matrix"
    end;
  _mult_matrix m

external _translate : x:float -> y:float -> z:float -> unit
    = "ml_glTranslated"
external _rotate : angle:float -> x:float -> y:float -> z:float -> unit
    = "ml_glRotated"
external _scale : x:float -> y:float -> z:float -> unit
    = "ml_glScaled"

let translate ?:x [< 0. >] ?:y [< 0. >] ?:z [< 0. >] =
  _translate :x :y :z
and rotate :angle ?:x [< 0. >] ?:y [< 0. >] ?:z [< 0. >] =
  _rotate :angle :x :y :z
and scale ?:x [< 0. >] ?:y [< 0. >] ?:z [< 0. >] =
  _scale :x :y :z

external frustum :
    left:float -> right:float -> bottom:float ->
    top:float -> near:float -> far:float -> unit
    = "ml_glFrustum"

external ortho :
    left:float -> right:float -> bottom:float ->
    top:float -> near:float -> far:float -> unit
    = "ml_glOrtho"

external viewport : x:int -> y:int -> w:int -> h:int -> unit
    = "ml_glViewport"

external depth_range : near:float -> far:float -> unit
    = "ml_glDepthRange"

external push_matrix : unit -> unit
    = "ml_glPushMatrix"
external pop_matrix : unit -> unit
    = "ml_glPopMatrix"

external _clip_plane : plane:int -> equation:float array -> unit
    = "ml_glClipPlane"
let clip_plane :plane :equation =
  if plane < 0 or plane > 5 or Array.length equation <> 4
  then invalid_arg "Gl.clip_plane";
  _clip_plane :plane :equation

type cap = [
      alpha_test
      auto_normal
      blend
      clip_plane0
      clip_plane1
      clip_plane2
      clip_plane3
      clip_plane4
      clip_plane5
   (* color_logic_op *)
      color_material
      cull_face
      depth_test
      dither
      fog
   (* index_logic_op *)
      light0
      light1
      light2
      light3
      light4
      light5
      light6
      light7
      lighting
      line_smooth
      line_stipple
      logic_op
      map1_color_4
      map1_index
      map1_normal
      map1_texture_coord_1
      map1_texture_coord_2
      map1_texture_coord_3
      map1_texture_coord_4
      map1_vertex_3
      map1_vertex_4
      map2_color_4
      map2_index
      map2_normal
      map2_texture_coord_1
      map2_texture_coord_2
      map2_texture_coord_3
      map2_texture_coord_4
      map2_vertex_3
      map2_vertex_4
      normalize
(*    polygon_offset_fill
      polygon_offset_line
      polygon_offset_point *)
      point_smooth
      polygon_smooth
      polygon_stipple
      scissor_test
      stencil_test
      texture_1d
      texture2d
      texture_gen_q
      texture_gen_r
      texture_gen_s
      texture_gen_t
  ]

external enable : cap -> unit = "ml_glEnable"
external disable : cap -> unit = "ml_glDisable"

external shade_model : [flat smooth] -> unit = "ml_glShadeModel"

(*
type rgba = { red: float; green: float; blue: float; alpha: float }
type coords = { x: float; y: float; z: float; w: float }
*)

type rgba = float * float * float * float
type coords = float * float * float * float

type light_param = [
      ambient (rgba)
      diffuse (rgba)
      specular (rgba)
      position (coords)
      spot_direction (coords)
      spot_exponent (float)
      spot_cutoff (float)
      constant_attenuation (float)
      linear_attenuation (float)
      quadratic_attenuation (float)
  ] 

external light : num:int -> param:light_param -> unit
    = "ml_glLight"

type light_model_param = [
      ambient (rgba)
      local_viewer (float)
      two_side (float)
  ] 

external light_model : light_model_param -> unit = "ml_glLightModel"

type material_param = [
      ambient (rgba)
      diffuse (rgba)
      specular (rgba)
      emission (rgba)
      shininess (float)
      ambient_and_diffuse (rgba)
      color_indexes (float * float * float)
  ] 

external material : face:face -> param:material_param -> unit
    = "ml_glMaterial"

type depth_func = [
      never
      less
      equal
      lequal
      greater
      notequal
      gequal
      always
  ]

external depth_func : depth_func -> unit = "ml_glDepthFunc"
external depth_mask : bool -> unit = "ml_glDepthMask"

type sfactor = [
      zero
      one
      dst_color
      one_minus_dst_color
      src_alpha
      one_minus_src_alpha
      dst_alpha
      one_minus_dst_alpha
      src_alpha_saturate
      constant_color_ext
      one_minus_constant_color_ext
      constant_alpha_ext
      one_minus_constant_alpha_ext
  ]

type dfactor = [
      zero
      one
      src_color
      one_minus_src_color
      src_alpha
      one_minus_src_alpha
      dst_alpha
      one_minus_dst_alpha
      constant_color_ext
      one_minus_constant_color_ext
      constant_alpha_ext
      one_minus_constant_alpha_ext
  ]
      
external blend_func : src:sfactor -> dst:dfactor -> unit
    = "ml_glBlendFunc"

type fog_param = [
      mode ([linear exp exp2])
      density (float)
      start (float)
      End (float)
      index (float)
      color (float * float * float * float)
  ]

external fog : fog_param -> unit = "ml_glFog"

type glist = int

let shift_list : glist -> by:int -> glist = fun l :by -> l+by

external is_list : glist -> bool = "ml_glIsList"
external gen_lists : int -> glist = "ml_glGenLists"
external delete_lists : from:glist -> range:int -> unit = "ml_glDeleteLists"
external new_list :
    glist -> mode:[compile compile_and_execute] -> unit
    = "ml_glNewList"
external end_list : unit -> unit = "ml_glEndList"
external call_list : glist -> unit = "ml_glCallList"

external call_lists : [byte(string) int(int array)] -> unit
    = "ml_glCallLists"
external list_base : glist -> unit = "ml_glListBase"

(*
type component = [
      alpha
      luminance
      luminance_alpha
      rgb
      rgba
      depth_component
  ]

type format = [
      color_index
      red
      green
      blue
      alpha
      rgb
      rgba
      luminance
      luminance_alpha
      depth_component
  ]

type bitmap

type data = [
      byte (string)
      bitmap (bitmap)
      int (int array)
      float (float array)
  ]

external _tex_image_2D :
      level:int -> components:component -> width:int -> height:int ->
      border:int -> format:format -> data -> unit
    = "ml_glTexImage2D"

let rec is_power n =
  if n <= 1 then n = 1 else n land 1 = 0 & is_power (n lsr 1)

let tex_image_2D :level :components :width :height :border :format data =
  if not (is_power (width-border)) or not (is_power (height-border))
  then invalid_arg "Gl.tex_image_2D";
  let size =
    match format with
      `color_index|`red|`green|`blue|`alpha|`luminance|`depth_component -> 1
    | `luminance_alpha -> 2
    | `rgb -> 3
    | `rgba -> 4
    
*)
