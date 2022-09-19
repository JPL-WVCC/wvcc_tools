pro read_cris_viirs_ind_demo

;This is a demo code to use the MEaSUREs SNPP CrIS-VIIRS collocation index products to obtain VIIRS observations over collocated CrIS FOV
;The index file could be used together with any L1 and L2 products of CrIS and VIIRS (750m)
;For CrIS L1B data structure, please refer to CrIS L1B user guide
;For VIIRS L1 and L2 data structure and dimension names, please refer to VIIRS user guide 
;All indices are 0-based following IDL convention.
;---By Qing Yue, Jan, 2022


;determine which CrIS granule's index file will be read 
indroot='/tmp/pair/product/'
yearmon='201710/'
day='01/'
cris_gran='SNDR.SNPP.CRIS.20171001T0006.m06.g002.L1B_NSR.std.v02_05.G.180623021521/'

inddir=indroot+yearmon+day+cris_gran+'IND_CrIS_VIIRSMOD_SNDR.SNPP.'+strmid(cris_gran,15,13)+strmid(cris_gran,32,5)+'/'

indfile=inddir+'IND_CrIS_VIIRSMOD_SNDR.SNPP.'+strmid(cris_gran,15,13)+strmid(cris_gran,32,5)+'.nc'

;first read in the global attributes, which contains the following useful information
;VIIRS_File_Names: contains the files names of VIIRS granules included in the index file, which could be used to find VIIRS granule IDs for VIIRS L1 and L2 products
;CrIS_File_Name: contains the file name of the CrIS granule, which could be used to find CrIS granule ID for CrIS L1 and L2 products
;CrIS_Start_Time, CrIS_End_Time: contains the start and end time of the CrIS scan (UTC) 
;CrIS_Min_Lat, CrIS_Min_Lon, CrIS_Max_Lon, CrIS_Max_Lat: contains the latitude and longitude boundaries of the file

err=read_ncdf(indfile,attribute,/global_attributes)
VIIRS_File_Names=strsplit(string(attribute.VIIRS_File_Names),',',/extract)
;insert other strong manipulations to form files names of other VIIRS L2 products if needed, such as VIIRS L2 fire
;here we only demonstrate examples using the VIIRS saved in the input folder. 
VIIRSroot='/tmp/pair/input/'

n_VIIRS=n_elements(VIIRS_File_Names)

;read in the VIIRS variable of interest, which is usually 2D [number_of_pixels,number_of_lines] after IDL reads it in,
;then concatinate the variable from different granules to stack up the number of lines 
for i=0,n_VIIRS-1 do begin
    VIIRS_file=VIIRSroot+yearmon+day+cris_gran+VIIRS_File_Names[i]
    err=read_nc4(VIIRS_file,data_VIIRS,groupname='geolocation_data',content_list=['latitude'])
    if i eq 0 then begin
       VIIRS_lat=data_VIIRS.latitude
       data_VIIRS=0
    endif
    if i GE 1 then begin
       VIIRS_lat=concat(VIIRS_lat,data_VIIRS.latitude,dimension=1)
       data_VIIRS=0
    endif
endfor

;read in the collocation index
err=read_ncdf(indfile,index)
result=size(index.FOVCount_ImagerPixel,/dimension) 
FOVCount_ImagerPixel=index.FOVCount_ImagerPixel ;records the count of imager pixels per sounder FOV, arranged in sounder FOV dimensions (as in the variable result)

;calculate cumulatively the end index of number of pixels for VIIRS
FOVCount2=total(reform(index.FOVCount_ImagerPixel,result[0]*result[1]*result[2]),/cumulative,/integer) ;cumulatively counts

;find the location of CrIS FOVs with more than 1 VIIRS pixels collocated
;Note that IDL where function return 1D index, which needs to be converted to 3D as CrIS FOV is arranged as a 3D matrix
findcollocation=where(FOVCount_ImagerPixel GE 1,nfindcollocation)   
col = findcollocation mod result[0]
row = (findcollocation / result [0]) mod result[1]
frame = findcollocation / (result[1]*result[0])

for i=0,nfindcollocation -1 do begin

;read out the VIIRS indices for each CrIS FOV that has more than 1 VIIRS pixels collocated
;the position of the CrIS FOV is [Col[i],row[i],frame[i]]
    if i eq 0 and findcollocation[0] eq 0 then begin
      dy=index.number_of_pixels[0:FOVCount2[0]-1] & dx=index.number_of_lines[0:FOVCount2[0]-1]
    endif else begin
      dy=index.number_of_pixels[FOVCount2[findcollocation[i-1]]:FOVCount2[findcollocation[i]]-1]
      dx=index.number_of_lines[FOVCount2[findcollocation[i-1]]:FOVCount2[findcollocation[i]]-1]
    endelse
;take out the part of the VIIRS variable as determined by the index
;this will be the VIIRS variable over the CrIS FOV at the location of [Col[i],row[i],frame[i]] 
    VIIRS_Lat_onthisCrIS=VIIRS_lat[dx,dy]

;insert analysis or IO code to process the VIIRS data

endfor
stop
       
end
