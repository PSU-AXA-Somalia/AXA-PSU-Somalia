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
file_list.in <- list.files(dir_data_in,pattern=".tif.zip",recursive=TRUE)

#---------------------------------------------------------------------------------
# Extract Lon/Lat for RFE
#---------------------------------------------------------------------------------
unzip(paste(dir_data_in,file_list.in[5],sep=sep),exdir =dir_data_in)
newfiles <- substr(file_list.in[5],1,nchar(file_list.in[5])-4)
Dataset_Example <- suppressWarnings(raster(paste(dir_data_in,newfiles,sep=sep)))
lat     <- coordinates(Dataset_Example)[,1]
long    <- coordinates(Dataset_Example)[,2]
if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep="")))){
   fwrite(list(long),paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
}
if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep="")))){
   fwrite(list(lat),paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep=""),row.names=FALSE,quote=FALSE) 
}        
a <- file.remove(paste(dir_data_in,newfiles,sep=sep))

#---------------------------------------------------------------------------------
# Extract dates from the files
#---------------------------------------------------------------------------------
date.list <- unlist(lapply(strsplit(file_list.in,"africa_rfe."),"[",2))
date.list <- as.Date(substr(date.list,1,8),format="%Y%m%d")
file_list.in <- file_list.in[order(date.list)]
date.list <- date.list[order(date.list)]

#Make a full date table from that list and write to file
dates        <- suppressWarnings(makedates(date.list))
dates        <- dates[which(is.na(dates$Date)==FALSE),]
dates$file_list.in <- file_list.in
write.csv(dates,paste(dir_data_in,"/",StemIn,"_Datelist.csv",sep=""),row.names=FALSE,quote=FALSE)  

#---------------------------------------------------------------------------------
# CREATE RFE FUNCTION
#---------------------------------------------------------------------------------
CreateRFE2 <- function(f,dir_data_in,StemIn,dir_data_out,StemOut,date.list,file_list.in,globalcrs,dataoverwrite){
   require(terra)
   # Create filename
   
   year_dir.out <- paste(dir_data_out,substr(date.list[f],1,4),sep=sep)
   
   if(!dir.exists(year_dir.out)){dir.create(year_dir.out)}
   
   file_loc.out <- paste(year_dir.out,paste(StemOut,"_",date.list[f],".tif",sep=""),sep=sep) 
   
   file_name.out <- paste(StemOut,"_",date.list[f],".tif",sep="")
   
   # Decide if you want to look at this file
   continue <- FALSE
   if(dataoverwrite == FALSE){
      if(file.exists(file_loc.out)){continue <- FALSE}else{continue <- TRUE}
   }else{
      continue <- TRUE
   }
   
   if(continue == TRUE){
      # Unzip the data, and rename
      file_name.in <- paste(dir_data_in,file_list.in[f],sep=sep)
      
      if((file.exists(file_name.in))&(continue == TRUE)){continue <- TRUE}else{continue <- FALSE}
   }
   
   # If you do...
   if(continue == TRUE){
      
      # Unzip the data, and rename
      tmp <- unzip(file_name.in,exdir=dir_data_out)
      if(is.null(tmp) == FALSE){
         newlyunzipped <- paste(dir_data_out,substr(file_list.in[f],1,(nchar(file_list.in[f])-4)),sep=sep)
         
         # Read in and change the projection
         r <- suppressWarnings(terra::rast(newlyunzipped))
         crs(r) <- paste("EPSG:",globalcrs,sep="")
         r[r < 0] <- NA
         
         if(length(unique(values(r)))<=1){
            return(paste("EMPTY",file_name.out))
         }else{
            
            # Write to file
            #if(file.exists(file_loc.out)){file.remove(file_loc.out)}
            suppressMessages(suppressWarnings(terra::writeRaster(round(r,1), filename=file_loc.out, filetype="GTiff",overwrite=TRUE)))
            
            # Write regridded to file - to be added
            suppressWarnings(suppressMessages(file.remove(newlyunzipped)))
            return(file_name.out)
         }
         
      }else{
         return(paste("CORRUPTED",file_name.out))
         
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

myres <- foreach(f = 1:length(file_list.in)) %dopar%  CreateRFE2(f,dir_data_in,StemIn,dir_data_out,
                                                              StemOut,date.list,file_list.in,globalcrs,
                                                              dataoverwrite)


print(Sys.time() -a)

