;+
; 
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
;
; :Params:
;    iuvs_record: in, required, type=structure
;       the single data record structure to hold IUVS KP data
;    instruments: in, optional, type=struct
;      a struct that signals which types of data have been requested, 
;      so that only those fields are included in the structures.
;


;-
pro MVN_KP_IUVS_STRUCT_INIT, iuvs_record, nalt_struct=nalt_struct,  $
                             instruments=instruments

if not (keyword_set(nalt_struct)) then begin
  nalt_struct = {periapse_rad:32, periapse_den:53, c_l_limb:-1, c_l_high:130, c_e_limb:-1, c_e_high:-1, stellarocc:40}
endif
  
  ;; Check ENV variable to see if we are in debug mode
  debug = getenv('MVNTOOLKIT_DEBUG')
  
  if not keyword_set(debug) then begin
    on_error, 1
  endif
  
  ;; Default to filling all instruments if not specified
  if not keyword_set(instruments) then begin
    instruments $
      = CREATE_STRUCT('lpw',      1, 'euv',      1, 'static',   1, 'swia',1, $
                      'swea',     1, 'mag',      1, 'sep',      1, $
                      'ngims',    1, 'periapse', 1, 'c_e_disk', 1, $
                      'c_e_limb', 1, 'c_e_high', 1, 'c_l_disk', 1, $
                      'c_l_limb', 1, 'c_l_high', 1, 'apoapse' , 1, $
                      'stellarocc', 1)
  endif
  
  ;; ---------------------------------------------------------------------- ;;
  ;; ------------------- Create IUVS structure ---------------------------- ;;
 

  ;CREATE THE STRUCT CONTAINING THE COMMON PORTION OF ALL IUVS OBSERVATIONS
  iuvs_record_common = create_struct(                                        $
    'time_start'               ,'',                                          $
    'time_stop'                ,'',                                          $
    'sza'                      ,!VALUES.F_NAN,                               $
    'local_time'               ,!VALUES.F_NAN,                               $
    'lat'                      ,!VALUES.F_NAN,                               $
    'lon'                      ,!VALUES.F_NAN,                               $
    'lat_mso'                  ,!VALUES.F_NAN,                               $
    'lon_mso'                  ,!VALUES.F_NAN,                               $
    'orbit_number'             ,-1L,                                         $
    'mars_season_ls'           ,!VALUES.F_NAN,                               $
    'spacecraft_geo'           ,make_array(3, /DOUBLE, VALUE=!VALUES.D_NAN), $
    'spacecraft_mso'           ,make_array(3, /DOUBLE, VALUE=!VALUES.D_NAN), $
    'sun_geo'                  ,make_array(3, /DOUBLE, VALUE=!VALUES.D_NAN), $
    'spacecraft_geo_longitude' ,!VALUES.F_NAN,                               $
    'spacecraft_geo_latitude'  ,!VALUES.F_NAN,                               $
    'spacecraft_mso_longitude' ,!VALUES.F_NAN,                               $
    'spacecraft_mso_latitude'  ,!VALUES.F_NAN,                               $
    'subsolar_point_geo_longitude' ,!VALUES.F_NAN,                           $
    'subsolar_point_geo_latitude'  ,!VALUES.F_NAN,                           $
    'spacecraft_sza'           ,!VALUES.F_NAN,                               $
    'spacecraft_local_time'    ,!VALUES.F_NAN,                               $
    'spacecraft_altitude'      ,!VALUES.F_NAN,                               $
    'mars_sun_distance'        ,!VALUES.F_NAN,                               $
    'n_alt_bins'               ,-1L)                                         
    
  iuvs_record_temp = create_struct(['orbit'],-1L)

  ;INCLUDE IUVS STELLAR OCCULTATION DATA STRUCTURE
  if instruments.stellarocc then begin
      if nalt_struct.stellarocc gt 0 then begin
        nalt = nalt_struct.stellarocc
      endif else begin
        nalt = 40
      endelse
      i5 = create_struct(                                                          $
  ;      NAME                ='occultation',                                       $
        iuvs_record_common,                                                        $
        'n_alt_den_bins'     ,!VALUES.F_NAN,                                       $
        'target_name'        ,'',                                                  $
        'scale_height_id'    ,strarr(3),                                           $
        'scale_height'       ,make_array(3,      /FLOAT, VALUE=!VALUES.F_NAN),     $
        'scale_height_unc'   ,make_array(3,      /FLOAT, VALUE=!VALUES.F_NAN),     $
        'retrieval_id'       ,strarr(4),                                           $
        'retrieval'          ,make_array(4,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
        'retrieval_unc'      ,make_array(4,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
        'retrieval_sys_unc'  ,make_array(3, /FLOAT, VALUE=!VALUES.F_NAN),          $
        'alt'              ,make_array(nalt,    /FLOAT, VALUE=!VALUES.F_NAN))   
      
    
    iuvs_record_temp1 = create_struct(['stellar_occ'],[i5,i5,i5,i5,i5],iuvs_record_temp)
  endif else  iuvs_record_temp1 = create_struct(iuvs_record_temp)


  ;INCLUDE IUVS APOAPSE DATA STRUCTURE
  if instruments.apoapse then begin
    i2 = create_struct(                                                     $
;      NAME               ='apoapse',                                        $
      iuvs_record_common ,                                                  $
      'ozone_depth'      ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'ozone_depth_err'  ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'albedo'           ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'albedo_unc'       ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'auroral_index'    ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'dust_depth'       ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'dust_depth_err'   ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_id'      ,strarr(4),                                        $
      'radiance'         ,make_array(4,90,45, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_err'     ,make_array(4,90,45, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_sys_unc' ,make_array(4,       /FLOAT, VALUE=!VALUES.F_NAN), $
      'sza_bp'           ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'local_time_bp'    ,make_array(90,45,   /FLOAT, VALUE=!VALUES.F_NAN), $
      'lon_bins'         ,make_array(90,      /FLOAT, VALUE=!VALUES.F_NAN), $
      'lat_bins'         ,make_array(45,      /FLOAT, VALUE=!VALUES.F_NAN))
      
    iuvs_record_temp2 = create_struct(['apoapse'],i2,iuvs_record_temp1)
  endif else  iuvs_record_temp2 = create_struct(iuvs_record_temp1)

  
  ;INCLUDE IUVS LO RES HIGH ALITUDE CORONA DATA STRUCTURE
  if instruments.c_l_high then begin
  if nalt_struct.c_l_high gt 0 then begin
      nalt = nalt_struct.c_l_high
  endif else begin
    nalt = 150
  endelse

    i6 = create_struct(                                                      $
;      NAME                   ='c_l_high',                                   $
      iuvs_record_common     ,                                               $
      'half_int_distance_id' ,strarr(2),                                     $
      'half_int_distance'    ,make_array(2,    /FLOAT, VALUE=!VALUES.F_NAN), $
      'half_int_distance_unc',make_array(2,    /FLOAT, VALUE=!VALUES.F_NAN), $
      'density_id'           ,strarr(2),                                     $
      'column_density'     ,make_array(2,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'column_density_unc' ,make_array(2,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'density_sys_unc'    ,make_array(2,      /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_id'        ,strarr(2),                                       $
      'radiance'           ,make_array(2,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_unc'       ,make_array(2,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_sys_unc'   ,make_array(2,      /FLOAT, VALUE=!VALUES.F_NAN), $
      'alt'                ,make_array(nalt,   /FLOAT, VALUE=!VALUES.F_NAN)  $
      )
      
    iuvs_record_temp3 = create_struct(['corona_lo_high'],i6,iuvs_record_temp2)
  endif else  iuvs_record_temp3 = create_struct(iuvs_record_temp2)

 
  ;INCLUDE IUVS LO RES LIMB CORONA DATA STRUCTURE

  if instruments.c_l_limb then begin
    if nalt_struct.c_l_limb gt 0 then begin
      nalt = nalt_struct.c_l_limb
    endif else begin
      nalt = 1
    endelse

    i7 = create_struct(                                                   $
;      NAME               ='c_l_limb',                                    $
      iuvs_record_common ,                                                $
      'scale_height_id'  ,strarr(7),                                      $
      'scale_height'     ,make_array(7,     /FLOAT, VALUE=!VALUES.F_NAN), $
      'scale_height_unc' ,make_array(7,     /FLOAT, VALUE=!VALUES.F_NAN), $
      'density_id'       ,strarr(7),                                      $
      'density'        ,make_array(7,nalt,  /FLOAT, VALUE=!VALUES.F_NAN), $
      'density_unc'    ,make_array(7,nalt,  /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_id'      ,strarr(11),                                     $
      'radiance'       ,make_array(11,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_unc'   ,make_array(11,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'temperature_id'   ,'',                                             $
      'temperature'      ,!VALUES.F_NAN,                                  $
      'temperature_unc'  ,!VALUES.F_NAN,                                  $
      'alt'              ,make_array(nalt,    /FLOAT, VALUE=!VALUES.F_NAN))
      
    iuvs_record_temp4 = create_struct(['corona_lo_limb'],i7,iuvs_record_temp3)
  endif else  iuvs_record_temp4 = create_struct(iuvs_record_temp3)

  
  ;INCLUDE IUVS LO RES DISK CORONA DATA STRUCTURE
  if instruments.c_l_disk then begin
    i8 = create_struct(                                               $
;      NAME               ='c_l_disk',                                $
      iuvs_record_common ,                                            $
      'ozone_depth'      ,!VALUES.F_NAN,                              $
      'ozone_depth_err'  ,!VALUES.F_NAN,                              $
      'auroral_index'    ,!VALUES.F_NAN,                              $
      'dust_depth'       ,!VALUES.F_NAN,                              $
      'dust_depth_err'   ,!VALUES.F_NAN,                              $
      'radiance_id'      ,strarr(4),                                  $
      'radiance'         ,make_array(4, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_err'     ,make_array(4, /FLOAT, VALUE=!VALUES.F_NAN))
      
    iuvs_record_temp5 = create_struct(['corona_lo_disk'],i8,iuvs_record_temp4)
  endif else  iuvs_record_temp5 = create_struct(iuvs_record_temp4)

  
  ;INCLUDE IUVS ECHELLE HIGH ALTITUDE CORONA DATA STRUCTURE 
  if instruments.c_e_high then begin    
    if nalt_struct.c_e_high gt 0 then begin
      nalt = nalt_struct.c_e_high
    endif else begin
      nalt = 1
    endelse
    
    i3 = create_struct(                                                      $
;          NAME                     ='c_e_high',                             $
          iuvs_record_common ,                                               $
          'half_int_distance_id'   ,strarr(3),                               $ 
          'half_int_distance', make_array(3, /FLOAT, VALUE=!VALUES.F_NAN),   $ 
          'half_int_distance_unc',                                           $
            make_array(3,    /FLOAT, VALUE=!VALUES.F_NAN),                   $
          'radiance_id'            ,strarr(3),                               $ 
          'radiance', make_array(3,nalt, /FLOAT, VALUE=!VALUES.F_NAN),       $ 
          'radiance_unc', make_array(3,nalt, /FLOAT, VALUE=!VALUES.F_NAN),   $ 
          'alt', make_array(nalt,   /FLOAT, VALUE=!VALUES.F_NAN))           
    
             iuvs_record_temp6 = create_struct(['corona_e_high'],i3,$
                                               iuvs_record_temp5)
  endif else iuvs_record_temp6 = create_struct(iuvs_record_temp5)

  
  ;INCLUDE IUVS ECHELLE LIMB CORONA DATA STRUCTURE
  if instruments.c_e_limb then begin
    if nalt_struct.c_e_limb gt 0 then begin
      nalt = nalt_struct.c_e_limb
    endif else begin
      nalt = 1
    endelse
    
    i4 = create_struct(                                                      $
;      NAME                     ='c_e_limb',                                  $
      iuvs_record_common ,                                                   $
      'half_int_distance_id' ,strarr(3),                                     $
      'half_int_distance'    ,make_array(3,    /FLOAT, VALUE=!VALUES.F_NAN), $
      'half_int_distance_unc',make_array(3,    /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_id'          ,strarr(3),                                     $
      'radiance'             ,make_array(3,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_unc'         ,make_array(3,nalt, /FLOAT, VALUE=!VALUES.F_NAN), $
      'alt'                  ,make_array(nalt,   /FLOAT, VALUE=!VALUES.F_NAN))
      
    iuvs_record_temp7 = create_struct(['corona_e_limb'],i4,iuvs_record_temp6)
  endif else  iuvs_record_temp7 = create_struct(iuvs_record_temp6)
  
  
  ;INCLUDE IUVS ECHELLE DISK CORONA DATA STRUCTURE
  if instruments.c_e_disk then begin
    i9 = create_struct(                                            $
;      NAME            ='c_e_disk',                                 $
      iuvs_record_common ,                                         $
      'radiance_id'   ,strarr(3),                                  $
      'radiance'      ,make_array(3, /FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_unc'  ,make_array(3, /FLOAT, VALUE=!VALUES.F_NAN))
      
    iuvs_record_temp8 = create_struct(['corona_e_disk'],i9,iuvs_record_temp7)
  endif else  iuvs_record_temp8 = create_struct(iuvs_record_temp7)

  
  ;INCLUDE IUVS PERIAPSE DATA STRUCTURE
  if instruments.periapse then begin
    if nalt_struct.periapse_rad gt 0 then begin
      nalt_rad = nalt_struct.periapse_rad
    endif else begin
      nalt_rad = 32
    endelse
    if nalt_struct.periapse_den gt 0 then begin
      nalt_den = nalt_struct.periapse_den
    endif else begin
      nalt_den = 53
    endelse
    i1 = create_struct(                                                        $
;      NAME                ='periapse',                                        $
      iuvs_record_common,                                                      $
      'n_alt_den_bins'   ,!VALUES.F_NAN,                                       $
      'scale_height_id'  ,strarr(7),                                           $
      'scale_height'     ,make_array(7,      /FLOAT, VALUE=!VALUES.F_NAN),     $
      'scale_height_unc' ,make_array(7,      /FLOAT, VALUE=!VALUES.F_NAN),     $
      'density_id'       ,strarr(7),                                           $
      'density'          ,make_array(7,nalt_den, /FLOAT, VALUE=!VALUES.F_NAN), $
      'density_unc'      ,make_array(7,nalt_den, /FLOAT, VALUE=!VALUES.F_NAN), $
      'density_sys_unc'  ,make_array(7,      /FLOAT, VALUE=!VALUES.F_NAN),     $
      'radiance_id'      ,strarr(11),                                          $
      'radiance'         ,make_array(11,nalt_rad,/FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_unc'     ,make_array(11,nalt_rad,/FLOAT, VALUE=!VALUES.F_NAN), $
      'radiance_sys_unc' ,make_array(11,     /FLOAT, VALUE=!VALUES.F_NAN),     $
      'temperature_id'   ,'',                                                  $
      'temperature'      ,!VALUES.F_NAN,                                       $
      'temperature_unc'  ,!VALUES.F_NAN,                                       $
      'alt_rad'          ,make_array(nalt_rad, /FLOAT, VALUE=!VALUES.F_NAN),  $
      'alt_den'          ,make_array(nalt_den, /FLOAT, VALUE=!VALUES.F_NAN))   
      
    iuvs_record_temp9 = create_struct(['periapse'],[i1,i1,i1],iuvs_record_temp8)
  endif else  iuvs_record_temp9 = create_struct(iuvs_record_temp8)

  
  ;COPY TO OUTPUT STRUCTURE
  iuvs_record = 0
  iuvs_record = create_struct(iuvs_record_temp9)
  iuvs_common = iuvs_record_common
end
