#========================================================================================
# Runset script2: Make Climatologies/Anomalies
#
# YOU SHOULD HAVE OPENED R-STUDIO BY DOUBLE CLICKING Step0_Core_PROJECTFILE.Rproj
# At the top of your screen, it should say "Core - R-Studio" & the files tab should be looking in the main folder. 
# If not, close R-Studio and reopen correctly
#========================================================================================

rm(list=ls())

#=========================================================================================
# ANSWER THESE QUESTIONS
#=========================================================================================
   # --------------------------------------------------------------------------------------
   # What is the min/max year that you would like?
   #--------------------------------------------------------------------------------------
   minyear <- 2001
   maxyear <- 2021

   #---------------------------------------------------------------------------------------
   # How much days would you accept as missing before the entire year
   # should be marked as missing
   #---------------------------------------------------------------------------------------
   missinglimit <- 1000

   #---------------------------------------------------------------------------------------
   # Do you want to overwrite existing climatologies
   # Leave as FALSE unless you suspect the data is corrupted
   #---------------------------------------------------------------------------------------
   overwrite <- FALSE

#======================================================================================== 
# RUN THE SCRIPTS, SELECT ALL THE TEXT IN THE WHOLE FILE AND PRESS RUN-ALL
#========================================================================================= 
   #---------------------------------------------------------------------------------------
   # Load the functions     
   #---------------------------------------------------------------------------------------
   source("Step0_Runset_Parameters.R")
   
   #------------------------------------------------------------------------------------------
   # Find out which daily datasets there are
   # If you want to edit the datasets being updated, you can change Daily_datasetlist (not recommended)
   #------------------------------------------------------------------------------------------
   Daily_datasetlist  <- list.files(dir_data_remote_BGeoTif_daily)
   Pentad_datasetlist  <- list.files(dir_data_remote_BGeoTif_pentad)
   Dekad_datasetlist  <- list.files(dir_data_remote_BGeoTif_dekad)
   Month_datasetlist  <- list.files(dir_data_remote_BGeoTif_month)
   
   #------------------------------------------------------------------------------------------
   # Run the code
   #------------------------------------------------------------------------------------------
   source(paste(dir_code,"1a_ClimateAnomCode_sub.R",sep=sep))
   source(paste(dir_code,"1a_ClimateAnomCode.R",sep=sep))
   
   #------------------------------------------------------------------------------------------
   # Tidy up
   #------------------------------------------------------------------------------------------
   setwd(dir_runset)
   rm(list=ls())
   