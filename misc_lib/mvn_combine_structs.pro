pro mvn_combine_structs,str1,str2,strsum,structyp=structyp
;+
; NAME:
;    COMBINE_STRUCTS
;
; PURPOSE:
;  takes two arrays of structures str1,str2 which have the
;  same number of elements but possibly different tags
;  and makes another structure which has the same number of elements
;  but the tags of both str1,str2 and has their respective tags 
;  values copied into it
;
; CALLING SEQUENCE
;    combine_structs, struct1, struct2, newstruct, structyp=structyp
;
; INPUTS:
;    struct1,struc2: The two structures to be combined. If structure arrays, 
;               Must contain the same number of structs.
;
; KEYWORD PARAMETERS:
;   structyp: a string with the name of the new structure.
;     if already defined the program will crash.
;
; Author Dave Johnston UofM
; 
; ADDED MVN_KP PREFIX WITHOUT MODIFYING ANY OTHER CODE FOR INCLUSION 
;   IN MAVEN TOOLKIT WITHOUT POSSIBILITY OF CONFLICT WITH ROUTINES ON 
;   USER COMPUTERS ALREADY.
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;-

if n_params() LT 2 then begin 
  print,'-syntax combine_structs,str1,str2,strsum,structyp=structyp'
  return
endif

s1=size(str1)
s2=size(str2)

if s1(1) ne s2(1) then begin
  print,'structure sizes are different'
  return
endif

str=create_struct(name=structyp,str1(0),str2(0))
strsum=replicate(str,s1(1))
mvn_copy_struct,str1,strsum
mvn_copy_struct,str2,strsum

return
end
