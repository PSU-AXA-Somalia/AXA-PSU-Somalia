#' Make a standard table of dates from the R datelist you feed it
#'
#' Sometimes it is nice to just extract the attributes of an R date-list rather than messing with the date format
#' This takes a vector of dates and outputs a data.frame containing the following
#'
#' ColumnName (class)    : Description (strptime code as appropriate)
#'
#'  - Date         (Date)       : Date in yyyy-mm-dd format.
#'  - Year         (numeric)    : Year (as.numeric(%Y))
#'  - Month        (numeric)    : Month (as.numeric(%m))
#'  - Day          (numeric)    : The day in the month (as.numeric(%d))
#'  - Dekad        (numeric)    : The 10 day period (3 per month), from 1-36 (custom)
#'  - Pentad       (numeric)    : The 5 day period (6 per month), from 1-72 (custom)
#'  - DOY          (numeric)    : The Julian Day of Year e.g. 365 in a non-leap year, 366 in a leap year (as.numeric(%j))
#'  - DOY366       (numeric)    : The 5 day period (6 per month), from 1-72 (custom)
#'  - MonthDay     (numeric)    : A number of the month-day (mmdd). Essentially a numeric version of DOY366  (mmdd)
#'  - YearMonth    (numeric)    : A number of the year-month (yyyymm). Useful for monthly splits/group statistics (yyyymm)
#'  - YearDekad    (numeric)    : A number of the year-dekad (yyyyDD). Useful for dekadal splits/group statistics  (yyyyDD)
#'  - YearPentad   (numeric)    : A number of the year-pentad (yyyypp). Useful for pentadal splits/group statistics (yyyyPP)
#'  - Season       (character)  : The boreal season (DJF,MAM,JJA,SON) e.g. DJF is December,January,February
#'  - SomaliSeason (character)  : Rough Somali seasons, e.g. Dehr (Gu, ,Dehr,jilaal)
#'
#' @param infile A vector of dates, or a character vector in the format "yyyy-mm-dd"
#' @return A data frame of all the date attributes
#' @export
makedates <- function(dates.in){
   #------------------------------------------------------------------------------
   # MAKEDATES
   # Make a standard table of dates from the R datelist you feed it
   #------------------------------------------------------------------------------
   # First check that a list of dates was input
   #------------------------------------------------------------------------------
   if(class(dates.in) != "Date"){
      backup <- dates.in
      dates.in <- try(as.Date(dates.in), silent=TRUE)
      if(class(dates.in) != "Date"){
         stop(paste("You did not input a vector of dates \n Your input data had a class of:",class(backup)))
      }
   }

   #------------------------------------------------------------------------------
   # Create basic data.frame
   #------------------------------------------------------------------------------
   dates.out <- data.frame(Date=dates.in,
                       Year       = as.numeric(format.Date(dates.in,"%Y")),
                       Month      = as.numeric(format.Date(dates.in,"%m")),
                       Day        = as.numeric(format.Date(dates.in,"%d")),
                       Dekad      =3,
                       Pentad     =6,
                       DOY        = as.numeric(format.Date(dates.in,"%j")),
                       DOY366     =1)

   #------------------------------------------------------------------------------
   # Set up Dekads
   #------------------------------------------------------------------------------
   dates.out$Dekad[(dates.out$Day > 0) &(dates.out$Day <= 20)] <- 1
   dates.out$Dekad[(dates.out$Day > 10)&(dates.out$Day <= 20)] <- 2
   dates.out$Dekad <- dates.out$Dekad + (3*(dates.out$Month-1))

   #------------------------------------------------------------------------------
   # Set up Pentads
   #------------------------------------------------------------------------------
   dates.out$Pentad[(dates.out$Day > 0) &(dates.out$Day <= 25)] <- 1
   dates.out$Pentad[(dates.out$Day > 5) &(dates.out$Day <= 10)] <- 2
   dates.out$Pentad[(dates.out$Day > 10)&(dates.out$Day <= 15)] <- 3
   dates.out$Pentad[(dates.out$Day > 15)&(dates.out$Day <= 20)] <- 4
   dates.out$Pentad[(dates.out$Day > 20)&(dates.out$Day <= 25)] <- 5
   dates.out$Pentad <- dates.out$Pentad + (6*(dates.out$Month-1))

   #------------------------------------------------------------------------------
   # Set up numeric combinations
   #------------------------------------------------------------------------------
   dates.out$MonthDay   <-  as.numeric(paste(sprintf("%02d",dates.out$Month),sprintf("%02d",dates.out$Day),sep=""))
   dates.out$YearMonth  <-  as.numeric(paste(sprintf("%04d",dates.out$Year),sprintf("%02d",dates.out$Month),sep=""))
   dates.out$YearDekad  <-  as.numeric(paste(sprintf("%04d",dates.out$Year),sprintf("%02d",dates.out$Dekad),sep=""))
   dates.out$YearPentad <-  as.numeric(paste(sprintf("%04d",dates.out$Year),sprintf("%02d",dates.out$Pentad),sep=""))

   tmpdate <- seq(from=as.Date("2000-01-01"),to=as.Date("2000-12-31"),by="d")
   MonthDayTable <- data.frame(DOY366=1:366,MonthDay = as.numeric(paste(format.Date(tmpdate,"%m"),format.Date(tmpdate,"%d"),sep="")))
   mergetable <- merge(dates.out[c("Date","MonthDay")],MonthDayTable,by=c("MonthDay"),all.x=TRUE,all.y=FALSE)
   mergetable <- mergetable[order(mergetable$Date),]
   dates.out$DOY366 <- mergetable$DOY366

   dates.out$SomaliSeason <- "Dehr"
   dates.out$SomaliSeason[dates.out$Dekad %in% c(3:10)] <- "Jiilal"
   dates.out$SomaliSeason[dates.out$Dekad %in% c(11:18)] <- "Gu"
   dates.out$SomaliSeason[dates.out$Dekad %in% c(19:27)] <- "Xagaa"

   return(dates.out)
}
