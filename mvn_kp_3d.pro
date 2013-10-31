;+
; Interactive 3D visualization of MAVEN spacecraft trajectory and insitu/iuvs KP parameters.
;
; :Params:
;    bounds : in, required, type="lonarr(ndims, 3)"
;       bounds 
;
; :Keywords:
;    start : out, optional, type=lonarr(ndims)
;       input for start argument to H5S_SELECT_HYPERSLAB
;    count : out, optional, type=lonarr(ndims)
;       input for count argument to H5S_SELECT_HYPERSLAB
;    block : out, optional, type=lonarr(ndims)
;       input for block keyword to H5S_SELECT_HYPERSLAB
;    stride : out, optional, type=lonarr(ndims)
;       input for stride keyword to H5S_SELECT_HYPERSLAB
;-

@mvn_kp_3d_event.pro
@mvn_kp_3d_cleanup.pro
@mvn_kp_3d_atmshell.pro
@MVN_KP_3D_PATH_COLOR.pro
@MVN_KP_3D_PERI_COLOR.pro
@MVN_KP_3D_CURRENT_PERIAPSE.pro
@MVN_KP_TAG_PARSER.pro
@MVN_KP_TAG_VERIFY.pro
@mg_linear_function.pro

pro MVN_KP_3D, insitu, iuvs=iuvs, time=time, basemap=basemap, grid=grid, cow=cow, subsolar=subsolar, submaven=submaven, $
               field=field, color_table=color_table, bgcolor=bgcolor, plotname=plotname, color_bar=color_bar,$
               whiskers=whiskers,parameterplot=parameterplot,periapse_limb_scan=periapse_limb_scan, direct=direct
  
  common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
  
  ;PARSE DATA STRUCTURES FOR BEGINNING, END, AND MID TIMES
    ;SET THE TIME BOUNDS BASED ON THE INSITU DATA STRUCTURE
      start_time = double(insitu[0].time)
      end_time = double(insitu[n_elements(insitu.time)-1].time)
    
      start_time_string = time_string(start_time, format=0)
      end_time_string = time_string(end_time, format=0)
      
      total_points = n_elements(insitu.time)
      if keyword_set(time) then begin
        if size(time,/type) eq 7 then begin         ;string based time 
          initial_time = time_double(time)
        endif 
        if size(time,/type) eq 3 then begin         ;double time
          initial_time = time
        endif
        if n_elements(time) eq 1 then begin       ;use beginning and end times of insitu, with this as the plotted time
          if (initial_time gt start_time) and (initial_time lt end_time) then begin
            time_index=0L
            temp_time = min(abs(insitu.time - initial_time),time_index)
            mid_time = insitu[time_index].time
            mid_time_string = time_string(mid_time,format=0)
          endif else begin
            print,'REQUESTED INITIAL PLOT TIME OF ',strtrim(string(time),2),' IS OUTSIDE THE RANGE INCLUDED IN THE DATA STRUCTURES. PLOTTING MID-TIME INSTEAD'
            time_index = long(total_points/2L)
            mid_time = insitu[time_index].time
            initial_time = mid_time
            mid_time_string = time_string(mid_time,format=0)
          endelse
        endif                                     ;end of single value time loop
        if n_elements(time) eq 2 then begin       ;use this as beginning and end times to be plotted, with initial plotas the midpoint
          if (initial_time[0] gt start_time) and (initial_time[0] lt end_time) then begin
            start_time = initial_time[0]
            start_time_string = time_string(initial_time[0],format=0)
            start_index=0L
            temp_time = min(abs(insitu.time - initial_time[0]),start_index)
            insitu = insitu[start_index:*]
          endif else begin
            print, 'REQUESTED START TIME OF ',strtrim(string(time[0]),2),' IS OUTSIDE THE RANGE INCLUDED IN THE DATA STRUCTURES.'
          endelse
          if (initial_time[1] gt start_time) and (initial_time[1] lt end_time) then begin
            end_time = initial_time[1]
            end_time_string = time_string(initial_time[1],format=0)
            end_index = 0l
            temp_time = min(abs(insitu.time - initial_time[1]),end_index)
            insitu = insitu[0:end_index]
          endif else begin
            print, 'REQUESTED END TIME OF ',strtrim(string(time[1]),2),' IS OUTSIDE THE RANGE INCLUDED IN THE DATA STRUCTURES.'
          endelse
          total_points = n_elements(insitu.time)
          time_index = long(total_points/2L)
          mid_time = insitu[time_index].time
          initial_time = mid_time
          mid_time_string = time_string(mid_time,format=0)
        endif                                     ;end of 2 value time loop
        if n_elements(time) eq 3 then begin       ;use this as the beginning, middle, and end times 
           if (initial_time[0] gt start_time) and (initial_time[0] lt end_time) then begin
            start_time = initial_time[0]
            start_time_string = time_string(initial_time[0],format=0)
            start_index=0L
            temp_time = min(abs(insitu.time - initial_time[0]),start_index)
            insitu = insitu[start_index:*]
          endif else begin
            print, 'REQUESTED START TIME OF ',strtrim(string(time[0]),2),' IS OUTSIDE THE RANGE INCLUDED IN THE DATA STRUCTURES.'
          endelse
          if (initial_time[2] gt start_time) and (initial_time[2] lt end_time) then begin
            end_time = initial_time[2]
            end_time_string = time_string(initial_time[2],format=0)
            end_index = 0l
            temp_time = min(abs(insitu.time - initial_time[2]),end_index)
            insitu = insitu[0:end_index]
          endif else begin
            print, 'REQUESTED END TIME OF ',strtrim(string(time[2]),2),' IS OUTSIDE THE RANGE INCLUDED IN THE DATA STRUCTURES.'
          endelse
          if (initial_time[1] gt start_time) and (initial_time[1] lt end_time) then begin
            time_index=0L
            temp_time = min(abs(insitu.time - initial_time[1]),time_index)
            mid_time = insitu[time_index].time
            mid_time_string = time_string(mid_time,format=0)    
          endif else begin
            print, 'REQUESTED PLOT TIME OF ',strtrim(string(time[1]),2),' IS OUTSIDE THE RANGE INCLUDED IN THE DATA STRUCTURES. PLOTTING THE MID-TIME INSTEAD.'
            total_points = n_elements(insitu.time)
            time_index = long(total_points/2L)
            mid_time = insitu[time_index].time
            initial_time = mid_time
            mid_time_string = time_string(mid_time,format=0) 
          endelse
        endif                                       ;end of 3 value time loop
      endif else begin
        time_index = long(total_points/2L)
        mid_time = insitu[time_index].time
        initial_time = mid_time
        mid_time_string = time_string(mid_time,format=0)
      endelse 
   
  ;PARSE DATA STRUCTURES FOR KP DATA AVAILABILITY
  
     instrument_array = intarr(15)     ;flags to indicate if a given instrumnet data is present
     
     tags=tag_names(insitu)
     temp = where(tags eq 'LPW')
     if temp ne -1 then instrument_array[0] = 1
     temp = where(tags eq 'STATIC')
     if temp ne -1 then instrument_array[1] = 1
     temp = where(tags eq 'SWIA')
     if temp ne -1 then instrument_array[2] = 1
     temp = where(tags eq 'SWEA')
     if temp ne -1 then instrument_array[3] = 1
     temp = where(tags eq 'MAG')
     if temp ne -1 then instrument_array[4] = 1
     temp = where(tags eq 'SEP')
     if temp ne -1 then instrument_array[5] = 1
     temp = where(tags eq 'NGIMS')
     if temp ne -1 then instrument_array[6] = 1

     if keyword_set(iuvs) then begin
      instrument_array[7] = 1
      tags1 = tag_names(iuvs)
      temp = where(tags1 eq 'PERIAPSE')
      if temp ne -1 then instrument_array[8] = 1
      temp = where(tags1 eq 'APOAPSE')
      if temp ne -1 then instrument_array[9] = 1
      temp = where(tags1 eq 'CORONA_E_HIGH')
      if temp ne -1 then instrument_array[10] = 1
      temp = where(tags1 eq 'CORONA_E_DISK')
      if temp ne -1 then instrument_array[11] = 1
      temp = where(tags1 eq 'STELLAR_OCC')
      if temp ne -1 then instrument_array[12] = 1
      temp = where(tags1 eq 'CORONA_LO_HIGH')
      if temp ne -1 then instrument_array[13] = 1
      temp = where(tags1 eq 'CORONA_LO_LIMB')
      if temp ne -1 then instrument_array[14] = 1
     endif
  
  
  ;PARSE COMMAND LINE OPTIONS FOR INITIAL CONDITIONS
  
    ;DEFINE THE BASEMAP
    install_result = routine_info('mvn_kp_3d',/source)
    install_directory = strsplit(install_result.path,'mvn_kp_3d.pro',/extract,/regex)
    
    ;CHECK THE INSITU DATA STRUCTURE FOR RELEVANT FIELDS
      MVN_KP_TAG_PARSER, insitu, base_tag_count, first_level_count, second_level_count, base_tags,  first_level_tags, second_level_tags

    ;BACKGROUND COLORS
    bg_colors = [[0,0,0],[15,15,15],[30,30,30],[45,45,45],[60,60,60],[75,75,75],[90,90,90],[105,105,105],[120,120,120],[135,135,135],[150,150,150],$
                 [165,165,165],[180,180,180],[195,195,195],[210,210,210],[225,225,225],[240,240,240],[255,255,255]]
  
    if keyword_set(bgcolor) then begin
      backgroundcolor = bg_colors[bgcolor]
    endif else begin
      backgroundcolor = [15,15,15]
    endelse
  
    ;default colorbar settings
      colorbar_max = 100.
      colorbar_min = 0.0
      colorbar_stretch=0

  
  ;BUILD THE WIDGET

    ;set the size of the draw window
      xsize=800
      ysize=800
    
    base = widget_base(title='MAVEN Key Parameter Visualization',/column)
    subbase = widget_base(base,/row)

      ;BASE AND VISUALIZATION WINDOW
      subbaseL = widget_base(subbase)
      draw = widget_draw(subbaseL, xsize=xsize, ysize=ysize, graphics_level=2, $
                         /button_events, /motion_events, /wheel_events, uname='draw',$
                         retain=2)
    
    if keyword_set(direct) eq 0 then begin          ;SKIP THIS IF /DIRECT IS SET, SKIPPING THE GUI INTERFACE
                         
      ;TOP LEVEL MENU                  
      subbaseR = widget_base(subbase)
       subbaseR1 = widget_base(subbaseR,/column)
        button1 = widget_button(subbaseR1, value='Mars/Label Options', uname='mars',$
                                xsize=300, ysize=30)
        button1 = widget_button(subbaseR1, value='In-Situ Data', uname='insitu', xsize=300, ysize=30)
        if instrument_array[7] eq 1 then begin
          button1 = widget_button(subbaseR1, value='IUVS Data', uname='iuvs', xsize=300, ysize=30)
        endif
        button1 = widget_button(subbaseR1, value='Viewing Geometries', uname='views', xsize=300, ysize=30)
        button1 = widget_button(subbaseR1, value='Models', uname='models',xsize=300,ysize=30)
        button1 = widget_button(subbaseR1, value='Outputs', uname='output', xsize=300,ysize=30)
        button1 = widget_button(subbaseR1, value='Animation', uname='animation', xsize=300, ysize=30)
        button1 = widget_button(subbaseR1, value='Help', uname='help',xsize=300,ysize=30)       
 
      ;TIME BAR ACROSS THE BOTTOM

        timebarbase = widget_base(base, /column,/frame, /align_center, xsize=1100)
        time_min = start_time                     ;PROVIDES LATER ABILITY TO CHANGE AND UPDATE START/END TIMES
        time_max = end_time
        timelabelbase = widget_base(timebarbase, xsize=1100, ysize=20, /row)
        label5 = widget_label(timelabelbase, value=strtrim(string(time_string(time_min,format=4)),2), scr_xsize=200, /align_left)
        label6 = widget_label(timelabelbase, value='Time Range', /align_center, scr_xsize=590)
        label7 = widget_label(timelabelbase, value=strtrim(string(time_string(time_max,format=4)),2), scr_xsize=200, /align_right)
        timeline = cw_fslider(timebarbase, /drag, maximum=time_max, minimum=time_min, /double, $
                              uname='time', title='Displayed Time',xsize=1100,/edit,/suppress_value)
        widget_control,timeline,set_value=mid_time
        
       ;MARS GLOBE/LABEL OPTIONS MENU 
       subbaseR2 = widget_base(subbaseR,/column)
       marsbase = widget_base(subbaseR2,/column)
;       ;BASEMAP OPTIONS
        button1 = widget_button(marsbase, value='Spacecraft Orbit Track', uname='orbit_onoff', xsize=300, ysize=30)
        label1 = widget_label(marsbase, value='Basemap')
        basemapbase = widget_base(marsbase, /column,/frame,/exclusive)
          button1 = widget_button(basemapbase, value='MDIM',uname='basemap1',xsize=300,ysize=30)
          widget_control,button1, /set_button                  
          button1 = widget_button(basemapbase, value='MOLA',uname='basemap1',xsize=300,ysize=30)                  
          button1 = widget_button(basemapbase, value='MOLA_BW',uname='basemap1',xsize=300,ysize=30)                  
          button1 = widget_button(basemapbase, value='MAG',uname='basemap1',xsize=300,ysize=30)
          button1 = widget_button(basemapbase, value='BLANK',uname='basemap1',xsize=300,ysize=30) 
          button1 = widget_button(basemapbase, value='User Defined',uname='basemap1',xsize=300,ysize=30)                                          
;      ;LABEL OPTIONS
        label2 = widget_label(marsbase, value='Label Options')
        gridbase = widget_base(marsbase, /column,/frame)
        button2 = widget_button(gridbase, value='Grid',uname='grid', xsize=300,ysize=30)
        button2 = widget_button(gridbase, value='Sub-Solar Point', uname='subsolar',xsize=300,ysize=30)
        button2 = widget_button(gridbase, value='Sub-Spacecraft', uname='submaven', xsize=300,ysize=30)
        button2 = widget_button(gridbase, value='Terminator', uname='terminator', xsize=300,ysize=30,sensitive=0)
        button2 = widget_button(gridbase, value='Sun Vector', uname='sunvector', xsize=300, ysize=30,sensitive=0)
        button2 = widget_button(gridbase, value='Planet Axes', uname='axes', xsize=300, ysize=30)
        button2 = widget_button(gridbase, value='Parameters', uname='parameters', xsize=300, ysize=30)
        button2 = widget_button(gridbase, value='Plotted Values', uname='orbitPlotName', xsize=300, ysize=30)
        
       ;COLOR OPTIONS
        label2 = widget_label(marsbase, value='Color Options')
        gridbase1 = widget_base(marsbase,/column,/frame)
        loadct,0,/silent
        bgcolor = cw_clr_index(gridbase1, uname ='background_color',color_values=bg_colors,xsize=210,ysize=30)
        
        button2 = widget_button(marsbase, value='Return',uname='mars_return', xsize=300,ysize=30)             

        ;VIEWING GEOMETRY OPTIONS MENU
        subbaseR3 = widget_base(subbaseR,/column)
          
          button3 = widget_button(subbaseR3, value='Return',uname='view_return', xsize=300,ysize=30)             
 
 
 
        ;MODEL DISPLAY OPTIONS
        subbaseR4 = widget_base(subbaseR, /column)
          label4 = widget_label(subbaseR4, value='Atmosphere Shells', /align_center)
          modbase1 = widget_base(subbaseR4, /row,/frame)
            button4 = widget_button(modbase1, value='Level 1', uname='atmLevel1', xsize=70, ysize=30)
            button41c = widget_button(modbase1, value='Load', uname='atmLevel1Load',xsize=50, ysize=30,sensitive=0)
            atmLevel1height = 100
            button41a = widget_text(modbase1, value=strtrim(string(atmlevel1height),2), uname='atmLevel1height',/editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase1, value='km')
            atmlevel1alpha = 100
            button41b = widget_text(modbase1, value=strtrim(string(atmlevel1alpha),2), uname='atmLevel1alpha', /editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase1, value='%')
          modbase2 = widget_base(subbaseR4, /row,/frame)
            button4 = widget_button(modbase2, value='Level 2', uname='atmLevel2', xsize=70, ysize=30)
            button42c = widget_button(modbase2, value='Load', uname='atmLevel2Load',xsize=50, ysize=30,sensitive=0)
            atmLevel2height = 200
            button42a = widget_text(modbase2, value=strtrim(string(atmlevel2height),2), uname='atmLevel2height',/editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase2, value='km')
            atmlevel2alpha = 100
            button42b = widget_text(modbase2, value=strtrim(string(atmlevel2alpha),2), uname='atmLevel2alpha', /editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase2, value='%')       
          modbase3 = widget_base(subbaseR4, /row,/frame)
            button4 = widget_button(modbase3, value='Level 3', uname='atmLevel3', xsize=70, ysize=30)
            button43c = widget_button(modbase3, value='Load', uname='atmLevel3Load',xsize=50, ysize=30,sensitive=0)
            atmLevel3height = 300
            button43a = widget_text(modbase3, value=strtrim(string(atmlevel3height),2), uname='atmLevel3height',/editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase3, value='km')
            atmlevel3alpha = 100
            button43b = widget_text(modbase3, value=strtrim(string(atmlevel3alpha),2), uname='atmLevel3alpha', /editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase3, value='%')    
          modbase4 = widget_base(subbaseR4, /row,/frame)
            button4 = widget_button(modbase4, value='Level 4', uname='atmLevel4', xsize=70, ysize=30)
            button44c = widget_button(modbase4, value='Load', uname='atmLevel4Load',xsize=50, ysize=30,sensitive=0)
            atmLevel4height = 400
            button44a = widget_text(modbase4, value=strtrim(string(atmlevel4height),2), uname='atmLevel4height',/editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase4, value='km')
            atmlevel4alpha = 100
            button44b = widget_text(modbase4, value=strtrim(string(atmlevel4alpha),2), uname='atmLevel4alpha', /editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase4, value='%') 
          modbase5 = widget_base(subbaseR4, /row,/frame)
            button4 = widget_button(modbase5, value='Level 5', uname='atmLevel5', xsize=70, ysize=30)
            button45c = widget_button(modbase5, value='Load', uname='atmLevel5Load',xsize=50, ysize=30,sensitive=0)
            atmLevel5height = 500
            button45a = widget_text(modbase5, value=strtrim(string(atmlevel5height),2), uname='atmLevel5height',/editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase5, value='km')
            atmlevel5alpha = 100
            button45b = widget_text(modbase5, value=strtrim(string(atmlevel5alpha),2), uname='atmLevel5alpha', /editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase5, value='%') 
          modbase6 = widget_base(subbaseR4, /row,/frame)
            button4 = widget_button(modbase6, value='Level 6', uname='atmLevel6', xsize=70, ysize=30)
            button46c = widget_button(modbase6, value='Load', uname='atmLevel6Load',xsize=50, ysize=30,sensitive=0)
            atmLevel6height = 600
            button46a = widget_text(modbase6, value=strtrim(string(atmlevel6height),2), uname='atmLevel6height',/editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase6, value='km')
            atmlevel6alpha = 100
            button46b = widget_text(modbase6, value=strtrim(string(atmlevel6alpha),2), uname='atmLevel6alpha', /editable,xsize=7,ysize=1,sensitive=0)
            label4 = widget_label(modbase6, value='%') 
          button4 = widget_button(subbaseR4, value='Return',uname='model_return', xsize=300,ysize=30)             
        
        
        ;OUTPUT OPTIONS
        subbaseR5 = widget_base(subbaseR, /column)
        
          button5 = widget_button(subbaseR5, value='Save Configuration',uname='config_save',xsize=300, ysize=30)
          button5 = widget_button(subbaseR5, value='Load Configuration',uname='config_load',xsize=300, ysize=30)
          button5 = widget_button(subbaseR5, value='Export View',uname='save_view',xsize=300,ysize=30)
          button5 = widget_button(subbaseR5, value='Return',uname='output_return', xsize=300,ysize=30)             
        
        ;HELP MENU
        subbaseR6 = widget_base(subbaseR, /column)
          text = widget_text(subbaseR6, /scroll,xsize=45,ysize=55)
          button6 = widget_button(subbaseR6, value='Return',uname='help_return',xsize=300,ysize=30)
        
        ;INSITU MENU
        subbaseR7 = widget_base(subbaseR, /column)
         subbaseR7a = widget_base(subbaseR7, /column,/frame)
           label7 = widget_label(subbaseR7a, value='Orbital Track Plots')
            vert_align = 15
            if instrument_array[0] eq 1 then begin
              lpw_list = tag_names(insitu.lpw)
              drop1=widget_droplist(subbaseR7a, value=lpw_list, uname='lpw_list',title='LPW',frame=5, yoffset=vert_alignf)
              vert_align = vert_align + 15
            endif
            if instrument_array[1] eq 1 then begin
              static_list = tag_names(insitu.static)
              drop1=widget_droplist(subbaseR7a, value=static_list, uname='static_list', title='STATIC', frame=5, yoffset=vert_align)
              vert_align = vert_align + 15
            endif
            if instrument_array[2] eq 1 then begin
              swia_list = tag_names(insitu.swia)
              drop1=widget_droplist(subbaseR7a, value=swia_list, uname='swia_list', title='SWIA', frame=5, yoffset=vert_align)
              vert_align = vert_align + 15
            endif
            if instrument_array[3] eq 1 then begin
              swea_list = tag_names(insitu.swea)
              drop1=widget_droplist(subbaseR7a, value=swea_list, uname='swea_list', title='SWEA', frame=5, yoffset=vert_align)
              vert_align = vert_align + 15
            endif
            if instrument_array[4] eq 1 then begin
              mag_list = tag_names(insitu.mag)
              drop1=widget_droplist(subbaseR7a, value=mag_list, uname='mag_list', title='MAG', frame=5, yoffset=vert_align)
              vert_align = vert_align + 15
            endif
            if instrument_array[5] eq 1 then begin
              sep_list = tag_names(insitu.sep)
              drop1=widget_droplist(subbaseR7a, value=sep_list, uname='sep_list', title='SEP', frame=5, yoffset=vert_align)
              vert_align = vert_align + 15
            endif
            if instrument_array[6] eq 1 then begin
              ngims_list = tag_names(insitu.ngims)
              drop1=widget_droplist(subbaseR7a, value=ngims_list, uname='ngims_list', title='NGIMS', frame=5, yoffset=vert_align)
              vert_align = vert_align + 15
            endif
        
         button7 = widget_button(subbaseR7, value='Vector Plots', uname='vector_display',xsize=300,ysize=30)
         subbaseR7b = widget_base(subbaseR7, /column,/frame,/exclusive)
           if instrument_array[4] eq 1 then begin
             button7 = widget_button(subbaseR7b, value='Magnetic Field', uname='vector_field', xsize=300,ysize=15)
           endif
           if instrument_array[2] eq 1 then begin
             button7 = widget_button(subbaseR7b, value='SWIA H+ Flow Velocity', uname='vector_field', xsize=300,ysize=15)
           endif
           if instrument_array[1] eq 1 then begin
             button7 = widget_button(subbaseR7b, value='STATIC H+ Flow Velocity', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='STATIC O+ Flow Velocity', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='STATIC O2+ Flow Velocity', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='STATIC H+/He++ Characteristic Direction', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='STATIC Pickup Ion Characteristic Direction', uname='vector_field', xsize=300,ysize=15)
           endif
           if instrument_array[5] eq 1 then begin
             button7 = widget_button(subbaseR7b, value='SEP Look Direction 1', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='SEP Look Direction 2', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='SEP Look Direction 3', uname='vector_field', xsize=300,ysize=15)
             button7 = widget_button(subbaseR7b, value='SEP Look Direction 4', uname='vector_field', xsize=300,ysize=15)
           endif
             
            button7 = widget_button(subbaseR7, value='Plot',uname='overplots',xsize=300,ysize=30) 
            subbaseR7c = widget_base(subbaseR7, /column, /frame)
              button7 = widget_button(subbaseR7c, value='ColorTable',uname='colortable',xsize=300,ysize=30)
              button7 = widget_button(subbaseR7c, value = 'Color Bar', uname='ColorBarPlot', xsize=300, ysize=30)
              subbaseR7d = widget_base(subbaseR7c, /row)
                label7 = widget_label(subbaseR7d, value='Min')
                text7 = widget_text(subbaseR7d, value= string(colorbar_min), /editable,xsize=3,uname='colorbar_min')
                label7 = widget_label(subbaseR7d, value='Max')
                text7 = widget_text(subbaseR7d, value=string(colorbar_max), /editable,xsize=3,uname='colorbar_max')
                button7 = widget_button(subbaseR7d, value='Reset', uname='colorbar_reset')
                subbaseR7e = widget_base(subbaseR7d, /row,/exclusive)
                button7a = widget_button(subbaseR7e, value='Linear', uname='colorbar_stretch')
                widget_control, button7a, /set_button
                button7 = widget_button(subbaseR7e, value='Log', uname='colorbar_stretch')
          button7 = widget_button(subbaseR7, value='Return',uname='insitu_return',xsize=300,ysize=30)
        
        ;IUVS MENU
        subbaseR8 = widget_base(subbaseR, /column)
          if instrument_array[8] eq 1 then begin
            subbaseR8a = widget_base(subbaseR8, /column,/frame) 
              label8 = widget_label(subbaseR8a, value='Periapse Limb Scans', /align_center)
              button8 = widget_button(subbaseR8a, value='Display All Profiles', uname='periapse_all', xsize=300, ysize=30)
              subbaseR8b = widget_base(subbaseR8a, /column,sensitive=0)
                  peri_den_list = 'Density: '+strtrim(iuvs[0].periapse[0].density_id,2)
                  drop1=widget_droplist(subbaseR8b,value=peri_den_list,uname='peri_select',title='Density Profiles', frame=5)
                  peri_rad_list = 'Radiance: '+strtrim(iuvs[0].periapse[0].radiance_id,2)
                  drop1=widget_droplist(subbaseR8b,value=peri_rad_list,uname='peri_select',title='Radiance Profiles', frame=5)
                  button8 = widget_button(subbaseR8b, value='Display Altitude Profile', uname='peri_profile', xsize=300, ysize=30)                  
                  button8 = widget_button(subbaseR8b, value='Select Individual Scans', uname='periapse_some', xsize=300, ysize=30)
          endif
          
          button8 = widget_button(subbaseR8, value='Return',uname='iuvs_return',xsize=300,ysize=30)
          
          ;ANIMATION MENU
          subbaseR9 = widget_base(subbaseR, /column)
            label9 = widget_label(subbaseR9, value='Animation Options', /align_center)
            subbaseR9a = widget_base(subbaseR9, /row)
              label9 = widget_label(subbaseR9a, value='Full Time Animation', /align_center)
              button9a = widget_button(subbaseR9a, value='Start', uname='full_time_anim_begin')
              button9b = widget_button(subbaseR9a, value='Stop', uname='full_time_anim_end',sensitive=0)
            
            button9 = widget_button(subbaseR9, value='Return', uname='anim_return', xsize=300, ysize=30)
            
            
    endif         ;END OF THE WIDGET CREATION LOOP (SKIPPED IF /DIRECT SET)      
          
    widget_control, base,/realize
    widget_control, draw, get_value=window  
  
  ;SET THE INITIAL VIEWING DETAILS

    view = obj_new('IDLgrView', color=backgroundcolor, viewplane_rect=[-2,-2,4,4], eye=5.1,projection=2)
    view -> SetProperty, zclip = [5.0,-5.0]
    model = obj_new('IDLgrModel')
    view -> add, model
    
      ;DEFINE THE BASEMAP
    if keyword_set(basemap) eq 0 then begin
      read_jpeg,install_directory+'MDIM_2500x1250.jpg',image     ;USE MDIM AS DEFAULT BASEMAP FOR NOW
    endif else begin
      case basemap of 
        'mdim': read_jpeg,install_directory+'MDIM_2500x1250.jpg',image
        'mola': read_jpeg,install_directory+'MOLA_color_2500x1250.jpg',image
        'mola_bw': read_jpeg,install_directory+'MOLA_bw_2500x1250.jpg',image
        'mag': read_jpeg,install_directory+'Mars_Crustal_Magnetism_MGS.jpg',image
      endcase
    endelse
    
   ;BUILD THE GLOBE
    npoints=361
    rplanet = .33962
    arr = REPLICATE(rplanet,npoints,npoints)
    mesh_obj, 4, vertices, polygons, arr
    oImage = OBJ_NEW('IDLgrImage', image )
      vector = FINDGEN(npoints)/(npoints-1.) 
      texure_coordinates = FLTARR(2, npoints, npoints) 
      texure_coordinates[0, *, *] = vector # REPLICATE(1., npoints) 
      texure_coordinates[1, *, *] = REPLICATE(1., npoints) # vector 
      oPolygons = OBJ_NEW('IDLgrPolygon', $ 
        DATA = vertices, POLYGONS = polygons, $ 
        COLOR = [255, 255, 255], reject=1, shading=1,$ 
        TEXTURE_COORD = texure_coordinates, $ 
        TEXTURE_MAP = oImage, /TEXTURE_INTERP)
     model -> ADD, oPolygons  
     
   ;ADD ADDITIONAL 'GLOBES' WITH TEMPORARY TEXTURE FOR LATER ATM MODELS
    
    MVN_KP_3D_ATMSHELL, atmModel1, oPolygons1, .34962
    MVN_KP_3D_ATMSHELL, atmModel2, oPolygons2, .35962
    MVN_KP_3D_ATMSHELL, atmModel3, oPolygons3, .36962
    MVN_KP_3D_ATMSHELL, atmModel4, oPolygons4, .37962
    MVN_KP_3D_ATMSHELL, atmModel5, oPolygons5, .38962
    MVN_KP_3D_ATMSHELL, atmModel6, oPolygons6, .39962
    
     view -> add, atmModel1
     view -> add, atmModel2
     view -> add, atmModel3
     view -> add, atmModel4
     view -> add, atmModel5
     view -> add, atmModel6
     atmModel1->setproperty,hide=1
     atmModel2->setproperty,hide=1
     atmModel3->setproperty,hide=1
     atmModel4->setproperty,hide=1
     atmModel5->setproperty,hide=1
     atmModel6->setproperty,hide=1
     
    ;ADD LINES   DEFAULT THAT GRIDLINES ARE NOT SHOWN
     ;LATITUDE
      xcenter = 0
      ycenter = 0
      rplanet = .33962
      ogridarr =objarr(13)
      points = (2*!pi/359.0) * FINDGEN(360)
      radius = rplanet+(rplanet*0.0001)
      for i=0,4 do begin
       x = (xcenter + radius * cos(points))*cos((-60.+(30.*i))*(!pi/180.))
       y = (ycenter + radius * sin(points))*cos((-60.+(30.*i))*(!pi/180.))
       z = (points*0.)+(ycenter + (radius * sin((-60.+(30.*i))*(!pi/180.))))
       arr = transpose ([[x],[y],[z]])
       ogridarr[i] = obj_new('IDLgrPolyline',arr,linestyle=2,thick=2)
      endfor
     ;LONGITUDE
      for i=0,7 do begin
        x = xcenter + radius * cos((45.*i)*(!pi/180.)) * cos(points)
        y = ycenter + radius * sin((45.*i)*(!pi/180.)) * cos(points)
        z = ycenter + radius * sin(points)
        arr = transpose([[x],[y],[z]])
        ogridarr[5+i] = obj_new('IDLgrPolyline',arr,linestyle=2,thick=2)
      endfor
      gridlines = obj_new('IDLgrModel')
      for i = 0, n_elements(ogridarr) - 1 do $ 
        gridlines -> ADD, ogridarr[i]
      mytext_north = OBJ_NEW('IDLgrText', 'N', LOCATION=[0,0,rplanet+0.001], COLOR=[255,255,255],onglass=1,char_dimensions=[10,10],render_method=render_method)
      gridlines->Add, mytext_north  
      mytext_south = OBJ_NEW('IDLgrText', 'S', LOCATION=[0,0,-rplanet-0.001], COLOR=[255,255,255],onglass=1,char_dimensions=[10,10],render_method=render_method)
      gridlines->Add, mytext_south
      view -> add, gridlines

      gridlines -> setProperty, hide=1
      
      if keyword_set(grid) then gridlines -> setProperty,hide=0
    
    
    ;ADD THE AXES TO THE PLANET
      axesModel = obj_new('IDLgrModel')
      xticks = obj_new('idlgrtext',['1','2','3'])
      yticks = obj_new('idlgrtext',['1','2','3'])
      zticks = obj_new('idlgrtext',['1','2','3'])
      xticktitle=obj_new('idlgrtext','X')
      yticktitle=obj_new('idlgrtext','Y')
      zticktitle=obj_new('idlgrtext','Z')
      Xaxis = obj_new('IDLgraxis',0,color=[200,200,200], thick=2,tickvalues=[.33962,.67924,1.01886],ticktext=Xticks,ticklen=0.1,title=xticktitle)
      Yaxis = obj_new('IDLgraxis',1,color=[200,200,200], thick=2,tickvalues=[.33962,.67924,1.01886],ticktext=Yticks,ticklen=0.1,title=yticktitle)
      Zaxis = obj_new('IDlgraxis',2,color=[200,200,200], thick=2,tickvalues=[.33962,.67924,1.01886],ticktext=Zticks,ticklen=0.1,title=zticktitle)
      axesModel->add, Xaxis
      axesModel->add, Yaxis
      axesModel->add, Zaxis
      view->add, axesModel
      axesmodel->setproperty,hide=1
      if keyword_set(axes) then axesmodel->setproperty,hide=0

    ;ADD THE LIGHTING
      lightModel = obj_new('IDLgrModel')
      model->add, lightModel
      
      ;LIGHT FROM THE SUN (CALCULATED TO BE IN THE RIGHT PLACE)
        ;CONVERT SOLAR POSITION TO X,Y,Z
        solar_x_coord = 10000. * cos(insitu.spacecraft.subsolar_point_geo_latitude*(!pi/180.)) * cos(insitu.spacecraft.subsolar_point_geo_longitude*(!pi/180.))
        solar_y_coord = 10000. * cos(insitu.spacecraft.subsolar_point_geo_latitude*(!pi/180.)) * sin(insitu.spacecraft.subsolar_point_geo_longitude*(!pi/180.))
        solar_z_coord = 10000. * sin(insitu.spacecraft.subsolar_point_geo_latitude*(!pi/180.))
      
      dirLight = obj_new('IDLgrLight', type=2, location=[solar_x_coord[time_index],solar_y_coord[time_index],solar_z_coord[time_index]])
      lightModel->add, dirLight
      
      ;OVERALL LIGHTING FOR THE DARKSIDE
      ambientLight = obj_new('IDLgrLight', type=0, intensity=0.2)
      lightModel->add, ambientLight

    ;ADD A VECTOR POINTING TO THE SUN, IF REQUESTED 
      sun_model = obj_new('IDLgrModel')
     
      sun_vector = obj_new('IDLgrPolyline',[[0,-10000],[0,10000],[0,0]],color=[255,255,255],thick=5)
      sun_model->add, sun_vector
      sun_model->setproperty,hide=1
      if keyword_set(sunmodel) then sun_model->setproperty,hide=0
      
    ;ADD THE TERMINATOR 
  
    ;ADD THE SUB-SOLAR POINT
    
      sub_solar_model = obj_new('IDLgrModel')
      view->add,sub_solar_model
      sub_solar_point = obj_new('IDLgrSymbol',data=24, color=[255,255,0], fill_color=[255,255,0], filled=1, size=[0.02,0.02,0.02])
      subsolar_x_coord = rplanet * cos(insitu.spacecraft.subsolar_point_geo_latitude*(!pi/180.)) * cos(insitu.spacecraft.subsolar_point_geo_longitude*(!pi/180.))
      subsolar_y_coord = rplanet * cos(insitu.spacecraft.subsolar_point_geo_latitude*(!pi/180.)) * sin(insitu.spacecraft.subsolar_point_geo_longitude*(!pi/180.))
      subsolar_z_coord = rplanet * sin(insitu.spacecraft.subsolar_point_geo_latitude*(!pi/180.))
      
      sub_solar_line = obj_new('IDLgrPolyline', [subsolar_x_coord[time_index],subsolar_x_coord[time_index]],[subsolar_y_coord[time_index],subsolar_y_coord[time_index]],$
                                [subsolar_z_coord[time_index],subsolar_z_coord[time_index]],color=[255,255,0],thick=1,symbol=sub_solar_point)
      for i=0,n_elements(sub_solar_line) -1 do sub_solar_model -> add,sub_solar_line[i]
      sub_solar_model -> setproperty,hide=1
      if keyword_set(subsolar) then sub_solar_model ->setproperty,hide=0
    
    ;ADD THE SUB-SPACECRAFT POINT
      sub_maven_model = obj_new('IDLgrModel')
      view->add,sub_maven_model
      submaven_point = obj_new('IDLgrSymbol',data=18, color=[0,0,255], fill_color=[0,0,255], filled=1, size=[0.02,0.02,0.02])
      submaven_x_coord = rplanet * cos(insitu.spacecraft.sub_sc_latitude*(!pi/180.)) * cos(insitu.spacecraft.sub_sc_longitude*(!pi/180.))
      submaven_y_coord = rplanet * cos(insitu.spacecraft.sub_sc_latitude*(!pi/180.)) * sin(insitu.spacecraft.sub_sc_longitude*(!pi/180.))
      submaven_z_coord = rplanet * sin(insitu.spacecraft.sub_sc_latitude*(!pi/180.))
      
      sub_maven_line = obj_new('IDLgrPolyline', [submaven_x_coord[time_index],submaven_x_coord[time_index]],[submaven_y_coord[time_index],submaven_y_coord[time_index]],$
                                [submaven_z_coord[time_index],submaven_z_coord[time_index]],color=[0,0,255],thick=1,symbol=submaven_point)
      for i=0,n_elements(sub_maven_line) -1 do sub_maven_model -> add,sub_maven_line[i]
      sub_maven_model -> setproperty,hide=1
      if keyword_set(submaven) then sub_maven_model ->setproperty,hide=0    
    
    
    ;ADD THE MOUSE CONTROL
      track = obj_new('Trackball', [xsize, ysize] / 2, (xsize < ysize) / 2)


    ;ADD TEXT LABELS 
      textModel = obj_new('IDLgrModel')
      timetext = OBJ_NEW('IDLgrText',time_string(mid_time,format=0), color=[0,255,0], locations=[-2,1.9,0] )
      textModel->add, timetext
      view->add,textModel

    ;CREATE THE PARAMETER LABELS
      parameterModel = obj_new('IDLgrModel')
      paraText1 = obj_new('IDLgrText','Distance to Sun:'+strtrim(string(insitu(time_index).spacecraft.mars_sun_distance),2)+' AU',color=[0,255,0], locations=[-1.99,1.7,0])
      parameterModel->add, paraText1
      paraText2 = obj_new('IDLgrText','Mars Season:'+strtrim(string(insitu(time_index).spacecraft.mars_season),2),color=[0,255,0], locations=[-1.99,1.6,0])
      parameterModel->add,paraText2
      paraText3 = obj_new('IDLgrText','MAVEN Altitude:'+strtrim(string(insitu(time_index).spacecraft.altitude),2),color=[0,255,0], locations=[-1.99,1.5,0])
      parameterModel->add,paraText3
      paraText4 = obj_new('IDLgrText','Solar Zenith Angle:'+strtrim(string(insitu(time_index).spacecraft.sza),2),color=[0,255,0], locations=[-1.99,1.4,0])
      parameterModel->add,paraText4
      paraText5 = obj_new('IDLgrText','Local Time:'+strtrim(string(insitu(time_index).spacecraft.local_time),2),color=[0,255,0], locations=[-1.99,1.3,0])
      parameterModel->add,paraText5    
      view->add,parameterModel
      parameterModel->setproperty,hide=1

    ;CREATE THE ORBITAL PATH
      x_orbit = (insitu.spacecraft.geo_x)/10000.0
      y_orbit = (insitu.spacecraft.geo_y)/10000.0
      z_orbit = (insitu.spacecraft.geo_z)/10000.0

      ;DEFINE THE COLORS ALONG THE FLIGHT PATH
        if keyword_set(color_table) then begin
          path_color_table = color_table
        endif else begin
          path_color_table = 13             ;default RAINBOW color table, changable
        endelse
        loadct,path_color_table,/silent
          
        if keyword_set(field) then begin      ;if parameter not selected, pass an invalid value
          MVN_KP_TAG_VERIFY, insitu, field,base_tag_count, first_level_count, base_tags,  $
                             first_level_tags, check, level0_index, level1_index, tag_array
          if check ne 0 then begin         ;if requested parameter doesn't exist, default to none
            print,'REQUESTED PLOT PARAMETER, '+strtrim(string(field),2)+' IS NOT PART OF THE DATA STRUCTURE.'
            plotted_parameter_name = ''
            current_plotted_value = ''
            level0_index = -9
            level1_index = -9
          endif else begin
            plotted_parameter_name = tag_array[0]+':'+tag_array[1]
            current_plotted_value = insitu[time_index].(level0_index).(level1_index)
          endelse             
        endif else begin                ;if no parameter selected, default to none
          plotted_parameter_name = ''
          current_plotted_value = ''
          level0_index = -9
          level1_index = -9
        endelse 

        vert_color = intarr(3,n_elements(insitu.spacecraft.geo_x))        
        MVN_KP_3D_PATH_COLOR, insitu, level0_index, level1_index, path_color_table, vert_color,colorbar_ticks,0.0,100.0,0.   
        orbit_model = obj_new('IDLgrModel')
        view -> add, orbit_model
        orbit_path = obj_new('IDLgrPolyline', x_orbit,y_orbit,z_orbit, thick=2,vert_color=vert_color,shading=1)
        for i=0,n_elements(orbit_path) -1 do orbit_model -> add,orbit_path[i]

    ;CREATE THE VECTOR MODEL TO HOLD SUCH DATA
    
      vector_model = obj_new('IDLgrModel')
      x_vector = fltarr(n_elements(x_orbit)*2)
      y_vector = fltarr(n_elements(y_orbit)*2)
      z_vector = fltarr(n_elements(z_orbit)*2)
      vector_polylines = lonarr(3*n_elements(insitu.spacecraft.geo_x))
      for i=0l,n_elements(x_orbit)-1 do begin
        x_vector[i*2] = x_orbit[i]
        y_vector[i*2] = y_orbit[i]
        z_vector[i*2] = x_orbit[i]       
        x_vector[(i*2)+1] = x_orbit[i]
        y_vector[(i*2)+1] = y_orbit[i]+0.00001
        z_vector[(i*2)+1] = z_orbit[i]
        vector_polylines[i*3] = 2l
        vector_polylines[(i*3)+1] = (i*2l)
        vector_polylines[(i*3)+2] = (i*2l)+1l  
      endfor 
      vector_path = obj_new('IDLgrPolyline', x_vector, y_vector, z_vector, polylines=vector_polylines, thick=1, vert_color=vert_color,shading=1,alpha_channel=0.2)
      for i=0l,n_elements(vector_path)-1 do vector_model->add,vector_path[i]
      view -> add,vector_model
      vector_model->setProperty,hide=1  
      if keyword_set(whiskers) then vector_model->setproperty,hide=0


    ;CREATE A LABEL FOR WHAT IS PLOTTED ALONG THE SPACECRAFT ORBIT
      plottedNameModel = obj_new('IDLgrModel')
      plotText1 = obj_new('IdlgrText',plotted_parameter_name, color=[0,255,0],locations=[1.99,1.9,0],alignment=1.0)
      plotText2 = obj_new('IdlgrText',strtrim(string(current_plotted_value),2), color=[0,255,0], locations=[1.99,1.82,0],alignment=1.0)
      plottedNameModel->add,plotText1
      plottedNameModel->add,plotText2
      view->add,plottedNameModel
      plottedNameModel->setproperty,hide=1
      if keyword_set(plotname) then plottedNameModel->setproperty,hide=0
      
    ;CREATE A COLORBAR FOR THE ALONG TRACK PLOTS
      colorbarmodel = obj_new('IDLgrModel')
      barDims = [0.1, 0.4]
      colorbar_ticktext = obj_new('idlgrtext',string(colorbar_ticks),color=[0,255,0])
      colorbar1 = obj_new('IdlgrColorbar', dimensions=barDims, r_curr,g_curr, b_curr, /show_axis, /show_outline, ticktext=colorbar_ticktext,major=5,color=[0,255,0])
      colorbarmodel->add,colorbar1
      view->add,colorbarmodel
      colorbarmodel->translate,1.9,-1.9,0
      colorbarmodel->setproperty, hide=1
      if keyword_set(color_bar) then colorbarmodel->setproperty,hide=0
      
     ;CREATE THE SPACECRAFT 
     
        maven_model = obj_new('IDLgrModel')
        if keyword_set(cow) then begin
          model_scale = 0.1
        endif else begin
          model_scale = 0.01
        endelse
        MVN_KP_3D_MAVEN_MODEL, x,y,z,polylist,model_scale,cow=cow,install_directory           ;ROUTINE TO LOAD A MODEL OF THE MAVEN SPACECRAFT (WHEN AVAILABLE)
        ;MOVE THE MAVEN MODEL TO THE CORRECT ORBITAL LOCATION
         x = x + x_orbit(time_index)
         y = y + y_orbit(time_index)
         z = z + z_orbit(time_index)
        maven_poly = obj_new('IDLgrPolygon', x, y, z, polygons=polylist, color=[100,80,25], shading=1,reject=1)
        maven_model -> add, maven_poly
        view -> add, maven_model

      ;CREATE THE PARAMETER PLOT ALONG THE BOTTOM EDGE OF THE DISPLAY
      
        plot_model = obj_new('IDLgrModel')
        view->add,plot_model
        plot_x = insitu.time
        plot_y = fltarr(n_elements(insitu.spacecraft.altitude))
        plot_y = insitu.spacecraft.altitude
        plot_colors = intarr(3,n_elements(plot_x))
        plot_colors[0,*] = 255
        plot_colors[0,time_index-50:n_elements(plot_x)-1] = 0
        plot_colors[2,time_index-50:n_elements(plot_x)-1] = 255
        parameter_plot = obj_new('IDLgrPlot', plot_x, plot_y,color=[0,255,0],vert_colors=plot_colors)
        plot_model -> add, parameter_plot
        
        parameter_plot->getproperty, xrange=xr, yrange=yr
        xc = mg_linear_function(xr, [-1.7,1.4])
        yc = mg_linear_function(yr, [-1.9,-1.5])
        parameter_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc

        parameter_yaxis = obj_new('IDLgrAxis', 1, range=yr,color=[0,128,0],thick=2,tickdir=1,/exact,notext=1)
        parameter_xaxis = obj_new('IDLgrAxis', 0, range=xr,color=[0,128,0],thick=2,tickdir=1,/exact,notext=1)
        plot_model->add,parameter_yaxis
        plot_model->add,parameter_xaxis
        parameter_yaxis->setproperty,xcoord_conv=[-1.7,xc[1]],ycoord_conv=yc
        parameter_xaxis->setproperty,xcoord_conv=xc,ycoord_conv=yc
        plot_model->setproperty,hide=1
        if keyword_set(parameterplot) then plot_model->setproperty,hide=0

      ;CREATE THE PERIAPSE LIMB SCANS
        if instrument_array[8] eq 1 then begin
          periapse_limb_model =  obj_new('IDLgrModel')
          view->add, periapse_limb_model
          periapse_x = fltarr(n_elements(iuvs.periapse.time_start)*2*n_elements(iuvs[0].periapse[0].alt))
          periapse_y = fltarr(n_elements(iuvs.periapse.time_start)*2*n_elements(iuvs[0].periapse[0].alt))
          periapse_z = fltarr(n_elements(iuvs.periapse.time_start)*2*n_elements(iuvs[0].periapse[0].alt))
          periapse_polyline = lonarr(n_elements(iuvs.periapse.time_start)*3*n_elements(iuvs[0].periapse[0].alt))
          peri_vert_colors = intarr(3,n_elements(iuvs[0].periapse[0].alt)*n_elements(iuvs.periapse.time_start))
          peri_vert_colors[2,*] = 255
          
          peri_index = 0
          for i=0,n_elements(iuvs)-1 do begin
            for j=0, n_elements(iuvs[i].periapse)-1 do begin
              for k=0,n_elements(iuvs[i].periapse[j].alt)-1 do begin
                  periapse_x[peri_index] = (rplanet+(iuvs[i].periapse[j].alt[k]/10000.0)) * cos(iuvs[i].periapse[j].lat*(!pi/180.)) * cos(iuvs[i].periapse[j].lon*(!pi/180.))
                  periapse_y[peri_index] = (rplanet+(iuvs[i].periapse[j].alt[k]/10000.0)) * cos(iuvs[i].periapse[j].lat*(!pi/180.)) * sin(iuvs[i].periapse[j].lon*(!pi/180.))
                  periapse_z[peri_index] = (rplanet+(iuvs[i].periapse[j].alt[k]/10000.0)) * sin(iuvs[i].periapse[j].lat*(!pi/180.)) 
                peri_index = peri_index+1
              endfor
            endfor
          endfor
          
          for i=0,n_elements(iuvs.periapse.time_start)-1 do begin
            periapse_polyline[i*(n_elements(iuvs[0].periapse[0].alt)+1)] = n_elements(iuvs[0].periapse[0].alt)
            for j=1,n_elements(iuvs[0].periapse[0].alt) do begin
              periapse_polyline[(i*(n_elements(iuvs[0].periapse[0].alt)+1))+j]= (i*(n_elements(iuvs[0].periapse[0].alt)))+(j-1)
            endfor
          endfor
          
          periapse_vectors = obj_new('IDLgrPolyline', periapse_x, periapse_y, periapse_z, polylines=periapse_polyline, vert_colors=peri_vert_colors, thick=3,color=[0,0,255])
          for i=0, n_elements(periapse_vectors)-1 do periapse_limb_model->add,periapse_vectors[i]
          periapse_limb_model->setproperty,hide=1
          if keyword_set(periapse_limb_scan) then periapse_limb_model->setproperty,hide=0

        ;CREATE THE PERIAPSE LIMB SCAN ALTITUDE PLOT
          if keyword_set(periapse_limb_scan) ne 1 then begin
             periapse_limb_scan = 'Density: H'
          endif
          
          MVN_KP_3D_CURRENT_PERIAPSE, iuvs.periapse, initial_time, current_periapse, periapse_limb_scan, xlabel
          
          alt_plot_model = obj_new('IDLgrModel')
          view->add,alt_plot_model
          alt_plot = obj_new('IDLgrPlot', current_periapse[1,*], current_periapse[0,*],color=[0,255,0],vert_colors=[255,255,255],linestyle=0)
          alt_plot_model -> add, alt_plot
  
          alt_plot->getproperty, xrange=xr, yrange=yr
          xc = mg_linear_function(xr, [-1.75,-1.4])
          yc = mg_linear_function(yr, [-1.3,1.0])
          alt_plot->setproperty,xcoord_conv=xc, ycoord_conv=yc
          alt_xaxis_title = obj_new('IDLgrText', xlabel, color=[0,255,0])
          alt_xaxis_ticks = obj_new('idlgrtext', [strtrim(string(min(current_periapse[1,*]), format='(E8.2)'),2),strtrim(string(max(current_periapse[1,*]), format='(E8.2)'),2)])
          
          alt_yaxis = obj_new('IDLgrAxis', 1, range=yr,color=[0,128,0],thick=2,tickdir=1,/exact,major=5)
          alt_xaxis = obj_new('IDLgrAxis', 0, range=xr,color=[0,128,0],thick=2,tickdir=1,/exact,major=2,title=alt_xaxis_title,ticktext=alt_xaxis_ticks)
          alt_plot_model->add,alt_yaxis
          alt_plot_model->add,alt_xaxis
          alt_yaxis->setproperty,xcoord_conv=[-1.76,xc[1]],ycoord_conv=yc
          alt_xaxis->setproperty,xcoord_conv=[-1.75,xc[1]],ycoord_conv=[-1.3,yc[1]]
          alt_plot_model->setproperty,hide=1
          if keyword_set(periapse_limb_scan) then alt_plot_model->setproperty,hide=0

        endif 

     

    window->draw, view

  ;SET THE GLOBAL VARIABLES TO KEEP EVERYTHING IN CHECK

    if keyword_set(direct) eq 0 then begin                ;SKIP ALL THIS IF /DIRECT IS SET, SKIPPING THE GUI INTERFACE

        if keyword_set(iuvs) then begin
          iuvs_state = {iuvs:iuvs, $
                        periapse_limb_model:periapse_limb_model, periapse_vectors:periapse_vectors, current_periapse:current_periapse, periapse_limb_scan:periapse_limb_scan, $
                        alt_plot_model:alt_plot_model, alt_plot:alt_plot, alt_yaxis:alt_yaxis, alt_xaxis:alt_xaxis, alt_xaxis_title:alt_xaxis_title, alt_xaxis_ticks:alt_xaxis_ticks, $
                        subbaseR8b:subbaseR8b}             
        endif
        
        insitu_state = {button1: button1, button2: button2, button3: button3, button4: button4, button5: button5, button6: button6, $
                 button41a: button41a, button41b: button41b, button41c: button41c, button42a: button42a, button42b: button42b, $
                 button42c: button42c, button43a: button43a, button43b: button43b, button43c: button43c, button44a: button44a, $
                 button44b: button44b, button44c: button44c, button45a: button45a, button45b: button45b, button45c: button45c, $
                 button46a: button46a, button46b: button46b, button46c: button46c, button9a:button9a, button9b:button9b, $
                 window: window, $
                 draw: draw, $
                 backgroundcolor: backgroundcolor, $
                 subbaseR: subbaseR, subbaseR1: subbaseR1, subbaseR2: subbaseR2, subbaseR3: subbaseR3, subbaseR4: subbaseR4, $
                 subbaseR5: subbaseR5, subbaseR6: subbaseR6, subbaseR7: subbaseR7, subbaseR8: subbaseR8, subbaseR9:subbaseR9, $
                 text: text, $
                 view: view, $
                 model: model, $
                 opolygons: opolygons, $
                 atmModel1: atmModel1, atmModel2: atmModel2, atmModel3: atmModel3, atmModel4: atmModel4, atmModel5: atmModel5, atmModel6: atmModel6, $
                 opolygons1: opolygons1, opolygons2: opolygons2, opolygons3: opolygons3, opolygons4: opolygons4, opolygons5: opolygons5, opolygons6: opolygons6, $
                 atmLevel1alpha: atmLevel1alpha, atmLevel2alpha: atmLevel2alpha, atmLevel3alpha: atmLevel3alpha, atmLevel4alpha: atmLevel4alpha, atmLevel5alpha: atmLevel5alpha, atmLevel6alpha: atmLevel6alpha, $
                 atmLevel1height: atmLevel1height, atmLevel2height: atmLevel2height, atmLevel3height: atmLevel3height, atmLevel4height: atmLevel4height, atmLevel5height: atmLevel5height, atmLevel6height: atmLevel6height, $
                 gridlines: gridlines, $
                 axesmodel: axesmodel, $
                 dirlight: dirlight,  lightmodel: lightmodel, $
                 track: track, $
                 textModel: textModel, $
                 timetext: timetext, $
                 orbit_model: orbit_model, orbit_path: orbit_path, path_color_table: path_color_table, $
                 vector_model:vector_model, vector_path: vector_path, $
                 maven_model: maven_model, $
                 sun_model: sun_model, $
                 sub_solar_line: sub_solar_line, $
                 sub_solar_model: sub_solar_model, $
                 sub_maven_line: sub_maven_line, $
                 sub_maven_model: sub_maven_model, $
                 parametermodel:parametermodel, $
                 plottednamemodel:plottednamemodel, $
                 colorbarmodel: colorbarmodel, colorbar_ticks: colorbar_ticks, colorbar_ticktext: colorbar_ticktext, colorbar1: colorbar1, $
                 colorbar_min:colorbar_min, colorbar_max:colorbar_max, colorbar_stretch:colorbar_stretch, $
                 plot_model: plot_model, parameter_plot: parameter_plot, plot_colors:plot_colors, parameter_yaxis:parameter_yaxis, $
                 paratext1: paratext1, paratext2: paratext2, paratext3: paratext3, paratext4: paratext4, paratext5: paratext5, $
                 plottext1: plottext1, plottext2: plottext2, $
                 plotted_parameter_name: plotted_parameter_name, $
                 current_plotted_value: current_plotted_value, $
                 x_orbit: x_orbit, y_orbit: y_orbit, z_orbit: z_orbit, $
                 solar_x_coord: solar_x_coord, solar_y_coord: solar_y_coord, solar_z_coord: solar_z_coord, $
                 subsolar_x_coord: subsolar_x_coord, subsolar_y_coord: subsolar_y_coord, subsolar_z_coord: subsolar_z_coord, $
                 submaven_x_coord: submaven_x_coord, submaven_y_coord: submaven_y_coord, submaven_z_coord: submaven_z_coord, $
                 insitu: insitu, $
                 time_index:time_index, initial_time:initial_time, $
                 base: base, $
                 level0_index: level0_index, level1_index: level1_index, $
                 install_directory: install_directory, $
                 instrument_array:instrument_array $
                 }
     
      
        if keyword_set(iuvs) then begin
          state = create_struct(insitu_state, iuvs_state)
        endif else begin
          state = insitu_state
        endelse
                          
      pstate = ptr_new(state, /no_copy)
    
      
        ;set menu visibilities
          widget_control,(*pstate).subbaseR2, map=0
          widget_control,(*pstate).subbaseR3, map=0
          widget_control,(*pstate).subbaseR4, map=0
          widget_control,(*pstate).subbaseR5, map=0
          widget_control,(*pstate).subbaseR6, map=0
          widget_control,(*pstate).subbaseR7, map=0
          widget_control,(*pstate).subbaseR8, map=0
          widget_control,(*pstate).subbaseR9, map=0
      
      widget_control, base, set_uvalue=pstate
    
      xmanager, 'MVN_KP_3D', base,/no_block, cleanup='MVN_KP_3D_cleanup', event_handler='MVN_KP_3D_event'

  endif               ;END OF THE /DIRECT KEYWORD CHECK LOOP

finish:
end
