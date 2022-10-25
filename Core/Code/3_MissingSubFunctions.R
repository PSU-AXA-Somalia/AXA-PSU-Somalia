#--------------------------------------------------------------------
# Find replace missing
#--------------------------------------------------------------------

#---------------------------------------------------------------------
# Variety of ways to fill missing data
#---------------------------------------------------------------------
replacemissing <- function(missingdate,dataset,family,iridl,iri,dir_data_remote_BGeoTif_daily,dir_data_remote_ARaw_missing){
   
   #---------------------------------------------------------------------
   # print warning 
   #---------------------------------------------------------------------
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n ----------\n Replacing missing day:",
                                                    dataset,",",
                                                    missingdate,"\n"))}
   
   continue <- TRUE

   
   #---------------------------------------------------------------------
   # Try the IRI route as needed
   #---------------------------------------------------------------------
   if((is.na(iri)==FALSE)&(iridl==TRUE)&(grepl("iridl",iri))){
      
      # Set up the download filename
      file.name<-paste(dir_data_remote_ARaw_missing,paste(dataset,"_",missingdate,".nc",sep=""),sep="/")
      
      # If the file has not been downloaded already
      if(!file.exists(file.name)){
         
         # See how the IRI data library sets up the files
         prexyaddress <- iri
         if(verbose %in% c(TRUE,"Limited")){message(paste("\n ----------\n Downloading from IRI"))}
                                                          
         # The IRI uses different formats for different products 
         type1 <- c("ARC","RFE","CHIRP","CHIRTS")
         if(grepl(paste(type1, collapse="|"),iri)){type=1}
         type2 <- c("TAMSAT")
         if(grepl(paste(type2, collapse="|"),iri)){type=2}
         # it will not run for non IRIDL addresses
         
         ## NEED TAMSAT Rain
         if(type==1){
            timestuff <- paste("T/%28", as.numeric(format.Date(missingdate,"%d")),
                               "%20"  , format.Date(missingdate,"%b"), 
                               "%20"  , as.numeric(format.Date(missingdate,"%Y")), 
                               "%29VALUES",sep="")
            fulladdress <- paste(prexyaddress,"/",timestuff,"/","data.nc",sep="")
         }
         if(type==2){
            timestuff <- format.Date(missingdate,"%Y%m%d")
            timestuff <- paste("T/%28", as.numeric(format.Date(missingdate,"%d")),
                               "%20"  , format.Date(missingdate,"%b"), 
                               "%20"  , as.numeric(format.Date(missingdate,"%Y")), 
                               "%29VALUES",sep="")
            fulladdress <- paste(prexyaddress,"/",timestuff,"/","data.nc",sep="")
         }
         
         download.file(fulladdress,file.name,quiet=FALSE,method="auto")
         print(file.name)
      }else{
         if(verbose %in% c(TRUE,"Limited")){message(paste("\n ----------\n Already downloaded"))}
         
      }
      
      r <- suppressWarnings(raster(file.name))
      suppressWarnings(crs(r) <- paste("EPSG:",globalcrs,sep=""))
      
      if(tolower(family) %in% c("tmin" ,"tmax")){
         r[r < -90] <- NA
         r[r > 300] <- NA
         
      }else{
         r[r < 0] <- NA
      }

      # maybe the entire file is blank, if so fill another way
      if(length(unique(values(r)))<=1){
         if(verbose %in% c(TRUE,"Limited")){message(paste("       Downloaded file blank"))}
         continue <- TRUE
      }else{
         # if there is data, go ahead and save
         
         
         file_loc.out <- paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),
                               paste(dataset,"_",missingdate,".tif",sep=""),sep=sep) 
         if(family %in% c("rain","tmin","tmax","rhum")){
            suppressMessages(suppressWarnings(terra::writeRaster(round(r,1), filename=file_loc.out, filetype="GTiff",overwrite=TRUE)))
         }else{
            suppressMessages(suppressWarnings(terra::writeRaster(r, filename=file_loc.out, filetype="GTiff",overwrite=TRUE)))
         }
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(file_loc.out,".aux.xml",sep="")))))
         missingdays[d,"missing"] <- FALSE
         missingdays[d,"Sat"] <- paste(Daily_datasetlist$Stem[n_data],"_",
                                       missingdate,".tif",sep="")
         continue <- FALSE
         return("IRIDL")
      }
      
   }   

   #---------------------------------------------------------------------
   # Otherwise fill. Could also use the TAMSAT/CHIRPS fill approach.
   #---------------------------------------------------------------------
   if(continue==TRUE){
      if(verbose %in% c(TRUE,"Limited")){message(paste("       Filling with bad fill"))}
      #---------------------------------------------------------------------
      # Try taking the before/after average. You can speed up with Terra, but
      # rubbish fill
      #---------------------------------------------------------------------
      flag.prev <- FALSE
      flag.next <- FALSE
      
      # Look for the day before
      before <- paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),paste(dataset,"_",(missingdate-1),".tif",sep=""),sep=sep)
      if(file.exists(before)){
         r.prev <- suppressWarnings(raster(before))
         flag.prev <- TRUE
      }
      
      # Look for the day after
      after <- paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),paste(dataset,"_",(missingdate+1),".tif",sep=""),sep=sep)
      if(file.exists(after)){
         r.next <- suppressWarnings(raster(after))
         flag.next <- TRUE
      }
      
      # If they are both true, take the average
      if((flag.prev==TRUE)&(flag.next==TRUE)){
         r <- calc(stack(r.prev,r.next),mean,na.rm=TRUE)
         fname <- paste(dataset,"_",missingdate,".tif",sep="")
         if(family %in% c("rain","tmin","tmax","rhum")){
            raster::writeRaster(round(r,1),paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),format="GTiff",overwrite=TRUE)
         }else{
            raster::writeRaster(r,paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),format="GTiff",overwrite=TRUE)
         }
            a<-try(suppressMessages(suppressWarnings(file.remove(paste(paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),".aux.xml",sep="")))))
         if(verbose %in% c(TRUE,"Limited")){message( "       Filling using average of prev and next")}
         return("Prev-Next")
      }
      
      # If one of them is true, take the previous day
      if(flag.prev==TRUE){
         fname <- paste(dataset,"_",missingdate,".tif",sep="")
         if(family %in% c("rain","tmin","tmax","rhum")){
            raster::writeRaster(round(r.prev,1),paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),format="GTiff",overwrite=TRUE)
         }else{
            raster::writeRaster(r.prev,paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),format="GTiff",overwrite=TRUE)
         }         
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),".aux.xml",sep="")))))
         if(verbose %in% c(TRUE,"Limited")){message( "       Filling using previous day")}
         return("Prev")
      }
      # If one of them is true, take the next day
      if(flag.next==TRUE){
         if(verbose %in% c(TRUE,"Limited")){message( "       Filling using next day")}
         fname <- paste(dataset,"_",missingdate,".tif",sep="")
         if(family %in% c("rain","tmin","tmax","rhum")){
            raster::writeRaster(round(r.next,1),paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),format="GTiff",overwrite=TRUE)
         }else{
            raster::writeRaster(r.next,paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),format="GTiff",overwrite=TRUE)
         } 
         a<-try(suppressMessages(suppressWarnings(file.remove(paste(
            paste(dir_data_remote_BGeoTif_daily,dataset,format.Date(missingdate,"%Y"),fname,sep=sep),".aux.xml",sep="")))))
         
         return("Next")
      }
      if((flag.prev==FALSE)&(flag.next==FALSE)){
         return(FALSE)
      }   
   }   
}







