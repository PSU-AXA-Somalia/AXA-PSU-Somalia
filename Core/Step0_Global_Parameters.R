
#================================================================================================================
# GLOBAL PARAMETERS
# YOU SHOULD HAVE OPENED R-STUDIO THROUGH DOUBLE-CLICKING Step0_Core_PROJECTFILE.Rproj.
# (It should say Core - main - RStudio at the top), if not close R-Studio and open properly!
#
# If you update this file, please change the date
# If you are brand new to R/R-Studio, read this first: https://psu-spatial.github.io/Geog364-2021/pg_Tut1_about.html 
#================================================================================================================
globalparams_lastupdated <- as.Date("2022-06-11")
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
   # If your R version is struggling to install updates, try turning auto_update_package <- FALSE
   #---------------------------------------------------------------------------------
    use_github_repos     <- FALSE    
    auto_update_packages <- FALSE
    
    #---------------------------------------------------------------------------------
    # Are you running on a supercomputer/HPC platform? TRUE
    # Or on a single desktop/laptop  FALSE
    #---------------------------------------------------------------------------------
    PSUSuperComputer <- FALSE
    
    #---------------------------------------------------------------------------------
    # Remote data?
    # If you are storing the data elsewhere, add the address here
    # It will still assume the code is in this folder structure.
    # Else set to NA
    #---------------------------------------------------------------------------------
    RemoteData <- "/Volumes/Mac storage space/Work/Somalia/AXA-PSU-Somalia/Core/Data"
    
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
# And run the setup   
#=================================================================================
   source("Step0_Global_SetUp.R")   
 
   
