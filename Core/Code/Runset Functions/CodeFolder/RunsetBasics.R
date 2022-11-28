
#---------------------------------------------------------------------------------
# Set up file structures
#---------------------------------------------------------------------------------
products_daily  <-  list.files(dir_data_remote_BGeoTif_daily)
products_pentad <-  list.files(dir_data_remote_BGeoTif_pentad)
products_dekad  <-  list.files(dir_data_remote_BGeoTif_dekad)
products_month  <-  list.files(dir_data_remote_BGeoTif_month)


#-------------------------------------------------------------------------------
# Grab a sample file to extract meta data
#---------------------------------------------------------------------------------
n=1 ; flag <- FALSE
while((length(list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[n],sep=sep)))<=0) & (flag ==FALSE)){
   n <- n+1 ; if(n >= length(products_daily)){flag <- TRUE}
} 
if(flag == TRUE){
   m=1 ; flag2 <- FALSE
   while((length(list.files(paste(dir_data_remote_BGeoTif_pentad,products_pentad[m],sep=sep)))<=0) & (flag2 ==FALSE)){
      m <- m+1;  print(m); if(m >= length(products_pentad)){flag2 <- TRUE;print ("No Pentad Data")}
   } 
   if(flag2 == TRUE){
      p=1 ; flag3 <- FALSE
      while((length(list.files(paste(dir_data_remote_BGeoTif_dekad,products_dekad[m],sep=sep)))<=0) & (flag3 ==FALSE)){
         p <- p+1; print(p) ; if(p >= length(products_dekad)){flag2 <- TRUE; stop("No data at all")}
      } 
   }  
   ## NEED TO THEN WORK OUT THE SAMPLE FILE
}else{
   samplefile <- raster(paste(paste(dir_data_remote_BGeoTif_daily,products_daily[n],sep=sep), 
                              list.files(paste(dir_data_remote_BGeoTif_daily,products_daily[n],sep=sep))[1],sep=sep))
}

#-------------------------------------------------------------------------------
# Now read in the shapefile
#-------------------------------------------------------------------------------
print("Shapefile option")
# remove any spurious .shps
if(substr(shapefile_name,nchar(shapefile_name)-3,nchar(shapefile_name)) == ".shp"){shapefile_name <- substr(shapefile_name,1,nchar(shapefile_name)-4)}
# read in the shapefile
shapefile <- st_read(dir_data_shape,shapefile_name)
shapefile <- st_transform(shapefile,st_crs(samplefile))
if(is.na(column_name) == FALSE){
   colloc <- which(toupper(names(shapefile)) %in% toupper(column_name))
   shapefile <- shapefile %>% dplyr::filter_at(colloc, dplyr::all_vars(. == column_value))
}

# Check that the shapefile fits inside the raster
if((st_bbox(shapefile)$xmin< st_bbox(shapefile)$xmin)|(st_bbox(shapefile)$ymin< st_bbox(shapefile)$ymin)|
   (st_bbox(shapefile)$xmax> st_bbox(shapefile)$xmax)|(st_bbox(shapefile)$ymax> st_bbox(shapefile)$ymax)){
   stop("Your shapefile extent is larger than the rasters extent. Make a new runset with a larger box")
}

