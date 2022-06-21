#' palettemaker
#'
#' Create a directory if it doesn't already exist
#'
#' @param package currently either "brewer" or "viridis"
#' @param pal The sub-palette you want e.g. "Blues"
#' @param n How many output colours you want
#' @param reverse Set to true if you want the colors to go the other way
#' @param removestart numeric: Setting to 1 removes the first color, 2 the two first colors etc.
#' @param removeend numeric: Setting to 1 removes the final color, 2 the two final colors etc.
#' @param rgb Set to true to output rgb values rather than hex
#' @return It outputs a list, with the first value a description of the options, and the second a list value with the colors in either hex or rgb.
#' @details
#' Someone wanted the rgbs for a custom 19 value colorbrewer color-scale. This is the result of that request.
#' @examples
#' #-------------------------------------------------------------------------------------
#' # Example 1: Basic hex
#' #-------------------------------------------------------------------------------------
#'    Example1 <- palettemaker(package = "viridis",  pal = "viridis",
#'                               n  = 10,  rgb = FALSE, reverse = TRUE,
#'                               removeend = 0, removestart = 2)
#'
#'    #The first list value is the option you entered
#'    #The second list value are the colours
#'     print(Example1[[1]])
#'     print(Example1[[2]])
#'
#'    #Make a plot
#'     plot(1:10, 1:10,cex=2,pch=16,col= Example1[[2]],main=Example1[[1]])
#'
#' #-------------------------------------------------------------------------------------
#' # Example 2: Create a palette, save the colours to the palette code and plot
#' #-------------------------------------------------------------------------------------
#'    Example2 <- palettemaker("brewer","Blues",17,rgb=FALSE,reverse=FALSE,removeend=0,removestart=0)
#'    eval(parse(text=paste(paste(Example2[[1]], "<- Example2[[2]]"))))
#'    plot(1:17, 1:17,cex=2,pch=16,col= brewer_Blues_17_hex)
#'
#' #-------------------------------------------------------------------------------------
#' # Example 3: Make an rgb output and save output text file to the Output subfolder
#' #            Note your final palette will be of size n,
#' #            even if you remove colours from the original palette
#' #-------------------------------------------------------------------------------------
#'
#'    rgbpal <- palettemaker("brewer","Spectral",22,rgb=TRUE,reverse=TRUE,removeend=1,removestart=3)
#'    filename <- paste(rgbpal[[1]],".txt",sep="")
#'    write.table(rgbpal[[2]],filename,col.names = FALSE,row.names = FALSE,quote=FALSE,sep = "\t")
#' @export

########################################################################################
# MAKE YOUR OWN COLOR RAMPS, HLG Sept 2021
########################################################################################
#---------------------------------------------------
# package:       currently either "brewer" or "viridis"
# pal:           the sub-palette you want e.g. "Blues"
# n:             how many output colours you want
# reverse :      set to true if you want the colors to go the other way
# removeend:      1 removes the final color, 2 the two final colors etc
# removestart:    1 removes the first color, 2 the two first colors etc
# rgb             set to true to output rgb values
#---------------------------------------------------

palettemaker <- function(package,pal,n,reverse=FALSE,removestart=FALSE,removeend=FALSE,rgb=FALSE){
   require(RColorBrewer)
   require(viridis)
   require(paletteer)

   if(tolower(package) %in% "brewer"){
     inner <- brewer.pal(n = 9, name = pal)
   }else if(tolower(package) %in% "viridis"){
     inner <- viridis(9, option = pal)
   }else{
      stop("Choose either 'brewer' or 'viridis'")
   }

   if(removeend > 0){inner <-  inner[-((9-(removeend-1)):9)]}
   if(removestart > 0){inner <-  inner[-(1:(1+(removestart-1)))]}
   if(reverse == TRUE){inner <- rev(inner)}

   fullpal <- colorRampPalette(inner)(n)
   if(rgb == TRUE){
      fullpal <- t(col2rgb(fullpal))
   }

   core <- paste(package,pal,n,sep="_")
   if(removeend   > 0){core <- paste(core,paste("remend",removeend,sep=""),sep="_")}
   if(removestart > 0){core <- paste(core,paste("remstart",removestart,sep=""),sep="_")}
   if(reverse ==TRUE) {core <- paste(core,"reversed",sep="_")}
   if(rgb ==TRUE) {core <- paste(core,"rgb",sep="_")}else{core <- paste(core,"hex",sep="_")}

   out <- vector(2,mode="list")
   out[[1]] <- core
   out[[2]] <- fullpal
   return(out)
}
