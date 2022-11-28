##########################################################################################
# STEP3_TemporalSum
#
# This script will temporally average the satellite data to pentadal, dekadal and monthly
# formats.  It will also now fill in missing data with blanks and regrid to a standard grid.
##########################################################################################
rm(list=ls())

# The next updates will be to make availability plots and a selection of grids

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
   
   #---------------------------------------------------------------------------------------
   # Do you want to try and find small gaps of missing data from the IRI data library? 
   # Leave as TRUE unless you have no internet (< 5 day gaps only)
   #---------------------------------------------------------------------------------------
   iridl <- TRUE
   
   #---------------------------------------------------------------------------------------
   # There are three options for searching for missing data
   # "data", from the beginning to end of the data in the folder e.g. just look for gaps
   # "year", the Jan-1 in the first year of data, to Dec-31 in the final year
   # "all", all data from the start to present
   #---------------------------------------------------------------------------------------
   missingchoice  <- "data"
   
   #---------------------------------------------------------------------------------------
   # What is your regrid template?
   #---------------------------------------------------------------------------------------
   regrid_template <- "Grid10.tif"
   
#======================================================================================== 
# RUN THE SCRIPTS, SELECT ALL THE TEXT IN THE WHOLE FILE AND PRESS RUN-ALL
#========================================================================================= 
  #---------------------------------------------------------------------------------------
  # Load the functions     
  #---------------------------------------------------------------------------------------
   source("Step0_Global_Parameters.R")

   #------------------------------------------------------------------------------------------
   # Run the missing data code
   #------------------------------------------------------------------------------------------
   source(paste(dir_code,"3_MissingReplace.R",sep=sep))
   
   #------------------------------------------------------------------------------------------
   # Run the temporal sum code
   #------------------------------------------------------------------------------------------
   source(paste(dir_code,"3_TemporalSumFunctions.R",sep=sep))
   
   #------------------------------------------------------------------------------------------
   # Tidy up
   #------------------------------------------------------------------------------------------
   setwd(dir_core)
   rm(list=ls())
   
   