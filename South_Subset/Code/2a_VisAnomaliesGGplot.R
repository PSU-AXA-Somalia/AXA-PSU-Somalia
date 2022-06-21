library(RColorBrewer)
library(rgeos)
library(rasterVis)
library(viridis)
library(shiny)


#------------------------------------------------------------------------
# Dekad
#------------------------------------------------------------------------
# Setup
Dekad_datasetlist  <- list.files(dir_data_remote_BGeoTif_dekad)
climplots    <- vector(mode="list",length=length(Dekad_datasetlist))
climate_prod <- vector(mode="list",length=length(Dekad_datasetlist))

for(n_data in seq(Dekad_datasetlist)){
   #------------------------------------------------------------------------
   # Get filenames amd load data
   #------------------------------------------------------------------------
   dataset <- Dekad_datasetlist[n_data]   
   subdir.product <- paste(dir_data_remote_CDerived_1climate,paste("anom",dataset,sep="_"),sep=sep)
   subdir.year <- paste(subdir.product,paste(minyear,maxyear,sep="_"),sep=sep)
   if(!dir.exists(subdir.year)){error("You do not have these years")}
   subdir.ANOM <- paste(subdir.year,paste("ANOMALY",sep="_"),sep=sep)
   subdir.CLIM <- paste(subdir.year,paste("CLIMATOLOGY",sep="_"),sep=sep)
   subdir.CLIM.dekad   <-  paste(subdir.CLIM,"C_QC_data_dekad",sep=sep)
   subdir.ANOM.dekad   <-  paste(subdir.ANOM,"C_QC_data_dekad",sep=sep)
   
   #------------------------------------------------------------------------
   # Read in the data
   #------------------------------------------------------------------------
   climate_prod[[n_data]] <- stack(paste(subdir.CLIM.dekad,list.files(subdir.CLIM.dekad),sep=sep))
   climate_prod[[n_data]]  <- reclassify(climate_prod[[n_data]], cbind(1000, Inf, NA), right=FALSE)
   
}   

#------------------------------------------------------------------------
# Get dynamic zmin/zmax
#------------------------------------------------------------------------
zmin <- 0;zmax=0
for(n_data in seq(Dekad_datasetlist)){
   zmin <-min(c(zmin,minValue(climate_prod[[n_data]])),na.rm=TRUE)
   zmax <-max(c(zmax,maxValue(climate_prod[[n_data]])),na.rm=TRUE)
   #zmax <- 16
}   

#------------------------------------------------------------------------
# Read in a shapefile
#------------------------------------------------------------------------
# shape <- st_read(paste(dir_data_shape,"gadm36_SOM_2.shp",sep=sep))
# shape2 <- suppressWarnings(st_crop(shape,extent(r)))
som <- getData('GADM', country="SOM", level=2)
som <- gSimplify(som, tol=0.01, topologyPreserve=TRUE)
ext <- extent(climate_prod)

#------------------------------------------------------------------------
# sort out dekad
#------------------------------------------------------------------------
mon <- rep(month.abb[1],3)
for(n in 2:12){mon<- c(mon,rep(month.abb[n],3))}
DekadName <- paste(mon," Dek-", rep(1:3,12),sep = "")


#------------------------------------------------------------------------
# Create plots
#------------------------------------------------------------------------
for(n_data in seq(Dekad_datasetlist)){
   dataset <- Dekad_datasetlist[n_data]   
   
   zmin <-minValue(climate_prod[[n_data]])
   zmax <-maxValue(climate_prod[[n_data]])
   
   names(climate_prod[[n_data]]) <- DekadName
   
   # Make and save plot
   climplots[[n_data]] <- gplot(climate_prod[[n_data]]) + 
      geom_tile(aes(fill = value)) +
      #  geom_sf(data = som ,
      #          size = .5, colour = "black",fill=NA) +
      facet_wrap(~ variable) +
      theme_minimal()+
      theme(axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            #axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            #axis.text.x=element_blank(),
            axis.ticks.y=element_blank(),
            panel.spacing=unit(0, "lines") ,
            legend.position="bottom",
            panel.border = element_rect(fill = NA))+
      scale_fill_gradientn(colours = brewer.pal(9,"YlGnBu"),name=paste("Climatology:", strsplit(dataset,"rain_")[[1]][2])) +
      coord_equal()
}


#=========================================================================
# User interface
#=========================================================================

ui <- fluidPage(
   # App title ----
   titlePanel("Climatology"),
   
   # Sidebar layout with input and output definitions ----
   sidebarLayout(
      
      # Sidebar panel for inputs ----
      sidebarPanel(
         
         radioButtons("Product", "Product:",
                      c("Rain_RFE2_1_Geo" = "rain_rfe",
                        "Rain_TAMSAT_3.1" = "rain_tamsat",
                        "SM_TAMSAT_smc_avail_top" = "smc_avail_top")),
         textOutput("greeting")
         
      ),
      
      # Main panel for displaying outputs ----
      mainPanel(
         plotOutput(outputId = "distPlot" , width = "100%", height = "900px")
      )
   )
)

server <- function(input, output) {
   output$distPlot <- renderPlot({
      Product <- switch(input$Product,
                        rain_rfe = climplots[[1]] ,
                        rain_tamsat = climplots[[2]],
                        smc_avail_top =climplots[[5]])
      Product
   })
   output$greeting <- renderText({
      Product <- switch(input$Product,
                        rain_rfe = "this is where I can put the spreadsheet info for product 1" ,
                        rain_tamsat = "this is where I can put the spreadsheet info for product 1" ,
                        smc_avail_top ="this is where I can put the spreadsheet info for product 1" )
      paste(c("\n",Product))
   })
}

shinyApp(ui, server)


#=========================================================================
# Differences
#=========================================================================
TAMSAT0.1 <- climate_prod[[2]]
TAMSAT0.1 <- resample(TAMSAT0.1,climate_prod[[1]])
RFE.minus.TAMSAT <- climate_prod[[1]]- TAMSAT0.1

zmin <-min(minValue(RFE.minus.TAMSAT),na.rm=TRUE)
zmax <-max(maxValue(RFE.minus.TAMSAT),na.rm=TRUE)
zmax <- max(abs(zmin),zmax)
zmin <- zmax-(2*zmax)

names(climate_prod[[n_data]]) <- DekadName


#------------------------------------------------------------------------
# Make and save plot
#------------------------------------------------------------------------
gplot(RFE.minus.TAMSAT) + 
   geom_tile(aes(fill = value)) +
   #  geom_sf(data = som ,
   #          size = .5, colour = "black",fill=NA) +
   facet_wrap(~ variable) +
   theme_minimal()+
   theme(axis.title.x=element_blank(),
         axis.title.y=element_blank(),
         #axis.text.x=element_blank(),
         axis.ticks.x=element_blank(),
         #axis.text.x=element_blank(),
         axis.ticks.y=element_blank(),
         panel.spacing=unit(0, "lines") ,
         legend.position="bottom",
         panel.border = element_rect(fill = NA))+
   scale_fill_gradientn(colours = brewer.pal(9,"RdBu"),name=paste("RFE-TAMSAT")) +
   coord_equal()


gplot(climate_prod[[1]]) + 
   geom_tile(aes(fill = value)) +
   #  geom_sf(data = som ,
   #          size = .5, colour = "black",fill=NA) +
   facet_wrap(~ variable) +
   theme_minimal()+
   theme(axis.title.x=element_blank(),
         axis.title.y=element_blank(),
         #axis.text.x=element_blank(),
         axis.ticks.x=element_blank(),
         #axis.text.x=element_blank(),
         axis.ticks.y=element_blank(),
         panel.spacing=unit(0, "lines") ,
         legend.position="bottom",
         panel.border = element_rect(fill = NA))+
   scale_fill_gradientn(colours = brewer.pal(9,"YlGnBu"),name=paste("Climatology: RFE rain")) +
   coord_equal()


gplot(climate_prod[[2]]) + 
   geom_tile(aes(fill = value)) +
   #  geom_sf(data = som ,
   #          size = .5, colour = "black",fill=NA) +
   facet_wrap(~ variable) +
   theme_minimal()+
   theme(axis.title.x=element_blank(),
         axis.title.y=element_blank(),
         #axis.text.x=element_blank(),
         axis.ticks.x=element_blank(),
         #axis.text.x=element_blank(),
         axis.ticks.y=element_blank(),
         panel.spacing=unit(0, "lines") ,
         legend.position="bottom",
         panel.border = element_rect(fill = NA))+
   scale_fill_gradientn(colours = brewer.pal(9,"YlGnBu"),name=paste("Climatology: RFE rain")) +
   coord_equal()



