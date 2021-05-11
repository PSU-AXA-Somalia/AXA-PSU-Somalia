#================================================================================
# AXA-XL - PSU Somalia Code
# HLG April 2021
# This script downloads, collates and saves 
# point specific data for a range of satellite products from the IRI data library
#================================================================================
 dir_Output_data <- paste(dir_Runset,"0_Data",sep=computer_sep)
 working <- getwd()
 library(velox)
 
#---------------------------------------------------------------------------------
# And a function to extract the data
#---------------------------------------------------------------------------------
 extractpoint <- function(filename,location.sp,location,n){
   e <- extent(location$lon[n]-1, location$lon[n]+1, 
               location$lat[n]-1, location$lat[n]+1)
    
   r <- velox(filename)
   r$crop(e)
   return(r$extract_points(location.sp))
 }

#---------------------------------------------------------------------------------
# Cycle through each product & location
#---------------------------------------------------------------------------------
 for(n in 1:nrow(location)){
    print(location[n,])
   
    #-----------------------------------------------------------------------------
    # Create a place to store the output
    #-----------------------------------------------------------------------------
    satellite_container <- vector(mode="list",length = nrow(InternalSat))
    names(satellite_container) <- InternalSat$Name
   
    #-----------------------------------------------------------------------------
    # and extract for each product
    #-----------------------------------------------------------------------------
    for(s in 1:nrow(InternalSat)){
       setwd(InternalSat$Location[s])
       print(InternalSat$Name[s])
       satout <- data.frame(Date=datelist,Data=NA)
       
       #--------------------------------------------------------------------------
       # This could be parallelized to make it go faster
       #--------------------------------------------------------------------------
       for(d in 1:length(datelist)){
          if(d %in% seq(from=1,to=100000,by=1000)){print(datelist[d])}
          filename <- paste(InternalSat$PreAddress,
                            format.Date(datelist[d],InternalSat$DateFormat),
                            InternalSat$PostAddress,sep="")
          if(file.exists(filename)){
             satout$Data[d] <- extractpoint(filename,location.sp,location,n)
          }
       }
       
    } 
 }
 
 
 
 setwd(working)     