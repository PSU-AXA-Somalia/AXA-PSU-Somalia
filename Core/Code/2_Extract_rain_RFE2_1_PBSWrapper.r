#=================================================================================
# HLG 2021,
# This converts raw RFE2 data to my standardised format
# The top part comes from the wrapper
# PBS JOB TEST
#=================================================================================
rm(list=ls())

#------------------------------------------------------------------------------------------
# Load directory locations and libraries, plus the meta data stored in the main level csv
#------------------------------------------------------------------------------------------
overwrite<-FALSE
source("../Step0_Global_Parameters.R")
Data_Meta <- read.csv("../Step0_Datasets.csv")
Script_All <- paste(dir_code,Data_Meta$ConvertScript,sep=sep)

#---------------------------------------------------------------------------------
# Dataset parameters
#---------------------------------------------------------------------------------
n_data <-  which(Data_Meta$Dataset %in% "RFE2")
family   <- Data_Meta$Family[n_data]
dataset  <- Data_Meta$Dataset[n_data]
version  <- Data_Meta$Version[n_data]
modified <- Data_Meta$Modified[n_data]
print(dir_core)

source("2_Extract_rain_RFE2_1.R")

