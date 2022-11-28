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
      filenamesout <- str_replace(filenamesin,"Geo",regridname)
      
      #------------------------------------------------------------------------------
      # If so, set up a new template
      #------------------------------------------------------------------------------
      if(length(filenamesin)>0){
         regridtemplate <- raster(paste(dir_core,regrid_template,sep=sep))
         regrid_test <- raster(paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily[2],sep=sep))
         
         regridtemplate <- extend(regridtemplate,regrid_test)
         gdal_setInstallation()
         valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
         if(valid_install == TRUE){ 
            if(verbose %in% c(TRUE,"Limited")){message(paste("     Using GDAL"))}
            res <- foreach(nnn = 1:length(filenamesin)) %dopar%  suppressWarnings(try(gdalwarp(srcfile=paste(dir_data_remote_BGeoTif_daily,dataset,files_in.daily[nnn],sep=sep),
                                                                                               dstfile=paste(dir_reformat,filenamesout[nnn],sep=sep),
                                                                                               tr=res(regridtemplate),
                                                                                               te=c(bbox(extent(regridtemplate))),
                                                                                               r='bilinear',overwrite=FALSE,verbose=FALSE)))
         }else{
            if(verbose %in% c(TRUE,"Limited")){message(paste("    You don't have a valid Gdal install. Line 149"))}
            # You can write some code like the myresults below which will slowly regrid the data by reading it in then regridding and outputting

         }
         if(family %in% c("rain","tmin","tmax","rhum")){
            myresults <- foreach(nnn = 1:length(filenamesin)) %dopar% terra::writeRaster(round(rast(paste(dir_reformat,filenamesout[nnn],sep=sep)),2), 
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








###########################################################################################################################
# PENTADAL FUNCTIONS
###########################################################################################################################

#==========================================================================================================================
# PENTADALMISSING: Missing dates in each Pentad
#==========================================================================================================================
pentadalmissing <- function(dates,datasetpentaddir,missinglimitpentad){
   
   #------------------------------------------------------------------------------
   # OK, now let's look for missing data
   # make a table of how many values in each pentad
   #------------------------------------------------------------------------------
   totalinpentad <- data.frame(pentadyear = sapply(split(dates$YearPentad,dates$YearPentad),"[",1),
                               pentad     = sapply(split(dates$Pentad,dates$YearPentad),"[",1),
                               numdata   = sapply(split(dates$YearPentad,dates$YearPentad),length))
   
   #------------------------------------------------------------------------------
   # Now compare from what *should* be there                           
   # Startdate is defined as day 1 of the first probably full pentad in the dataset
   #------------------------------------------------------------------------------
   startdate <- as.Date(min(dates$Date,na.rm=TRUE))
   if(as.numeric(format.Date(startdate,"%d")) %in% 2:9){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"),format.Date(startdate,"%m"),"10",sep="-"))
   }
   if(as.numeric(format.Date(startdate,"%d")) %in% 11:19 ){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"),format.Date(startdate,"%m"),"20",sep="-"))
   }   
   if(as.numeric(format.Date(startdate,"%d")) > 21 ){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"),format.Date(startdate,"%m"),"1",sep="-"))
      startdate <- seq(from=startdate,length.out=2,by="m")[2]
   }     
   
   #------------------------------------------------------------------------------
   # sort out an enddate at the end of the final full pentad.
   #------------------------------------------------------------------------------
   enddate <- as.Date(max(dates$Date,na.rm=TRUE))
   if(as.numeric(format.Date(enddate,"%d")) > 20){
      enddate <- as.Date(paste(format.Date(enddate,"%Y"),format.Date(enddate,"%m"),"20",sep="-"))
   }
   if(as.numeric(format.Date(enddate,"%d")) %in% 10:19 ){
      enddate <- as.Date(paste(format.Date(enddate,"%Y"),format.Date(enddate,"%m"),"10",sep="-"))
   }   
   if(as.numeric(format.Date(enddate,"%d")) %in% 1:9 ){
      enddate <- as.Date(paste(format.Date(enddate,"%Y"),format.Date(enddate,"%m"),"1",sep="-"))
   }     
   
   #------------------------------------------------------------------------------
   # Now work out what the full datelist *should* have been
   #------------------------------------------------------------------------------
   alldates <- seq(from=startdate,to=enddate,by="d") 
   alldates <- suppressWarnings(makedates(alldates))
   alldates <- alldates[which(is.na(alldates$Date)==FALSE),] 
   
   #------------------------------------------------------------------------------
   # and how many *should* have been in each pentad
   #------------------------------------------------------------------------------
   allexpected <- data.frame( year = sapply(split(alldates$Year,alldates$YearPentad),"[",1),
                              month=sapply(split(alldates$Month,alldates$YearPentad),"[",1),
                              pentadyear = sapply(split(alldates$YearPentad,alldates$YearPentad),"[",1),
                              pentad     = sapply(split(alldates$Pentad,alldates$YearPentad),"[",1),
                              expected   = sapply(split(alldates$YearPentad,alldates$YearPentad),length))
   
   #------------------------------------------------------------------------------
   # Now we have a table of the available pentad per date and the missing data
   # Ignore the start and end of the timeseries where we know there are no full pentads
   #------------------------------------------------------------------------------
   fulldatelist <- merge(totalinpentad,allexpected, by=c("pentadyear","pentad"),all.x=FALSE,all.y=TRUE)   
   fulldatelist$numdata[which(is.na(fulldatelist$numdata)==TRUE)] <- 0 
   fulldatelist$missing <- fulldatelist$expected - fulldatelist$numdata
   
   #------------------------------------------------------------------------------
   # Apply any rules
   #------------------------------------------------------------------------------
   fulldatelist$include <- TRUE
   fulldatelist$include[fulldatelist$missing > missinglimitpentad] <- FALSE
   
   #------------------------------------------------------------------------------
   # And write to file
   #------------------------------------------------------------------------------
   missingfile <- paste(datasetpentaddir,paste("pentad_missing",dataset,"limit",missinglimitpentad,".csv",sep="_"),sep=sep)
   write.csv(fulldatelist[fulldatelist$missing>0,],file = missingfile)
   return(fulldatelist)
}






























###########################################################################################################################
# DEKADAL FUNCTIONS
###########################################################################################################################

#==========================================================================================================================
# DEKADALMISSING: Missing dates in each Dekad
#==========================================================================================================================
dekadalmissing <- function(dates,datasetdekaddir,missinglimitdekad){
   
   #------------------------------------------------------------------------------
   # OK, now let's look for missing data
   # make a table of how many values in each dekad
   #------------------------------------------------------------------------------
   totalindekad <- data.frame(dekadyear = sapply(split(dates$YearDekad,dates$YearDekad),"[",1),
                              dekad     = sapply(split(dates$Dekad,dates$YearDekad),"[",1),
                              numdata   = sapply(split(dates$YearDekad,dates$YearDekad),length))
   
   #------------------------------------------------------------------------------
   # Now compare from what *should* be there                           
   # Startdate is defined as day 1 of the first probably full dekad in the dataset
   #------------------------------------------------------------------------------
   startdate <- as.Date(min(dates$Date,na.rm=TRUE))
   if(as.numeric(format.Date(startdate,"%d")) %in% 2:9){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"),format.Date(startdate,"%m"),"10",sep="-"))
   }
   if(as.numeric(format.Date(startdate,"%d")) %in% 11:19 ){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"),format.Date(startdate,"%m"),"20",sep="-"))
   }   
   if(as.numeric(format.Date(startdate,"%d")) > 21 ){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"),format.Date(startdate,"%m"),"1",sep="-"))
      startdate <- seq(from=startdate,length.out=2,by="m")[2]
   }     
   
   #------------------------------------------------------------------------------
   # sort out an enddate at the end of the final full dekad.
   #------------------------------------------------------------------------------
   enddate <- as.Date(max(dates$Date,na.rm=TRUE))
   if(as.numeric(format.Date(enddate,"%d")) > 20){
      enddate <- as.Date(paste(format.Date(enddate,"%Y"),format.Date(enddate,"%m"),"20",sep="-"))
   }
   if(as.numeric(format.Date(enddate,"%d")) %in% 10:19 ){
      enddate <- as.Date(paste(format.Date(enddate,"%Y"),format.Date(enddate,"%m"),"10",sep="-"))
   }   
   if(as.numeric(format.Date(enddate,"%d")) %in% 1:9 ){
      enddate <- as.Date(paste(format.Date(enddate,"%Y"),format.Date(enddate,"%m"),"1",sep="-"))
   }     
   
   #------------------------------------------------------------------------------
   # Now work out what the full datelist *should* have been
   #------------------------------------------------------------------------------
   alldates <- seq(from=startdate,to=enddate,by="d") 
   alldates <- suppressWarnings(makedates(alldates))
   alldates <- alldates[which(is.na(alldates$Date)==FALSE),] 
   
   #------------------------------------------------------------------------------
   # and how many *should* have been in each dekad
   #------------------------------------------------------------------------------
   allexpected <- data.frame( year = sapply(split(alldates$Year,alldates$YearDekad),"[",1),
                              month=sapply(split(alldates$Month,alldates$YearDekad),"[",1),
                              dekadyear = sapply(split(alldates$YearDekad,alldates$YearDekad),"[",1),
                              dekad     = sapply(split(alldates$Dekad,alldates$YearDekad),"[",1),
                              expected   = sapply(split(alldates$YearDekad,alldates$YearDekad),length))
   
   #------------------------------------------------------------------------------
   # Now we have a table of the available dekad per date and the missing data
   # Ignore the start and end of the timeseries where we know there are no full dekads
   #------------------------------------------------------------------------------
   fulldatelist <- merge(totalindekad,allexpected, by=c("dekadyear","dekad"),all.x=FALSE,all.y=TRUE)   
   fulldatelist$numdata[which(is.na(fulldatelist$numdata)==TRUE)] <- 0 
   fulldatelist$missing <- fulldatelist$expected - fulldatelist$numdata
   
   #------------------------------------------------------------------------------
   # Apply any rules
   #------------------------------------------------------------------------------
   fulldatelist$include <- TRUE
   fulldatelist$include[fulldatelist$missing > missinglimitdekad] <- FALSE
   
   #------------------------------------------------------------------------------
   # And write to file
   #------------------------------------------------------------------------------
   missingfile <- paste(datasetdekaddir,paste("dekad_missing",dataset,"limit",missinglimitdekad,".csv",sep="_"),sep=sep)
   write.csv(fulldatelist[fulldatelist$missing>0,],file = missingfile)
   return(fulldatelist)
}

#==========================================================================================================================
# DEKADSUMFUNCT: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
dekadsumfunct <- function(n,fulldatelist,dir_data_remote_BGeoTif_daily,datasetdekaddir,dataset,files_in.daily,dates,overwrite,family){
   require(terra)
   
   #------------------------------------------------------------------------------
   # get the dekad wanted and make the output file name
   #------------------------------------------------------------------------------
   dekadyear <- fulldatelist$dekadyear[n]
   outputfile <- paste(datasetdekaddir,fulldatelist$year[n],paste(dataset,"_dekad_",dekadyear,".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, male the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile))){
      inputfiles <- paste(dir_data_remote_BGeoTif_daily,dataset,
                          files_in.daily[which(as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")%in%  
                                                  dates$Date[dates$YearDekad %in% dekadyear])],sep=sep)
      if(length(inputfiles) > 2){
         
         if(family %in% c("rain","tmin","tmax","rhum")){
            suppressMessages(suppressWarnings(terra::writeRaster(round(mean(rast(inputfiles)),1), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
         }else{
            suppressMessages(suppressWarnings(terra::writeRaster(mean(rast(inputfiles)), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
         } 
      }
   }
   return(outputfile)
}



###########################################################################################################################
# MONTHLY FUNCTIONS
###########################################################################################################################

#==========================================================================================================================
# MONTHMISSING: Missing dates in each month
#==========================================================================================================================
monthmissing <- function(dates,datasetmonthdir,missinglimitmonth){
   
   #------------------------------------------------------------------------------
   # OK, now let's look for missing data
   # make a table of how many values in each dekad
   #------------------------------------------------------------------------------
   totalinmonth <- data.frame(monthyear = sapply(split(dates$YearMonth,dates$YearMonth),"[",1),
                              month     = sapply(split(dates$Month,dates$YearMonth),"[",1),
                              numdata   = sapply(split(dates$YearMonth,dates$YearMonth),length))
   
   #------------------------------------------------------------------------------
   # Now compare from what *should* be there                           
   # Startdate is defined as day 1 of the first probably full month in the dataset
   # e.g. if beyond day 1, go forward a month
   #------------------------------------------------------------------------------
   startdate <- as.Date(min(dates$Date,na.rm=TRUE))
   if(as.numeric(format.Date(startdate,"%d")) > 1){
      startdate <- as.Date(paste(format.Date(startdate,"%Y"), as.numeric(format.Date(startdate,"%m"))+1, "1",sep="-"))
   }
   
   #------------------------------------------------------------------------------
   # sort out an enddate at the end of the final full month 
   #------------------------------------------------------------------------------
   enddate <- as.Date(max(dates$Date,na.rm=TRUE))
   enddate <- as.Date(paste(as.numeric(format.Date(enddate,"%Y"))+1,format.Date(enddate,"%m"),"1",sep="-")) - 1
   
   
   #------------------------------------------------------------------------------
   # Now work out what the full datelist *should* have been
   #------------------------------------------------------------------------------
   alldates <- seq(from=startdate,to=enddate,by="d") 
   alldates <- suppressWarnings(makedates(alldates))
   alldates <- alldates[which(is.na(alldates$Date)==FALSE),] 
   
   #------------------------------------------------------------------------------
   # and how many *should* have been in each dekad
   #------------------------------------------------------------------------------
   allexpected <- data.frame( year      = sapply(split(alldates$Year,alldates$YearMonth),"[",1),
                              month     = sapply(split(alldates$Month,alldates$YearMonth),"[",1),
                              monthyear = sapply(split(alldates$YearMonth,alldates$YearMonth),"[",1),
                              expected  = sapply(split(alldates$YearMonth,alldates$YearMonth),length))
   
   #------------------------------------------------------------------------------
   # Now we have a table of the available dekad per date and the missing data
   # Ignore the start and end of the timeseries where we know there are no full dekads
   #------------------------------------------------------------------------------
   fulldatelist <- merge(totalinmonth,allexpected, by=c("monthyear","month"),all.x=FALSE,all.y=TRUE)   
   fulldatelist$numdata[which(is.na(fulldatelist$numdata)==TRUE)] <- 0 
   fulldatelist$missing <- fulldatelist$expected - fulldatelist$numdata
   
   #------------------------------------------------------------------------------
   # Apply any rules
   #------------------------------------------------------------------------------
   fulldatelist$include <- TRUE
   fulldatelist$include[fulldatelist$missing > missinglimitmonth] <- FALSE
   
   #------------------------------------------------------------------------------
   # And write to file
   #------------------------------------------------------------------------------
   missingfile <- paste(datasetmonthdir,paste("month_missing",dataset,"limit",missinglimitmonth,".csv",sep="_"),sep=sep)
   write.csv(fulldatelist[fulldatelist$missing>0,],file = missingfile)
   return(fulldatelist)
}



#==========================================================================================================================
# MONTHSUMFUNCT: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
monthsumfunct <- function(n,fulldatelist,dir_data_remote_BGeoTif_daily,datasetmonthdir,dataset,files_in.daily,dates,overwrite,family){
   require(Greatrex.Functions)
   require(terra)
   
   #------------------------------------------------------------------------------
   # get the dekad wanted and make the output file name
   #------------------------------------------------------------------------------
   monthyear <- fulldatelist$monthyear[n]
   outputfile <- paste(datasetmonthdir,fulldatelist$year[n],paste(dataset,"_month_",monthyear,".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, male the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile))){
      inputfiles <- paste(dir_data_remote_BGeoTif_daily,dataset,
                          files_in.daily[which(as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")%in%  
                                                  dates$Date[dates$YearMonth %in% monthyear])],sep=sep)
      
      if(length(inputfiles) > 2){
         if(family %in% c("rain","tmin","tmax","rhum")){
            suppressMessages(suppressWarnings(terra::writeRaster(round(mean(rast(inputfiles)),1), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
         }else{
            suppressMessages(suppressWarnings(terra::writeRaster(mean(rast(inputfiles)), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
         }
      }   
   }   
   return(outputfile)
}

