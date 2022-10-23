##########################################################################################
# STEP2_Reformat_Data: THIS WILL REFORMAT ALL PRODUCTS TO A STANDARD GEOTIF
# HLG 2021-10-30, V16
#  
# All the satellite data comes in its own unique formats with its own unique quirks
# This code takes all of that and makes it a standardized GeoTif that can be used in the
# rest of the code.
#
# YOU SHOULD HAVE OPENED R-STUDIO BY DOUBLE CLICKING Step0_Core_PROJECTFILE.Rproj
# At the top of your screen, it should say "Core - R-Studio" & the files tab should be looking in the main folder. 
# If not, close R-Studio and reopen correctly
#
##########################################################################################
#-----------------------------------------------------------------------------------------
# YOU SHOULD HAVE OPENED R-STUDIO BY DOUBLE CLICKING Step0_Core_PROJECTFILE.Rproj
# At the top of your screen, it should say "Core - R-Studio" & the files tab should be looking in the main folder. 
# If not, close R-Studio and reopen correctly
#-----------------------------------------------------------------------------------------
 rm(list=ls())
 source("Step0_Global_Parameters.R")
 
#=========================================================================================
# GENERAL PARAMETERS - ANSWER THESE QUESTIONS
#=========================================================================================
   #--------------------------------------------------------------------------------------
   # overwriteGeo (TRUE | FALSE)
   # Do you want to overwrite existing geotifs?
   #--------------------------------------------------------------------------------------
     overwriteGeo <- FALSE

   #--------------------------------------------------------------------------------------
   # Here is the list of all the scripts that the code will attempt to run
   # (missing scripts will simply be ignored)
   #--------------------------------------------------------------------------------------
     Data_Meta <- read.csv("Step0_Datasets.csv")
     print(Data_Meta)
 
#=========================================================================================
# Select the entire script and press Run All
#=========================================================================================
 # DO NOT RUN UNTIL YOU ARE READY FOR A FULL RUN!
     
     source(paste(dir_code,"2a_Extract_rain_Wrapper.R",sep=sep))
     