
##########################################################################################
# STEP2a_Crop_To_Runset: CROP TO RUNSET AREA
# HLG 2021-10-30, V1
#  
# This script will help you crop to a smaller area and create the runset folder
##########################################################################################
 rm(list=ls())
 Data_Meta <- read.csv("Step0_Datasets.csv")
 source("Step0_Global_Parameters.R")

#=========================================================================================
# GENERAL PARAMETERS - ANSWER THESE QUESTIONS
#=========================================================================================
  #---------------------------------------------------------------------------------------
  # Runset name. 
  #  What do you want to call your runset? E.g. what should the folder be called?
  #  If you want to auto-name from the shapefile/bounding box, then put as NA
  #---------------------------------------------------------------------------------------
   Runset <- "South_Somalia"
 
  #---------------------------------------------------------------------------------------
  # SaveAnalysis 
  #   IF you want to overwrite to the same runset name, do you want to save your past analysis?  
  #   TURN SaveAnalysis off if you have already run this code to save a backup of your work 
  #   or it will keep making copies (up to 5 times)
  #---------------------------------------------------------------------------------------
   SaveAnalysis <- TRUE
 
  #---------------------------------------------------------------------------------------
  # RUNSET Remote Sensing data location
  # If want to  store the data elsewhere, add the address here
  # Else set to NA for auto
  #---------------------------------------------------------------------------------------
   dir_data_runset_override <- NA
   
    
#=========================================================================================
# SPATIAL CROP OPTIONS - ANSWER THESE QUESTIONS
#=========================================================================================
  #---------------------------------------------------------------------------------------
  # SubsetOption: Where do you want to subset to?  
  #    A box [1] or to the borders of a shapefile/subset of one? [2]
  #---------------------------------------------------------------------------------------
    SubsetOption <- 1

       #----------------------------------------------------------------------------------
       # IF OPTION 1 (box) - Else set each to NA
       # Add your box coordinates here in lat/long 
       #
       # If you want a buffer around your box for plots, 
       #  Add in degrees the width of the buffer/border/margin 
       #  Else set to 0.
       #----------------------------------------------------------------------------------
         Box.MinLong <- 40.5   ;   Box.MaxLong <- 46.25
         Box.MinLat  <- -2  ;   Box.MaxLat  <- 5.75
         

         Box.buffer  <- 0.2

         #----------------------------------------------------------------------------------
         # IF OPTION 2 (Shapefile) - Else set each to NA
         #
         # Shapefile.Folder
         #   Add the location  on your computer of the shapefiles, 
         #
         # Shapefile.Folder
         #   Add the name  of the shapefile
         #
         # Shapefile.croptype (choose "box)
         #   Exact subset cropped to shapefile border? ["exact"]  [FUTURE]
         #   Or box around that shapefile? ["box"]  [THIS ONE WORKS]
         # 
         # If you want a buffer around your box for plots, 
         #   Add in degrees the width of the buffer/border/margin
         #
         # OPTIONAL - if you want use only part of a shapefile for this (say one region)
         #    
         #
         #  Shapefile.ColName
         #    What column should I look for the subset in? (else set to NA)
         #
         #  Shapefile.ColValue
         #    What value in this column indicates your subset? (else set to NA)
         #----------------------------------------------------------------------------------
           Shapefile.Folder <- paste(dir_data_shape,"gadm41_PAK_shp",sep=sep)  
           Shapefile.Name   <- "gadm41_PAK_1" 
           
           Shapefile.croptype <- "box"
           Box.buffer  <- 0.2
           
           Shapefile.ColName  <- NA#"NAME_1"
           Shapefile.ColValue <- NA#"Gedo"  

           
#=========================================================================================
# All Products? [ALL] or just certain ones? (make vector)
# Run  list.files(dir_data_remote_BGeoTif_daily,pattern="Grid",recursive=FALSE)
#  to see what they are           
#=========================================================================================
   ProductChoice <- c("rain_CHIRPS_2",
                 "tmax_CHIRTS_1",
                 "tmin_CHIRTS_1",
                 "rain_RFE2_1",
                 "rain_TAMSAT_3.1",
                 "sm_TAMSAT_1_smc_avail_top",
                 "sm_TAMSAT_1_smcl_1",
                 "sm_TAMSAT_1_smcl_2",
                 "sm_TAMSAT_1_smcl_3",
                 "sm_TAMSAT_1_smcl_4",
                 "sm_TAMSAT_1_MeanColumnSoilMoisture")        
           
           
#=========================================================================================
# RUN CODE
# Highlight everything in this script and press Run All
#=========================================================================================
 source(paste(dir_code,"4_Crop_To_Runset_code.R",sep=sep))

           
#=========================================================================================
# Hint! 
#  
#  If you're not sure how to find the column/value of your region in the shapefile,
#  Use this command in the console to read in a shapefile of your choice and take a look
#    quickcheck <- (sf::st_read(file.choose())); head(quickcheck)
#
#  You can then use the table command to see the potential regions e.g.
#  table(quickcheck$NAME_1)
#  THIS IS CASE SENSITIVE
# 
#  And tmap's QTM to make a quick plot of that column
#  tmap:qtm(quickcheck,fill="NAME_1")
#=========================================================================================
           
           
           
           
           
           
           
           
           
           
           
           
           