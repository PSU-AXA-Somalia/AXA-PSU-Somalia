
# this code is linked to Step2a_Crop_To_Runset.R in the main code folder.

#---------------------------------------------------------------------------------
# Set up file structures
#---------------------------------------------------------------------------------
 products_daily  <-  list.files(dir_data_remote_BGeoTif_daily_regrid_10,pattern="_")
 products_pentad <-  list.files(dir_data_remote_BGeoTif_pentad,pattern="_")
 products_dekad  <-  list.files(dir_data_remote_BGeoTif_dekad,pattern="_")
 products_month  <-  list.files(dir_data_remote_BGeoTif_month,pattern="_")

 if("pentad_README" %in% products_pentad) { 
   products_pentad <- products_pentad[-which(products_daily %in% "pentad_README")]
 }
 
 
#---------------------------------------------------------------------------------
# Create Runset folder name
#---------------------------------------------------------------------------------
 if(is.na(Runset)){
  if(Option == 1){
    Runset <- paste("BOX",round(MinLong,3),round(MaxLong,3),
                    round(MinLat,3),round(MaxLat,3),sep="_") 
  }else{
    if(is.na(column_value)){
      Runset <- paste(Shapefile.Name,croptype,sep="_")
    }else{
      Runset <- paste(column_value,croptype,sep="_")
    }
  }
 }


#---------------------------------------------------------------------------------
# And create main folder
#---------------------------------------------------------------------------------
 dir_runset     <- paste(dir_main,"Runset",Runset,sep=sep)
 conditionalcreate(dir_runset)
 if(verbose){message(paste("Setting up file structures in",dir_runset))}

#---------------------------------------------------------------------------------
# Check that the output folders don't have special names
#---------------------------------------------------------------------------------
 if(is.na(override_analysisfoldername==FALSE)){
   dir_analysis_raw    <- paste(dir_runset,runset_foldername_rawoutput,sep=sep)
 }else{
   if(verbose){message(paste("Overriding output folder names"))}
   dir_analysis_raw    <- paste(dir_runset,override_analysisfoldername,sep=sep)
   runset_foldername_rawoutput <- override_analysisfoldername
 } 

 if(is.na(override_visualisationfoldername==FALSE)){
   dir_analysis_vis    <- paste(dir_runset,runset_foldername_visualise,sep=sep)
 }else{
   if(verbose){message(paste("Overriding visualisation folder names"))}
   dir_analysis_vis    <- paste(dir_runset,override_visualisationfoldername,sep=sep)
   runset_foldername_visualise <-  override_visualisationfoldername 
 } 

 if(verbose){message("  1. Creating runset parameters, saved as Step0_Runset_Parameters.R")}

#---------------------------------------------------------------------------------
# Read in and store runset parameters, editing as necessary
#---------------------------------------------------------------------------------
LocalParamsWrapper <- readLines("Step0_Global_Parameters.R")

# Show what runset it is
 LocalParamsWrapper[[3]] <- paste("# RUNSET PARAMETERS, Runset name:",Runset)

# Add in date updated
LocalParmsLine3 <- grep("runsetparamdate_DONOTDELETE",LocalParamsWrapper)
LocalParamsWrapper[LocalParmsLine3] <- paste("runsetparams_lastupdated <- as.Date(\"",Sys.Date(),"\")",sep="")

# Add in new setupfile updated
LocalParmsLine4 <- grep("Step0_Global_SetUp",LocalParamsWrapper)
LocalParamsWrapper[LocalParmsLine4] <- str_replace(LocalParamsWrapper[LocalParmsLine4],"Step0_Global_SetUp","Step0_Runset_SetUp")


# write out full thing  
write_lines(LocalParamsWrapper[[1]],file=paste(dir_runset,"Step0_Runset_Parameters.R",sep=sep))
for (m in 2:length(LocalParamsWrapper)){
   write_lines(LocalParamsWrapper[[m]],file=paste(dir_runset,"Step0_Runset_Parameters.R",sep=sep),append=TRUE)
}  


#---------------------------------------------------------------------------------
# Read in and store runset setup, editing as necessary
#---------------------------------------------------------------------------------
LocalParams        <- readLines("Step0_Global_SetUp.R")

# Switch core to runset name
projfile <- list.files(dir_core)[grep(".rproj",tolower(list.files(dir_core)))]
newprojfile <- paste("Step0_",Runset,"PROJECT.Rproj",sep="")

LocalParmsLineproj <- grep(projfile,LocalParams)
for(L in 1:length(LocalParmsLineproj)){
   LocalParams[LocalParmsLineproj[L]] <- str_replace(LocalParams[LocalParmsLine4],projfile,newprojfile)
}

LocalParmsLineproj <- grep("dir_main",LocalParams)
LocalParams[LocalParmsLineproj[1]] <- "  dir_main <- substr(getwd(),start=1,stop=nchar(getwd()))"


 # Switch core to runset name
  LocalParams[min(grep("dir_core",LocalParams))] <- paste("dir_core        <- dir_main,", "\"","../../Core", "\"",",sep=sep" ,sep="")
  LocalParams[min(grep("dir_runset",LocalParams))] <- paste("dir_runset        <- dir_main,", "\"","../Runset", "\"",",sep=sep" ,sep="")
  
 # Makr runset output folders
  LocalParmsLine1 <- grep("runset_foldername_rawoutput",LocalParams)
  LocalParams[LocalParmsLine1] <- paste("dir_analysis_raw <- paste(dir_main, \"",runset_foldername_rawoutput," \",sep=sep)",sep="")

  LocalParmsLine2 <- grep("runset_foldername_visualise",LocalParams)
  LocalParams[LocalParmsLine2] <- paste("dir_analysis_vis <- paste(dir_main, \"",runset_foldername_visualise," \",sep=sep)",sep="")

  
# write out full thing  
write_lines(LocalParams[[1]],file=paste(dir_runset,"Step0_Runset_Setup.R",sep=sep))
for (m in 2:length(LocalParams)){
  write_lines(LocalParams[[m]],file=paste(dir_runset,"Step0_Runset_Setup.R",sep=sep),append=TRUE)
}  


#---------------------------------------------------------------------------------
# Move the existing analysis folder if it exists and you want to save
# ONLY DOES THIS IF THERE IS DATA!
#---------------------------------------------------------------------------------
if(SaveAnalysis == TRUE){
  if(verbose){message("  2. Looking for old analysis to save from deletion")}
  if(dir.exists(dir_runset)){
    # IF there is analysis already done, copy it
    if(length(list.files(dir_analysis_raw))>0){
      newfolder <- paste(dir_analysis_raw,"OLD",Sys.Date(),sep="_")
      nn=1
      while(dir.exists(newfolder)){
        newfolder <- paste(newfolder,n,sep="_")
        nn=nn+1
        if(nn > 5){warning("You have 5 back up data folders, not a good way of storing your data")}
        if(nn > 10){stop("You have 10 back up data folders, sort out your data storage")}
      }
      if(verbose){message(paste("     a) Old raw output found, moving to subfolder:",newfolder))}
      file.rename(dir_analysis_raw,newfolder)
    }
    if(length(list.files(dir_analysis_vis))>0){
      newfolder <- paste(dir_analysis_vis,"OLD",Sys.Date(),sep="_")
      nn=1
      while(dir.exists(newfolder)){
        newfolder <- paste(newfolder,n,sep="_")
        nn=nn+1
        if(nn > 5){warning("You have 5 back up data folders, not a good way of storing your data")}
        if(nn > 10){stop("You have 10 back up data folders, sort out your data storage")}
      }
      if(verbose){message(paste("     a) Old visualisation found, moving to subfolder:",newfolder))}
      file.rename(dir_analysis_vis,newfolder)
    }        
  }  
}

#---------------------------------------------------------------------------------
# And create the folder, then move over the directory structure
#---------------------------------------------------------------------------------
if(verbose){message("  3. Creating subfolders")}

conditionalcreate(dir_analysis_raw)
conditionalcreate(dir_analysis_vis)

alldirs <- ls()
alldirs <- alldirs[ grep("dir_",alldirs)]
alldirs <- alldirs[-grep("dir_main",alldirs)]
alldirs <- alldirs[-grep("dir_core",alldirs)]
alldirs <- alldirs[-grep("dir_runset",alldirs)]
alldirs <- alldirs[-grep("dir_data_remote_ARaw",alldirs)]
alldirs <- sort(alldirs)

fin <- length(alldirs)
for(dir_count in 1:fin){
  #print(dir_count)
  dirnew <- eval(parse(text = alldirs[dir_count]))
  dirout <- str_replace(dirnew,"Core",paste("Runset",Runset,sep=sep))
  conditionalcreate(dirout)
  
  if(alldirs[dir_count] %in% "dir_data_remote_BGeoTif_daily"){
    for(p in products_daily){
      dirinprod <- paste(dir_data_remote_BGeoTif_daily,p,sep=sep)
      diroutprod <- str_replace(dirinprod,"Core",paste("Runset",Runset,sep=sep))
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
  if(alldirs[dir_count] %in% "dir_data_remote_BGeoTif_pentad"){
    for(p in products_pentad){
      dirinprod <- paste(dir_data_remote_BGeoTif_pentad,p,sep=sep)
      diroutprod <- str_replace(dirinprod,"Core",paste("Runset",Runset,sep=sep))
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
  if(alldirs[dir_count] %in% "dir_data_remote_BGeoTif_dekad"){
    for(p in products_dekad){
      dirinprod <- paste(dir_data_remote_BGeoTif_dekad,p,sep=sep)
      diroutprod <- str_replace(dirinprod,"Core",paste("Runset",Runset,sep=sep))
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
  if(alldirs[dir_count] %in% "dir_data_remote_BGeoTif_month"){
    for(p in products_month){
      dirinprod <- paste(dir_data_remote_BGeoTif_month,p,sep=sep)
      diroutprod <- str_replace(dirinprod,"Core",paste("Runset",Runset,sep=sep))
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
}

#---------------------------------------------------------------------------------
# and set up runset versions of the main directories
#---------------------------------------------------------------------------------
dir_data_remote_BGeoTif_daily_runset  <- dir_data_remote_BGeoTif_daily
dir_data_remote_BGeoTif_pentad_runset <- dir_data_remote_BGeoTif_pentad
dir_data_remote_BGeoTif_dekad_runset  <- dir_data_remote_BGeoTif_dekad
dir_data_remote_BGeoTif_month_runset  <- dir_data_remote_BGeoTif_month

dir_data_remote_BGeoTif_daily_runset  <- str_replace(dir_data_remote_BGeoTif_daily_runset,"Core",paste("Runset",Runset,sep=sep))
dir_data_remote_BGeoTif_pentad_runset <- str_replace(dir_data_remote_BGeoTif_pentad_runset,"Core",paste("Runset",Runset,sep=sep))
dir_data_remote_BGeoTif_dekad_runset  <- str_replace(dir_data_remote_BGeoTif_dekad_runset,"Core",paste("Runset",Runset,sep=sep))
dir_data_remote_BGeoTif_month_runset  <- str_replace(dir_data_remote_BGeoTif_month_runset,"Core",paste("Runset",Runset,sep=sep))


if(verbose){message("  4. Loading global spatial meta data")}

#---------------------------------------------------------------------------------
# Read in test file from the main folder to get crs & check if there is data 
# Needlessly complex so that it autochooses a folder with data in
#---------------------------------------------------------------------------------
movedata <- TRUE


#---------------------------------------------------------------------------------
# Look for daily files that exist
#---------------------------------------------------------------------------------
# list all the files in each product folder
prod_count_daily=1 ; flag_daily <- FALSE
tmpfiles <- list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[prod_count_daily],sep=sep))
tmpfiles <- tmpfiles[grep(".tif",tmpfiles)]
# See if that folder is empty and move on
while((length(tmpfiles) <=0) & (flag_daily ==FALSE)){
  prod_count_daily <- prod_count_daily+1
  if(prod_count_daily >= length(products_daily)){
    flag_daily <- TRUE;warning("No Daily Data found for any product")
  }
} 


if(flag_daily == TRUE){
  #---------------------------------------------------------------------------------
  # Look for pentadal files
  #---------------------------------------------------------------------------------
  # list all the files in each product folder
  prod_count_pentad=1 ; flag_pentad <- FALSE
  tmpfiles2 <- list.files(paste(dir_data_remote_BGeoTif_pentad,products_daily[prod_count_pentad],sep=sep))
  tmpfiles2 <- tmpfiles2[grep(".tif",tmpfiles2)]
  # See if that folder is empty and move on
  while((length(tmpfiles2) <=0) & (flag_pentad ==FALSE)){
    prod_count_pentad <- prod_count_pentad+1
    if(prod_count_pentad >= length(products_pentad)){flag_pentad <- TRUE;warning("No Pentad Data Found for any product")}
  } 
  
  if(flag_pentad == TRUE){
    # Look for dekadal files
    prod_count_dekad=1 ; flag_dekad <- FALSE
    tmpfiles3 <- list.files(paste(dir_data_remote_BGeoTif_dekad,products_dekad[prod_count_dekad],sep=sep))
    tmpfiles3 <- tmpfiles3[grep(".tif",tmpfiles3)]
    while((length(tmpfiles3)<=0) & (flag_dekad ==FALSE)){
      prod_count_dekad <- prod_count_dekad+1; print(prod_count_dekad) ; 
      if(prod_count_dekad >= length(products_dekad)){flag_dekad <- TRUE; warning("No Dekadal Data found for any product")}
    } 
    
    if(flag_dekad == TRUE){
      # Look for monthly files
      prod_count_month=1 ; flag_month <- FALSE
      tmpfiles4 <- list.files(paste(dir_data_remote_BGeoTif_month,products_month[prod_count_month],sep=sep))
      tmpfiles4 <- tmpfiles4[grep(".tif",tmpfiles4)]
      while((length(tmpfiles4)<=0) & (flag_month ==FALSE)){
        q <- q+1; print(q) ; 
        if(p >= length(products_dekad)){
          flag_month <- TRUE; warning("No data found for at all! NO DATA IS BEING MOVED. THIS IS BAD")
          movedata <- FALSE
        }
        
      } 
    }      
  }
}


#---------------------------------------------------------------------------------
# Now see if our chosen files are valid
#---------------------------------------------------------------------------------
if(flag_daily==FALSE){
  #---------------------------------------------------------------------------------
  # If daily data was found
  #---------------------------------------------------------------------------------
  if(verbose){message("  5. Loading daily global meta data")}
  flag_read <- FALSE; file_count <- 1
  
  repeat{
    # find a file that is valid
    if(file_count > 1000){
      warningmessage <- paste("The auto-chosen folder did not have data (bad) \n 1. Please type file.choose() into the console including parentheses & press Enter, \n 2. Choose ANY .tif file from a subfolder of: \n",dir_data_remote_BGeoTif,"\n 3. Press open to print the location into the console,\n 4. Copy/paste the ENTIRE PATH AND FILE NAME into override_spatialmeta\n    e.g. override_spatialmeta <- LOCATION_ON_YOUR_COMPUTER",sep,"Filename",sep="")
      stop(warningmessage, call. = FALSE)      
    }  
    options(show.error.messages = FALSE)
    samplefile <- try(raster( paste(dir_data_remote_BGeoTif_daily,products_daily[prod_count_daily],tmpfiles[file_count],sep=sep)),silent=TRUE)
    options(show.error.messages = TRUE)
    file_count <- file_count+1
    if(class(samplefile) %in% "try-error"){
      warningmessage <- paste("Not a geotif/corrupted:",tmpfiles[file_count-1],"Next!") 
      print(warningmessage) 
      next
    }else{
      if(is.na(st_crs(samplefile))){
        warningmessage <- paste("No CRS:",tmpfiles[file_count-1],"Next!") 
        print(warningmessage) 
        next
      }else{
        if(verbose){message(paste("Reading in file:",tmpfiles[file_count-1],"to gather meta data") )}
        flag_read <- TRUE
        break
      }        
    }  
  }
  
}else{
  if(flag_pentad==FALSE){
    #---------------------------------------------------------------------------------
    # If pentadal data was found
    #---------------------------------------------------------------------------------
    if(verbose){message("  5. Loading pentadal global meta data")}
    
    flag_read <- FALSE; file_count <- 1
    
    repeat{
      # find a file that is valid
      if(file_count > 1000){
        warningmessage <- paste("The auto-chosen folder did not have data (bad) \n 1. Please type file.choose() into the console including parentheses & press Enter, \n 2. Choose ANY .tif file from a subfolder of: \n",dir_data_remote_BGeoTif,"\n 3. Press open to print the location into the console,\n 4. Copy/paste the ENTIRE PATH AND FILE NAME into override_spatialmeta\n    e.g. override_spatialmeta <- LOCATION_ON_YOUR_COMPUTER",sep,"Filename",sep="")
        stop(warningmessage, call. = FALSE)      
      }  
      options(show.error.messages = FALSE)
      samplefile <- try(raster( paste(dir_data_remote_BGeoTif_pentad,products_pentad[prod_count_pentad],tmpfiles2[file_count],sep=sep)),silent=TRUE)
      options(show.error.messages = TRUE)
      file_count <- file_count+1
      
      if(class(samplefile) %in% "try-error"){
        warningmessage <- paste("Not a geotif/corrupted:",tmpfiles2[file_count-1],"Next!") 
        print(warningmessage) 
        next
      }else{
        if(is.na(st_crs(samplefile))){
          warningmessage <- paste("No CRS:",tmpfiles2[file_count-1],"Next!") 
          print(warningmessage) 
          next
        }else{
          if(verbose){message(paste("Reading in file:",tmpfiles2[file_count-1],"to gather meta data") )}
          flag_read <- TRUE
          break
        }        
      }  
    }
  }else{
    #---------------------------------------------------------------------------------
    # If dekadal data was found
    #---------------------------------------------------------------------------------
    if(flag_dekad==FALSE){
      if(verbose){message("  5. Loading dekadal global meta data")}
      
      flag_read <- FALSE; file_count <- 1
      
      repeat{
        if(file_count > 1000){
          warningmessage <- paste("The auto-chosen folder did not have data (bad) \n 1. Please type file.choose() into the console including parentheses & press Enter, \n 2. Choose ANY .tif file from a subfolder of: \n",dir_data_remote_BGeoTif,"\n 3. Press open to print the location into the console,\n 4. Copy/paste the ENTIRE PATH AND FILE NAME into override_spatialmeta\n    e.g. override_spatialmeta <- LOCATION_ON_YOUR_COMPUTER",sep,"Filename",sep="")
          stop(warningmessage, call. = FALSE)      
        }  
        options(show.error.messages = FALSE)
        samplefile <- try(raster( paste(dir_data_remote_BGeoTif_dekad,products_dekad[prod_count_dekad],tmpfiles3[file_count],sep=sep)),silent=TRUE)
        options(show.error.messages = TRUE)
        file_count <- file_count+1
        
        if(class(samplefile) %in% "try-error"){
          warningmessage <- paste("Not a geotif/corrupted:",tmpfiles3[file_count-1],"Next!") 
          print(warningmessage) 
          next
        }else{
          if(is.na(st_crs(samplefile))){
            warningmessage <- paste("No CRS:",tmpfiles3[file_count-1],"Next!") 
            print(warningmessage) 
            next
          }else{
            if(verbose){message(paste("Reading in file:",tmpfiles3[file_count-1],"to gather meta data") )}
            flag_read <- TRUE
            break
          }        
        }
      }  
    }else{
      #---------------------------------------------------------------------------------
      # If monthly data was found
      #---------------------------------------------------------------------------------
      if(verbose){message("  5. Loading monthly global meta data")}
      
      flag_read <- FALSE; file_count <- 1
      
      repeat{
        if(file_count > 1000){
          warningmessage <- paste("YOUR CORE FOLDER IS EMPTY OF SATELLITE DATA (bad) \n EITHER \n\n  Run the earlier scripts to download/format the data or.. \n\n  Check 0_Global_Params.r for a dodgy folder name (dir_data_remote)  or  \n\n   1. Please type file.choose() into the console including parentheses & press Enter, \n   2. Choose ANY .tif file from a subfolder of: \n     ",dir_data_remote_BGeoTif,"\n   3. Press open to print the location into the console,\n   4. Copy/paste the ENTIRE PATH AND FILE NAME into override_spatialmeta\n      e.g. override_spatialmeta <- LOCATION_ON_YOUR_COMPUTER",sep,"Filename",sep="")
          stop(warningmessage, call. = FALSE)      
        }  
        options(show.error.messages = FALSE)
        samplefile <- try(raster( paste(dir_data_remote_BGeoTif_month,products_month[prod_count_month],tmpfiles4[file_count],sep=sep)),silent=TRUE)
        options(show.error.messages = TRUE)
        file_count <- file_count+1
        
        if(class(samplefile) %in% "try-error"){
          warningmessage <- paste("Not a geotif/corrupted:",tmpfiles4[file_count-1],"Next!") 
          print(warningmessage) 
          next
        }else{
          if(is.na(st_crs(samplefile))){
            warningmessage <- paste("No CRS:",tmpfiles4[file_count-1],"Next!") 
            print(warningmessage) 
            next
          }else{
            if(verbose){message(paste("Reading in file:",tmpfiles4[file_count-1],"to gather meta data") )}
            flag_read <- TRUE
            break
          }        
        }  
      }             
    }
  }
}

if(movedata){ 
  if(verbose){message("  6. Setting up data move")}
  
  #---------------------------------------------------------------------------------
  # Read in the data, or make the lon/lat box extent
  #---------------------------------------------------------------------------------
  # IF CHOOSING A BOX
  if(SubsetOption == 1){
    newbox <- st_bbox(c(xmin = Box.MinLong, xmax = Box.MaxLong, 
                        ymin = Box.MinLat, ymax = Box.MaxLat), crs = st_crs(samplefile))
    newbox <- st_bbox(extend(extent(newbox),Box.buffer),crs = st_crs(samplefile))
  }
  
  # IF CHOOSING A SHAPEFILE
  if(SubsetOption %in% 2){
    if(verbose){message(paste("      a. Using shapefile",Shapefile.Name,"to crop"))}
    
    # remove any spurious ".shps" in the file name
    if(substr(Shapefile.Name,nchar(Shapefile.Name)-3,nchar(Shapefile.Name)) == ".shp"){
      Shapefile.Name <- substr(Shapefile.Name,1,nchar(Shapefile.Name)-4)
    }
    
    if(!file.exists(paste(Shapefile.Folder,"/",Shapefile.Name,".shp",sep=""))){stop("Your shapefile does not exist")}
    
    # read in the shapefile
    boundary <- suppressMessages(suppressWarnings(st_read(Shapefile.Folder,Shapefile.Name,quiet=TRUE)))
    boundary <- st_transform(boundary,st_crs(samplefile))
    
    # and choose just the region if selected
    if(is.na(Shapefile.ColName) == FALSE){
      if(verbose){message(paste("      b. Subsetting shapefile to polygons where",Shapefile.ColName,"=",Shapefile.ColValue))}
      
      colloc <- which(toupper(names(boundary)) %in% toupper(Shapefile.ColName))
      
      if(!(Shapefile.ColValue %in% unique(st_drop_geometry(boundary)[,colloc]))){
        print(cat(paste("There is no value of ",Shapefile.ColValue,"in the shapefile column",Shapefile.ColName, "\n Please choose out of:\n")))
        print(unique(st_drop_geometry(boundary)[,colloc]))
        stop()
      }
      boundary <- boundary %>% dplyr::filter_at(colloc, dplyr::all_vars(. == Shapefile.ColValue))
    }
    if(toupper(Shapefile.croptype) == "BOX"){
      if(verbose){message("      a. Using a BOX to subset the data to:")}
      newbox <- st_bbox(extend(extent(boundary),Box.buffer),crs = st_crs(samplefile))
    }else{
      newbox <- boundary
    }
    
  }  
  
  #---------------------------------------------------------------------------------
  # Record extent
  #---------------------------------------------------------------------------------
  if(verbose){message("  7. Outputting new extent")}
  png(paste(dir_runset,paste("0CroppedArea_",Runset,".png",sep=""),sep=sep))
  plot(crop(samplefile,newbox),main=paste(Runset,": Cropped area",sep=""),asp=1)
  if(SubsetOption %in% 2){
     plot(st_geometry(boundary),add=TRUE)
  }     
  dev.off()
  write.csv(print(newbox),paste(dir_runset,paste("0MetaData_",Runset,".csv",sep=""),sep=sep))
  
  
  #---------------------------------------------------------------------------------
  # Function to crop and resave the data
  #---------------------------------------------------------------------------------
  minicrop <- function(infile,indirectory,sep,Runset,newbox,outdirectory,Overwrite){
    outputfile <- paste(outdirectory,paste(Runset,infile,sep="_"),sep=sep)
    if((Overwrite == FALSE) & (file.exists(outputfile))){
      
    }else{
      r <- raster::raster(paste(indirectory,infile,sep=sep))
      writeRaster(crop(r,newbox), filename=outputfile, format="GTiff", overwrite=Overwrite)
    }  
    return(infile)
  }
  
  
  #---------------------------------------------------------------------------------
  # Now apply it using foreach - and run
  #---------------------------------------------------------------------------------
  # DAILY
  
  n<-1
  if(verbose){message("  8. Cropping daily data")}
  if(length(products_daily)>0){
    
    for(p in 1:length(products_daily)){
      a <- Sys.time()
      
      if(verbose){message(paste("     ",products_daily[p] ))}
      indirectory <- paste(dir_data_remote_BGeoTif_daily,products_daily[p],sep=sep)
      productfiles <- list.files(indirectory)
      productfiles <- productfiles[(grep(".tif",productfiles))]
      outdirectory <- paste(dir_data_remote_BGeoTif_daily_runset,products_daily[p],sep=sep)
      Overwrite=FALSE
      
      productfilesnew <- base::split(productfiles,base::cut(seq_along(productfiles),breaks=10))
      
      for(time in 1:length(productfilesnew)){
        if(verbose){message(paste("       From",productfilesnew[[time]][1],"to",productfilesnew[[time]][length(productfilesnew[[time]])]))}
        test <- foreach(tmpn = productfilesnew[[time]]) %dopar%  minicrop(tmpn,indirectory,sep,Runset,newbox,outdirectory,Overwrite)
      }
      print(Sys.time() -a  )
      
    }
  }else{
    message("     NO DAILY DATA")
  }
  
  
  # PENTAD
  
  if(verbose){message("  9. Cropping pentadal data")}
  if(length(products_pentad)>0){
    for(p in 1:length(products_pentad)){
      a <- Sys.time()
      
      if(verbose){message(paste("     ",products_pentad[p] ))}
      indirectory <- paste(dir_data_remote_BGeoTif_pentad,products_pentad[p],sep=sep)
      productfiles <- list.files(indirectory)
      productfiles <- productfiles[(grep(".tif",productfiles))]
      
      outdirectory <- paste(dir_data_remote_BGeoTif_pentad_runset,products_pentad[p],sep=sep)
      
      Overwrite=FALSE
      productfiles <- base::split(productfiles,base::cut(seq_along(productfiles),breaks=10))
      
      for(time in 1:length(productfiles)){
        if(verbose){message(paste("       From",productfiles[[time]][1],"to",productfiles[[time]][length(productfiles[[time]])]))}
        test <- foreach(tmpn = productfiles[[time]]) %dopar%  minicrop(tmpn,indirectory,sep,Runset,newbox,outdirectory,Overwrite)
      }
      print(Sys.time() -a  )
      
    }
  }else{
    message("     NO PENTADAL DATA")
  }
  
  
  # DEKAD
  
  if(verbose){message("  10. Cropping dekadal data")}
  if(length(products_dekad)>0){
    for(p in 1:length(products_dekad)){
      a <- Sys.time()
      
      if(verbose){message(paste("     ",products_dekad[p] ))}
      indirectory <- paste(dir_data_remote_BGeoTif_dekad,products_dekad[p],sep=sep)
      productfiles <- list.files(indirectory)
      productfiles <- productfiles[(grep(".tif",productfiles))]
      outdirectory <- paste(dir_data_remote_BGeoTif_dekad_runset,products_dekad[p],sep=sep)
      
      productfiles <- base::split(productfiles,base::cut(seq_along(productfiles),breaks=10))
      Overwrite=FALSE
      
      for(time in 1:length(productfiles)){
        if(verbose){message(paste("       From",productfiles[[time]][1],"to",productfiles[[time]][length(productfiles[[time]])]))}
        test <- foreach(tmpn = productfiles[[time]]) %dopar%  minicrop(tmpn,indirectory,sep,Runset,newbox,outdirectory,Overwrite)
      }
      print(Sys.time() -a  )
      
    }
  }else{
    message("     NO DEKADAL DATA")
  }
  
  
  # MONTH
  if(verbose){message("  11. Cropping monthly data")}
  
  if(length(products_month)>0){
    
    for(p in 1:length(products_month)){
      
      a <- Sys.time()
      if(verbose){message(paste("     ",products_month[p] ))}
      
      indirectory <- paste(dir_data_remote_BGeoTif_month,products_month[p],sep=sep)
      productfiles <- list.files(indirectory)
      productfiles <- productfiles[(grep(".tif",productfiles))]
      
      outdirectory <- paste(dir_data_remote_BGeoTif_month_runset,products_month[p],sep=sep)
      
      productfiles <- base::split(productfiles,base::cut(seq_along(productfiles),breaks=10))
      Overwrite=FALSE
      
      for(time in 1:length(productfiles)){
        if(verbose){message(paste("       From",productfiles[[time]][1],"to",productfiles[[time]][length(productfiles[[time]])]))}
        test <- foreach(tmpn = productfiles[[time]]) %dopar%  minicrop(tmpn,indirectory,sep,Runset,newbox,outdirectory,Overwrite)
      }
      print(Sys.time() -a  )
      
    }
  }else{
    message("     NO MONTHLY DATA")
  }
  
}  # movedata

#------------------------------------------------------------------------------
# And create the project file
#------------------------------------------------------------------------------
projfile <- list.files(dir_core)[grep(".rproj",tolower(list.files(dir_core)))]
newprojfile <- paste("Step0_",Runset,"PROJECT.Rproj",sep="")
tmp  <- file.copy(from=paste(dir_core,projfile,sep=sep),to=paste(dir_runset,newprojfile,sep=sep))  


#------------------------------------------------------------------------------ 
# Open on request
#------------------------------------------------------------------------------
setwd(dir_core)
rm(list=ls())  


