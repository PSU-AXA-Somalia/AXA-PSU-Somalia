##########################################################################################
# STEP3_TemporalSum: THIS WILL REFORMAT ALL PRODUCTS TO A STANDARD GEOTIF
# HLG 2021-10-31, 
# v6. It will also now fill in missing data with blanks
#  
# This script will temporally average the satellite data to pentadal, dekadal and monthly
# formats.  You should be running R-Studio using the R project
##########################################################################################
 rm(list=ls())

#========================================================================================= 
# GENERAL PARAMETERS, ANSWER THESE QUESTIONS  
#=========================================================================================
  #---------------------------------------------------------------------------------------
  # How much days would you accept as missing before the entire pentad/dekad/month
  # should be marked as missing
  #   -Pentad (~5 days in a pentad, 6 per month)
  #   -Dekad (~10 days in a dekad, 3 per month)
  #   -Monthly 
  #---------------------------------------------------------------------------------------
   missinglimitpentad <- 1
   missinglimitdekad  <- 3
   missinglimitmonth  <- 5
  
  #---------------------------------------------------------------------------------------
  # Do you want to overwrite existing pentadal/dekadal/monthly file
  # Leave as FALSE unless you suspect the data is corrupted
  #---------------------------------------------------------------------------------------
   overwrite <- FALSE

#======================================================================================== 
# RUN THE SCRIPTS, SELECT ALL THE TEXT IN THE WHOLE FILE AND PRESS RUN-ALL
#========================================================================================= 
  #---------------------------------------------------------------------------------------
  # Load the functions     
  #---------------------------------------------------------------------------------------
   source("Step0_Global_Parameters.R")

  #------------------------------------------------------------------------------------------
  # Find out which daily datasets there are
  # If you want to edit the datasets being updated, you can change Daily_datasetlist (not recommended)
  #------------------------------------------------------------------------------------------
   Daily_datasetlist  <-  list.files(dir_data_remote_BGeoTif_daily)

   #------------------------------------------------------------------------------------------
   # Run the code
   #------------------------------------------------------------------------------------------
   source(paste(dir_code,"3b_TemporalSumFunctionsSub.R",sep=sep))
   source(paste(dir_code,"3_TemporalSumFunctions.R",sep=sep))
   
   #------------------------------------------------------------------------------------------
   # Tidy up
   #------------------------------------------------------------------------------------------
   setwd(dir_core)
   rm(list=ls())
   
   

