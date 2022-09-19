function read_nc4,filename,buffer,groupname=groupname,content_list=content_list,lun=lun

grpnames=strsplit(groupname,/extract,'/')
ngrplayers=n_elements(grpnames)

nitems=n_elements(content_list)

status=is_ncdf(filename)
if status eq -1 then begin
print,"Failed to open "+filename
if arg_present(lun) then printf,lun,"Failed to open "+filename
return,-1
endif

fid=ncdf_open(filename)  ;open file

grpid=ncdf_ncidinq(fid,grpnames[0])
if grpid eq -1 then begin
   print,'Error finding parent group '+grpnames[0]+'from '+filename
   ncdf_close,fid
   return,-1
endif


if ngrplayers GT 1 then begin
      for i=0,ngrplayers-2 do begin
          grpid=ncdf_ncidinq(grpid,grpnames[i+1])
          if grpid eq -1 then begin
             print,'Error finding group '+grpnames[i+1]+' in '+groupname + 'from '+filename
             ncdf_close,fid           
             return,-1
          endif
      endfor
endif
    
j=0
for j=0, nitems-1 do begin
    item_name=content_list[j]
    varid=ncdf_varid(grpid,item_name)   
    if (varid GE 0) then begin
       ncdf_varget,grpid,varid,item_val
       if j eq 0 then begin
          buffer=create_Struct(item_name,item_val)
       endif else begin
          tag_list=tag_names(buffer)
          tag_loc=where(tag_list eq strupcase(item_name))
          if tag_loc[0] eq -1 then begin
             buffer=create_struct(buffer,item_name,item_val)
          endif
       endelse
    endif else begin
       print,'Error reading '+item_name +'from '+filename
       ncdf_close,fid       
       if arg_present(lun) then printf,lun,'Error reading '+item_name +'from '+filename
       return,-1
    endelse
endfor

ncdf_close,fid
return,0
end
