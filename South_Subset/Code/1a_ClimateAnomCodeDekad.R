
#==========================================================================================================================
# dekad climatology: takes the raster mean and saves it to a new geotif, ignoring existing files
#==========================================================================================================================
dekadclimatologies<- function(nnn,dekad.list,dekads,dir_data_remote_BGeoTif_dekad, subdir.CLIM.dekad,subdir.ANOM.dekad,dataset,files_in.dekad,overwrite ){
   
   require(Greatrex.Functions)
   #------------------------------------------------------------------------------
   # get the dekad wanted and make the output file name
   #------------------------------------------------------------------------------
   dekadsindex <- dekads[nnn]
   
   inputkey <- as.numeric(substr(files_in.dekad,nchar(files_in.dekad)-5,nchar(files_in.dekad)-4))

   outputfileclim <- paste(subdir.CLIM.dekad,paste(dataset,"_dekadanom_",
                                               minyear,".",maxyear,".",
                                               sprintf("%03d",dekadsindex),".tif",sep=""),sep=sep)
   
   #------------------------------------------------------------------------------
   # if the outputfile exists, make the input filename
   #------------------------------------------------------------------------------
   if((overwrite==TRUE)|(!file.exists(outputfileclim))){
      
      subsetfiles <- files_in.dekad[which(inputkey %in%  dekad.list[dekad.list %in% dekadsindex])]
      
      inputfiles <- paste(dir_data_remote_BGeoTif_dekad,dataset,subsetfiles,sep=sep)
      
      if(length(inputfiles) > 2){
         datain <- stack(inputfiles,quick=TRUE)
         r.mean <- rasterstack_mean_fast(datain)
         r.anom <- datain-r.mean
         
         # write the mean to file

         writeRaster(r.mean, filename=outputfileclim, format="GTiff", overwrite=TRUE)
         
         # write the anomalies to file
         outputfiles <- paste(subdir.ANOM.dekad,paste(substr(subsetfiles,1,nchar(subsetfiles)-4),"_ANOM.tif",sep=""),sep=sep)
         
         for(ff in 1:length(inputfiles)){
            writeRaster(r.anom[[ff]], filename=outputfiles[ff], format="GTiff", overwrite=TRUE)
         }   
         
         
      }   
   }   
   return(outputfileclim)
}




makeanomalydekadclimate <-  function(dataset,minyear,maxyear,missinglimit,dir_data_remote_BGeoTif_dekad,dir_data_remote_CDerived_climate_dekad ,overwrite){  

   if(verbose %in% c(TRUE,"Limited")){message(paste("     Creating climatologies and anomalies"))}
   
   #---------------------------------------------------------------------------------
   # Function to turn dekad data into dekadal data
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

   subdir.CLIM.dekad   <-  paste(subdir.CLIM,"A_QC_data_dekad",sep=sep)
   subdir.CLIM.dekad  <-  paste(subdir.CLIM,"B_QC_data_dekad",sep=sep)
   subdir.CLIM.dekad   <-  paste(subdir.CLIM,"C_QC_data_dekad",sep=sep)
   subdir.CLIM.month   <-  paste(subdir.CLIM,"D_QC_data_month",sep=sep)
   create <- sapply(c(subdir.CLIM.dekad,subdir.CLIM.dekad,
                      subdir.CLIM.dekad,subdir.CLIM.month),conditionalcreate,silent=TRUE)
 
   subdir.ANOM.dekad   <-  paste(subdir.ANOM,"A_QC_data_dekad",sep=sep)
   subdir.ANOM.dekad  <-  paste(subdir.ANOM,"B_QC_data_dekad",sep=sep)
   subdir.ANOM.dekad   <-  paste(subdir.ANOM,"C_QC_data_dekad",sep=sep)
   subdir.ANOM.month   <-  paste(subdir.ANOM,"D_QC_data_month",sep=sep)
   create <- sapply(c(subdir.ANOM.dekad,subdir.ANOM.dekad,
                      subdir.ANOM.dekad,subdir.ANOM.month),conditionalcreate,silent=TRUE)
   
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_out.anom <- list.files(subdir.ANOM)
   files_out.clim <- list.files(subdir.CLIM)
   
   files_in.dekad    <- list.files(paste(dir_data_remote_BGeoTif_dekad,dataset,sep=sep))
   files_in.dekad    <- files_in.dekad[grep(".tif",files_in.dekad)]
   
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
   res <- foreach(nnn = 1:length(date.list)) %dopar% dekadclimatologies(nnn,dekad.list,dekads,
                                                                     dir_data_remote_BGeoTif_dekad,
                                                                     subdir.CLIM.dekad,subdir.ANOM.dekad,
                                                                     dataset,files_in.dekad,overwrite )
   print(Sys.time() -a)   
   #print(res)
}


#------------------------------------------------------------------------------------------
# Run the scripts, highlight everything and press Run-All (or command/ctrl Enter)
#------------------------------------------------------------------------------------------
for(n_data in seq_along(Dekad_datasetlist)){
   dataset <- Dekad_datasetlist[n_data]   
   
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   res <- makeanomalydekadclimate(dataset,minyear,maxyear,missinglimit,
                                 dir_data_remote_BGeoTif_dekad,
                                 dir_data_remote_CDerived_1climate ,overwrite)

      
}


