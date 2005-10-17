(* $Id: build.ml,v 1.1 2005-10-17 08:28:18 garrigue Exp $ *)
(* A script to build lablgtk2 libraries *)

open StdLabels

let ocamlc = ref "ocamlc.opt"
let ocamlopt = ref "ocamlopt.opt"
let flags = ref "-thread -w s -I +labltk"
let ccomp_type = ref "msvc"   (* "msvc" for MSVC++, "cc" for Mingw. Attempt ot autodetect *)

let split ?(sep = [' ';'\t';'\r';'\n']) s =
  let len = String.length s in
  let rec loop last cur acc =
    if cur > len then acc else
    let next = cur+1 in
    if cur = len || List.mem s.[cur] sep then
      if cur > last then loop next next (String.sub s ~pos:last ~len:(cur-last) :: acc)
      else loop next next acc
    else loop last next acc
  in List.rev (loop 0 0 [])

let lablgl_mls = split "raw gl		glLight	glList	glMap glMat	glMisc	glPix	glClear glTex	glDraw	glFunc	gluMisc gluNurbs	gluQuadric	gluTess	gluMat glArray"
let togl_mls = split "togl"
let glut_mls = split "glut"
let gl_libs = "opengl32.lib glu32.lib"
let tk_libs = "tk83.lib tcl83.lib gdi32.lib user32.lib "
let glut_libs = "glut32.lib "

(* Hack to check for mingw *)
let () =
  try
    let ic = open_in "../Makefile.config" in
    while true do
      let s = input_line ic in
      match split ~sep:[' ';'\t';'='] s with
        "CCOMPTYPE" :: cc :: _ -> ccomp_type := cc
      | _ -> ()
    done
  with _ -> ()

(*
let gtk_libs =
  if !ccomp_type = "msvc" then gtk_libs else
  let libs =
    List.map (split gtk_libs) ~f:
      (fun nm ->
        if Filename.check_suffix nm ".lib" then "-l"^Filename.chop_extension nm^".dll"
        else nm)
  in String.concat " " libs
*)

let exe cmd args =
  let cmd = String.concat " " (cmd :: !flags :: args) in
  print_endline cmd; flush stdout;
  let err = Sys.command cmd in
  if err > 0 then failwith ("error "^string_of_int err)

let may_remove f =
  if Sys.file_exists f then Sys.remove f

let byte () =
  List.iter (lablgl_mls @ togl_mls @ glut_mls) ~f:
    begin fun file ->
      if Sys.file_exists (file ^ ".mli") then exe !ocamlc ["-c"; file^".mli"];
      exe !ocamlc ["-c"; file^".ml"]
    end;
  List.iter ["lablgl", lablgl_mls, "";
             "togl", togl_mls, tk_libs;
             "lablglut", glut_mls, glut_libs]
    ~f:begin fun (lib, mls,libs) ->
      let cmos = List.map mls ~f:(fun nm -> nm ^".cmo") in
      exe !ocamlc (["-a -o"; lib^".cma"; "-cclib -l"^lib; "-dllib -l"^lib;
                    "-cclib \""^libs^gl_libs^"\""] @ cmos);
      List.iter cmos ~f:may_remove
    end

let native () =
  List.iter (lablgl_mls @ togl_mls @ glut_mls) ~f:
    (fun file -> exe !ocamlopt ["-c"; file^".ml"]);
  List.iter ["lablgl", lablgl_mls, "";
             "togl", togl_mls, tk_libs;
             "lablglut", glut_mls, glut_libs]
    ~f:begin fun (lib, mls,libs) ->
      let cmxs = List.map mls ~f:(fun nm -> nm ^".cmx") in
      exe !ocamlopt (["-a -o"; lib^".cmxa"; "-cclib -l"^lib;
                    "-cclib \""^libs^gl_libs^"\""] @ cmxs);
      List.iter mls ~f:(fun nm -> may_remove (nm ^ ".obj"); may_remove (nm ^ ".o"))
    end

let rename ~ext1 ~ext2 file =
  if Sys.file_exists (file^ext1) && not (Sys.file_exists (file^ext2)) then begin
    prerr_endline ("Renaming "^file^ext1^" to "^file^ext2);
    Sys.rename (file^ext1) (file^ext2)
  end

let () =
  try
    let arg = if Array.length Sys.argv > 1 then Sys.argv.(1) else "" in
    if arg <> "" && arg <> "byte" && arg <> "opt" then begin
      prerr_endline "ocaml build.ml [ byte | opt ]";
      prerr_endline "  byte   build bytecode library only";
      prerr_endline "  opt    build both bytecode and native (default)";
      exit 2
    end;
    byte ();
    if arg = "opt" || arg <> "byte" then begin
      try native () with
        Failure err ->
          prerr_endline ("Native build failed: " ^ err);
          prerr_endline "You can still use the bytecode version"
    end;
    if !ccomp_type = "msvc" then begin
      List.iter ["liblablgl"; "libtogl"; "liblablglut"] ~f:(rename ~ext1:".a" ~ext2:".lib");
      prerr_endline "Now ready to use on an OCaml MSVC port"
    end else begin
      List.iter ["liblablgl"; "libtogl"; "liblablglut"] ~f:(rename ~ext2:".a" ~ext1:".lib");
      prerr_endline "Now ready to use on an OCaml Mingw port"
    end
  with Failure err ->
    prerr_endline ("Bytecode failed: " ^ err)
