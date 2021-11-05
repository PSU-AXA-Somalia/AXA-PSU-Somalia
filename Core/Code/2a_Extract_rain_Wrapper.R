#=========================================================================================
# This is linked with Step2_Reformat_Data (or with the appropriate pbs file)
# It will not run in isolation
#=========================================================================================

   if(verbose %in% c(TRUE,"Limited")){message("\nStep 2: Starting Data Conversion")}
   
   #------------------------------------------------------------------------------------------
   # Run each script in turn
   #------------------------------------------------------------------------------------------
   Script_All <- paste(dir_code,Data_Meta$ConvertScript,sep=sep)
   
   for(n_data in seq_along(Script_All)){
      if(verbose %in% c(TRUE,"Limited")){message(paste("\n   Running",Data_Meta$ConvertScript[n_data]))}
      
      # Check it exists 
      if(!file.exists(Script_All[n_data])){
         if(verbose %in% c(TRUE,"Limited")){message(paste("       This script is missing and the data will be ignored \n       ",Script_All[n_data],"\n"))}
         
      }else{
         # If it exists, then run
         family   <- Data_Meta$Family[n_data]
         dataset  <- Data_Meta$Dataset[n_data]
         version  <- Data_Meta$Version[n_data]
         modified <- Data_Meta$Modified[n_data]
         source(Script_All[n_data])
      }
   }
   setwd(dir_core)
   rm(list=ls())
   