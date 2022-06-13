


#=================================================================================
# This creates the temporal sum of all the data
#=================================================================================
#---------------------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------------------
############################################################################
# PENTADAL FUNCTION
############################################################################
makepentadal <-  function(dataset,datastem,regrid_template,dir_core,missinglimitpendad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_pentad,overwrite){  
   
   #---------------------------------------------------------------------------------
   # Function to regrid daily data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   regridname <- substr(regrid_template,1,nchar(regrid_template)-4)
   dataset_regrid  <- paste(datastem,regridname,sep="_")
   dir_reformat <- paste(dir_data_remote_BGeoTif_daily,dataset_regrid,sep=sep)
   
   if(!dir.exists(dir_reformat)){dir.create(dir_reformat)}
   
   datasetpentaddir        <- paste(dir_data_remote_BGeoTif_pentad,paste("pentad",dataset,sep="_"),sep=sep)
   datasetpentaddireformat <- paste(dir_data_remote_BGeoTif_pentad,paste("pentad",dataset_regrid,sep="_"),sep=sep)
   
   if(!dir.exists(datasetpentaddir)){dir.create(datasetpentaddir)}
   if(!dir.exists(datasetpentaddireformat)){dir.create(datasetpentaddireformat)}
   
   #---------------------------------------------------------------------------------
   # Get input files and the regridding template
   #---------------------------------------------------------------------------------
   files_in.daily   <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
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
   files_out.regrid   <- list.files(dir_reformat)
   files_out.pentadal <- list.files(datasetpentaddir)
   files_out.pentadalregrid <- list.files(datasetpentaddireformat)
   
   #------------------------------------------------------------------------------
   # Now make a datelist by extracting the date from the filename
   #------------------------------------------------------------------------------
   fulldatelist <- pentadalmissing(dates,datasetpentaddir,missinglimitpentad)
   
   #------------------------------------------------------------------------------
   # Test if regridding is needed
   #------------------------------------------------------------------------------
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
      
      a<-file.copy(paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily,sep=sep), 
                   paste(dir_reformat,filenamesout,sep=sep),overwrite=FALSE)
      
   }
   #}
   #------------------------------------------------------------------------------
   # Otherwise regrid
   #------------------------------------------------------------------------------
   if(regrid_flag){
      #------------------------------------------------------------------------------
      # see if there are files left to do
      #------------------------------------------------------------------------------
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Regridding data"))}
      if(length(files_out.regrid)>0){
         filenamesin <- files_in.daily[-(which(files_in.daily %in% files_out.regrid))]
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
         
         res <- foreach(nnn = 1:length(filenamesin)) %dopar%  gdalwarp(srcfile=paste(dir_data_remote_BGeoTif_daily,dataset,filenamesin[nnn],sep=sep),
                                                                       dstfile=paste(dir_reformat,filenamesout[nnn],sep=sep),
                                                                       tr=res(regridtemplate),
                                                                       te=c(bbox(extent(regridtemplate))),
                                                                       r='bilinear',overwrite=FALSE,verbose=FALSE)
      }
      if(verbose %in% c(TRUE,"Limited")){message(paste("     Finished regridding"))}
   }
   rm(regrid_test)
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to pendatal (this can take a while)"))}
   
   a <- Sys.time()
   myresults <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% pentadsumfunct(nnn,fulldatelist ,dir_data_remote_BGeoTif_daily,
                                                                           datasetpentaddir,dataset,files_in.daily,
                                                                           dates,overwrite)
   print(Sys.time() -a)  
   
   # Only do this twice if the regrid actually did something
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily regridded to pendatal (this can take a while)"))}
   
   if(regrid_flag){
      a <- Sys.time()
      files_in.dailyregrid   <- list.files(dir_reformat)
      
      myresults <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% pentadsumfunct(nnn,fulldatelist ,dir_data_remote_BGeoTif_daily,
                                                                              datasetpentaddireformat,dataset_regrid,files_in.dailyregrid,
                                                                              dates,overwrite)
      print(Sys.time() -a)  
   }else{
      files_in.pentad <- list.files(datasetpentaddir)
      Pentadfilenamesout <- str_replace(files_in.pentad,"Geo",regridname)
      a<-file.copy(paste(datasetpentaddir,files_in.pentad,sep=sep),   
                   paste(datasetpentaddireformat,Pentadfilenamesout,sep=sep),overwrite=FALSE)
   }
   return(regrid_flag)
}
### END OF PENTADAL


############################################################################
# DEKADAL FUNCTION
############################################################################
makedekadal <-  function(dataset,datastem,missinglimitdekad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_dekad,overwrite){  
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to dekadal (this can take a while)"))}
   #---------------------------------------------------------------------------------
   # Function to turn daily data into dekadal data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   datasetdekaddir <- paste(dir_data_remote_BGeoTif_dekad,paste("dekad",dataset,sep="_"),sep=sep)
   if(!dir.exists(datasetdekaddir)){dir.create(datasetdekaddir)}
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.dekadal <- list.files(datasetdekaddir)
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
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
   a <- Sys.time()
   res <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% dekadsumfunct(nnn,fulldatelist,dir_data_remote_BGeoTif_daily,
                                                                    datasetdekaddir,dataset,files_in.daily,dates,overwrite)
   print(Sys.time() -a)   
   #print(res)
}
### END OF DEKADAL


############################################################################
# MONTHLY FUNCTION
############################################################################
makemonthly <-  function(dataset,datastem,missinglimitmonth,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_month,overwrite){  
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to monthly (this can take a while)"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn daily data into monthly data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   datasetmonthdir <- paste(dir_data_remote_BGeoTif_month,paste("month",dataset,sep="_"),sep=sep)
   if(!dir.exists(datasetmonthdir)){dir.create(datasetmonthdir)}
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.month <- list.files(datasetmonthdir)
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
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
   a <- Sys.time()
   res <- foreach(n = 1:nrow(fulldatelist)) %dopar% monthsumfunct(n,fulldatelist,dir_data_remote_BGeoTif_daily,
                                                                  datasetmonthdir,dataset,files_in.daily,dates,
                                                                  overwrite)
   print(Sys.time() -a)   
   #print(res)
}
### END OF MONTHLY



##########################################################################################
# CODE
#---------------------------------------------------------------------------------------
# For each product
#---------------------------------------------------------------------------------------
for(n_data in seq_along(Daily_datasetlist$Stem)){
   
   #---------------------------------------------------------------------------------------
   # Set up the meta data and get the input files
   #---------------------------------------------------------------------------------------
   dataset <- Daily_datasetlist$Dataset[n_data]   
   datastem <- substr(dataset, 1,nchar(dataset)-4)
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
   
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
   pentadcreated <- makepentadal(dataset,datastem,regrid_template,dir_core,missinglimitpentad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_pentad,overwrite)
   dekadcreated  <- makedekadal(dataset,datastem,missinglimitdekad,dir_data_remote_BGeoTif_daily_regrid_10,dir_data_remote_BGeoTif_dekad,overwrite,regrid_flag=pentadcreated)
   #monthcreated  <- makemonthly(dataset,datastem,missinglimitmonth,dir_data_remote_BGeoTif_daily_regrid_10,dir_data_remote_BGeoTif_month,overwrite,regrid_flag=pentadcreated)
   
   
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
   files_in.daily    <- files_in.daily[grep(".tif",files_in.daily)]
   
   #------------------------------------------------------------------------------
   # Now make a datelist by extracting the date from the filename
   #------------------------------------------------------------------------------
   date.list    <-  data.frame(Date=as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d"),
                               Sat=files_in.daily)
   fulldatelist <-  data.frame(Date=seq(from=min(date.list$Date),to=max(date.list$Date),by="d"),all=TRUE)
   fulldatelist <-  merge(fulldatelist,date.list,by="Date",all.x=TRUE)
   samplefile   <-  raster(paste(dir_data_remote_BGeoTif_daily,dataset,fulldatelist$Sat[min(which(is.na(fulldatelist$Sat)==FALSE))],sep=sep))
   samplefile[,] <- NA
   
   if(length(which(is.na(fulldatelist$Sat)==TRUE))>0){
      missinglist <-  fulldatelist[which(is.na(fulldatelist$Sat)==TRUE),]
      for(m in 1:nrow(missinglist)){
         tmp <- samplefile
         names(tmp) <- paste(dataset,format.Date(missinglist$Date[m],"%Y.%m.%d"))
         writeRaster(tmp, filename=paste(dir_data_remote_BGeoTif_daily,dataset,paste(dataset,"_",missinglist$Date[m],".tif",sep=""),sep=sep), 
                     format="GTiff", overwrite=TRUE)
         if(verbose %in% c(TRUE,"Limited")){message(paste("    Writing blank file for date: ",missinglist$Date[m]))}
         
      }        
   }
}