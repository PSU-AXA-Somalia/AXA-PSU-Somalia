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

# Top level
dir_0main           <- "."  
dir_Code            <- paste(dir_0main,"0_Code",sep=computer_sep)
dir_Output          <- paste(dir_0main,"..","AXA-PSU-Output",sep=computer_sep)


# Code folder tree - hardwired
 dir_Output_template <- paste(dir_Code, "0_Template",sep=computer_sep)
 dir_Code_Download   <- paste(dir_Code, "1_Download",sep=computer_sep) 
 dir_Code_Extract    <- paste(dir_Code, "2_Extract",sep=computer_sep) 
 dir_Code_Analysis   <- paste(dir_Code, "3_Analysis",sep=computer_sep) 
 dir_Code_Dashboard  <- paste(dir_Code, "4_Dashboard",sep=computer_sep) 

 
# Output file tree creator 
RunsetDir <- function(dir_Output,runset="Test",type="1_Point",create=TRUE,computer_sep="/"){ 
   #-----------------------------------------------------------------   
   # This both creates the folders from the template 
   # and sets up file locations
   #-----------------------------------------------------------------   
   
   if(create== TRUE){
      newdir <- paste(dir_Output,type,runset,sep=computer_sep) 
      if(dir.exists(newdir)){stop(paste("ERROR! Runset: ",type,"/",runset," already exists. Re-name & try again",sep=""))}
      dir.create(newdir)
      file.copy(from=dir_Output_template, 
                to=newdir, recursive=TRUE)
   }
}  
   dir_Runset            <- paste(dir_Output,type,sep=computer_sep)
   dir_Runset_Download   <- paste(dir_Code, "0_Download",sep=computer_sep) 
   dir_Runset_Extract    <- paste(dir_Code, "1_Extract",sep=computer_sep) 
   dir_Runset_Analysis   <- paste(dir_Code, "2_Analysis",sep=computer_sep) 
   dir_Runset_Dashboard  <- paste(dir_Code, "3_Dashboard",sep=computer_sep) 
} 
 