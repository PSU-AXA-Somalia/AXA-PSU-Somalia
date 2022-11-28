
#===============================================================================
# 1. SET UP RUNSET FOLDER
#===============================================================================
 #----- Create Runset folder name, auto name as required
 if(is.na(Runset)){
    if(Option == 1){
       Runset <- paste("BOX",round(MinLong,3),round(MaxLong,3),round(MinLat,3),round(MaxLat,3),sep="_") 
    }else{
       if(is.na(column_value)){Runset <- paste(Shapefile.Name,croptype,sep="_")}else{Runset <- paste(column_value,croptype,sep="_")}
    }
 }

 #----- Create main folders
 dir_runset <- paste(dir_main,"Runset",Runset,sep=sep)
 conditionalcreate(dir_runset)
 if(verbose){message(paste("Setting up file structures in",dir_runset))}
 
 
 #===============================================================================
 # 2. SET UP SPATIAL EXTENT/BOX AND GET DATASETS AND A SAMPLE FILE
 #===============================================================================
 if(verbose){message("  1. Selecting data products")}
 
 # List all the available products
 #--------------------------------------------------------------------------------
  products_daily  <-  list.files(dir_data_remote_BGeoTif_daily,pattern="Grid",recursive=FALSE)
  products_pentad <-  list.files(dir_data_remote_BGeoTif_pentad,pattern="Grid",recursive=FALSE)
  products_dekad  <-  list.files(dir_data_remote_BGeoTif_dekad,pattern="Grid",recursive=FALSE)
  products_month  <-  list.files(dir_data_remote_BGeoTif_month,pattern="Grid",recursive=FALSE)
 
  #--------------------------------------------------------------------------------
  # Just choose subset as needed
  #--------------------------------------------------------------------------------
  if(tolower(ProductChoice[1]) != "all"){
    products_daily   <-  products_daily[grepl( paste(ProductChoice, collapse = "|"),products_daily)]
    products_pentad  <-  products_pentad[grepl( paste(ProductChoice, collapse = "|"),products_pentad)]
    products_dekad  <-  products_dekad[grepl( paste(ProductChoice, collapse = "|"),products_dekad)]
    products_month  <-  products_month[grepl( paste(ProductChoice, collapse = "|"),products_month)]
  }
 
  
  #--------------------------------------------------------------------------------
  # Get standard CRS
  #--------------------------------------------------------------------------------
  samplefile <- raster(list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[1],sep=sep),
                                recursive=TRUE,full.names=TRUE,include.dirs = TRUE,pattern=".tif")[1])
  samplefileterra <- rast(list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[1],sep=sep),
                                  recursive=TRUE,full.names=TRUE,include.dirs = TRUE,pattern=".tif")[1])
  
 #===============================================================================
 # CHECK THE PARAMETERS.
 #===============================================================================
  #--------------------------------------------------------------------------------
  # If the user chose a box
  #--------------------------------------------------------------------------------  
  if(SubsetOption == 1){
    if(verbose){message(paste("      a. Cropping to a box:",Box.MinLong,"to",Box.MaxLong,",",Box.MinLat,"to",Box.MaxLat))}
    newbox <- st_bbox(c(xmin = Box.MinLong, xmax = Box.MaxLong, ymin = Box.MinLat, ymax = Box.MaxLat), 
                      crs = st_crs(samplefile))
    newbox <- st_bbox(extend(extent(newbox),Box.buffer),crs = st_crs(samplefile))
    
    # Get a terra version
    terrabbox <- ext(as.numeric(newbox$xmin),
                     as.numeric(newbox$xmax),
                     as.numeric(newbox$ymin),
                     as.numeric(newbox$ymax))
  }
 
  #--------------------------------------------------------------------------------
  # If the user chose a shapefile
  #--------------------------------------------------------------------------------  
  if(SubsetOption %in% 2){
    if(verbose){message(paste("      a. Using shapefile",Shapefile.Name,"to crop"))}

    # remove any spurious ".shps" in the file name 
    if(substr(Shapefile.Name,nchar(Shapefile.Name)-3,nchar(Shapefile.Name)) == ".shp"){
       Shapefile.Name <- substr(Shapefile.Name,1,nchar(Shapefile.Name)-4)
    }
     
    # and check it exists 
    if(!file.exists(paste(Shapefile.Folder,"/",Shapefile.Name,".shp",sep=""))){stop("Your shapefile does not exist")}
    
    # read in the boundary shapefile
    boundary <- suppressMessages(suppressWarnings(st_read(Shapefile.Folder,Shapefile.Name,quiet=TRUE)))
    boundary <- st_transform(boundary,st_crs(samplefile))
    
    # and choose just the region if selected
    if(is.na(Shapefile.ColName) == FALSE){
       if(verbose){message(paste("      b. Subsetting shapefile to polygons where",Shapefile.ColName,"=",Shapefile.ColValue))}
       colloc <- which(toupper(names(boundary)) %in% toupper(Shapefile.ColName))

       # check if the requested column name exists       
       if(!(Shapefile.ColValue %in% unique(st_drop_geometry(boundary)[,colloc]))){
          print(cat(paste("There is no value of ",Shapefile.ColValue,"in the shapefile column",Shapefile.ColName, "\n Please choose out of:\n")))
          print(unique(st_drop_geometry(boundary)[,colloc]))
          stop()
       }
       # Select outer boundary
       boundary <- boundary %>% dplyr::filter_at(colloc, dplyr::all_vars(. == Shapefile.ColValue))
    }
    
    # Select outer boundary
    if(toupper(Shapefile.croptype) == "BOX"){
       if(verbose){message("      a. Using a box around the shapefile to subset the data to:")}
       newbox <- st_bbox(extend(extent(boundary),Box.buffer),crs = st_crs(samplefile))
    }else{
       newbox <- boundary
    }
    terrabbox <- ext(as.numeric(newbox$xmin),
                     as.numeric(newbox$xmax),
                     as.numeric(newbox$ymin),
                     as.numeric(newbox$ymax))
  }  
 
 
  #===============================================================================
  # Check list is fully appropriate e.g. the spatial extents overlap.
  # Remove datasets that don't overlatp
  #===============================================================================
  toremove <- NA
  for(myfile in 1:length(products_daily)){
     # read in a test file
      testfile <- rast(list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[myfile],"2002",sep="/"),
                                  pattern="_",recursive=TRUE,include.dirs = TRUE,full.names=TRUE)[1])

      # does the file exist?
      if(relate(testfile,terrabbox,"intersects")){
         #Might be an issue with half and half
      }else{
         if(verbose){message(paste("       ",products_daily[myfile],"Ignoring: no overlap"))}
         toremove <- c(toremove,products_daily[myfile])
      }
  }
  
  # sort out file list again.
  products_daily <- products_daily[!(products_daily %in% toremove)]
  products_pentad <- products_pentad[!(products_pentad %in% paste("pentad",toremove,sep="_"))]
  products_dekad <- products_dekad[!(products_pentad %in% paste("dekad",toremove,sep="_"))]
  products_month <- products_month[!(products_pentad %in% paste("month",toremove,sep="_"))]
  
  #===============================================================================
  # Then get list of files in each folder left.
  #===============================================================================
  
  if(verbose){message("  2. Getting input file names")}
  
  # Get list of daily files in each one
  products_daily_files <- unlist(
     foreach(n = 1:length(products_daily)) %dopar% list.files(
        paste(dir_data_remote_BGeoTif_daily, products_daily[n], sep = "/"),
        pattern ="_",recursive = TRUE))
  
  products_pentad_files <- unlist(
     foreach(n = 1:length(products_pentad)) %dopar% list.files(
        paste(dir_data_remote_BGeoTif_pentad, products_pentad[n], sep = "/"),
        pattern ="_",recursive = TRUE))
  
  products_dekad_files <- unlist(
     foreach(n = 1:length(products_dekad)) %dopar% list.files(
        paste(dir_data_remote_BGeoTif_dekad, products_dekad[n], sep = "/"),
        pattern = "_",recursive = TRUE))
  
  products_month_files <- unlist(
        foreach(n = 1:length(products_month)) %dopar% list.files(
           paste(dir_data_remote_BGeoTif_month, products_month[n], sep = "/"),
           pattern="_",recursive=TRUE))

#===============================================================================
# 1. CREATE NEW PARAMETER FILES
#===============================================================================

 source(paste(dir_code,"4_Crop_To_Runset_Sub_EditGlobalParam.R",sep=sep))
 source(paste(dir_code,"4_Crop_To_Runset_Sub_EditGlobalSetup.R",sep=sep))
  


#---------------------------------------------------------------------------------
# Move the existing analysis folder if it exists and you want to save
# Rather than delete anything, I just move it to a new subfolder
#---------------------------------------------------------------------------------
  dir_runset_data <-  paste(dir_runset,"Data",sep=sep)
  dir_runset_code <-  paste(dir_runset,"Code",sep=sep)
  
if(SaveAnalysis == FALSE){
   # delete the data folder
   if(verbose){message("  4. Deleting the Runset data/analysis folder")}
   
   if(dir.exists(dir_runset_remote)){
      file.remove(list.files(dir_runset_remote, 
                             recursive = TRUE,include.dirs = TRUE,
                             full.names = TRUE))
      }   
   
}else{   
  if(dir.exists(dir_runset_data)){
     
    if(length(list.files(dir_runset_data))>0){
       if(verbose){message("  4. Backing up old data")}
       
      newfolder <- paste(dir_runset_data,"OLD",Sys.Date(),sep="_")
      nn=1
      while(dir.exists(newfolder)){
        newfolder <- paste(newfolder,n,sep="_")
        nn=nn+1
        if(nn > 5){warning("You have 5 back up data folders, not a good way of storing your data")}
        if(nn > 10){stop("You have 10 back up data folders, sort out your data storage")}
      }
      if(verbose){message(paste("     a) Old Sat Data found, moving to subfolder:",newfolder))}
      file.rename(dir_runset_data,newfolder)
    }
  } 
     
   if(dir.exists(dir_runset_code)){
      if(length(list.files(dir_runset_code))>0){
         if(verbose){message("  4. Backing up old code")}
         
         newfolder <- paste(dir_runset_code,"OLD",Sys.Date(),sep="_")
         nn=1
         while(dir.exists(newfolder)){
           newfolder <- paste(newfolder,n,sep="_")
           nn=nn+1
           if(nn > 5){warning("You have 5 back up data folders, not a good way of storing your data")}
           if(nn > 10){stop("You have 10 back up data folders, sort out your data storage")}
         }
         if(verbose){message(paste("     a) Old code found, moving to subfolder:",newfolder))}
         file.rename(dir_runset_code,newfolder)
      }
   }   

}

#---------------------------------------------------------------------------------
# CREATE THE NEW FOLDER NAMES AND DIRECTORY STRUCTURE
#---------------------------------------------------------------------------------
if(verbose){message("  5. Creating subfolders")}

# First deal with the new runset data location
conditionalcreate(dir_runset_data)

# If you want an override location for the data this will set it
if(is.na(dir_data_runset_override)==FALSE){
   conditionalcreate(dir_data_runset_override)
   dir_data_runset <- dir_data_runset_override
}else{
   dir_data_runset <- dir_runset_data
   conditionalcreate(dir_runset_data)
}   

dir_data_remote_runset <-  paste(dir_data_runset,"2_Remote_Sensing",sep=sep)
conditionalcreate(dir_data_remote_runset)


# Now just auto move everything else over
alldirs <- ls()
alldirs <- alldirs[ grep("dir_",alldirs)]
alldirs <- alldirs[-grep("dir_main",alldirs)]
alldirs <- alldirs[-grep("dir_core",alldirs)]
alldirs <- alldirs[-grep("dir_runset",alldirs)]
alldirs <- alldirs[-grep("dir_GLOBAL",alldirs)]
alldirs <- alldirs[-grep("dir_data_remote_ARaw",alldirs)]
alldirs <- alldirs[-grep("dir_data_remote_CDerived",alldirs)]

alldirs <- alldirs[-which(alldirs %in% "dir_data")]
alldirs <- alldirs[-which(alldirs %in% "dir_data_runset")]
alldirs <- alldirs[-which(alldirs %in% "dir_data_runset_override")]
alldirs <- alldirs[-which(alldirs %in% "dir_data_remote")]
alldirs <- alldirs[-which(alldirs %in% "dir_data_remote_runset")]


alldirs <- sort(alldirs)

for(counter in 1:length(alldirs)){
 # print(alldirs[counter])
  dirnew <- eval(parse(text = alldirs[counter]))
  if(grepl("Data" ,dirnew)){
     dirout <-str_replace(dirnew,dir_data_remote,dir_data_remote_runset)
  }else{
     dirout <- str_replace(dirnew,"Core",paste("Runset",Runset,sep=sep))
  }
  conditionalcreate(dirout)
  
  if(alldirs[counter] %in% "dir_data_remote_BGeoTif_daily"){
    for(p in products_daily){
      dirinprod <- paste(dir_data_remote_BGeoTif_daily,p,sep=sep)
      diroutprod <- str_replace(dirinprod,dir_data_remote,dir_data_remote_runset)
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
  if(alldirs[counter] %in% "dir_data_remote_BGeoTif_pentad"){
    for(p in products_pentad){
      dirinprod <- paste(dir_data_remote_BGeoTif_pentad,p,sep=sep)
      diroutprod <- str_replace(dirinprod,dir_data_remote,dir_data_remote_runset)
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
  if(alldirs[counter] %in% "dir_data_remote_BGeoTif_dekad"){
    for(p in products_dekad){
      dirinprod <- paste(dir_data_remote_BGeoTif_dekad,p,sep=sep)
      diroutprod <- str_replace(dirinprod,dir_data_remote,dir_data_remote_runset)
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
  if(alldirs[counter] %in% "dir_data_remote_BGeoTif_month"){
    for(p in products_month){
      dirinprod <- paste(dir_data_remote_BGeoTif_month,p,sep=sep)
      diroutprod <- str_replace(dirinprod,dir_data_remote,dir_data_remote_runset)
      suppressWarnings(conditionalcreate(diroutprod))
    }
  }
}

#---------------------------------------------------------------------------------
# and set up runset versions of the main directories
#---------------------------------------------------------------------------------
dir_data_remote_BGeoTif_daily_runset  <- str_replace(dir_data_remote_BGeoTif_daily,dir_data_remote,dir_data_remote_runset)
dir_data_remote_BGeoTif_pentad_runset <- str_replace(dir_data_remote_BGeoTif_pentad,dir_data_remote,dir_data_remote_runset)
dir_data_remote_BGeoTif_dekad_runset  <- str_replace(dir_data_remote_BGeoTif_dekad,dir_data_remote,dir_data_remote_runset)
dir_data_remote_BGeoTif_month_runset  <- str_replace(dir_data_remote_BGeoTif_month,dir_data_remote,dir_data_remote_runset)

#---------------------------------------------------------------------------------
# MOVING THE DATA
#---------------------------------------------------------------------------------
if(verbose){message("  6. Loading global spatial meta data")}

#---------------------------------------------------------------------------------
# Read in test file from the main folder to get crs & check if there is data 
# Needlessly complex so that it autochooses a folder with data in
#---------------------------------------------------------------------------------
movedata <- TRUE

#=================================================================================
# THIS SECTION CHECKS TO SEE THAT SATELLITE DATA EXISTS
#=================================================================================
 #---------------------------------------------------------------------------------
 # Look for daily files that exist
 #---------------------------------------------------------------------------------
 # list all the files in each product folder
 prod_count_daily=1 ; flag_daily <- FALSE
 tmpfiles <- list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[prod_count_daily],sep=sep),recursive=TRUE,pattern=".tif")
 # See if that folder is empty and move on
 while((length(tmpfiles) <=0) & (flag_daily ==FALSE)){
  prod_count_daily <- prod_count_daily+1
  tmpfiles <- list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[prod_count_daily],sep=sep),recursive=TRUE,pattern=".tif")
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
  tmpfiles2 <- list.files(paste(dir_data_remote_BGeoTif_pentad,products_pentad[prod_count_pentad],sep=sep),recursive=TRUE,pattern=".tif")
  # See if that folder is empty and move on
  while((length(tmpfiles2) <=0) & (flag_pentad ==FALSE)){
    prod_count_pentad <- prod_count_pentad+1
    tmpfiles2 <- list.files(paste(dir_data_remote_BGeoTif_pentad,products_pentad[prod_count_pentad],sep=sep),recursive=TRUE,pattern=".tif")
    if(prod_count_pentad >= length(products_pentad)){flag_pentad <- TRUE;warning("No Pentad Data Found for any product")}
  } 
  
  if(flag_pentad == TRUE){
    # Look for dekadal files
    prod_count_dekad=1 ; flag_dekad <- FALSE
    tmpfiles3 <- list.files(paste(dir_data_remote_BGeoTif_dekad,products_dekad[prod_count_dekad],sep=sep),recursive=TRUE,pattern=".tif")
    while((length(tmpfiles3)<=0) & (flag_dekad ==FALSE)){
      prod_count_dekad <- prod_count_dekad+1; print(prod_count_dekad) ; 
      tmpfiles3 <- list.files(paste(dir_data_remote_BGeoTif_dekad,products_dekad[prod_count_dekad],sep=sep),recursive=TRUE,pattern=".tif")
      
      if(prod_count_dekad >= length(products_dekad)){flag_dekad <- TRUE; warning("No Dekadal Data found for any product")}
    } 
    
    if(flag_dekad == TRUE){
      # Look for monthly files
      prod_count_month=1 ; flag_month <- FALSE
      tmpfiles4 <- list.files(paste(dir_data_remote_BGeoTif_month,products_month[prod_count_month],sep=sep),recursive=TRUE,pattern=".tif")
      
      tmpfiles4 <- tmpfiles4[grep(".tif",tmpfiles4)]
      while((length(tmpfiles4)<=0) & (flag_month ==FALSE)){
         prod_count_month <- prod_count_month+1; print(prod_count_month) ; 
         tmpfiles4 <- list.files(paste(dir_data_remote_BGeoTif_month,products_month[prod_count_month],sep=sep),recursive=TRUE,pattern=".tif")
        
        if(p >= length(products_month)){
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
  if(verbose){message("  7. Loading daily global meta data")}
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
    if(verbose){message("  7. Loading pentadal global meta data")}
    
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
      if(verbose){message("  7. Loading dekadal global meta data")}
      
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
      if(verbose){message("  7. Loading monthly global meta data")}
      
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
  if(verbose){message("  8. Setting up data move")}
  
  #---------------------------------------------------------------------------------
  # Record extent
  #---------------------------------------------------------------------------------
  if(verbose){message("  8. Outputting new extent")}
  png(paste(dir_runset,paste("CroppedArea_",Runset,".png",sep=""),sep=sep))
  plot(crop(samplefile,newbox),main=paste(Runset,": Cropped area",sep=""),asp=1)
  if(SubsetOption %in% 2){
     plot(st_geometry(boundary),add=TRUE)
  }     
  dev.off()
  write.csv(print(newbox),paste(dir_runset,paste("MetaData_",Runset,".csv",sep=""),sep=sep))
  
  
  #---------------------------------------------------------------------------------
  # Function to crop and resave the data
  #---------------------------------------------------------------------------------
  minicrop <- function(infile,indirectory,sep,Runset,newbox,outdirectory,Overwrite){
     
     if(grepl(sep,infile)){
        #there are subdirectories ,create them and edit the actual filename
        actualfile <- strsplit(infile,sep)
        actualfilename <- actualfile[[1]][length(actualfile[[1]])]
        outputfile <- paste(outdirectory,infile,sep=sep)
        outputfile <- str_replace(outputfile,actualfilename,paste(Runset,actualfilename,sep="_"))
        
        # make subdirectories
        for(sublayer in 1:(length(actualfile[[1]])-1)){
           conditionalcreate(paste(outdirectory,actualfile[[1]][sublayer],sep=sep))
        }
           
     }else{
        outputfile <- paste(outdirectory,infile,sep=sep)
        outputfile <- paste(outdirectory,paste(Runset,infile,sep="_"),sep=sep)
     }

    
    if((Overwrite == FALSE) & (file.exists(outputfile))){
      
    }else{
      r <- rast(paste(indirectory,infile,sep=sep))
      
      suppressMessages(suppressWarnings(terra::writeRaster(round(crop(r,terrabbox),1), 
                                                           filename=outputfile, filetype="GTiff",overwrite=Overwrite)))
      a<-try(suppressMessages(suppressWarnings(file.remove(paste(outputfile,".aux.json",sep="")))))
      
    }  
    return(infile)
  }
  
  
  #---------------------------------------------------------------------------------
  # Now apply it using foreach - and run
  #---------------------------------------------------------------------------------
  # DAILY
  
  n<-1
  if(verbose){message("  9. Cropping daily data")}
  if(length(products_daily)>0){
    
    for(p in 1:length(products_daily)){
      a <- Sys.time()
      
      if(verbose){message(paste("     ",products_daily[p] ))}
      indirectory <- paste(dir_data_remote_BGeoTif_daily,products_daily[p],sep=sep)
      productfiles <- list.files(indirectory,recursive=TRUE,pattern=".tif")
      outdirectory <- paste(dir_data_remote_BGeoTif_daily_runset,products_daily[p],sep=sep)
      Overwrite=FALSE
      
      productfilesnew <- base::split(productfiles,base::cut(seq_along(productfiles),breaks=10))
      
      for(time in 1:length(productfilesnew)){
         a <- Sys.time()
         
        if(verbose){message(paste("       From",productfilesnew[[time]][1],"to",productfilesnew[[time]][length(productfilesnew[[time]])]))}
        test <- foreach(tmpn = productfilesnew[[time]]) %dopar%  minicrop(tmpn,indirectory,sep,Runset,newbox,outdirectory,Overwrite)

        print(Sys.time() -a  )
      }

    }
  }else{
    message("     NO DAILY DATA")
  }
  
  
  # PENTAD
  
  if(verbose){message("  10. Cropping pentadal data")}
  if(length(products_pentad)>0){
    for(p in 1:length(products_pentad)){
      a <- Sys.time()
      
      if(verbose){message(paste("     ",products_pentad[p] ))}
      indirectory <- paste(dir_data_remote_BGeoTif_pentad,products_pentad[p],sep=sep)
      productfiles <- list.files(indirectory,recursive=TRUE)
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
  
  if(verbose){message("  11. Cropping dekadal data")}
  if(length(products_dekad)>0){
    for(p in 1:length(products_dekad)){
      a <- Sys.time()
      
      if(verbose){message(paste("     ",products_dekad[p] ))}
      indirectory <- paste(dir_data_remote_BGeoTif_dekad,products_dekad[p],sep=sep)
      productfiles <- list.files(indirectory,recursive=TRUE)
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
  if(verbose){message("  12. Cropping monthly data")}
  
  if(length(products_month)>0){
    
    for(p in 1:length(products_month)){
      
      a <- Sys.time()
      if(verbose){message(paste("     ",products_month[p] ))}
      
      indirectory <- paste(dir_data_remote_BGeoTif_month,products_month[p],sep=sep)
      productfiles <- list.files(indirectory,recursive=TRUE)
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
newprojfile <- paste("Step0_",Runset,"_PROJECT.Rproj",sep="")
tmp  <- file.copy(from=paste(dir_core,projfile,sep=sep),to=paste(dir_runset,newprojfile,sep=sep))  


#------------------------------------------------------------------------------
# And finally, move the up to date code over
#------------------------------------------------------------------------------
tomove <- list.files(paste(dir_code,"Runset Functions","MainFolder",sep=sep),full.names = TRUE,include.dirs = TRUE)
fnames <- list.files(paste(dir_code,"Runset Functions","MainFolder",sep=sep))
tmp  <- file.copy(from=tomove,to=paste(dir_runset,fnames,sep=sep))  

#------------------------------------------------------------------------------
tomove <- list.files(paste(dir_code,"Runset Functions","CodeFolder",sep=sep),full.names = TRUE,include.dirs = TRUE)
fnames <- list.files(paste(dir_code,"Runset Functions","CodeFolder",sep=sep))
tmp  <- file.copy(from=tomove,to=paste(dir_runset,"Code",fnames,sep=sep))  



#------------------------------------------------------------------------------ 
# Open on request
#------------------------------------------------------------------------------
setwd(dir_core)
rm(list=ls())  


