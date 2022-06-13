#=================================================================================
# HLG 2021,
# This converts raw RFE2 data to my standardised format
#=================================================================================
# Dataset parameters
#---------------------------------------------------------------------------------
# family    <-"sm"  ;  dataset   <- "TAMSAT"
# version   <- 1      ;  modified  <- "Raw"
# overwrite <- FALSE

##################################################################

 setwd(dir_core)

 #Daily/Dekadal/Pentadal/Monthly raw data
 OutFolder_Route <- dir_data_remote_BGeoTif_daily


#---------------------------------------------------------------------------------
# Sort out input folder the meta data
# StemIn  is rain_RFE2_1_Raw
# StemOut is rain_RFE2_1_Geo
# dir_data_in is "~/Desktop/SOMALIA_CODE/Core/Data/2_Remote_Sensing/0_Raw_data/rain_RFE2_1_Raw"
#---------------------------------------------------------------------------------
  if((nchar(modified) > 0)&(is.na(modified)==FALSE)){
    StemIn  <- paste(family,dataset,version,modified,"Raw",sep="_")
    StemOut <- paste(family,dataset,version,modified,sep="_")
  }else{
    StemIn  <- paste(family,dataset,version,"Raw",sep="_")
    StemOut <- paste(family,dataset,version,sep="_")
  }
  dir_data_in  <- paste(dir_data_remote_ARaw,StemIn,sep=sep)
  
  # Set up one folder name for each sub-variable
  dir_data_out <- paste(OutFolder_Route,StemOut,sep=sep)
  
#---------------------------------------------------------------------------------
# Now set up the output folders
# Also add in the regridded folders FUTURE WORK
#---------------------------------------------------------------------------------
  
  # From Jules Documentation 
  LayerThickness_1 <- 0.1
  LayerThickness_2 <- 0.25
  LayerThickness_3 <- 0.65
  LayerThickness_4 <- 2
  
   #---------------------------------------------------------------------------------
   # Now set up the subfolders
   # NOTE - put all the subfolder stuff together in a table
   #---------------------------------------------------------------------------------
   makesubfolder <- function(subfolder,OutFolder_Route,StemOut,file_list.out,overwriteGeo){
      dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
      if(!(file.exists(dir_data_out))){
         dir.create(dir_data_out)
      }
      file_list.out <- list.files(dir_data_out)
      if(length(file_list.out)<=0){dataoverwrite <- TRUE}else{dataoverwrite <- overwriteGeo}
      return(dataoverwrite)
   }
   
   dataoverwrite <- makesubfolder("smcl_1",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("smcl_2",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("smcl_3",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("smcl_4",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("MeanColumnSoilMoisture",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("esoil_gb",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("ecan_gb",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("smc_avail_top",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("runoff",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   dataoverwrite <- makesubfolder("JULESprecip",OutFolder_Route,StemOut,file_list.out,overwriteGeo)
   

#=================================================================================
# THIS PART CHANGES FROM DATASET TO DATASET
#=================================================================================
 #---------------------------------------------------------------------------------
 # List input zip files
 #---------------------------------------------------------------------------------
   file_list.in <- sort(list.files(dir_data_in,recursive=TRUE)[grep(".nc",list.files(dir_data_in,recursive=TRUE))])
   
 #---------------------------------------------------------------------------------
 # Extract Lon/Lat for TAMSAT SM
 #---------------------------------------------------------------------------------
   ncin <- nc_open(paste(dir_data_in,file_list.in[5],sep=sep))
   lat     <- ncvar_get(ncin,"latitude")[1,]
   long    <- ncvar_get(ncin,"longitude")[,1]
   if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep="")))){
      fwrite(list(long),paste(dir_data_in,sep, StemIn,"_Longitude.csv",sep=""),row.names=FALSE,quote=FALSE)   
   }
   if(!(file.exists(paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep="")))){
      fwrite(list(lat),paste(dir_data_in,sep, StemIn,"_Latitude.csv",sep=""),row.names=FALSE,quote=FALSE) 
   }  
   nc_close(ncin)   
   
 #---------------------------------------------------------------------------------
 # Extract dates from the files
 #---------------------------------------------------------------------------------
  date.list <- as.Date(substr(unlist(lapply(strsplit(file_list.in,"_"),"[",6)),1,8),format="%Y%m%d")
  file_list.in <- file_list.in[order(date.list)]
  date.list <- date.list[order(date.list)]
  
  #Make a full date table from that list and write to file
  dates        <- suppressWarnings(makedates(date.list))
  dates        <- dates[which(is.na(dates$Date)==FALSE),]
  dates$file_list.in <- file_list.in
  
  write.csv(dates,paste(dir_data_in,"/",StemIn,"_Datelist.csv",sep=""),row.names=FALSE,quote=FALSE)   
  
  
 #---------------------------------------------------------------------------------
 # CREATE TAMSAT FUNCTION
 #---------------------------------------------------------------------------------
 CreateTAMSAT_SM <- function(f,dir_data_in,OutFolder_Route,StemOut,date.list,file_list.in,
                             LayerThickness_1,LayerThickness_2,LayerThickness_3,LayerThickness_4,
                             globalcrs,dataoverwrite){
    subfolder <- "smcl_1"
    dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
    file_name.out <- paste(dir_data_out,paste(StemOut,"_smcl.1_","Geo_",date.list[f],".tif",sep=""),sep="/")
    
    # Decide if you want to look at this file
    continue <- FALSE
    if(dataoverwrite == FALSE){
       if(file.exists(file_name.out)){continue <- FALSE}else{continue <- TRUE}
    }else{
       continue <- TRUE
    }
    
        # If you do...
    if(continue == TRUE){
       
       ncin <- nc_open(paste(dir_data_in,file_list.in[f],sep="/"))
       smcl <- ncvar_get(ncin,"smcl")
       
       # Soil Moisture Content Layer 1 (top)  (0.1m thick)
       subfolder <- "smcl_1"
       smcl.1 <- rast(flipud(t(smcl[,,1])),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(smcl.1) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(smcl.1, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Soil Moisture Content Layer 2 0.25m thick
       subfolder <- "smcl_2"
       smcl.2 <- rast(flipud(t(smcl[,,2])),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(smcl.2) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(smcl.2, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Soil Moisture Content Layer 3 0.65m thick
       subfolder <- "smcl_3"
       smcl.3 <- rast(flipud(t(smcl[,,3])),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(smcl.3) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(smcl.3, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Soil Moisture Content Layer 4 (lowest) - 2.0m thick
       subfolder <- "smcl_4"
       smcl.4 <- rast(flipud(t(smcl[,,4])),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(smcl.4) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(smcl.4, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Average soil moisture in m3/m3 - https://www.evernote.com/l/AcXYGR1z1axG270YaiICcCc99Jp45ldtuFY 
       subfolder <- "MeanColumnSoilMoisture"
       sm_1 <- smcl.1*(LayerThickness_1*1000)
       sm_2 <- smcl.2*(LayerThickness_2*1000)
       sm_3 <- smcl.3*(LayerThickness_3*1000)
       sm_4 <- smcl.4*(LayerThickness_4*1000)
       smcl.mean <- mean(rast(list(sm_1,sm_2,sm_3,sm_4)))
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(smcl.mean, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Gridbox surface evapotranspiration from soil moisture store (kg m-2 s-1).
       subfolder <- "esoil_gb"
       esoil_gb.raw <- ncvar_get(ncin,"esoil_gb")
       esoil_gb <- rast(flipud(t(esoil_gb.raw)),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(esoil_gb) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(esoil_gb, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Gridbox surface run-off from soil moisture store (kg m-2 s-1).
       subfolder <- "runoff"
       runoff.raw <- ncvar_get(ncin,"runoff")
       runoff <- rast(flipud(t(runoff.raw)),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(runoff) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(runoff, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Gridbox mean evaporation from canopy/surface store (kg m-2 s-1).
       subfolder <- "ecan_gb"
       ecan_gb.raw <- ncvar_get(ncin,"ecan_gb")
       ecan_gb <- rast(flipud(t(ecan_gb.raw)),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(ecan_gb) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(ecan_gb, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       # Gridbox available moisture in surface layer of depth given by zsmc (kg m-2).
       subfolder <- "smc_avail_top"
       smc_avail_top.raw <- ncvar_get(ncin,"smc_avail_top")
       smc_avail_top <- rast(flipud(t(smc_avail_top.raw)),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(smc_avail_top) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(smc_avail_top, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))

              # Gridbox precipitation rate (kg m-2 s-1).
       subfolder <- "JULESprecip"
       JULESprecip.raw <- ncvar_get(ncin,"precip")
       JULESprecip <- rast(flipud(t(JULESprecip.raw)),extent=ext(c(min(long), max(long), min(lat), max(lat))))
       crs(JULESprecip) <- paste("EPSG:",globalcrs,sep="")
       dir_data_out <- paste(OutFolder_Route,paste(StemOut,subfolder,"Geo",sep="_"),sep=sep)
       file_name.out <- paste(dir_data_out,paste(StemOut,"_",subfolder,"_","Geo_",date.list[f],".tif",sep=""),sep="/")
       suppressMessages(suppressWarnings(terra::writeRaster(JULESprecip, filename=file_name.out, filetype="GTiff",overwrite=TRUE)))
       a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_name.out,".aux.json",sep="")))))
       
       
       nc_close(ncin)
       
       return(file_list.in[f])
     
    }else{
      return(paste("IGNORED",file_list.in[f]))
    }

 }
 
 #---------------------------------------------------------------------------------
 # Parallel computing saves about 3/4 time, but this will still take 18minutes
 #---------------------------------------------------------------------------------
  # ForEach, length(date.list)
  a <- Sys.time()
  if(verbose %in% c(TRUE,"Limited")){message(paste("\n     Writing Data"))}
  
  myres <- foreach(f = 1:10) %dopar%  CreateTAMSAT_SM(f,dir_data_in,OutFolder_Route,StemOut,date.list,file_list.in,
                                                      LayerThickness_1,LayerThickness_2,LayerThickness_3,LayerThickness_4,
                                                      globalcrs,dataoverwrite)
  
 print(Sys.time() -a)
  
  
  

   
   
 
