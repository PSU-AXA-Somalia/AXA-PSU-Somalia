


#=================================================================================
# This creates the temporal sum of all the data
#=================================================================================
#---------------------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------------------
############################################################################
# PENTADAL FUNCTION
############################################################################
makepentadal <-  function(dataset,datastem,regrid_template,dir_core,missinglimitpendad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_pentad,overwrite,family){  
   
   #---------------------------------------------------------------------------------
   # Function to regrid daily data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   regridname <- substr(regrid_template,1,nchar(regrid_template)-4)
   dataset_regrid  <- paste(datastem,regridname,sep="_")
   dir_reformat <- paste(dir_data_remote_BGeoTif_daily,dataset_regrid,sep=sep)
   

   if(!dir.exists(dir_reformat)){dir.create(dir_reformat)}
   
   subdirs <- paste(dir_reformat,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                            dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   for(n in 1:length(subdirs)){
      if(!dir.exists(subdirs[n])){dir.create(subdirs[n])}
   }
   
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Sorting out meta data"))}
   aa <- Sys.time()
   

   
   ### pentad data
   datasetpentaddir        <- paste(dir_data_remote_BGeoTif_pentad,paste("pentad",dataset,sep="_"),sep=sep)
   datasetpentaddireformat <- paste(dir_data_remote_BGeoTif_pentad,paste("pentad",dataset_regrid,sep="_"),sep=sep)
   
   if(!dir.exists(datasetpentaddir)){dir.create(datasetpentaddir)}
   if(!dir.exists(datasetpentaddireformat)){dir.create(datasetpentaddireformat)}
   
   
   subdirs <- paste(datasetpentaddir,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                    dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   subdirsref <- paste(datasetpentaddireformat,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                              dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   for(n in 1:length(subdirs)){
      if(!dir.exists(subdirs[n])){dir.create(subdirs[n])}
      if(!dir.exists(subdirsref[n])){dir.create(subdirsref[n])}
   }
   
   
   #---------------------------------------------------------------------------------
   # Get input files and the regridding template
   #---------------------------------------------------------------------------------
   files_in.daily   <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep),recursive=TRUE)
   files_in.daily   <- files_in.daily[grep(".tif",files_in.daily)]
   regridtemplate <- rast(paste(dir_core,regrid_template,sep=sep))
   
   #---------------------------------------------------------------------------------
   # Get the date list from the files
   #---------------------------------------------------------------------------------
   date.list    <- as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")
   dates        <- suppressWarnings(makedates(date.list))
   dates        <- dates[which(is.na(dates$Date)==FALSE),]
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.regrid   <- list.files(dir_reformat,recursive=TRUE)
   files_out.pentadal <- list.files(datasetpentaddir,recursive=TRUE)
   files_out.pentadalregrid <- list.files(datasetpentaddireformat,recursive=TRUE)
   
   #------------------------------------------------------------------------------
   # Now make a datelist by extracting the date from the filename
   #------------------------------------------------------------------------------
   fulldatelist <- pentadalmissing(dates,datasetpentaddir,missinglimitpentad)
   
   #------------------------------------------------------------------------------
   # Test if regridding is needed
   #------------------------------------------------------------------------------
   print(Sys.time() -aa)  
   aa <- Sys.time()
   regrid_flag <- TRUE
   regrid_test <- rast(paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily[2],sep=sep))
   
   #if(setequal(round(res(regrid_test),5),round(res(regridtemplate),5))){
   gridx <- c(seq(from=ext(regridtemplate)[1,],length.out = 100000,by=-res(regridtemplate)[1]),
              seq(from=ext(regridtemplate)[2,],length.out = 100000,by=res(regridtemplate)[1]))
   gridy <- c(seq(from=ext(regridtemplate)[3,],length.out = 100000,by=-res(regridtemplate)[2]),
              seq(from=ext(regridtemplate)[4,],length.out = 100000,by=res(regridtemplate)[2]))                 
   
   #------------------------------------------------------------------------------
   # If they share the exact same extent, I assume we will be OK
   #------------------------------------------------------------------------------
   if((round(ext(regrid_test)[1],5) %in% round(gridx,5))&(round(ext(regrid_test)[2],5) %in% round(gridx,5))&
      (round(ext(regrid_test)[3],5) %in%  round(gridy,5))&(round(ext(regrid_test)[4],5) %in% round(gridy,5))){
      regrid_flag <- FALSE
      
      filenamesout <- str_replace(files_in.daily,"Geo",regridname)
      
      filesin <- paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily,sep=sep)
      filesout <- paste(dir_reformat,filenamesout,sep=sep)
      foldersout <- unique(unlist(lapply(str_split(filenamesout,sep),"[",1)))
      aa <- Sys.time()
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Coping data to regrid file - same resolution"))}
      a<-file.copy(paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily,sep=sep), 
                   paste(dir_reformat,filenamesout,sep=sep),overwrite=FALSE)

      
   }
   print(Sys.time() -aa)  
   
   #}
   #------------------------------------------------------------------------------
   # Otherwise regrid
   #------------------------------------------------------------------------------
   if(regrid_flag){
      #------------------------------------------------------------------------------
      # see if there are files left to do
      #------------------------------------------------------------------------------
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Regridding data"))}
      aa <- Sys.time()
      
      if(length(files_out.regrid)>0){
         
         filenamesin <- files_in.daily[-(which(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4) %in% 
                                                  substr(files_out.regrid,nchar(files_out.regrid)-13,nchar(files_out.regrid)-4)))]
      }else{
         filenamesin <- files_in.daily
      }   
      filenamesout <- str_replace(files_in.daily,"Geo",regridname)
      
      #------------------------------------------------------------------------------
      # If so, set up a new template
      #------------------------------------------------------------------------------
      if(length(filenamesin)>0){
         regridtemplate <- raster(paste(dir_core,regrid_template,sep=sep))
         regrid_test <- raster(paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily[2],sep=sep))
         
         regridtemplate <- extend(regridtemplate,regrid_test)
         
         
         
         res <- foreach(nnn = 1:length(filenamesin)) %dopar%  gdalwarp(srcfile=paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily[nnn],sep=sep),
                                                                       dstfile=paste(dir_reformat,filenamesout[nnn],sep=sep),
                                                                       tr=res(regridtemplate),
                                                                       te=c(bbox(extent(regridtemplate))),
                                                                       r='bilinear',overwrite=FALSE,verbose=FALSE)
         
         if(family %in% c("rain","tmin","tmax","rhum")){
            myresults <- foreach(nnn = 1:length(filenamesin)) %dopar% terra::writeRaster(round(rast(paste(dir_reformat,filenamesout[nnn],sep=sep)),1), 
                                                                              filename=paste(dir_reformat,filenamesout[nnn],sep=sep), 
                                                                              filetype="GTiff", overwrite=TRUE)
         }
      }
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Finished regridding"))}
      print(Sys.time() -aa)  
      
   }
   rm(regrid_test)

   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to pendatal (this can take a while)"))}
   
   aa <- Sys.time()
   myresults <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% pentadsumfunct(nnn,fulldatelist ,
                                                                           dir_data_remote_BGeoTif_daily,
                                                                           datasetpentaddir,
                                                                           dataset,files_in.daily,
                                                                           dates,overwrite,family)
   print(Sys.time() -aa)  
   
   # Only do this twice if the regrid actually did something
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily regridded to pendatal (this can take a while)"))}
   
   if(regrid_flag){
      aa <- Sys.time()
      files_in.dailyregrid   <- list.files(dir_reformat,recursive=TRUE)
      
      myresults <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% pentadsumfunct(nnn,fulldatelist ,
                                                                              dir_data_remote_BGeoTif_daily,
                                                                              datasetpentaddireformat,
                                                                              dataset_regrid,files_in.dailyregrid,
                                                                              dates,overwrite,family)
      print(Sys.time() -aa)  
   }else{
      aa <- Sys.time()
      
      files_in.pentad <- list.files(datasetpentaddir,recursive=TRUE)
      Pentadfilenamesout <- str_replace(files_in.pentad,"Geo",regridname)
      a<-file.copy(paste(datasetpentaddir,files_in.pentad,sep=sep),   
                   paste(datasetpentaddireformat,Pentadfilenamesout,sep=sep),overwrite=FALSE)
      print(Sys.time() -aa)  
      
   }
   return(regrid_flag)
}
### END OF PENTADAL


############################################################################
# DEKADAL FUNCTION
############################################################################
makedekadal <-  function(dataset,datastem,missinglimitdekad,regrid_template,dir_core,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_dekad,overwrite,regrid_flag,family){  
   #---------------------------------------------------------------------------------
   # Function to turn daily data into dekadal data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   regridname <- substr(regrid_template,1,nchar(regrid_template)-4)
   dataset_regrid  <- paste(datastem,regridname,sep="_")
   dir_reformat <- paste(dir_data_remote_BGeoTif_daily,dataset_regrid,sep=sep)
   datasetdekaddir <- paste(dir_data_remote_BGeoTif_dekad,paste("dekad",dataset,sep="_"),sep=sep)
   datasetdekaddireformat <- paste(dir_data_remote_BGeoTif_dekad,paste("dekad",dataset_regrid,sep="_"),sep=sep)
   
   
   if(!dir.exists(datasetdekaddir)){dir.create(datasetdekaddir)}
   if(!dir.exists(datasetdekaddireformat)){dir.create(datasetdekaddireformat)}
   
   subdirs <- paste(datasetdekaddir,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                            dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   subdirsref <- paste(datasetdekaddireformat,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                    dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   for(n in 1:length(subdirs)){
      if(!dir.exists(subdirs[n])){dir.create(subdirs[n])}
      if(!dir.exists(subdirsref[n])){dir.create(subdirsref[n])}
   }
   
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.dekadal <- list.files(datasetdekaddir,recursive=TRUE)
   files_out.dekadal    <- files_out.dekadal[grep(".tif",files_out.dekadal)]
   
   files_out.dekadalregrid <- list.files(datasetdekaddireformat,recursive=TRUE)
   files_out.dekadalregrid    <- files_out.dekadalregrid[grep(".tif",files_out.dekadalregrid)]
   
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep),recursive=TRUE)
   files_in.daily    <- files_in.daily[grep(".tif",files_in.daily)]
   
   #------------------------------------------------------------------------------
   # Now make a datelist by extracting the date from the filename
   #------------------------------------------------------------------------------
   date.list    <- as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")
   dates        <- suppressWarnings(makedates(date.list))
   dates        <- dates[which(is.na(dates$Date)==FALSE),]
   fulldatelist <- dekadalmissing(dates,datasetdekaddir,missinglimitdekad)
   # make another file with all the dates
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to dekadal (this can take a while)"))}
   
   aa <- Sys.time()
   res <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% dekadsumfunct(nnn,fulldatelist,
                                                                    dir_data_remote_BGeoTif_daily,
                                                                    datasetdekaddir,
                                                                    dataset,files_in.daily,
                                                                    dates,overwrite,family)
   print(Sys.time() -aa)   
   #print(res)

   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file FOR REGRIDDED
   #------------------------------------------------------------------------------

   if(regrid_flag){
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily gridded to dekadal (this can take a while)"))}
      
      aa <- Sys.time()
      files_in.dailyregrid   <- list.files(dir_reformat,recursive=TRUE)
      
      myresults <- foreach(nnn = 1:length(files_in.dailyregrid)) %dopar% dekadsumfunct(nnn,fulldatelist ,
                                                                             dir_data_remote_BGeoTif_daily,
                                                                             datasetdekaddireformat,
                                                                             dataset_regrid,
                                                                             files_in.dailyregrid,
                                                                              dates,overwrite,family)
      
   
      
      
      print(Sys.time() -aa)  
   }else{
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Copying dekadal to dekadal gridded (this can take a while)"))}
      
      files_in.dekad <- list.files(datasetdekaddir,recursive=TRUE)
      Dekadfilenamesout <- str_replace(files_in.dekad,"Geo",regridname)
      aa <- Sys.time()
      
      a<-file.copy(paste(datasetdekaddir,files_in.dekad,sep=sep),   
                   paste(datasetdekaddireformat,Dekadfilenamesout,sep=sep),overwrite=FALSE)
      print(Sys.time() -aa)  
      
   }
   return(regrid_flag)   
   
 
}
### END OF DEKADAL


############################################################################
# MONTHLY FUNCTION
############################################################################


makemonthly <-  function(dataset,datastem,missinglimitmonth,regrid_template,dir_core,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_month,overwrite,regrid_flag,family){  
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to monthly (this can take a while)"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn daily data into monthly data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
 
   regridname <- substr(regrid_template,1,nchar(regrid_template)-4)
   dataset_regrid  <- paste(datastem,regridname,sep="_")
   dir_reformat <- paste(dir_data_remote_BGeoTif_daily,dataset_regrid,sep=sep)
   datasetmonthdir <- paste(dir_data_remote_BGeoTif_month,paste("month",dataset,sep="_"),sep=sep)
   datasetmonthdireformat <- paste(dir_data_remote_BGeoTif_month,paste("month",dataset_regrid,sep="_"),sep=sep)
   
   
   if(!dir.exists(datasetmonthdir)){dir.create(datasetmonthdir)}
   if(!dir.exists(datasetmonthdireformat)){dir.create(datasetmonthdireformat)}
   
   subdirs <- paste(datasetmonthdir,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                    dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   subdirsref <- paste(datasetmonthdireformat,list.dirs(paste(dir_data_remote_BGeoTif_daily,
                                                              dataset,sep=sep),full.names=FALSE,recursive=FALSE),sep=sep)
   for(n in 1:length(subdirs)){
      if(!dir.exists(subdirs[n])){dir.create(subdirs[n])}
      if(!dir.exists(subdirsref[n])){dir.create(subdirsref[n])}
   }
   
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------

   files_out.month <- list.files(datasetmonthdir,recursive=TRUE)
   files_out.month    <- files_out.month[grep(".tif",files_out.month)]
   
   files_out.monthregrid <- list.files(datasetmonthdireformat,recursive=TRUE)
   files_out.monthregrid    <- files_out.monthregrid[grep(".tif",files_out.monthregrid)]
   
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep),recursive=TRUE)
   files_in.daily    <- files_in.daily[grep(".tif",files_in.daily)]
   

   
   #------------------------------------------------------------------------------
   # Now make a datelist by extracting the date from the filename
   #------------------------------------------------------------------------------
   date.list         <- as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")
   dates        <- suppressWarnings(makedates(date.list))
   dates        <- dates[which(is.na(dates$Date)==FALSE),]
   fulldatelist      <- monthmissing(dates,datasetmonthdir,missinglimitmonth)
   # make another file with all the dates
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   
   aa <- Sys.time()
   res <- foreach(n = 1:nrow(fulldatelist)) %dopar% monthsumfunct(n,fulldatelist,dir_data_remote_BGeoTif_daily,
                                                                  datasetmonthdir,dataset,
                                                                  files_in.daily,dates,
                                                                  overwrite,family)
   print(Sys.time() -aa)   
   #print(res)
   
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file FOR REGRIDDED
   #------------------------------------------------------------------------------
   
   if(regrid_flag){
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily gridded to monthly (this can take a while)"))}
      
      aa <- Sys.time()
      
      files_in.dailyregrid   <- list.files(dir_reformat,recursive=TRUE)
      
      myresults <- foreach(nnn = 1:length(files_in.dailyregrid)) %dopar% monthsumfunct(nnn,fulldatelist ,
                                                                             dir_data_remote_BGeoTif_daily,
                                                                             datasetmonthdireformat,
                                                                             dataset_regrid,
                                                                             files_in.dailyregrid,
                                                                             dates,overwrite,family)
      print(Sys.time() -aa)  
   }else{
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Copying monthly to monthly gridded (this can take a while)"))}
      aa <- Sys.time()
      
      files_in.month <-  list.files(datasetmonthdir,recursive=TRUE)

      Monthfilenamesout <- str_replace(files_in.month,"Geo",regridname)
      a<-file.copy(paste(datasetmonthdir,files_in.month,sep=sep),   
                   paste(datasetmonthdireformat,Monthfilenamesout,sep=sep),overwrite=FALSE)
      print(Sys.time() -aa)  
      
   }
   return(regrid_flag)   
   
   
}
### END OF MONTHLY



##########################################################################################
# CODE
#---------------------------------------------------------------------------------------
# For each product
#---------------------------------------------------------------------------------------
for(n_data in 1:length(Daily_datasetlist$Stem)){

   #---------------------------------------------------------------------------------------
   # Set up the meta data and get the input files
   #---------------------------------------------------------------------------------------
   dataset <- Daily_datasetlist$Dataset[n_data]   
   family <- Daily_datasetlist$Family[n_data]   
   datastem <- substr(dataset, 1,nchar(dataset)-4)
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   geo_stem <- paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep)
   

   # remove any spurious tif/aux files
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Removing any spurious tif/aux files"))}
   suppressWarnings(suppressMessages(file.remove(list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE)[
      grep("tif.aux",list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE))])))
   suppressWarnings(suppressMessages(file.remove(list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE)[
      grep(".aux.json",list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE))])))
   
   files_in.daily    <- list.files(geo_stem,recursive=TRUE)
   files_in.daily <- files_in.daily[grep(".tif",files_in.daily)]
   
   
   
   #---------------------------------------------------------------------------------------
   # Extract the dates and any missing data
   #---------------------------------------------------------------------------------------
   date.list    <-  data.frame(Date=as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d"),
                               Sat=files_in.daily)
   fulldatelist <-  data.frame(Date=seq(from=min(date.list$Date),to=max(date.list$Date),by="d"),all=TRUE)
   fulldatelist <-  merge(fulldatelist,date.list,by="Date",all.x=TRUE)
   alldates <- seq(from=min(fulldatelist$Date,na.rm=TRUE),to=max(fulldatelist$Date,na.rm=TRUE),by="d")
   missing <- !(which(fulldatelist$Date %in% alldates))
   
   
   
   #---------------------------------------------------------------------------------------
   # THIS ALSO REFORMATS TO 0.1 DEGREE GRID MATCHING ARC2
   #---------------------------------------------------------------------------------------
   pentadcreated <- makepentadal(dataset,datastem,regrid_template,dir_core,missinglimitpentad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_pentad,overwrite,family)
   dekadcreated  <- makedekadal (dataset,datastem,missinglimitdekad,regrid_template,dir_core,dir_data_remote_BGeoTif_daily, dir_data_remote_BGeoTif_dekad,overwrite,regrid_flag=pentadcreated,family)
   monthcreated  <- makemonthly (dataset,datastem,missinglimitmonth,regrid_template,dir_core,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_month,overwrite,regrid_flag=pentadcreated,family)
   
   # files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep),recursive=TRUE)
   # files_in.daily    <- files_in.daily[grep(".tif",files_in.daily)]
   # 
   # #------------------------------------------------------------------------------
   # # Now make a datelist by extracting the date from the filename
   # #------------------------------------------------------------------------------
   # date.list    <-  data.frame(Date=as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d"),
   #                             Sat=files_in.daily)
   # fulldatelist <-  data.frame(Date=seq(from=min(date.list$Date),to=max(date.list$Date),by="d"),all=TRUE)
   # fulldatelist <-  merge(fulldatelist,date.list,by="Date",all.x=TRUE)
   # samplefile   <-  raster(paste(dir_data_remote_BGeoTif_daily,dataset,fulldatelist$Sat[min(which(is.na(fulldatelist$Sat)==FALSE))],sep=sep))
   # samplefile[,] <- NA
   # 
   # if(length(which(is.na(fulldatelist$Sat)==TRUE))>0){
   #    missinglist <-  fulldatelist[which(is.na(fulldatelist$Sat)==TRUE),]
   #    for(m in 1:nrow(missinglist)){
   #       tmp <- samplefile
   #       names(tmp) <- paste(dataset,format.Date(missinglist$Date[m],"%Y.%m.%d"))
   #       writeRaster(tmp, filename=paste(dir_data_remote_BGeoTif_daily,format.Date(missinglist$Date[m],"%Y"),dataset,paste(dataset,"_",missinglist$Date[m],".tif",sep=""),sep=sep), 
   #                   format="GTiff", overwrite=TRUE)
   #       if(verbose %in% c(TRUE,"Limited")){message(paste("    Writing blank file for date: ",missinglist$Date[m]))}
   #       
   #    }        
   # }
}