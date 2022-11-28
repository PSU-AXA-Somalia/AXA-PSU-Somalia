
source(paste(dir_code,"3b_TemporalSumFunctionsSub.R",sep=sep))


#=================================================================================
# This creates the temporal sum of all the data
#=================================================================================

#set up if you skipped the missing code
if(!( "runmissing" %in% ls())){
   names(Data_Meta)[3] <- "Satellite"
   Data_Meta$Stem <- paste(Data_Meta$Family,Data_Meta$Satellite,as.numeric(Data_Meta$Version),sep="_")
   Daily_datasetlist  <- data.frame(Dataset = Daily_datasetlist, Stem=NA)
   Daily_datasetlist$Stem <- substr(Daily_datasetlist$Dataset,1,(unlist(lapply(gregexpr('_', Daily_datasetlist$Dataset),"[",3))-1))
   Daily_datasetlist <- suppressWarnings(merge(Daily_datasetlist,Data_Meta,by="Stem",all.x=TRUE,all.y=FALSE))
}


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