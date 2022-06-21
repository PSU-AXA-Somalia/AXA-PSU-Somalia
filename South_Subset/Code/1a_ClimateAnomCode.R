
#==========================================================================================================================
# Daily climatology: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
dailyclimatologies<- function(nnn,fulldatelist,DOYs,dir_data_remote_BGeoTif_daily, subdir.CLIM.daily,subdir.ANOM.daily,dataset,files_in.daily,overwrite ){
   
   require(Greatrex.Functions)
   #------------------------------------------------------------------------------
   # get the pentad wanted and make the output file name
   #------------------------------------------------------------------------------
   DOYindex <- DOYs[nnn]
   
   inputkey <- as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")

   outputfile <- paste(subdir.CLIM.daily,paste(dataset,"_dailyanom_",
                                               minyear,".",maxyear,".",
                                               sprintf("%03d",DOYindex),".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, make the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfile))){
      
      subsetfiles <- files_in.daily[which(inputkey %in%  fulldatelist$Date[fulldatelist$DOY366 %in% DOYindex])]
      
      inputfiles <- paste(dir_data_remote_BGeoTif_daily,dataset,subsetfiles,sep=sep)
      
      if(length(inputfiles) > 2){
         datain <- stack(inputfiles,quick=TRUE)
         r.mean <- rasterstack_mean_fast(datain)
         r.anom <- datain-r.mean
         
         # write the mean to file

         writeRaster(r.mean, filename=outputfile, format="GTiff", overwrite=TRUE)
         
         # write the anomalies to file
         outputfiles <- paste(subdir.ANOM.daily,paste(substr(subsetfiles,1,nchar(subsetfiles)-4),"_ANOM.tif",sep=""),sep=sep)
         
         for(ff in 1:length(inputfiles)){
            writeRaster(r.anom[[ff]], filename=outputfiles[ff], format="GTiff", overwrite=TRUE)
         }   
         
         
      }   
   }   
   return(outputfile)
}




makeanomalydailyclimate <-  function(dataset,minyear,maxyear,missinglimit,dir_data_remote_BGeoTif_daily,dir_data_remote_CDerived_climate_daily ,overwrite){  

   if(verbose %in% c(TRUE,"Limited")){message(paste("     Creating climatologies and anomalies"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn daily data into pentadal data
   # Create directories if they don't already exist
   #---------------------------------------------------------------------------------
   subdir.product <- paste(dir_data_remote_CDerived_1climate,paste("anom",dataset,sep="_"),sep=sep)
   if(!dir.exists(subdir.product)){dir.create(subdir.product)}
   
   subdir.year <- paste(subdir.product,paste(minyear,maxyear,sep="_"),sep=sep)
   if(!dir.exists(subdir.year)){dir.create(subdir.year)}
   
   subdir.ANOM <- paste(subdir.year,paste("ANOMALY",sep="_"),sep=sep)
   if(!dir.exists(subdir.ANOM)){dir.create(subdir.ANOM)}
   
   subdir.CLIM <- paste(subdir.year,paste("CLIMATOLOGY",sep="_"),sep=sep)
   if(!dir.exists(subdir.CLIM)){dir.create(subdir.CLIM)}

   subdir.CLIM.daily   <-  paste(subdir.CLIM,"A_QC_data_daily",sep=sep)
   subdir.CLIM.pentad  <-  paste(subdir.CLIM,"B_QC_data_pentad",sep=sep)
   subdir.CLIM.dekad   <-  paste(subdir.CLIM,"C_QC_data_dekad",sep=sep)
   subdir.CLIM.month   <-  paste(subdir.CLIM,"D_QC_data_month",sep=sep)
   create <- sapply(c(subdir.CLIM.daily,subdir.CLIM.pentad,
                      subdir.CLIM.dekad,subdir.CLIM.month),conditionalcreate,silent=TRUE)
 
   subdir.ANOM.daily   <-  paste(subdir.ANOM,"A_QC_data_daily",sep=sep)
   subdir.ANOM.pentad  <-  paste(subdir.ANOM,"B_QC_data_pentad",sep=sep)
   subdir.ANOM.dekad   <-  paste(subdir.ANOM,"C_QC_data_dekad",sep=sep)
   subdir.ANOM.month   <-  paste(subdir.ANOM,"D_QC_data_month",sep=sep)
   create <- sapply(c(subdir.ANOM.daily,subdir.ANOM.pentad,
                      subdir.ANOM.dekad,subdir.ANOM.month),conditionalcreate,silent=TRUE)
   
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.anom <- list.files(subdir.ANOM)
   files_out.clim <- list.files(subdir.CLIM)
   
   files_in.daily    <- list.files(paste(dir_data_remote_BGeoTif_daily,dataset,sep=sep))
   files_in.daily    <- files_in.daily[grep(".tif",files_in.daily)]
   
   #------------------------------------------------------------------------------
   # Now make a date-list by extracting the date from the file.name
   #------------------------------------------------------------------------------
   date.list       <- as.Date(substr(files_in.daily,nchar(files_in.daily)-13,nchar(files_in.daily)-4),format="%Y-%m-%d")
   fulldatelist    <- suppressWarnings(makedates(date.list))
   DOYs <- sort(unique(fulldatelist$DOY366))
   
   #------------------------------------------------------------------------------
   # and calculate the output and save to a new file
   #------------------------------------------------------------------------------
   a <- Sys.time()
   res <- foreach(nnn = 1:nrow(fulldatelist)) %dopar% dailyclimatologies(nnn,fulldatelist,DOYs,
                                                                     dir_data_remote_BGeoTif_daily,
                                                                     subdir.CLIM.daily,subdir.ANOM.daily,
                                                                     dataset,files_in.daily,overwrite )
   print(Sys.time() -a)   
   #print(res)
}


#------------------------------------------------------------------------------------------
# Run the scripts, highlight everything and press Run-All (or command/ctrl Enter)
#------------------------------------------------------------------------------------------
for(n_data in seq_along(Daily_datasetlist)){
   dataset <- Daily_datasetlist[n_data]   
   
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   res <- makeanomalydailyclimate(dataset,minyear,maxyear,missinglimit,
                                 dir_data_remote_BGeoTif_daily,
                                 dir_data_remote_CDerived_1climate ,overwrite)

      
}


