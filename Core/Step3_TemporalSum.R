##########################################################################################
# STEP3_TemporalSum: THIS WILL REFORMAT ALL PRODUCTS TO A STANDARD GEOTIF
# HLG 2021-10-31, 
# v6. It will also now fill in missing data with blanks and regrid to a standard grid
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
  # Find out which daily datasets there are
  # If you want to edit the datasets being updated, you can change Daily_datasetlist (not recommended)
  #------------------------------------------------------------------------------------------
   Daily_datasetlist  <-  list.files(dir_data_remote_BGeoTif_daily)
   Daily_datasetlist <- Daily_datasetlist[grep("Geo",Daily_datasetlist)]
   Data_Meta <- read.csv("Step0_Datasets.csv")
   names(Data_Meta)[3] <- "Satellite"
   Data_Meta$Stem <- paste(Data_Meta$Family,Data_Meta$Satellite,as.numeric(Data_Meta$Version),sep="_")
   Daily_datasetlist  <- data.frame(Dataset = Daily_datasetlist, Stem=NA)
   Daily_datasetlist$Stem <- substr(Daily_datasetlist$Dataset,1,(unlist(lapply(gregexpr('_', Daily_datasetlist$Dataset),"[",3))-1))
   Daily_datasetlist <- suppressWarnings(merge(Daily_datasetlist,Data_Meta,by="Stem",all.x=TRUE,all.y=FALSE))
   

   #------------------------------------------------------------------------------------------
   # Run the code
   #------------------------------------------------------------------------------------------
   source(paste(dir_code,"3_MissingSubFunctions.R",sep=sep))
   source(paste(dir_code,"3_MissingReplace.R",sep=sep))
   
   
   
   source(paste(dir_code,"3b_TemporalSumFunctionsSub.R",sep=sep))
   source(paste(dir_code,"3_TemporalSumFunctions.R",sep=sep))
   
   #------------------------------------------------------------------------------------------
   # Tidy up
   #------------------------------------------------------------------------------------------
   setwd(dir_core)
   
   # rerun for rhum
   rm(list=ls())
   
  
   