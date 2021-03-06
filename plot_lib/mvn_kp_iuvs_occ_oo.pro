;+
;
; :Name: mvn_kp_iuvs_occ_oo
;
; Copyright 2017 Regents of the University of Colorado. All Rights Reserved.
; Released under the MIT license.
; This software was developed at the University of Colorado's Laboratory for Atmospheric and Space Physics.
; Verify current version before use at: https://lasp.colorado.edu/maven/sdc/public/pages/software.html
; :Author: Harter
;
; :Description:
;   This routine plots the IUVS PERIAPSE limb-scan KP data using
;   IDL's Object-Oriented Graphics routines.
;   All three limb-scans from each orbit are included in each plot,
;   with keywords allowing a choice of orbits and species.
;   By default, all limb scan data, both radiance and
;   density profiles, are displayed.
;
; :Params:
;    kp_data : in, required, type=structure
;       the IUVS data structure read into memory by the MVN_KP_READ routine
;
; :Keywords:
;    profiles : in, optional, type=intarr(ndims)
;       an array listing the orbits to be plotted
;    ret_species : in, optional, type=intarr(ndims)
;       an array listing the density measurements of particular
;       species to be plotted
;    nolegend : in, optional, type=strarr(1)
;       either 'vertical' or 'horizontal',
;       defining the orientation of the legend.
;    linear : in, optional, type=byte
;       optional keyword to make plots on a linear scale, instead of the
;       logarithmic default
;    oo: out, optional, object
;       Variable to which plot object may be passed to $MAIN$.
;    species_expand: in, optional, byte
;       if this keyword is selected, then all the species for a given orbit
;       will be plotted on a single graph
;    profile_expand: in, optional, byte
;       if this keyword is selected, then all the orbits will be combined
;       into a single plot for comparison purposes
;    range: in, optional, byte
;       if selected, this will return the temporal range of the data set
;       without plotting anything
;    colortable: in, optional, type=integer
;       an option to override the default colortable with any other
;       IDL colortable
;    window: in, optional, type=byte
;       if invoked, will create a new window instead of reusing the previous.
;    winX: in, optional, type=integer
;       sets the X size of the window, in pixels.
;    winY: in, optional, type=integer
;       sets the Y size of the window, in pixels.
;
; :History:   1.0   June 8, 2015
;
;-
pro MVN_KP_IUVS_OCC_OO, kp_data=kp_data, species_data=species_data, $
  altitude=altitude, $
  layout_vector=layout_vector, plot_name=plot_name, $
  oplot_vector=oplot_vector, color_vector=color_vector, $
  species_linestyle=species_linestyle, $
  species_thick=species_thick, hide_vector=hide_vector, $
  species_dimensions=species_dimensions, $
  profile_dimensions=profile_dimensions, $
  profile_inclusion=profile_inclusion, $
  oo=oo, leg=leg, winx=winx, winy=winy, $
  nolegend=nolegend, _extra=e, $
  retrieval_labels=retrieval_labels, $
  profile_labels=profile_labels, $
  species_expand=species_expand, $
  profile_expand=profile_expand

  tot_species = profile_dimensions * species_dimensions

  ;SET DEFAULT WINDOW SIZES
  if keyword_set(winX) ne 1 then begin
    winX=640
  endif
  if keyword_set(winY) ne 1 then begin
    winY=512
  endif

  ;
  ; Margins *may* come from driver routine; TBD
  ;  Currently ignored
  ;DETERMINE APPROPRIATE MARGINS
  ;MARGINS
  p_margin = replicate(0.1,4)   ; Set Default for OO graphics
  if keyword_set(species_expand) then begin
    p_margin[3] = 0.125      ; top margin
  endif

  ;
  ; Here is my new plotting loop
  ;
  ;  print,profile_inclusion
  ;  help,profile_inclusion
  ;  print,profile_dimensions
  ;  help,plot_name
  ;  help,color_vector
  ;stop
  include = where(profile_inclusion eq 1)

  plot1=[]
  for ispec = 0,species_dimensions-1 do begin
    k = ispec
    for iprof = 0,profile_dimensions-1 do begin
      i = (array_indices(intarr(n_elements(kp_data),3),include[iprof]))[0]
      j = (array_indices(intarr(n_elements(kp_data),3),include[iprof]))[1]
      igraph = ispec * profile_dimensions + iprof
      ; postpone xtitle for more pressing issues
      ;      xtitle = ( ispec lt radiance_dimensions ) $
      ;             ? 'kR' : 'cm!U-3!N'
      if oplot_vector[igraph] eq -1 then begin
        plot1 = [plot1,plot( species_data[i,j,k,*], altitude, $
          ytitle='Altitude[km]', $
          linestyle=species_linestyle[k], $
          thick=species_thick[k], $
          color=color_vector[*,iprof], $
          layout=layout_vector[igraph,*], $
          overplot=0, $
          title=plot_name[k,iprof], $
          current = keyword_set(iprof+k), $
          name=plot_name[k,iprof], $
          dimensions=[winX,winY], $
          _extra = e )]
      endif else begin
        plot1 = [plot1,plot( species_data[i,j,k,*], altitude, $
          ytitle='Altitude[km]', $
          linestyle=species_linestyle[k], $
          thick=species_thick[k], $
          color=color_vector[*,iprof], $
          overplot=plot1[oplot_vector[igraph]], $
          title=title, xtitle=xtitle, $
          current = keyword_set(iprof+k), $
          name=plot_name[k,iprof] )]
      endelse
    endfor
  endfor

  if( total(hide_vector) lt tot_species and $
    ~keyword_set(nolegend) )then begin
    ;  Only plot legend if we haven't hidden every item
    leg1 = legend(target=plot1)  ; ADD THE LEGEND
    for i = 0,tot_species-1 do begin
      leg1[i].hide = hide_vector[i]  ; HIDE REDUNDANT LABELS
    endfor
  endif

  ;ADD OVERALL LABELS

  ret_label = 0.7

  if keyword_set(species_expand) then begin
    ret_label = 0.48
  endif

  ;  Might want to change this to use plot names for species labels
  ;  and only use Radiance and Density for the non-species-expand plots

  text1 = text( ret_label, 0.965, 'Retrieval', /normal, target = plot1 )

  ;
  ;  Pass the plot object out, if requested
  ;
  if( arg_present(oo) and ~keyword_set(directgraphics) )then oo=plot1
  if( arg_present(oo) and arg_present(leg) and $
    total(hide_vector) lt tot_species and $
    ~keyword_set(nolegend) )then leg=leg1

end
