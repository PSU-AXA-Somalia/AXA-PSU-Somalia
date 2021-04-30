#================================================================================
# AXA-XL - PSU Somalia Code
# HLG April 2021
# This script downloads (extracts?), collates and saves 
# point specific data for a range of satellite products
#================================================================================
#--------------------------------------------------------------------------------
# Load libraries
#--------------------------------------------------------------------------------
rm(list=ls())
library(chirps)
 

#--------------------------------------------------------------------------------
# Choose Meta data
#--------------------------------------------------------------------------------
#--------------------------------------------------------
 # Location
 #--------------------------------------------------------
 location <- data.frame(lon = c(42.2362,42.2362),
                        lat = c(3.5039,4 ))

 #--------------------------------------------------------
 # Time
 #--------------------------------------------------------
 startdate <- as.Date("2002-05-01")
 enddate   <- as.Date("2020-05-01")

 #--------------------------------------------------------
 # Are you on a windows or a mac? [ "/" for mac, "\\" for windows]
 #--------------------------------------------------------
 mac_sep <- "/" 


#--------------------------------------------------------------------------------
# Set up download locations
#--------------------------------------------------------------------------------
 # U. Reading TAMSAT3 - 1983-present, Africa only  
 # IR only, but calibrated against extensive gauge sources
 satellites <- data.frame(Name="TAMSAT",
                          Web="http://iridl.ldeo.columbia.edu/SOURCES/.Reading/.Meteorology/.TAMSAT/.v3p0/.daily/.rfe",
                          Date="%d %b %Y")
 
 # NOAA ARC2 - 1983-present, Africa only
 # IR with gauge, significant spurious trend in E. Africa
 satellites <- rbind(satellites, c("ARC2", 
                                   "http://iridl.ldeo.columbia.edu/expert/SOURCES/.NOAA/.NCEP/.CPC/.FEWS/.Africa/.DAILY/.ARC2/.daily/.est_prcp",
                                   "%d %b %Y"))

 # NOAA RFE2 - 2000-present, Africa only.  
 # IR with Passive microwave and merged gauges
 satellites <- rbind(satellites, c("RFE2",
                                   "https://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NCEP/.CPC/.FEWS/.Africa/.DAILY/.RFEv2/.est_prcp",
                                   "%d %b %Y"))
 
 # UCSB CHIRPS, 1981-present, Global tropics  
 satellites <- rbind(satellites, c("CHIRPS",
                                   "https://iridl.ldeo.columbia.edu/SOURCES/.UCSB/.CHIRPS/.v2p0/.daily-improved/.global/.0p25/.prcp",
                                   "%d %b %Y"))
 
 # NASA TRMM 3B42 - 1998-2014  on board radar, IR, PM.., Global tropics  
 # The radar fell out the sky in 2014, so expect post 2014 skill to change dramatically
 satellites <- rbind(satellites, c("TRMM",
                                   "https://iridl.ldeo.columbia.edu/SOURCES/.NASA/.GES-DAAC/.TRMM_L3/.TRMM_3B42/.v7/.daily/.precipitation",
                                   "%d %b %Y"))
 
 #--------------------------------------------------------------------------------
 # and download for each location.  NEED TO SWAP LOOPS AROUND
 #--------------------------------------------------------------------------------
 for(n in 1:nrow(location)){
   print(location[n,])

    #-----------------------------------------------------------------------------
    # Create a place to store the output
    #-----------------------------------------------------------------------------
    satellite_container <- vector(mode="list",length = nrow(satellites))
    names(satellite_container) <- satellites$Name
 
    for(s in 1:nrow(satellites)){
      print(satellites$Name[s])
       #----------------------------------------
       # Select the location
       #----------------------------------------
       X  <-  location$lon[n]
       Y  <-  location$lat[n]
       
       #----------------------------------------
       # Create an IRI data library URL
       #----------------------------------------
       prexyaddress<- satellites$Web[s]
       timestuff <- paste("T/%28", format.Date(startdate,"%d"),"%20",format.Date(startdate,"%b"),"%20",format.Date(startdate,"%Y"),
                          "%29%28",format.Date(enddate,"%d"),"%20",  format.Date(enddate,"%b"),  "%20",format.Date(enddate,"%Y"),"%29RANGEEDGES",sep="")
       xystuff<-paste("Y/%28",Y,"%29VALUES/X/%28",X,"%29VALUES",sep="")
       postxyaddress<-"CopyStream/T+exch+table-+text+text+skipanyNaN+-table+.csv"
       
       address<-paste(prexyaddress,timestuff,xystuff,postxyaddress,sep=mac_sep)
       
       
       #----------------------------------------
       # Download
       #----------------------------------------
       file.name <- paste("tmp.csv",sep="")
       download.file(address,file.name,quiet=FALSE,method="wget")
       
       #----------------------------------------
       # Read in and add to the final data frame. You could make this a list, add columns, whatever
       #----------------------------------------
       satellite_container[[s]] <- read.csv("tmp.csv")
       file.remove("tmp.csv")
       names(satellite_container[[s]]) <- c("Date",satellites$Name[s])
       satellite_container[[s]]$Date <- as.Date(satellite_container[[s]]$Date,format=satellites$Date[s])

    }
    
    dataout <- satellite_container[[1]]
    
    for (s in 2:nrow(satellites)){
        dataout <- merge(dataout,satellite_container[[s]],by="Date",all.x=TRUE,all.y=TRUE)
    }
    
    fname <- paste("pointdata_",location$lon[n],"_",location$lat[n],sep="")
    fname <- paste(str_replace_all(fname,"\\.","-"),".csv",sep="")
    write.csv(dataout,fname,row.names=FALSE,quote=FALSE)
    
 }   
 
 
 