
#================================================================================================================
# GLOBAL PARAMETERS
# YOU SHOULD HAVE OPENED R-STUDIO THROUGH DOUBLE-CLICKING Step0_Core_PROJECTFILE.Rproj.
# (It should say Core - main - RStudio at the top), if not close R-Studio and open properly!
#
# If you update this file, please change the date
# If you are brand new to R/R-Studio, read this first: https://psu-spatial.github.io/Geog364-2021/pg_Tut1_about.html 
#================================================================================================================
globalparams_lastupdated <- as.Date("2021-11-14")
#runsetparamdate_DONOTDELETE

#================================================================================================================
# 1. GENERAL
#================================================================================================================
   #---------------------------------------------------------------------------------
   # Main directory (e.g. the location of the github download folder)
   # You can also type the command getwd() 
   # into the console and copy/paste the answer
   #---------------------------------------------------------------------------------
    dir_main <- "/Users/hlg5155/Dropbox/My Mac (E2-GEO-WKML011)/Documents/GitHub/Somalia/AXA-PSU-Somalia"

   #---------------------------------------------------------------------------------
   # Do you want messages on your screen?
   #---------------------------------------------------------------------------------
    verbose <- TRUE
    
   #---------------------------------------------------------------------------------
   # Are you able to download/install packages from github?
   # Likely TRUE if you have admin access on your computer, FALSE if its a work computer
   # and your organisation blocks it.  Try true and see if it works.
   #---------------------------------------------------------------------------------
    github <- TRUE    
    
   #---------------------------------------------------------------------------------
   # Are you running on a supercomputer/HPC platform? TRUE
   # Or on a single desktop/laptop  FALSE
   #---------------------------------------------------------------------------------
    PSUSuperComputer <- FALSE

    #---------------------------------------------------------------------------------
    # Directory separator:  
    # Type 
    #  getwd() 
    # into your console (including the empty parentheses) and press enter.
    # This will show you your current directory
    # Is the separator symbol between subdirectories "/" or "\\" ?  
    #---------------------------------------------------------------------------------
    sep <- "/"     

    #---------------------------------------------------------------------------------
    # Update packages:
    # Do you want this code to attempt to auto-update any packages that are not 
    # recent enough? Recommended TRUE unless you know this will break your other code
    # Seee Step0_Global_SetUp.R for package/version list.
    #---------------------------------------------------------------------------------
    updatepackage <- TRUE
    

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
 
   
