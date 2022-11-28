
#==========================================================================================================================
# dekad climatology: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
dekadclimatologies<- function(nnn,dekad.list,dekads,dir_data_remote_BGeoTif_dekad, subdir.year.clim,subdir.year.anom,dataset,files_in.dekad,overwrite,subfiles ){

   require(Greatrex.Functions)
   #------------------------------------------------------------------------------
   # get the dekad wanted and make the output file name
   #------------------------------------------------------------------------------
   dekadsindex <- dekads[nnn]
   
   inputkey <- as.numeric(substr(files_in.dekad,nchar(files_in.dekad)-5,nchar(files_in.dekad)-4))

   outputfile.climate <- paste(subdir.year.clim,paste(dataset,"_climate_",
                                               minyear,"_",maxyear,"_",
                                               sprintf("%03d",dekadsindex),".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, make the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile.climate))){
      
      subset.filesin <- files_in.dekad[which(inputkey %in%  dekad.list[dekad.list %in% dekadsindex])]
      subset.fulllocin  <- paste(dir_data_remote_BGeoTif_dekad,dataset,subset.filesin,sep=sep)
      
      if(length(subset.fulllocin) > 2){
         
         # using RASTER THIS TOOK 20 seconds
         #a <- Sys.time()
         #datain <- stack(subset.fulllocin,quick=TRUE)
         #r.clim <- rasterstack_mean_fast(datain)
         #r.anom <- datain-r.clim
         #print(Sys.time() -a)
         #writeRaster(r.clim, filename=outputfile.climate, format="GTiff", overwrite=TRUE)
         
         
         # using TERRA THIS TOOK 0.2 seconds
         #a <- Sys.time()
         datain <- rast(subset.fulllocin)
         r.clim <- app(datain,mean)
         r.anom <- datain-r.clim
         #print(Sys.time() -a)   
         suppressMessages(suppressWarnings(terra::writeRaster(round(r.clim,2), filename=outputfile.climate, filetype="GTiff",overwrite=TRUE)))
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(outputfile.climate,".aux.json",sep="")))))


         # write the anomalies to file, first create yearly subfolders
         lapply(paste(subdir.year.anom,subfiles,sep=sep),conditionalcreate)

         
         # get the years for the outputs
         filesin <- strsplit(sources(datain),sep)
         #filenamesin  <- unlist(lapply(filesin,"[",length(filesin[[1]])))
         #yearsubfoldersin <- unlist(lapply(filesin,"[",(length(filesin[[1]])-1)))
         
         outputfile.anom <- paste(subdir.year.anom,
                                  paste(
                                     substr(subset.filesin,1,nchar(subset.filesin)-10),
                                        minyear,"-",maxyear,"_","Anom_",
                                        substr(subset.filesin,nchar(subset.filesin)-9,nchar(subset.filesin)-4),
                                        ".tif",sep=""),sep=sep)
         
         for(ff in 1:length(subset.fulllocin)){
            suppressMessages(suppressWarnings(terra::writeRaster(round(r.anom[[ff]],2), filename=outputfile.anom[ff], filetype="GTiff",overwrite=TRUE)))
            a<-try(suppressMessages(suppressWarnings(file.remove(paste(outputfile.climate,".aux.json",sep="")))))
            
         }   
      }   
   }   
   return(outputfile.climate)
}


makeanomalydekadclimate <-  function(dataset,minyear,maxyear,missinglimit,dir_data_remote_BGeoTif_dekad,dir_data_remote_CDerived_dekad_anom,dir_data_remote_CDerived_dekad_clim,overwrite){  

   if(verbose %in% c(TRUE,"Limited")){message(paste("     Creating climatologies and anomalies"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn dekad data into climatologies and anomalies data
   #
   # Create CLIM directories if they don't already exist
   #---------------------------------------------------------------------------------

   subdir.product.clim <- paste(dir_data_remote_CDerived_dekad_clim,dataset,sep=sep)
   if(!dir.exists(subdir.product.clim)){dir.create(subdir.product.clim)}
   
   subdir.year.clim <- paste(subdir.product.clim,paste(minyear,maxyear,sep="_"),sep=sep)
   if(!dir.exists(subdir.year.clim)){dir.create(subdir.year.clim)}
   
   
   # Create ANOM directories if they don't already exist
   subdir.product.anom<- paste(dir_data_remote_CDerived_dekad_anom,dataset,sep=sep)
   if(!dir.exists(subdir.product.anom)){dir.create(subdir.product.anom)}
   
   subdir.year.anom <- paste(subdir.product.anom,paste(minyear,maxyear,sep="_"),sep=sep)
   if(!dir.exists(subdir.year.anom)){dir.create(subdir.year.anom)}
   

   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.anom <- list.files(subdir.year.anom,recursive=TRUE,pattern=".tif")
   files_out.clim <- list.files(subdir.year.clim,recursive=TRUE,pattern=".tif")
   files_in.dekad    <- list.files(paste(dir_data_remote_BGeoTif_dekad,dataset,sep=sep),recursive=TRUE,pattern=".tif")

   #------------------------------------------------------------------------------
   # Make any yearly subfolders and get out filenames. 
   #------------------------------------------------------------------------------
   subfiles <-unique(unlist(lapply(strsplit(files_in.dekad,sep),"[",1)))

   #------------------------------------------------------------------------------
   # Now make a date-list by extracting the date from the file.name
   #------------------------------------------------------------------------------
   date.list       <- substr(files_in.dekad,nchar(files_in.dekad)-9,nchar(files_in.dekad)-4)
   year.list       <- as.numeric(substr(date.list,1,4))
   dekad.list     <- as.numeric(substr(date.list,5,6))
   dekads <- sort(unique(dekad.list))
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   a <- Sys.time()
   res <- foreach(nnn = 1:length(dekads)) %dopar% dekadclimatologies(nnn,dekad.list,dekads,
                                                                     dir_data_remote_BGeoTif_dekad,
                                                                     subdir.year.clim,subdir.year.anom,
                                                                     dataset,files_in.dekad,overwrite,subfiles )
   print(Sys.time() -a)   
   #print(res)
}





###########################################################################################

#==========================================================================================================================
# monthly climatology: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
monthclimatologies<- function(nnn,month.list,months,dir_data_remote_BGeoTif_month, subdir.year.clim,subdir.year.anom,dataset,files_in.month,overwrite,subfiles){
   
   require(Greatrex.Functions)
   #------------------------------------------------------------------------------
   # get the month wanted and make the output file name
   #------------------------------------------------------------------------------
   monthsindex <- months[nnn]
   
   inputkey <- as.numeric(substr(files_in.month,nchar(files_in.month)-5,nchar(files_in.month)-4))
   
   outputfile.climate <- paste(subdir.year.clim,paste(dataset,"_climate_",
                                                      minyear,"_",maxyear,"_",
                                                      sprintf("%03d",monthsindex),".tif",sep=""),sep=sep)
   
   
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, make the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile.climate))){
      
      subset.filesin <- files_in.month[which(inputkey %in%  month.list[month.list %in% monthsindex])]
      subset.fulllocin  <- paste(dir_data_remote_BGeoTif_month,dataset,subset.filesin,sep=sep)
      
      if(length(subset.fulllocin) > 2){
       
         # using TERRA THIS TOOK 0.2 seconds
         #a <- Sys.time()
         datain <- rast(subset.fulllocin)
         r.clim <- app(datain,mean)
         r.anom <- datain-r.clim
         #print(Sys.time() -a)   
         suppressMessages(suppressWarnings(terra::writeRaster(round(r.clim,2), filename=outputfile.climate, filetype="GTiff",overwrite=TRUE)))
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(outputfile.climate,".aux.json",sep="")))))
         
         
         # write the anomalies to file, first create yearly subfolders
         lapply(paste(subdir.year.anom,subfiles,sep=sep),conditionalcreate)
         
         
         # get the years for the outputs
         filesin <- strsplit(sources(datain),sep)
         #filenamesin  <- unlist(lapply(filesin,"[",length(filesin[[1]])))
         #yearsubfoldersin <- unlist(lapply(filesin,"[",(length(filesin[[1]])-1)))
         
           
         outputfile.anom <- paste(subdir.year.anom,
                                  paste(
                                      substr(subset.filesin,1,nchar(subset.filesin)-10),
                                      minyear,"-",maxyear,"_","Anom_",
                                      substr(subset.filesin,nchar(subset.filesin)-9,nchar(subset.filesin)-4),
                                        ".tif",sep=""),sep=sep)
         
         
         
         for(ff in 1:length(subset.fulllocin)){
            suppressMessages(suppressWarnings(terra::writeRaster(round(r.anom[[ff]],2), filename=outputfile.anom[ff], filetype="GTiff",overwrite=TRUE)))
            a<-try(suppressMessages(suppressWarnings(file.remove(paste(outputfile.climate,".aux.json",sep="")))))
            
         }   
         
         
      
    
      }   
   }   
   return(outputfile.climate)
}




makeanomalymonthclimate <-  function(dataset,minyear,maxyear,missinglimit,dir_data_remote_BGeoTif_month,dir_data_remote_CDerived_month_anom,dir_data_remote_CDerived_month_clim,overwrite){  
   
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Creating climatologies and anomalies"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn month data into climatologies and anomalies data
   #
   # Create CLIM directories if they don't already exist
   #---------------------------------------------------------------------------------
   
   subdir.product.clim <- paste(dir_data_remote_CDerived_month_clim,dataset,sep=sep)
   if(!dir.exists(subdir.product.clim)){dir.create(subdir.product.clim)}
   
   subdir.year.clim <- paste(subdir.product.clim,paste(minyear,maxyear,sep="_"),sep=sep)
   if(!dir.exists(subdir.year.clim)){dir.create(subdir.year.clim)}
   
   
   # Create ANOM directories if they don't already exist
   subdir.product.anom<- paste(dir_data_remote_CDerived_month_anom,dataset,sep=sep)
   if(!dir.exists(subdir.product.anom)){dir.create(subdir.product.anom)}
   
   subdir.year.anom <- paste(subdir.product.anom,paste(minyear,maxyear,sep="_"),sep=sep)
   if(!dir.exists(subdir.year.anom)){dir.create(subdir.year.anom)}
   
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.anom <- list.files(subdir.year.anom,recursive=TRUE,pattern=".tif")
   files_out.clim <- list.files(subdir.year.clim,recursive=TRUE,pattern=".tif")
   files_in.month <- list.files(paste(dir_data_remote_BGeoTif_month,dataset,sep=sep),recursive=TRUE,pattern=".tif")
   subfiles <-unique(unlist(lapply(strsplit(files_in.month,sep),"[",1)))
   
   #------------------------------------------------------------------------------
   # Now make a date-list by extracting the date from the file.name
   #------------------------------------------------------------------------------
   date.list       <- substr(files_in.month,nchar(files_in.month)-9,nchar(files_in.month)-4)
   year.list       <- as.numeric(substr(date.list,1,4))
   month.list     <- as.numeric(substr(date.list,5,6))
   months <- sort(unique(month.list))
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   a <- Sys.time()
   res <- foreach(nnn = 1:length(months)) %dopar% monthclimatologies(nnn,month.list,months,
                                                                        dir_data_remote_BGeoTif_month,
                                                                        subdir.year.clim,subdir.year.anom,
                                                                        dataset,files_in.month,overwrite,subfiles)
   print(Sys.time() -a)   
   #print(res)
}




