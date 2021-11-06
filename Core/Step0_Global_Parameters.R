
#================================================================================================================
# GLOBAL PARAMETERS
# If you update this file, please change the date
#================================================================================================================
globalparams_lastupdated <- as.Date("2021-11-05")
#runsetparamdate_DONOTDELETE


#================================================================================================================
# 1. GENERAL
#================================================================================================================
   #---------------------------------------------------------------------------------
   # Just stops spatial update errors from R. IGNORE
   #---------------------------------------------------------------------------------
    options("rgdal_show_exportToProj4_warnings"="none")

   #---------------------------------------------------------------------------------
   # Do you want messages on your screen?
   #---------------------------------------------------------------------------------
    verbose <- TRUE

   #---------------------------------------------------------------------------------
   # Directory separator:  
   # Change to "\\" on Windows and "/" on a mac or linux
   #---------------------------------------------------------------------------------
     sep <- "/" 
     
   #---------------------------------------------------------------------------------
   # Spatial Params, what map projection CRS code do you want to apply?
   # 4326 is long/lat
   #---------------------------------------------------------------------------------
     globalcrs <- 4326


#================================================================================================================
# 2. LIBRARIES (requires all to be up-to-date)
#================================================================================================================
# For for the first time running this in your own R, you need to install these collections of commands. 
#
#     install.packages(c("sp","sf","ncdf4","exactextractr",
#                   "tmap"," leaflet","matlab","remotes",
#                   "parallel","foreach","doParallel",
#                   "dplyr","stringr", "readr","usethis"),dependencies=TRUE)
#
#    remotes::install_github('hgreatrex/Greatrex.Functions',force=TRUE)
#================================================================================================================

  if(verbose){message("Step 0: Loading Global Parameters")}
  if(verbose){message("        Loading libraries and packages")}
  suppressPackageStartupMessages(library(Greatrex.Functions))
     
  suppressPackageStartupMessages(library(tidyverse))
  suppressPackageStartupMessages(library(sp))
  suppressPackageStartupMessages(library(sf))
  suppressPackageStartupMessages(library(raster))
  suppressPackageStartupMessages(library(ncdf4))
  suppressPackageStartupMessages(library(exactextractr))
  suppressPackageStartupMessages(library(tmap))
  suppressPackageStartupMessages(library(leaflet))
  suppressPackageStartupMessages(library(matlab))
  suppressPackageStartupMessages(library(remotes))
  suppressPackageStartupMessages(library(parallel))
  suppressPackageStartupMessages(library(foreach))
  suppressPackageStartupMessages(library(doParallel))
  suppressPackageStartupMessages(library(dplyr))
  suppressPackageStartupMessages(library(stringr))
  suppressPackageStartupMessages(library(readr))
  suppressPackageStartupMessages(library(usethis))
 
 
 #================================================================================================================
 # 3. MAIN FOLDER AND PARALLEL COMPUTING
 #================================================================================================================
   #---------------------------------------------------------------------------------
   # Are you running on a supercomputer/HPC platform? TRUE
   # Or on a single desktop/laptop  FALSE
   #---------------------------------------------------------------------------------
    SuperComputer <- FALSE
   
   #---------------------------------------------------------------------------------
   # Set up initial parameters including the main directory location
   # DO NOT PUT A TRAILING / or \\ AT THE END OR IT WON'T WORK
   # Visibility of this to be improved
   #---------------------------------------------------------------------------------
    if(SuperComputer){
         suppressPackageStartupMessages(library(doMPI))
         dir_main  <- "/gpfs/group/hlg5155/default/RISE"
         cl <- startMPIcluster()
         registerDoMPI(cl)
    }else{
         dir_main        <- "/Users/hlg5155/Dropbox/My Mac (E2-GEO-WKML011)/Documents/GitHub/Somalia/AXA-PSU-Somalia"
         ncores <- detectCores(logical = FALSE)
         registerDoParallel(cores=(ncores-2))
    }
 

   #---------------------------------------------------------------------------------
   # Future features
   #---------------------------------------------------------------------------------
    # grid : make standardised grid(s) here
 
    
  
#=================================================================================
# DIRECTORIES SUB STRUCTURE
#=================================================================================
   #Level 0 
   dir_core        <- paste(dir_main,"Core",sep=sep)
   dir_data        <- paste(dir_core,"Data",sep=sep)
   dir_code        <- paste(dir_core,"Code",sep=sep)

   runset_foldername_rawoutput  <-  "Output1_RawPlots"
   runset_foldername_visualise   <- "Output2_Visualisation"
 
  #Data Level 1
   dir_data_shape           <- paste(dir_data,"1_Shapefiles",    sep=sep)
   dir_data_remote          <- paste(dir_data,"2_Remote_Sensing",sep=sep)
 
  #Data Level 2
   dir_data_remote_ARaw       <- paste(dir_data_remote,"0_Raw_data",sep=sep)
   dir_data_remote_BGeoTif    <- paste(dir_data_remote,"1_Raw_geoTifs",sep=sep)

  #Data Level 3
   dir_data_remote_BGeoTif_daily   <-  paste(dir_data_remote_BGeoTif,"A_QC_data_daily",sep=sep)
   dir_data_remote_BGeoTif_pentad  <-  paste(dir_data_remote_BGeoTif,"B_QC_data_pentad",sep=sep)
   dir_data_remote_BGeoTif_dekad   <-  paste(dir_data_remote_BGeoTif,"C_QC_data_dekad",sep=sep)
   dir_data_remote_BGeoTif_month   <-  paste(dir_data_remote_BGeoTif,"D_QC_data_month",sep=sep)
 


 
   
