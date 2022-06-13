#=========================================================================================
# This is linked with Step2_Reformat_Data (or with the appropriate pbs file)
# It will not run in isolation
#=========================================================================================

if(verbose %in% c(TRUE,"Limited")){message("\nStep 2: Starting Data Conversion")}

#------------------------------------------------------------------------------------------
# Run each script in turn
#------------------------------------------------------------------------------------------
Script_All <- paste(dir_code,Data_Meta$ConvertScript,sep=sep)

#------------------------------------------------------------------------------------------
# n_data cycles through each product e.g. n_data=1 will run ARC2 and the R script specified
# in the first row of Data_Meta
#------------------------------------------------------------------------------------------
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
      
      # Make the folder and check
      if((nchar(modified) > 0)&(is.na(modified)==FALSE)){
         StemIn  <- paste(family,dataset,version,modified,"Raw",sep="_")
         StemOut <- paste(family,dataset,version,modified,"Geo",sep="_")
      }else{
         StemIn  <- paste(family,dataset,version,"Raw",sep="_")
         StemOut <- paste(family,dataset,version,"Geo",sep="_")
      }
      
      if((!dir.exists(paste(dir_data_remote_ARaw,StemIn,sep="/")))|(length(dir(path=paste(dir_data_remote_ARaw,StemIn,sep="/"),all.files=TRUE))==0)){
         if(verbose %in% c(TRUE,"Limited")){message(paste("       No data so this will be ignored \n       ",Script_All[n_data],"\n"))}
      }else{
         source(Script_All[n_data])
      }   
   }
}
setwd(dir_core)
rm(list=ls())
