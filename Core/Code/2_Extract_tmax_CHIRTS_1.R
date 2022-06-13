#=================================================================================
# HLG 2022,
# This converts raw CHIRTS tmax data to my standardised format
#=================================================================================
# Dataset parameters
#---------------------------------------------------------------------------------
# family    <-"tmax"  ;  dataset   <- "CHIRTS"
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

# I'm assuming the data is stored in folders simply named the year
dir_data_in  <- paste(dir_data_remote_ARaw,StemIn,sep=sep)
yearfolders <- list.files(dir_data_in)
yearfolders <- suppressWarnings(yearfolders[which(as.numeric(yearfolders) %in% 1980:2060)])

# Now let's make a master list of input files and their source locations
file_list.in <- paste(dir_data_in,list.files(dir_data_in,recursive=TRUE),sep=sep)
file_list.in <- file_list.in[grep(".tif",file_list.in)]

if(verbose %in% c(TRUE,"Limited")){message(paste("\n     Writing Lat/Long/Dates"))}

#---------------------------------------------------------------------------------
# Extract Lon/Lat for CHIRPS
#---------------------------------------------------------------------------------
testval <- round(mean(length(file_list.in)))
suppressWarnings(rm(Dataset_Example))
Dataset_Example <- suppressWarnings(raster(file_list.in[testval], crs=4326))
lat     <- coordinates(Dataset_Example)[,2]
long    <- coordinates(Dataset_Example)[,1]
if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep="")))){
   fwrite(list(long),paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
}
if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep="")))){
   fwrite(list(lat),paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep=""),row.names=FALSE,quote=FALSE) 
}  
#---------------------------------------------------------------------------------
# Extract dates from the files
#---------------------------------------------------------------------------------

date.list <- substr(unlist(lapply(strsplit(file_list.in,"Tmax."),"[",2)),1,10)
date.list <- as.Date(date.list,format="%Y.%m.%d")
file_list.in <- file_list.in[order(date.list)]
date.list <- date.list[order(date.list)]

#Make a full date table from that list and write to file
dates        <- suppressWarnings(makedates(date.list))
dates        <- dates[which(is.na(dates$Date)==FALSE),]
dates$file_list.in <- file_list.in

write.csv(dates,paste(dir_data_in,"/",StemIn,"_Datelist.csv",sep=""),row.names=FALSE,quote=FALSE)   
#---------------------------------------------------------------------------------
# CREATE CHIRTS FUNCTION
#---------------------------------------------------------------------------------
CreateCHIRTSTMax <- function(f,dir_data_in,StemIn,dir_data_out,StemOut,date.list,file_list.in,globalcrs,dataoverwrite){
   
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
   file_name.in <- file_list.in[f]
   
   if((file.exists(file_name.in))&(continue == TRUE)){continue <- TRUE}else{continue <- FALSE}
   
   # If you do...
   if(continue == TRUE){
      
      # Read in and change the projection
      # a <- Sys.time()
      r <- suppressWarnings(rast(file_name.in))
      crs(r) <- paste("EPSG:",globalcrs,sep="")
      r[r < -90] <- NA
      r[r > 999] <- NA
      #print(Sys.time() -a)
      
      if(length(unique(values(r)))<=1){
         return(paste("EMPTY",file_name.out))
      }else{
         
         if(file.exists(file_loc.out)){file.remove(file_loc.out)}
         suppressMessages(suppressWarnings(terra::writeRaster(r, filename=file_loc.out, filetype="GTiff",overwrite=TRUE)))
         # Write regridded to file - to be added
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

myres <- foreach(f = 1:length(date.list)) %dopar%  CreateCHIRTSTMax(f,dir_data_in,StemIn,dir_data_out,StemOut,
                                                                    date.list,file_list.in,
                                                                    globalcrs,dataoverwrite)


if(verbose %in% c(TRUE,"Limited")){print(Sys.time() -a)}






