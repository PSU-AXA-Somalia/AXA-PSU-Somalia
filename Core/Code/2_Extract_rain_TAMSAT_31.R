#=================================================================================
# HLG 2021,
# This converts raw RFE2 data to my standardised format
#=================================================================================
# Dataset parameters
#---------------------------------------------------------------------------------
# family    <-"rain"  ;  dataset   <- "RFE2"
# version   <- 1      ;  modified  <- "Raw"
# overwrite <- FALSE

##################################################################

setwd(dir_core)

#Daily/Dekadal/Pentadal/Monthly raw data
OutFolder_Route <- dir_data_remote_BGeoTif_daily

#Does this dataset contain multiple sub-variables?
nvariables <- 1

#---------------------------------------------------------------------------------
# Sort out input folder the meta data
# StemIn  is rain_RFE2_1_Raw
# StemOut is rain_RFE2_1_Geo
# dir_data_in is "~/Desktop/SOMALIA_CODE/Core/Data/2_Remote_Sensing/0_Raw_data/rain_RFE2_1_Raw"
#---------------------------------------------------------------------------------
if((nchar(modified) > 0)&(is.na(modified)==FALSE)){
   StemIn  <- paste(family,dataset,version,modified,"Raw",sep="_")
   StemOut <- paste(family,dataset,version,modified,"Geo",sep="_")
}else{
   StemIn  <- paste(family,dataset,version,"Raw",sep="_")
   StemOut <- paste(family,dataset,version,"Geo",sep="_")
}
dir_data_in  <- paste(dir_data_remote_ARaw,StemIn,sep=sep)

#---------------------------------------------------------------------------------
# Now set up the output folders
# Also add in the regridded folders FUTURE WORK
#---------------------------------------------------------------------------------
# Set up one folder name for each sub-variable
if(nvariables <= 1){
   if((nchar(modified) > 0)&(is.na(modified)==FALSE)){ 
      StemOut <- paste(family,dataset,version,modified,"Geo",sep="_")
   }else{
      StemOut <- paste(family,dataset,version,"Geo",sep="_")
   } 
   dir_data_out <- paste(OutFolder_Route,StemOut,sep=sep)
}else{
   # TBA
}

# Create the folder if it doesn't already exist
# Find out if there are existing files there  - function in globalparams.r
# and list the files in there
conditionalcreate(dir_data_out)
file_list.out <- list.files(dir_data_out)
if(length(file_list.out)<=0){dataoverwrite <- TRUE}else{dataoverwrite <- overwriteGeo}


#=================================================================================
# THIS PART CHANGES FROM DATASET TO DATASET
#=================================================================================
#---------------------------------------------------------------------------------
# List input zip files
#---------------------------------------------------------------------------------
file_list.in <- list.files(dir_data_in)[grep(".zip",list.files(dir_data_in))]

#---------------------------------------------------------------------------------
# TAMSAT data is zipped by year, let's make a folder with it all unzipped
#---------------------------------------------------------------------------------
TAMSATdatadir <- paste(dir_data_in,"AllDataUnzipped",sep=sep)
if(!(file.exists(TAMSATdatadir))){dir.create(TAMSATdatadir)}

#---------------------------------------------------------------------------------
# Need to find the final year because I do want to overwrite that - I will assume that
# it needs completing each time.
#---------------------------------------------------------------------------------
if(verbose==TRUE){print("unzipping")}
for(f in 1:length(file_list.in)){
   if(verbose==TRUE){print(file_list.in[f])}
   a <- suppressWarnings(unzip(paste(dir_data_in,file_list.in[f],sep=sep),
                               exdir=TAMSATdatadir, overwrite=FALSE,junkpaths = TRUE,list=FALSE))
} 

#---------------------------------------------------------------------------------
# OK now pretend that never happened
#---------------------------------------------------------------------------------
dir_data_inold <- dir_data_in
dir_data_in <- TAMSATdatadir
file_list.in <- list.files(dir_data_in)[grep(".nc",list.files(dir_data_in))]
if(verbose %in% c(TRUE,"Limited")){message(paste("\n     Writing Lat/Long/Dates"))}

#---------------------------------------------------------------------------------
# Extract Lon/Lat for TAMSAT
#---------------------------------------------------------------------------------
Dataset_Example <- suppressWarnings(raster(paste(dir_data_in,file_list.in[5],sep=sep),crs=4236))
lat     <- coordinates(Dataset_Example)[,2]
long    <- coordinates(Dataset_Example)[,1]
if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep="")))){
   data.table::fwrite(list(long),paste(dir_data_in,   sep, StemIn,"_Longitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
   data.table::fwrite(list(long),paste(dir_data_inold,sep, StemIn,"_Longitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
}
if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep="")))){
   data.table::fwrite(list(lat),file=paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
   data.table::fwrite(list(lat),file=paste(dir_data_inold,sep, StemIn,"_Latitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
}



#---------------------------------------------------------------------------------
# Extract dates from the files
#---------------------------------------------------------------------------------
date.list <- unlist(lapply(strsplit(file_list.in,".v3.1.nc"),"[",1))
date.list <- as.Date(substr(date.list,4,13),format="%Y_%m_%d")
file_list.in <- file_list.in[order(date.list)]
date.list <- date.list[order(date.list)]

#Make a full date table from that list and write to file
dates        <- suppressWarnings(makedates(date.list))
dates        <- dates[which(is.na(dates$Date)==FALSE),]
dates$file_list.in <- file_list.in

write.csv(dates,paste(dir_data_inold,"/",StemIn,"_Datelist.csv",sep=""),row.names=FALSE,quote=FALSE)   
write.csv(dates,paste(dir_data_in,"/",StemIn,"_Datelist.csv",sep=""),row.names=FALSE,quote=FALSE)   
#---------------------------------------------------------------------------------
# CREATE TAMSAT FUNCTION
#---------------------------------------------------------------------------------
CreateTAMSAT <- function(f,dir_data_in,StemIn,dir_data_out,StemOut,date.list,file_list.in,globalcrs,dataoverwrite){
   
   # Create filename
   file_loc.out  <- paste(dir_data_out,paste(StemOut,"_",date.list[f],".tif",sep=""),sep=sep) 
   file_name.out <- paste(StemOut,"_",date.list[f],".tif",sep="")
   
   # Decide if you want to look at this file
   continue <- FALSE
   if(dataoverwrite == FALSE){
      if(file.exists(file_loc.out)){continue <- FALSE}else{continue <- TRUE}
   }else{
      continue <- TRUE
   }
   
   # Unzip the data, and rename
   file_name.in <- paste(dir_data_in,file_list.in[f],sep=sep)
   
   if((file.exists(file_name.in))&(continue == TRUE)){continue <- TRUE}else{continue <- FALSE}
   
   # If you do...
   if(continue == TRUE){
      # Read in and change the projection
      r <- rast(file_name.in)$"rfe_filled"
      crs(r) <- paste("EPSG:",globalcrs,sep="")
      r[r < 0] <- NA
      
      if(length(unique(values(r)))<=1){
         return(paste("EMPTY",file_name.out))
      }else{
         # Write to file
         if(file.exists(file_loc.out)){file.remove(file_loc.out)}
         suppressMessages(suppressWarnings(terra::writeRaster(r, filename=file_loc.out, filetype="GTiff",overwrite=TRUE)))
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_loc.out,".aux.json",sep="")))))
         return(file_name.out)
      }
   }else{
      return(paste("IGNORED",file_name.out))
   }
}

#---------------------------------------------------------------------------------
# Parallel computing saves about 3/4 time, but this will still take 18minutes
#---------------------------------------------------------------------------------
# ForEach
a <- Sys.time()
if(verbose %in% c(TRUE,"Limited")){message(paste("\n     Writing Data"))}

myres <- foreach(f = 1:length(date.list)) %dopar%  CreateTAMSAT(f,dir_data_in,StemIn,dir_data_out,StemOut,
                                                                date.list,file_list.in,
                                                                globalcrs,dataoverwrite)

print(Sys.time() -a)







