
####################################################
# THIS CODE DOWNLOADS EVI or NDVI DATA
# HLG - 21st July 2014
####################################################

#---------------------------------------------------------------------------
# 1 - Do you want EVI or NDVI?
#---------------------------------------------------------------------------
  vi.name <- "EVI"

#---------------------------------------------------------------------------
# 2 - Which directory would you like to put the file in?
#---------------------------------------------------------------------------
  FileDir <- "~/Documents" 

#---------------------------------------------------------------------------
# 2 - First select your data (currently set to Senegal)
#---------------------------------------------------------------------------
 # 1 - What's the top left coordinate of your box (North-West) 
 TL_long <- 14.1
 TL_lat <- -14.3

 # 4 - What's the bottom right coordinate of your box (South-East)
 BR_long <- 13.9
 BR_lat   <- -14.1

 #---------------------------------------------------------------------------
# 3 - Do you want the raw 16-daily data?  Or do you want averages for a specific month?
#      Set to "Raw" for the raw data
#      Set to "Monthly" for a monthly average
# 
#  If you chose Monthly, which month would you like to download? 
#  You can ignore this or set it to NA if you chose Raw
#---------------------------------------------------------------------------
  DownloadType <- "Monthly"
  Month <- 7
  
    
####################################################
# DON'T EDIT THE CODE BELOW THIS LINE.
# Select all the code in the script, right click and press run
####################################################
 DownloadType <- toupper(DownloadType)

#---------------------------------------------------------------------------
# This works out which part of Africa you're in
#---------------------------------------------------------------------------
  if(TL_long >= 20 & BR_long <= 60 & BR_lat >= 0 & TL_lat <= 40){
    Zone <- "EAF"
  } else if(TL_long >= -20 & BR_long <= 20 & BR_lat >= 0 & TL_lat <= 40){
    Zone <- "WAF"
  } else if(TL_long >= 20 & BR_long <= 50 & BR_lat >= 0 & TL_lat <= 20){
    Zone <- "Horn_of_Africa"
  } else if(TL_long >= 8 & BR_long <= -51 & BR_lat >= -35 & TL_lat <= 0){
    Zone <- "SAF"
  }else{
  	  print("Location out of range")
  }	    
  
#---------------------------------------------------------------------------
# Now create the URL.  See my e-mail for more details      
#---------------------------------------------------------------------------
 ad1 <- "http://iridl.ldeo.columbia.edu/expert/SOURCES/.USGS/.LandDAAC/.MODIS/.version_005/."
 ad2 <- paste0(Zone, "/.", vi.name)
 ad3 <- paste0("/X/", BR_lat, "/", TL_lat, "/RANGEEDGES")
 ad4 <- paste0("/Y/", BR_long, "/", TL_long, "/RANGEEDGES")
 ad5 <- "/[X/Y]average/"
 
 if(DownloadType == "MONTHLY"){
    Month <- month.abb[Month]  	
    ad6 <- paste0("T/monthlyAverage/T/(", Month, ")RANGE/")
 }else{
    ad6 <- ""	
 } 	   
 
 ad7 <- "T+exch+table-+text+text+-table++.csv"

 vec <- paste0("ad",1:7) 

#---------------------------------------------------------------------------
# Need to ensure get function calls variables from proper environment      
# This is something that's good for R to do.  You don't need to worry about it
#---------------------------------------------------------------------------
  myfunc <- function(x){
    return(get(x,envir = as.environment(-1)))
  }    
  
  url.name <- capture.output(cat(unlist(lapply(vec,myfunc)), sep = "", collapse = ""))
  vi.out <- paste0(FileDir,"/", DownloadType,vi.name,"_",TL_lat,"_",BR_lat,"_",TL_long,"_",BR_long,".csv")  # temp output file 
  download.file(url.name, vi.out, cacheOK = FALSE)
  
  print("Your file can be found at")
  print(vi.out,quote=FALSE)

