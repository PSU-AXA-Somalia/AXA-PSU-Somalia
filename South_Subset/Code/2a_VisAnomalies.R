library(RColorBrewer)
library(rgeos)
#------------------------------------------------------------------------
# Set up folder names
#------------------------------------------------------------------------
Daily_datasetlist  <- list.files(dir_data_remote_BGeoTif_daily)
Pentad_datasetlist  <- list.files(dir_data_remote_BGeoTif_pentad)
Month_datasetlist  <- list.files(dir_data_remote_BGeoTif_month)


#------------------------------------------------------------------------
# Dekad
#------------------------------------------------------------------------
# Setup
Dekad_datasetlist  <- list.files(dir_data_remote_BGeoTif_dekad)
n_data <- 1
dataset <- Dekad_datasetlist[n_data]   

# Get filenames
subdir.product <- paste(dir_data_remote_CDerived_1climate,paste("anom",dataset,sep="_"),sep=sep)
subdir.year <- paste(subdir.product,paste(minyear,maxyear,sep="_"),sep=sep)
if(!dir.exists(subdir.year)){error("You do not have these years")}
subdir.ANOM <- paste(subdir.year,paste("ANOMALY",sep="_"),sep=sep)
subdir.CLIM <- paste(subdir.year,paste("CLIMATOLOGY",sep="_"),sep=sep)
subdir.CLIM.dekad   <-  paste(subdir.CLIM,"C_QC_data_dekad",sep=sep)
subdir.ANOM.dekad   <-  paste(subdir.ANOM,"C_QC_data_dekad",sep=sep)

# Read in the data
climate_prod <- stack(paste(subdir.CLIM.dekad,list.files(subdir.CLIM.dekad),sep=sep))

# Read in a shapefile
shape <- st_read(paste(dir_data_shape,"gadm36_SOM_2.shp",sep=sep))
shape2 <- suppressWarnings(st_crop(shape,extent(r)))
som <- getData('GADM', country="SOM", level=2)
som <- gSimplify(som, tol=0.01, topologyPreserve=TRUE)


ext <- extent(climate_prod)
zmin <-min(minValue(climate_prod),na.rm=TRUE)
zmax <-max(maxValue(climate_prod),na.rm=TRUE)
mon <- rep(month.abb[1],3)
for(n in 2:12){mon<- c(mon,rep(month.abb[n],3))}
DekadName <- paste(mon," Dekad:", rep(1:3,12),sep = "")



#------------------------------------------------------------------------
# plot
#------------------------------------------------------------------------


   #plotname <-  paste(plotdir,paste(paste(Dataset,variablenames[v],"DekadClimPerc",Yearall[y],sep="_"),".png",sep=""),sep="/")
   
   #png(filename=plotname,width=7,height=7,units="in",res=200)
   mypalette <- brewer.pal(9, 'Blues')
   newcol <- colorRampPalette(mypalette)
   
   mylayout <- rbind(c(  1,  2,  3,  4,  5, 6),
                     c(  7,  8,  9, 10, 11,12),
                     c( 13, 14, 15, 16, 17,18),
                     c( 19, 20, 21, 22, 23,24),
                     c( 25, 26, 27, 28, 29,30),
                     c( 31, 32, 33, 34, 35,36))
   
   layout(mylayout)
   par(cex = 0.6)  # mini point
   par(mar = c(0, 0,0.25, .25), oma = c(3.5, 3.5, 2, 0.5)) # zero margins
   par(tcl = -0.25) # tiny tick marks
   par(mgp = c(1.5, 0.4, 0)) # moves the axis labels, numbers and lines themselves
   
   
   for(d in 1:36){
      print(d)
      tmp <- climate_prod[[d]]
      
      if(d %in% c(31)){
         image(climate_prod[[d]],
               xlim=c(ext@xmin,ext@xmax),ylim=c(ext@ymin,ext@ymax),asp=1,
               zlim=c(zmin,zmax),
               col= newcol(100))
         plot(som,add=TRUE)
         polygon(c(4,60,60,4,4),
                 c(4.4,4.4,9,9,4.4),col="white",border=FALSE)
         text(x=44,y=5,DekadName[d])
         box()
      }else{
         if(d %in% (c(1,7,13,19,25)) ){
            image(climate_prod[[d]],
                  axes=FALSE,
                  xlim=c(ext@xmin,ext@xmax),ylim=c(ext@ymin,ext@ymax),asp=1,
                  zlim=c(zmin,zmax),
                  col= newcol(100))
            plot(som,add=TRUE)
            polygon(c(4,60,60,4,4),
                    c(4.4,4.4,9,9,4.4),col="white",border=FALSE)
            text(x=44,y=5,DekadName[d])
            axis(1,labels=FALSE)
            axis(2)
            box()
            
         }else{
            if(d %in% (c(32:36))){
               image(climate_prod[[d]],
                     axes=FALSE,
                     xlim=c(ext@xmin,ext@xmax),ylim=c(ext@ymin,ext@ymax),asp=1,
                     zlim=c(zmin,zmax),
                     col= newcol(100))
               plot(som,add=TRUE)
               polygon(c(4,60,60,4,4),
                       c(4.4,4.4,9,9,4.4),col="white",border=FALSE)
               text(x=44,y=5,DekadName[d])
               axis(1)
               axis(2,labels=FALSE)
               box()
               
            }else{
               image(climate_prod[[d]],
                     axes=FALSE,
                     xlim=c(ext@xmin,ext@xmax),ylim=c(ext@ymin,ext@ymax),asp=1,
                     zlim=c(zmin,zmax),
                     col= newcol(100))
               plot(som,add=TRUE)
               polygon(c(4,60,60,4,4),
                       c(4.4,4.4,9,9,4.4),col="white",border=FALSE)
               text(x=44,y=5,DekadName[d])
               axis(1,labels=FALSE)
               axis(2,labels=FALSE)
               box()
            }
         }  
      }
   }
   
   dev.off()
   
}   