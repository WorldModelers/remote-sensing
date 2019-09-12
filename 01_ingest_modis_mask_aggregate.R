
#-------------------Base Setup--------------------------------------------------
rm(list=ls())

#---Set Project Directories
dirBase<-'/Volumes/GoogleDrive/My Drive/' #base directory

#-Project Directories
dirProj<-paste0(dirBase,'Remote Sensing Breakout/') #project directory
dirRdat<-paste0(dirProj,'r_code/rdata/') #r data filew
dirShapeFiles<-paste0(dirProj,'shapefiles/') #shape files
dirMODIS<-paste0(dirProj,'MODIS/') #modis directory
dirMask<-paste0(dirProj,'cropmask/') #crop mask directory


#===============================


#---------Libraries
library(raster)
library(R.utils)
library(rgeos)
library(rgdal)
library(reshape2)
library(stringr)
library(dplyr)
#===============================================================================

# Get Mask--- substitute for different mask if needed
m<-raster(paste0(dirMask,'East_AFRICA_cropmask_IIASA-IFPRI_Crop_fraction_area_CHIRPS_0.5.nc'))



#---------------Get MODIS Brick--------
setwd(dirMODIS)
prefix<-'MOD13C2_EVI_2003-2018.nc'
g<-stack(prefix) #stack much faster than brick, brick must point to one fiel

#--------------Read in Shapefiles-------------------------------
setwd(dirShapeFiles)
dsp<-readOGR(dsn='.',layer='gadm36_ETH_3') 

#----Crop Raster to Ethiopia
g<-raster::crop(g,dsp)


#-----Apply Crop Mask----
m<-raster::crop(m,g)
if(extent(g) != extent(m)){m<-raster::resample(m,g)} #must match raster resolution
g<-mask(g,m,maskvalue=0,updatevalue=NA)


#----Extract Mean EVI value
tic<-Sys.time() #set a timer
dkc<-raster::extract(g,dsp,fun=mean,na.rm=TRUE,sp=TRUE)
toc<-Sys.time()-tic #about 3 minutes on laptop with 16g ram

#--Write Out----
filname<-'01_modis_EVI_extracted_to_Ethiopia_with_Mask.Rdata'
setwd(dirRdat)
save(dkc,toc,file=filname) 


# Clean Up and format in Long and Wide Format then Write Out -------------------------------------------------

#--Convert to Long Format with Key ID variables
d<-dkc@data
names(d)<-tolower(names(d))
d<-dplyr::select(d,name_1,name_2,name_3,cc_3,x2003.01.31:x2018.12.31)
vars<-c('name_1','name_2','name_3','cc_3') #id variables
d<-melt(d,id.vars=vars)

#Extract year and Month
d$year<-str_sub(d$variable,start=2,end=5)
d$year<-as.numeric(d$year)
d$month<-str_sub(d$variable,start=7,end=8)
d$month<-as.numeric(d$month)

#Rename Variables
d<-dplyr::select(d,one_of(vars),year,month,value)
d<-dplyr::rename(d,modis_evi=value)
d$modis_evi<-round(d$modis_evi,3)

#Covert back to Wide Format
dwide<-reshape2::dcast(d,name_1+name_2+name_3+cc_3~year+month)

#Write out to Project Directory
setwd(dirProj)
write.csv(d,row.names=FALSE,'woreda_evi_values_long.csv')
write.csv(dwide,row.names=FALSE,'woreda_evi_values_wide.csv')


