
#=================================================================================
# This creates the temporal sum of all the data
#=================================================================================
#---------------------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------------------
############################################################################
# PENTADAL FUNCTION
############################################################################
makepentadal <-  function(dataset,missinglimitpendad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_pentad,overwrite){  
   if(verbose %in% c(TRUE,"Limited")){message(paste("     Summing daily to pendatal (this can take a while)"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn daily data into pentadal data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   datasetpentaddir <- paste(dir_data_remote_BGeoTif_pentad,paste("pentad",dataset,sep="_"),sep=sep)
   if(!dir.exists(datasetpentaddir)){dir.create(datasetpentaddir)}
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.pentadal <- list.files(datasetpentaddir)
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
   files_in.daily    <- files_in.daily[grep(".tif",files_in.daily)]
   
   #------------------------------------------------------------------------------
   # Now make a datelist by extracting the date from the filename
   #------------------------------------------------------------------------------
   date.list    <- as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")
   dates        <- suppressWarnings(makedates(date.list))
   dates        <- dates[which(is.na(dates$Date)==FALSE),]
   fulldatelist <- pentadalmissing(dates,datasetpentaddir,missinglimitpentad)
   # make another file with all the dates
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   a <- Sys.time()
   res <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% pentadsumfunct(nnn,fulldatelist ,dir_data_remote_BGeoTif_daily,
                                                                    datasetpentaddir,dataset,files_in.daily,dates,overwrite )
   print(Sys.time() -a)   
   #print(res)
}
### END OF PENTADAL


############################################################################
# DEKADAL FUNCTION
############################################################################
makedekadal <-  function(dataset,missinglimitdekad,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_dekad,overwrite){  
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
makemonthly <-  function(dataset,missinglimitmonth,dir_data_remote_BGeoTif_daily,dir_data_remote_BGeoTif_month,overwrite){  
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

