
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
   Runset <- "South_Subset_new"
 
  #---------------------------------------------------------------------------------------
  # SaveAnalysis 
  #   IF you want to overwrite to the same runset name, do you want to save your past analysis?  
  #   TURN SaveAnalysis off if you have already run this code to save a backup of your work 
  #   or it will keep making copies (up to 5 times)
  #---------------------------------------------------------------------------------------
   SaveAnalysis <- TRUE
 
  #---------------------------------------------------------------------------------------
  # Output folder override
  # 
  # This code will assume that the output folders in your runset are named as per 0_Global_Parameters. 
  # To see what these are - copy these 3 lines of code into the console (without the trailing zeros) 
  #    source("Step0_Global_Parameters.R")
  #    paste("Raw Output folder name:",runset_foldername_rawoutput)
  #    paste("Visualisation folder name: ",runset_foldername_visualise)
  #
  # IF THIS IS INCORRECT AND YOUR WANT YOUR OUTPUT TO BE SAVED, please update the names here (in quote marks)
  # IF YOU ARE HAPPY, LEAVE AS NA   
  #---------------------------------------------------------------------------------------
   override_analysisfoldername <- NA
   override_visualisationfoldername <- NA
   
  #---------------------------------------------------------------------------------------
  # Do you want your data folder in the runset or host it on say a hard drive
  # Either put "auto" or the address (in quotes that you want it in)
  #---------------------------------------------------------------------------------------
   datadir_loc <- "~/Desktop/"
   
    
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
         Box.MinLong <- 40.5   ;   Box.MaxLong <- 45
         Box.MinLat  <- 1  ;   Box.MaxLat  <- 5.25

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
           Shapefile.Folder <- paste(dir_data_shape,"gadm36_SOM_shp",sep=sep)  
           Shapefile.Name   <- "gadm36_SOM_2" 
           
           Shapefile.croptype <- "box"
           Box.buffer  <- 0.2
           
           Shapefile.ColName  <- "NAME_1"
           Shapefile.ColValue <- "Gedo"  

           
#=========================================================================================
# RUN CODE
# Highlight everything in this script and press Run All
#=========================================================================================
 source(paste(dir_code,"4_Crop_To_Runset_code.R",sep=sep))
 dir.remove(dir_data_remote_BGeoTif_daily_regrid_10)          

           
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
           
           
           
           
           
           
           
           
           
           
           
           
           