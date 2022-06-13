library(foreach)
library(doParallel)
ncores <- detectCores(logical = FALSE)
registerDoParallel(cores=(ncores-1))

folder <- "https://ftp.cpc.ncep.noaa.gov/fews/fewsdata/africa/rfe2/geotiff"

datelist <- seq(as.Date("2021-01-01"),as.Date("2022-02-25"), by="d")
monthlist <- substr(datelist,6,7)
yearlist <- substr(datelist,1,4)
filedates <- format.Date(datelist,"%Y%m%d")
destfolder <- "/Users/hlg5155/Dropbox/My Mac (E2-GEO-WKML011)/Documents/GitHub/Somalia/AXA-PSU-Somalia/Core/Data/2_Remote_Sensing/0_Raw_data/rain_RFE2_1_Raw"

DownloadFunct <- function(d,stem,yearlist,monthlist,filedates,destfolder) {
   filename <- paste("africa_rfe.",filedates[d],".tif.zip",sep="")
   url <- paste(folder,filename,sep="/")
   dest <- paste(destfolder,filename,sep="/")
   download.file(url,dest,quiet=FALSE)
}   


res <- foreach(d = 1:length(datelist)) %dopar% DownloadFunct(d,stem,yearlist,monthlist,filedates,destfolder)

