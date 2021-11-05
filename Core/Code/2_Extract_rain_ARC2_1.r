#=================================================================================
# HLG 2021,
# This converts raw ARC2 data to my standardised format
#=================================================================================
#---------------------------------------------------------------------------------
# Dataset parameters
#---------------------------------------------------------------------------------
# family    <-"rain"  ;  dataset   <- "ARC2"
# version   <- 1      ;  modified  <- "Raw"
# overwriteGeo <- FALSE

##################################################################

 setwd(dir_core)

 #Daily/Dekadal/Pentadal/Monthly raw data
 OutFolder_Route <- dir_data_remote_BGeoTif_daily

 #Does this dataset contain multiple sub-variables?
 nvariables <- 1

#---------------------------------------------------------------------------------
# Sort out input folder the meta data
# StemIn  is rain_ARC2_1_Raw
# StemOut is rain_ARC2_1_Geo
# dir_data_in is "~/Desktop/SOMALIA_CODE/Core/Data/2_Remote_Sensing/0_Raw_data/rain_ARC2_1_Raw"
#---------------------------------------------------------------------------------
  if(nchar(modified) > 0){
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
    if(nchar(modified) > 0){ 
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
 # Extract Lon/Lat for ARC2
 #---------------------------------------------------------------------------------
  Dataset_Example <- suppressWarnings(raster(unzip(paste(dir_data_in,file_list.in[5],sep=sep)),crs=4236))
  lat     <- coordinates(Dataset_Example)[,1]
  long    <- coordinates(Dataset_Example)[,2]
  write.csv(long,paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
  write.csv(lat,paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
  file.remove(substr(file_list.in[5],start=1,stop=nchar(file_list.in[5])-4))
  
  
 #---------------------------------------------------------------------------------
 # Extract dates from the files
 #---------------------------------------------------------------------------------
  date.list <- unlist(lapply(strsplit(file_list.in,"africa_arc."),"[",2))
  date.list <- as.Date(substr(date.list,1,8),format="%Y%m%d")
  file_list.in <- file_list.in[order(date.list)]
  date.list <- date.list[order(date.list)]
 
  #Make a full date table from that list and write to file
  dates        <- suppressWarnings(makedates(date.list))
  dates        <- dates[which(is.na(dates$Date)==FALSE),]
  dates$file_list.in <- file_list.in
  
  write.csv(dates,paste(dir_data_in,"/",StemIn,"_Datelist.csv",sep=""),row.names=FALSE,quote=FALSE)   
 
 #---------------------------------------------------------------------------------
 # CREATE ARC2 FUNCTION
 #---------------------------------------------------------------------------------
 CreateARC2 <- function(f,dir_data_in,StemIn,dir_data_out,StemOut,date.list,file_list.in,globalcrs,dataoverwrite){
    
    # Create filename
    file_name.out <- paste(StemOut,"_",date.list[f],".tif",sep="")
    file_loc.out <- paste(dir_data_out,paste(StemOut,"_",date.list[f],".tif",sep=""),sep=sep) 
    
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

      # Unzip the data, and rename
      tmp <- unzip(file_name.in,exdir=dir_data_out)
      if(is.null(tmp) == FALSE){
        
        newlyunzipped <- paste(dir_data_out,substr(file_list.in[f],1,(nchar(file_list.in[f])-4)),sep=sep)

        if(file.exists(file_loc.out)){file.remove(file_loc.out)}

        # Read in and change the projection
        r <- suppressWarnings(raster::raster(newlyunzipped))
        crs(r) <- CRS(SRS_string = paste("EPSG:",globalcrs,sep=""))
        # Re-grid and make those outputs too
        # TO BE ADDED
        
        # Write to file
        #if(file.exists(file_loc.out)){file.remove(file_loc.out)}
        raster::writeRaster(r, filename=file_loc.out, format="GTiff",overwrite=TRUE)
        # Write regridded to file - to be added
        suppressWarnings(suppressMessages(file.remove(newlyunzipped)))
        return(file_name.out)
        
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

  myres <- foreach(f = 1:length(date.list)) %dopar%  CreateARC2(f,dir_data_in,StemIn,dir_data_out,StemOut,
                                                                             date.list,file_list.in,
                                                                             globalcrs,dataoverwrite)
 print(Sys.time() -a)

 
   

   
 
