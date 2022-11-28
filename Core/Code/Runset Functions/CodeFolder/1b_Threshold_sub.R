

#--------------------------------------------------------------
# Make dekadal thresholds
#--------------------------------------------------------------
MakeThresholdsDekad <- function(nnn,dir_data_remote_BGeoTif_dekad,
                           dataset,files_in.dekad,sep,subdir.thresh.data,
                           levels.Dekadal,overwrite){
   
   file_in=files_in.dekad[nnn]
   filein <- paste(dir_data_remote_BGeoTif_dekad,dataset,file_in,sep=sep)
   dataout <- datain <- rast(filein)
   
   conditionalcreate(paste(subdir.thresh.data,unlist(lapply(strsplit(file_in,sep),"[",1)),sep=sep))
   
   filesout <- paste(subdir.thresh.data,sep,
                     substr(file_in,1,nchar(file_in)-10),
                     "Thresh",sprintf("%02d",levels.Dekadal),"_",
                     substr(file_in,nchar(file_in)-9,nchar(file_in)),sep="")
   
   for(L in seq_along(levels.Dekadal)){
   #   if(as.numeric(minmax(datain)[2]) > levels.Dekadal[L]|0){
         dataout[datain > levels.Dekadal[L]] <- 1
         dataout[datain <= levels.Dekadal[L]] <- 0        
   # }
      if((overwrite == TRUE)|(!file.exists(filesout[L]))){
         suppressMessages(suppressWarnings(terra::writeRaster(round(dataout,3), filename=filesout[L], filetype="GTiff",overwrite=TRUE)))
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(filesout[L],".aux.json",sep="")))))
      }   
   } 
   
   return(filein)
}

#--------------------------------------------------------------
# Make monthly thresholds
#--------------------------------------------------------------
MakeThresholdsMonth <- function(nnn,dir_data_remote_BGeoTif_month,
                           dataset,file_in,sep,subdir.thresh.data,
                           levels.Month,overwrite){
   
   filein <- paste(dir_data_remote_BGeoTif_month,dataset,file_in,sep=sep)
   dataout <- datain <- rast(filein)
   
   conditionalcreate(paste(subdir.thresh.data,unlist(lapply(strsplit(file_in,sep),"[",1)),sep=sep))
   
   
   filesout <- paste(subdir.thresh.data,sep,
                     substr(file_in,1,nchar(file_in)-10),
                     "Thresh",sprintf("%02d",levels.Month),"_",
                     substr(file_in,nchar(file_in)-9,nchar(file_in)),sep="")
   
   for(L in seq_along(levels.Month)){
      dataout[datain > levels.Month[L]] <- 1
      dataout[datain <= levels.Month[L]] <- 0
      if((overwrite == TRUE)|(!file.exists(filesout[L]))){
         suppressMessages(suppressWarnings(terra::writeRaster(round(dataout,3), filename=filesout[L], filetype="GTiff",overwrite=TRUE)))
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(filesout[L],".aux.json",sep="")))))
      }   
   } 
   
   return(filein)
}