
#================================================================================================================
# GLOBAL PARAMETERS
# YOU SHOULD HAVE OPENED R-STUDIO THROUGH DOUBLE-CLICKING Step0_Core_PROJECTFILE.Rproj.
# (It should say Core - main - RStudio at the top), if not close R-Studio and open properly!
#
# If you update this file, please change the date
# If you are brand new to R/R-Studio, read this first: https://psu-spatial.github.io/Geog364-2021/pg_Tut1_about.html 
#================================================================================================================
globalparams_lastupdated <- as.Date("2021-11-19")
#runsetparamdate_DONOTDELETE

#================================================================================================================
# 1. GENERAL
#================================================================================================================
   #---------------------------------------------------------------------------------
   # Do you want messages on your screen?
   #---------------------------------------------------------------------------------
    verbose <- TRUE
    
   #---------------------------------------------------------------------------------
   # Are you able to download/install packages from github? Try true and see if it works
   # 
   # [Likely TRUE if you have admin access on your computer, FALSE if its a work computer
   # and your organisation blocks it].  If you see it constantly fail to download from github,
   # turn to FALSE
   #
   # If your R version is struggling to install updates, try turning updatepackage <- FALSE
   #---------------------------------------------------------------------------------
    use_github_repos     <- TRUE    
    auto_update_packages <- FALSE
    
    #---------------------------------------------------------------------------------
    # Are you running on a supercomputer/HPC platform? TRUE
    # Or on a single desktop/laptop  FALSE
    #---------------------------------------------------------------------------------
    PSUSuperComputer <- FALSE
    
#================================================================================================================
# 2. SPATIAL - defaults are probably fine here
#================================================================================================================
   #---------------------------------------------------------------------------------
   # Spatial Params, what map projection CRS code do you want to apply?
   # 4326 is long/lat
   #---------------------------------------------------------------------------------
     globalcrs <- 4326

   #---------------------------------------------------------------------------------
   # Future features
   #---------------------------------------------------------------------------------
   # grid : make standardized grid parameters here
     

#=================================================================================
# 3. DIRECTORIES SUB STRUCTURE - you can edit sub-folder names here. 
# It will also auto-create any that don't exist, defaults probably fine
#=================================================================================
  #---------------------------------------------------------------------------------
  # Legacy directory separator. It will likely always be "/"
  # now windows has its act together in R.
  #---------------------------------------------------------------------------------
   sep <- "/"       
 
  #---------------------------------------------------------------------------------
  # Main directory (e.g. the location of the github download folder)
  # You SHOULD be runnnig via your project so it can auto find this    
  #---------------------------------------------------------------------------------
  if(("Step0_Core_PROJECTFILE.Rproj" %in% list.files())){
     dir_main <- substr(getwd(),start=1,stop=nchar(getwd())-5)
  }else{     
     if("dir_main" %in% ls()){
        if(verbose){message("Step 0: you were not in dir_main when running this. Weird.\n Are you debugging?\nChanging main directory back")}
        setwd(paste(dir_main,"Core",sep=sep))
     }else{
        message(paste("I don't think you opened R by double clicking Step0_Core_PROJECTFILE.Rproj\n Your current directory is", 
                   getwd(),"\n The code is looking for Step0_Core_PROJECTFILE.Rproj in this directory but can only see:"))
        paste(list.files())
        stop("CLOSE R-STUDIO.  RE-OPEN R-STUDIO BY DOUBLE CLICKING Step0_Core_PROJECTFILE.Rproj")
     }
  }

   #Level 0 
   dir_core        <- paste(dir_main,"Core",sep=sep)
   dir_runset      <- paste(dir_main,"Runset",sep=sep)

   #Data Level 1
   dir_data        <- paste(dir_core,"Data",sep=sep)
   dir_code        <- paste(dir_core,"Code",sep=sep)

   runset_foldername_rawoutput  <-  "Output1_RawPlots"
   runset_foldername_visualise   <- "Output2_Visualisation"

  #Data Level 2
   dir_data_shape           <- paste(dir_data,"1_Shapefiles",    sep=sep)
   dir_data_remote          <- paste(dir_data,"2_Remote_Sensing",sep=sep)

  #Data Level 3
   dir_data_remote_ARaw       <- paste(dir_data_remote,"0_Raw_data",sep=sep)
   dir_data_remote_BGeoTif    <- paste(dir_data_remote,"1_Raw_geoTifs",sep=sep)

  #Data Level 4
   dir_data_remote_BGeoTif_daily   <-  paste(dir_data_remote_BGeoTif,"A_QC_data_daily",sep=sep)
   dir_data_remote_BGeoTif_pentad  <-  paste(dir_data_remote_BGeoTif,"B_QC_data_pentad",sep=sep)
   dir_data_remote_BGeoTif_dekad   <-  paste(dir_data_remote_BGeoTif,"C_QC_data_dekad",sep=sep)
   dir_data_remote_BGeoTif_month   <-  paste(dir_data_remote_BGeoTif,"D_QC_data_month",sep=sep)
  
   
#=================================================================================
# And run the setup   
#=================================================================================
   source("Step0_Global_SetUp.R")   
 
   
