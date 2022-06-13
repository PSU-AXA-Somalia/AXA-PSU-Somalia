

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

#==========================================================================================================================
# PENTADSUMFUNCT: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
pentadsumfunct <- function(nnn,fulldatelist,dir_data_remote_BGeoTif_daily,datasetpentaddir,dataset,files_in.daily,dates,overwrite){
   #------------------------------------------------------------------------------
   # get the pentad wanted and make the output file name
   #------------------------------------------------------------------------------
   pentadyear <- fulldatelist$pentadyear[nnn]
   outputfile <- paste(datasetpentaddir,paste(dataset,"_pentad_",pentadyear,".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, male the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile))){
      inputfiles <- paste(dir_data_remote_BGeoTif_daily,dataset,
                          files_in.daily[which(as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")%in%  
                                                  dates$Date[dates$YearPentad %in% pentadyear])],sep=sep)
         if(length(inputfiles) > 2){
            suppressMessages(suppressWarnings(terra::writeRaster(mean(rast(inputfiles)), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
            
         }
  
   }   
   return(outputfile)
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
dekadsumfunct <- function(n,fulldatelist,dir_data_remote_BGeoTif_daily,datasetdekaddir,dataset,files_in.daily,dates,overwrite,regrid_flag){
   require(Greatrex.Functions)
   #------------------------------------------------------------------------------
   # get the dekad wanted and make the output file name
   #------------------------------------------------------------------------------
   dekadyear <- fulldatelist$dekadyear[n]
   outputfile <- paste(datasetdekaddir,paste(dataset,"_dekad_",dekadyear,".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, male the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile))){
      inputfiles <- paste(dir_data_remote_BGeoTif_daily,dataset,
                          files_in.daily[which(as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")%in%  
                                                  dates$Date[dates$YearDekad %in% dekadyear])],sep=sep)
      if(length(inputfiles) > 2){
         suppressMessages(suppressWarnings(terra::writeRaster(mean(rast(inputfiles)), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
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
 monthsumfunct <- function(n,fulldatelist,dir_data_remote_BGeoTif_daily,datasetmonthdir,dataset,files_in.daily,dates,overwrite,regrid_flag){
    require(Greatrex.Functions)
    #------------------------------------------------------------------------------
    # get the dekad wanted and make the output file name
    #------------------------------------------------------------------------------
    monthyear <- fulldatelist$monthyear[n]
    outputfile <- paste(datasetmonthdir,paste(dataset,"_month_",monthyear,".tif",sep=""),sep=sep)
    
    #------------------------------------------------------------------------------
    # if the outputfile exists, male the input filename
    #------------------------------------------------------------------------------
    if((overwrite==TRUE)|(!file.exists(outputfile))){
       inputfiles <- paste(dir_data_remote_BGeoTif_daily,dataset,
                           files_in.daily[which(as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")%in%  
                                                   dates$Date[dates$YearMonth %in% monthyear])],sep=sep)
       
       if(length(inputfiles) > 2){
          suppressMessages(suppressWarnings(terra::writeRaster(mean(rast(inputfiles)), filename=outputfile, filetype="GTiff",overwrite=TRUE)))
       }   
    }   
    return(outputfile)
 }
 
