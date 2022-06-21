#' Stack a raster quickly and take the mean
#'
#' When running raster stacks in parallel this is the fastest way I have found
#' All credit to Samuel Bosch
#' I found this code at
#' http://www.samuelbosch.com/2018/02/speeding-up-mean-and-standard-deviation.html
#' and adapted it to just take the mean
#'
#' @param infile A raster stack
#' @return A single raster which is the mean of the stack that was input
#' @export
rasterstack_mean_fast <- function(x) {
   #------------------------------------------------------------------------------
   # RASTERSTACK_MEAN_FAST
   # fast mean method for stacking rasters
   #------------------------------------------------------------------------------
   if(class(x) != "RasterStack"){stop(paste("You did not input a rasterstack. \n Your input had a class of:",class(x)))}
   s0 <- raster::nlayers(x)
   s1 <- raster::raster(x, layer=1)
   for(ri in 2:s0) {
      r <- raster::raster(x, layer=ri)
      s1 <- s1 + r
   }
   mymean=s1/s0
   return(mymean)
}


