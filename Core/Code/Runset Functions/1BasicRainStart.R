
window <- c("Apr-1","Jul-15")
windowdates <- format.Date(seq(from=as.Date(paste(2000,window[1]),format="%Y %b-%d"),
                                 to=as.Date(paste(2000,window[2]),format="%Y %b-%d"),by="d"),"%b-%d")

products_stem <- "rain"

products_daily_function <- products_daily[grep(paste(products_stem,"_",sep=""),products_daily)]

# DAILY
print("DAILY")

for(p in 1:length(products_daily_function)){
   indirectory <- paste(dir_runset_data_daily,products_daily_function[p],sep=sep)
   productfiles <- list.files(indirectory)
   productfiles <- productfiles[(grep(".tif",productfiles))]
   print(products_daily[p])
   
   AllDates <- as.Date(substr(productfiles,nchar(productfiles)-13,nchar(productfiles)-4))
   DoyList  <- format.Date(AllDates,"%b-%d")
   yearlist <- format.Date(AllDates,"%Y")
   
   datetable <- data.frame(Date=AllDates,DOY=DoyList,Year=yearlist)
   
   windowdatetable <- datetable[which(datetable$DOY %in% windowdates),]
   windowdatelist <- split(windowdatetable,windowdatetable$Year)
   years <- unlist(lapply(split(windowdatetable$Year,windowdatetable$Year),"[",1))
   names(windowdatelist) <- years
   
   outputraster <- vector(mode="list",length=length(windowdatelist))
   
   for(y in 1:length(windowdatelist)){
      print(years[y])
      r <- stack(paste(indirectory,productfiles[which(as.Date(datetable$Date) %in% as.Date(windowdatelist[[y]]$Date))],sep=sep))
      animate(r, pause = 0.25, n = 1)
   }
   
   #seasonal start
   #SM vs rain season start
   #length dry season
   #Normal now
   
}   