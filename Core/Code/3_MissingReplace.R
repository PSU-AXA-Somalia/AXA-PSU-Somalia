runmissing <- TRUE
names(Data_Meta)[3] <- "Satellite"
Data_Meta$Stem <- paste(Data_Meta$Family,Data_Meta$Satellite,as.numeric(Data_Meta$Version),sep="_")
Daily_datasetlist  <- data.frame(Dataset = Daily_datasetlist, Stem=NA)
Daily_datasetlist$Stem <- substr(Daily_datasetlist$Dataset,1,(unlist(lapply(gregexpr('_', Daily_datasetlist$Dataset),"[",3))-1))
Daily_datasetlist <- suppressWarnings(merge(Daily_datasetlist,Data_Meta,by="Stem",all.x=TRUE,all.y=FALSE))
#Daily_datasetlist <- Daily_datasetlist[-5,]


#---------------------------------------------------------------------------------
# MAIN CODE, st up the IRI files and connect to the subfolders
#---------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
# Create the record of missing data from the 1_RawGeoTifs folder
# For each product
#
# Now look through each dataset for missing data
#---------------------------------------------------------------------------------
if(verbose %in% c(TRUE,"Limited")){message(paste("     filling missing data"))}

for(n_data in 1:nrow(Daily_datasetlist)){

   #-----------------------------------------------------------------------------
   # Set up metadata
   #-----------------------------------------------------------------------------
   stem        <- Daily_datasetlist$Stem[n_data]
   family         <- Daily_datasetlist$Family[n_data]
   version        <- Daily_datasetlist$Version[n_data]
   modified       <- Daily_datasetlist$Modified[n_data]
   dataset        <- Daily_datasetlist$Dataset[n_data]  
   iri            <- Daily_datasetlist$IRIStem[n_data]  
   Satellite      <- Daily_datasetlist$Satellite[n_data]  
   satenddate     <- Daily_datasetlist$Enddate[n_data]  
   
   if(grepl("/",satenddate)){
      satenddate <- as.Date(satenddate,format="%m/%d/%y")
   }else{
      satenddate <- as.Date(satenddate)
   }
   if(verbose %in% c(TRUE,"Limited")){message(paste("         ",stem))}
   
   
   geo_stem <- paste(dir_data_remote_BGeoTif_daily,dataset,sep="/")
   raw_stem <- paste(dir_data_remote_ARaw_missing)
   
   #-----------------------------------------------------------------------------
   # Get files in the GeoFolder and get the dates from them
   #-----------------------------------------------------------------------------
   data_available <- list.files(geo_stem,recursive=TRUE)
   # remove any spurious tif/aux files
   suppressWarnings(suppressMessages(file.remove(list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE)[
                                                                          grep("tif.aux",list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE))])))
   suppressWarnings(suppressMessages(file.remove(list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE)[
      grep(".aux.json",list.files(geo_stem,recursive=TRUE,full.names=TRUE,include.dirs =TRUE))])))

   data_available <- list.files(geo_stem,recursive=TRUE)
   data_available <- data_available[grep(".tif",data_available)]
   
   
      
   date.list  <-  data.frame(Date=as.Date(substr(data_available,nchar(data_available)-13, nchar(data_available)-4),format="%Y-%m-%d"),
                             Sat=data_available)
   date.list$missing <- FALSE
   
   #-----------------------------------------------------------------------------
   # Make a list of dates to compare to using the option chosen in the script
   #-----------------------------------------------------------------------------
   if(tolower(missingchoice) %in% "data"){
      startdate <- min(date.list$Date)
      enddate <- max(date.list$Date)
   }else{
      if(tolower(missingchoice) %in% "year"){
         startdate <- as.Date(paste(format.Date(min(date.list$Date), "%Y"),"-01-01",sep=""))
         enddate   <- as.Date(paste(format.Date(max(date.list$Date), "%Y"),"-12-31",sep=""))
      }else{
         if(tolower(missingchoice) %in% "all"){
            startdate <- as.Date(paste(format.Date(min(date.list$Date), "%Y"),"-01-01",sep=""))
            enddate   <- Sys.Date()
         }else{
            stop(paste("I do not understand missingchoice option:",missingchoice,"\n Please choose data, year or all in quote marks"))
         } 
      }
   }
   
   if(!(is.na(satenddate))&enddate>as.Date(satenddate)){
      enddate <- as.Date(satenddate)
   }
   enddate <- as.Date(enddate)
   startdate <- as.Date(startdate)
   #-----------------------------------------------------------------------------
   # Merge and check
   #-----------------------------------------------------------------------------
   fulldatelist <-  data.frame(Date=seq(startdate,enddate,by="d"))
   fulldatelist <-  merge(fulldatelist,date.list,by="Date",all.x=TRUE)
   fulldatelist$missing[is.na(fulldatelist$missing)] <- TRUE
   
   #-----------------------------------------------------------------------------
   # If there are missing days move forwards
   #-----------------------------------------------------------------------------
   if(length(which(fulldatelist$missing == TRUE))>0){
      
      missingdays <- fulldatelist[fulldatelist$missing %in% TRUE,]
      missingdays$Sat <- dataset
      #-----------------------------------------------------------------------------
      # I DON'T want to download data I know for sure is missing, except I won't cause I'm going to fill it here
      #-----------------------------------------------------------------------------
      
      # Fill using the IRI DL or other dataset, or a simple before/after
      for(d in 1:nrow(missingdays)){
         missingdate <- missingdays$Date[d]
         missingdays$missing[d] <- replacemissing(missingdate,dataset,family,iridl,iri,
                                               dir_data_remote_BGeoTif_daily,
                                               dir_data_remote_ARaw_missing)
         
         
            
      }   
      
      missingfilerecord <- paste(dir_data_remote_ARaw_missing,"MissingData.csv",sep=sep)
      if(file.exists(missingfilerecord)){
         missingrecord <- fread(missingfilerecord)
         missingrecord$Date <- as.Date(missingrecord$Date)
         dups <- which(paste(missingrecord$Sat,missingrecord$Date) %in% paste(missingdays$Sat,missingdays$Date))
         if(length(dups)>0){missingrecord <- missingrecord[-dups,]}
         missingrecord <- rbind(missingrecord,missingdays)
         fwrite(missingrecord,missingfilerecord)
      }else{
         fwrite(missingdays,missingfilerecord)
      }
   }

}  
   
   
   
   