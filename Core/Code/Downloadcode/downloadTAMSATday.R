library(foreach)
library(doParallel)
ncores <- detectCores(logical = FALSE)
registerDoParallel(cores=(ncores-1))

stem <- "https://gws-access.jasmin.ac.uk/public/tamsat/rfe/data/v3.1/daily/"

datelist <- seq(as.Date("2021-01-01"),as.Date("2022-02-01"), by="d")
monthlist <- substr(datelist,6,7)
yearlist <- substr(datelist,1,4)
filedates <- format.Date(datelist,"%Y_%m_%d")
destfolder <- "/Users/hlg5155/Dropbox/My Mac (E2-GEO-WKML011)/Documents/GitHub/Somalia/AXA-PSU-Somalia/Core/Data/2_Remote_Sensing/0_Raw_data/rain_TAMSAT_3.1_Raw"

DownloadFunct <- function(d,stem,yearlist,monthlist,filedates,destfolder) {
   folder <- paste(stem,"/",yearlist[d],"/",monthlist[d],sep="")
   filename <- paste("rfe",filedates[d],".v3.1.nc",sep="")
   url <- paste(folder,filename,sep="/")
   dest <- paste(destfolder,filename,sep="/")
   download.file(url,dest,quiet=FALSE)
}   


res <- foreach(d = 1:length(datelist)) %dopar% DownloadFunct(d,stem,yearlist,monthlist,filedates,destfolder)
