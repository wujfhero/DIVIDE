;+
; :Name:
;   mvn_kp_3d_event_insitu_vec_list
; 
; :Description:
;   Procedure to respond to widget events selecting vector data 
;   from the in-situ instruments
;
; :Author:
;   Kevin McGouldrick (2015-May-08)
;
; :Parameters:
;   event: in, required
;     widget event
;   inst_code: in, required, string
;     short string indicating instrument code begin selected.  There
;     might be a more elegant way of doing this.
;     
; :Version:
;  1.0
;
;-
pro mvn_kp_3d_event_insitu_vec_list,event,inst_code
;
;  This is required to be able to update pstate
;
  widget_control, event.top, get_uvalue=pstate

  (*pstate).vector_color_source[0] = inst_code
  index = widget_info(event.id, /droplist_select)
  widget_control, event.id, get_value=newval
  (*pstate).vector_color_source[1] = newval(index)
  (*pstate).vector_path->getproperty,vert_color=vert_color
  insitu_spec = (*pstate).insitu
  MVN_KP_3D_VECTOR_COLOR, insitu_spec.static.(index), vert_color, $
                          (*pstate).colorbar_stretch
  (*pstate).vector_path->setproperty,vert_color=vert_color
  (*pstate).window ->draw,(*pstate).view

end
