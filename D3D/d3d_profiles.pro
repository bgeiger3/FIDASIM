;;RESTORES PROFILES FROM GAPROFILES SAVE FILES LOCATED IN INPUTS.PROFILE_DIR DIRECTORY
FUNCTION d3d_profiles,inputs

    ;; profiles structure
    ;;** Structure <83e8518>, 7 tags, length=5768, data length=5764, refs=1:
    ;;   TIME            FLOAT           4.42000
    ;;   RHO             DOUBLE    Array[120]
    ;;   TI              DOUBLE    Array[120] [eV]
    ;;   VTOR            DOUBLE    Array[120] [m/s]
    ;;   TE              DOUBLE    Array[120] [eV]
    ;;   DENE            DOUBLE    Array[120] [m^-3]
    ;;   ZEFF            DOUBLE    Array[120]


	;;CREATE FILENAMES 
	time_str='00000'+strtrim(string(long(inputs.time*1000)),1)
	time_str=strmid(time_str,4,/reverse_offset)
	shot_str=strtrim(string(inputs.shot),1)
	profile_str=shot_str+'.'+time_str

	dir=inputs.profile_dir+shot_str+'/'
	ne_string=dir+'dne'+profile_str
	te_string=dir+'dte'+profile_str
	ti_string=dir+'dti'+profile_str
	imp_string=dir+'dimp'+profile_str+'_Carbon'
	vtor_string=dir+'dtrot'+profile_str
	
	;;CHECK IF FILES EXIST
	file_array=[ne_string,te_string,ti_string,imp_string,vtor_string]
	err_array=dblarr(n_elements(file_array))
	for i=0,n_elements(file_array)-1 do begin
		if file_test(file_array[i]) eq 0 then begin
			print,file_array[i]+' does not exist: Exiting'
			err_array[i]=1
		endif
	endfor
	w=where(err_array eq 1 ,nw)
	if nw ne 0 then begin
		print,'FATAL ERROR'
		profiles={err:1}
	endif else begin
		;;RESTORE DENSITY
		restore,ne_string
		dene=ne_str.dens*10.0d^(19.0d) ;;m^-3
		dene_rho=ne_str.rho_dens
	
		;;RESTORE ELECTRON TEMPERATURE
		restore,te_string
		te=te_str.te*10.0d^(3.0d) ;;eV
		te_rho=te_str.rho_te
		
		;;RESTORE ION TEMPERATURE
		restore,ti_string
		ti=ti_str.ti*10.0d^(3.0d) ;;eV
		ti_rho=ti_str.rho_ti
	
		;;RESTORE ZEFF
		restore,imp_string
		zeff=impdens_str.zeff
		zeff_rho=impdens_str.rho_imp

		;;RESTORE VTOR
		restore,vtor_string
		vtor=tor_rot_str.tor_rot_local*tor_rot_str.r_tor_rot ;;m/s
		vtor_rho=tor_rot_str.rho_tor_rot
	
		;;SAVE IN PROFILE STRUCTURE
		profiles={time:inputs.time,rho:dene_rho,te:te,ti:ti,vtor:vtor,dene:dene,zeff:zeff,err:0}
	endelse
	return,profiles
END
