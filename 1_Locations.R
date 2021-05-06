#================================================================================
# AXA-XL - PSU Somalia Code
# HLG April 2021
# Sub-folder locations
#================================================================================

#--------------------------------------------------------
# Are you on a windows or a mac? [ "/" for mac, "\\" for windows]
#--------------------------------------------------------
computer_sep <- "/" 

#--------------------------------------------------------
# Now set up your folder locations. "." means current directory
# YOU SHOULD REALLY BE USING THE R PROJECT TO RUN THIS CODE
# but you can hardwire it without issue
#--------------------------------------------------------

#--------------------------------------------------------
# Top level
#--------------------------------------------------------
dir_0main           <- "."  
dir_Code            <- paste(dir_0main,"0_Code",sep=computer_sep)
dir_Output          <- paste(dir_0main,"..","AXA-PSU-Output",sep=computer_sep)

#--------------------------------------------------------
# Code folder tree - hardwired
#--------------------------------------------------------
 dir_Code_template <- paste(dir_Code, "0_Templates",sep=computer_sep)
 dir_Code_Download   <- paste(dir_Code, "1_Download",sep=computer_sep) 
 dir_Code_Extract    <- paste(dir_Code, "2_Extract",sep=computer_sep) 
 dir_Code_Analysis   <- paste(dir_Code, "3_Analysis",sep=computer_sep) 
 dir_Code_Dashboard  <- paste(dir_Code, "4_Dashboard",sep=computer_sep) 

#--------------------------------------------------------
# Other satellite data
#--------------------------------------------------------
 InternalSat <- data.frame(Name="TAMSAT_SM",
                           Location="/Volumes/Mac storage space/All_Data/2_Remote_Sensing/1_QC_data_daily/SM_TAMSAT_Full/MeanColumnSoilMoisture",
                           PreAddress="SM_tamsat_nceo_da_wb_v1p0p1_",
                           DateFormat="%Y%m%d",
                           PostAddress=".tif")

 InternalSat
#--------------------------------------------------------
# Output file tree creator 
#--------------------------------------------------------
RunsetDirectory <- function(dir_Output,runset="Test",type="1_Point",create=TRUE,computer_sep="/"){ 
   #-----------------------------------------------------------------   
   # This both creates the folders from the template 
   # and sets up file locations
   #-----------------------------------------------------------------   
   if(create== TRUE){
      
      # See if the file exists
      dir_Runset <- paste(dir_Output,type,runset,sep=computer_sep) 
      if(dir.exists(dir_Runset)){stop(paste("ERROR! Runset: ",type,"/",runset," already exists. Re-name & try again",sep=""))}
      
      # If not, create a new folder, copied over from templates
      newdir <- paste(dir_Output,type,sep=computer_sep) 
      file.copy(from=paste(dir_Code_template,type,sep=computer_sep),to=newdir, recursive=TRUE)
      
      # And rename
      file.rename(from=paste(newdir,type,sep=computer_sep),to=dir_Runset)

   }else{
      dir_Runset <- paste(dir_Output,type,runset,sep=computer_sep) 
      if(!dir.exists(dir_Runset)){stop(paste("ERROR! Runset: ",type,"/",runset," DOES NOT exist. Try again",sep=""))}
   }
   return(dir_Runset)
 }  
 
 
 
 