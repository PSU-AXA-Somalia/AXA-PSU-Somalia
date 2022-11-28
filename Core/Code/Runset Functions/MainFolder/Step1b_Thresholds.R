#========================================================================================
# Runset script2: Make Threshold Plots
#
# YOU SHOULD HAVE OPENED R-STUDIO BY DOUBLE CLICKING Step0_Core_PROJECTFILE.Rproj
# At the top of your screen, it should say "Core - R-Studio" & the files tab should be looking in the main folder. 
# If not, close R-Studio and reopen correctly
#========================================================================================

rm(list=ls())

#=========================================================================================
# ANSWER THESE QUESTIONS
#=========================================================================================
   #---------------------------------------------------------------------------------------
   # Do you want to overwrite existing files
   # Leave as FALSE unless you suspect the data is corrupted
   #---------------------------------------------------------------------------------------
   overwrite <- FALSE
   
   #---------------------------------------------------------------------------------------
   # What thresholds do you want?
   #---------------------------------------------------------------------------------------
   levels.Daily   <- c(0,5,10,20,30,50)
   levels.Pentad  <- c(0,5,10,20,30,50)
   levels.Dekadal <- c(0,5,10,20,30,50)
   levels.Month   <- c(0,5,10,20,30,50,100)
   
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
   Dekad_datasetlist  <- list.files(dir_data_remote_BGeoTif_dekad)
   Month_datasetlist  <- list.files(dir_data_remote_BGeoTif_month)
   
   #------------------------------------------------------------------------------------------
   # Run the code
   #------------------------------------------------------------------------------------------
   source(paste(dir_code,"1b_Threshold_sub.R",sep=sep))
   source(paste(dir_code,"1b_Threshold.R",sep=sep))
   
   #------------------------------------------------------------------------------------------
   # Tidy up
   #------------------------------------------------------------------------------------------
   setwd(dir_runset)
   rm(list=ls())
   