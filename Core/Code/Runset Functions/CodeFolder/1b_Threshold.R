
#------------------------------------------------------------------------------------
# DEKAD SCRIPTS
#------------------------------------------------------------------------------------
Dekad_datasetlist <- Dekad_datasetlist[grep("_rain_",Dekad_datasetlist)]



for(n_data in seq_along(Dekad_datasetlist)){
   #------------------------------------------------------------------------------
   # Choose Data
   #------------------------------------------------------------------------------
   dataset <- Dekad_datasetlist[n_data]  
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   #------------------------------------------------------------------------------
   # Make an output directory
   #------------------------------------------------------------------------------
   subdir.thresh.data <- paste(dir_data_remote_CDerived_dekad_thresh,dataset,sep="/")
   conditionalcreate(subdir.thresh.data)
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_in.dekad    <- list.files(paste(dir_data_remote_BGeoTif_dekad,dataset,sep=sep),recursive = TRUE,pattern=".tif")

   #------------------------------------------------------------------------------
   # Find thresholds and save
   #------------------------------------------------------------------------------
   a <- Sys.time()
   res <- foreach(nnn = 1:length(files_in.dekad)) %dopar%  MakeThresholdsDekad(nnn,dir_data_remote_BGeoTif_dekad,
                                                                  dataset,files_in.dekad,
                                                                  sep,subdir.thresh.data,
                                                                  levels.Dekadal,overwrite)
   print(Sys.time() -a)   
  
 }


#------------------------------------------------------------------------------------
# MONTH SCRIPTS
#------------------------------------------------------------------------------------
Month_datasetlist <- Month_datasetlist[grep("_rain_",Month_datasetlist)]
for(n_data in seq_along(Month_datasetlist)){
   #------------------------------------------------------------------------------
   # Choose Data
   #------------------------------------------------------------------------------
   dataset <- Month_datasetlist[n_data]  
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   #------------------------------------------------------------------------------
   # Make an output directory
   #------------------------------------------------------------------------------
   subdir.thresh.data <- paste(dir_data_remote_CDerived_month_thresh,dataset,sep="/")
   if(!dir.exists(subdir.thresh.data)){dir.create(subdir.thresh.data)}
   
   #------------------------------------------------------------------------------
   # And find out the existing files
   #------------------------------------------------------------------------------
   files_in.month    <- list.files(paste(dir_data_remote_BGeoTif_month,dataset,sep=sep),recursive = TRUE,pattern=".tif")

   #------------------------------------------------------------------------------
   # Find thresholds and save
   #------------------------------------------------------------------------------
   a <- Sys.time()
   res <- foreach(nnn = 1:length(files_in.month)) %dopar%  MakeThresholdsMonth(nnn,dir_data_remote_BGeoTif_month,
                                                                          dataset,file_in=files_in.month[nnn],
                                                                          sep,subdir.thresh.data,
                                                                          levels.Month,overwrite)
   print(Sys.time() -a)   
   
}


# ADD IN DAILY AND PENTADAL
