
#-------------------------------------------------------------------------------------------------------------
# Total rainfall over this & last season
#-------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------
# Libraries
#---------------------------------------------------------------------------------
Dataset <- "rain_TAMSAT_3.1_Filled"
overwrite <- FALSE

#---------------------------------------------------------------------------------
# Cropped location
#---------------------------------------------------------------------------------
xmin   <- 41
ymin   <- -2
xmax   <- 52
ymax   <- 13

#---------------------------------------------------------------------------------
# Find input files. These are zipped.
#---------------------------------------------------------------------------------
dir_data_input <- paste(dir_2geoTif_daily,Dataset,sep=sep)
file.list <- list.files(dir_data_input)[grep("tif",list.files(dir_data_input))]

#---------------------------------------------------------------------------------
# To be removed - get Somalia and resave
#---------------------------------------------------------------------------------
#---------------------------------------------------------------------------------
# Extract dates from the files
#---------------------------------------------------------------------------------
date.list <- as.Date(substr(file.list, nchar(file.list)-13,nchar(file.list)-4))

dates <- data.frame(Date=date.list,
                    Year=as.numeric(format.Date(date.list,"%Y")),
                    Month=as.numeric(format.Date(date.list,"%m")),
                    Day=as.numeric(format.Date(date.list,"%d")),
                    DOY=format.Date(date.list,"%m-%d"),
                    Dekad=3)

# Set up dekads and pentads - NEED TO DO PENTADS
dates$Dekad[(dates$Day > 0)&(dates$Day <= 20)] <- 1
dates$Dekad[(dates$Day > 10)&(dates$Day <= 20)] <- 2
dates$Dekad <- dates$Dekad + (3*(dates$Month-1))
dates$YearDekad <- as.numeric(paste(dates$Year,sprintf("%02d",dates$Dekad),sep=""))
dates$YearMonth <-  as.numeric(paste(dates$Year,sprintf("%02d",dates$Month),sep=""))
dates$Season <-  NA
dates$Season[dates$Month %in% c(9:12,1)] <- "Dehr"
dates$Season[dates$Month %in% c(2:7)] <- "Gu"
dates$YearSeason <-  paste(dates$Year,dates$Season,sep="-")

runlist <- sort(unique(dates$YearSeason))
newfolder <- "~/Desktop/Seasons"

#---------------------------------------------------------------------------------
# OK, so I need to read everything in and then subset by season and for Somalia
#---------------------------------------------------------------------------------
 for(d in 1:length(runlist)){
    # read in data
    subset <- which(dates$YearSeason %in% runlist[d])
    r_stack <- stack(paste(dir_2geoTif_daily,Dataset,file.list[subset],sep=sep))

    # Crop
    e <- as(extent(xmin, xmax, ymin, ymax), 'SpatialPolygons')
    crs(e) <- crs(r_stack)
    r_crop <- crop(r_stack, e)
          
    r_sum <- calc(r_crop, fun=sum)
    fname <- paste("~/Desktop/Seasons/TAMSAT-",runlist[d],".tif",sep="")
    writeRaster(r_sum, filename=fname, format="GTiff", overwrite=TRUE)
    
 }

#---------------------------------------------------------------------------------
# Let's do the Dehr season
#---------------------------------------------------------------------------------

runlist <- sort(unique(dates$Year))
files <-  list.files("~/Desktop/Seasons")[grep("Dehr", list.files("~/Desktop/Seasons"))]

dehr_stack <- stack(paste("~/Desktop/Seasons",files,sep=sep))   

data_array <- as.array(dehr_stack)
data_array2 <- data_array

for (x in 1:dim(data_array)[1]){
   for(y in 1:dim(data_array)[2]){
      data_array2[x,y,] <- percent_rank(data_array[x,y,])
   }
}

dekaddata_peranom <- brick(data_array2,crs=crs(dehr_stack))
extent(dekaddata_peranom) <- extent(dehr_stack)


out <- dekaddata_peranom


plotdir <- paste("~/Desktop","Plots",sep="/")
if(!(file.exists(plotdir))){
   dir.create(plotdir)
}  

   state <- st_read("/Volumes/Mac storage space/Main/All_Data/1_Shapefiles/gadm36_SOM_shp/gadm36_SOM_0.shp")
   
   plotname <-  paste(plotdir,"DehrTotal.png",sep="/")
   png(filename=plotname,width=7,height=7,units="in",res=200)
   mypalette <- brewer.pal(9, 'Spectral')
   newcol <- colorRampPalette(mypalette)
   
   mylayout <- rbind(c( 01, 02, 03, 04, 05,21),
                     c( 06, 07, 08, 09, 10,21),
                     c( 11, 12, 13, 14, 15,21),
                     c( 16, 17, 18, 19, 20,21))

   layout(mylayout)
   par(cex = 0.6)  # mini point
   par(mar = c(0, 0,0.25, .25), oma = c(3.5, 3.5, 2, 0.5)) # zero margins
   par(tcl = -0.25) # tiny tick marks
   par(mgp = c(1.5, 0.4, 0)) # moves the axis labels, numbers and lines themselves
   
   for(d in 1:19){
         if(d %in% c(16)){
            image(out[[d]],
                  #xlim=c(74.8,77.5),ylim=c(8,13.25),
                  asp=1,
                  zlim=c(0,1),
                  col= newcol(100))
            plot(st_geometry(state),add=TRUE)
        #    polygon(c(76.3,77.5,77.5,76.3,76.3),
      #              c(12.75,12.75,13.25,13.25,12.75),col="white",border=FALSE)
            text(x=76.9,y=13,runlist[d])
            box()
         }else{
            if(d %in% c(1,6,11) ){
               image(out[[d]],axes=FALSE,
                     #xlim=c(74.8,77.5),ylim=c(8,13.25),
                     asp=1,
                     zlim=c(0,1),
                     col= newcol(100))
               plot(st_geometry(state),add=TRUE)
          #    polygon(c(76.3,77.5,77.5,76.3,76.3),
          #             c(12.75,12.75,13.25,13.25,12.75),col="white",border=FALSE)
               text(x=76.9,y=13,runlist[d])
               axis(1,labels=FALSE)
               axis(2)
               box()
               
            }else{
               if(d %in% c(17:20)){
                  image(out[[d]],axes=FALSE,
                       # xlim=c(74.8,77.5),ylim=c(8,13.25),
                        asp=1,
                        zlim=c(0,1),
                        col= newcol(100))
                  plot(st_geometry(state),add=TRUE)
               #   polygon(c(76.3,77.5,77.5,76.3,76.3),
               #           c(12.75,12.75,13.25,13.25,12.75),col="white",border=FALSE)
                  text(x=76.9,y=13,runlist[d])
                  axis(1)
                  axis(2,labels=FALSE)
                  box()
                  
               }else{
                  image(out[[d]],axes=FALSE,
                        xlim=c(74.8,77.5),ylim=c(8,13.25),
                        asp=1,
                        zlim=c(0,1),
                        col= newcol(100))
                  plot(st_geometry(state),add=TRUE)
              #    polygon(c(76.3,77.5,77.5,76.3,76.3),
            #              c(12.75,12.75,13.25,13.25,12.75),col="white",border=FALSE)
                  text(x=76.9,d=13,runlist[d])
                  axis(1,labels=FALSE)
                  axis(2,labels=FALSE)
                  box()
               }
            }  
         }
   }
      
   
   
   dev.off()





