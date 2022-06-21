#' conditionalcreate
#'
#' Create a directory if it doesn't already exist
#'
#' @param dir The location and name of the directory you want to create  (e.g. "~/Desktop/test")
#' @param silent Do you want to print progress messages? By default this function is silent
#' @return Nothing, it just makes the directory
#' @details
#' This is just a shortcut function to silently make a directory if it doesn't exist and to have better error messages.
#' @examples
#' # Or change to a folder on your computer
#' conditionalcreate("~/Desktop/TestFolder")
#' conditionalcreate("~/Desktop/TestFolder", silent=FALSE)
#' @export
conditionalcreate <- function(dir,silent=TRUE){
   #------------------------------------------------------------------------------
   # CONDITIONAL CREATE
   #  Create a directory if it doesn't already exist
   #------------------------------------------------------------------------------
   stem <- substr(dir,start=1,stop=max(gregexpr("/",dir)[[1]]))

   if(!dir.exists(stem)){
      stop(paste("The base address you entered does not exist on your computer. You entered:",stem))
   }else{
      if(!dir.exists(dir)){
         if(!silent){message("Directory does not exist, making new directory")}
         dir.create(dir)
         if(!silent){message(paste("Success! Your directory was created at:",dir))}
      }else{
         if(!silent){message("Directory already exists, exiting function")}
      }
   }
}
