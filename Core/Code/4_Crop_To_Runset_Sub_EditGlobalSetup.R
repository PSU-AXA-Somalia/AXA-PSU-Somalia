
# HERE IS WHERE YOU CHANGE THE GLOBAL PARAMETERS TO THE RUNSET
#---------------------------------------------------------------------------------
# Read in and store runset parameters, editing as necessary
#---------------------------------------------------------------------------------
if(verbose){message("  4. Creating Runset setup code, saved as Step0_Runset_Setup.R")}

#---------------------------------------------------------------------------------
# and add here all the lines you want to fully replace
#---------------------------------------------------------------------------------

# Update date
FindReplace <- data.frame(LineToEdit = "dir_GLOBAL      <- \"DO NOT DELETE THIS LINE\"",
                          Replace = paste("dir_GLOBAL      <- \"",getwd(),"\"",sep=""))

# Add runset name
FindReplace <- rbind(FindReplace,c("dir_main <- substr(getwd()",                                   
                                   paste("dir_main <- getwd() ->  dir_runset")))    

FindReplace <- rbind(FindReplace,c("dir_core        <- paste(",                                   
                                   paste("dir_core <- dir_main")))    




# Change comments
StringUpdate <-  data.frame(LineToEdit = "Step 0: Loading Global Parameter",
                            TextToReplace = "Step 0: Loading Global Parameter",
                            With = "Step 0: Loading RUNSET Parameter")

# Check for right folder
StringUpdate <- rbind(StringUpdate,c("Step0_Core_PROJECTFILE.Rproj",
                                           "Step0_Core_PROJECTFILE.Rproj",
                                           paste("Step0_",Runset,"_PROJECT.Rproj",sep="")))                           


#---------------------------------------------------------------------------------
# Read in the parameter file and replace them
#---------------------------------------------------------------------------------
SetupFileText <- readLines("Step0_Global_SetUp.R")

# Work through each full row that needs replacing
for(row in 1:nrow(FindReplace)){
   LineToEdit <- grep(FindReplace[row,1],SetupFileText)
   SetupFileText[[LineToEdit]] <- FindReplace[row,2]
}

# And each row that needs updating
for(row in 1:nrow(StringUpdate)){
   LineToEdit <- grep(StringUpdate[row,1],SetupFileText)
   if(length(LineToEdit)>0){
      for(subrow in seq_along(LineToEdit)){
         SetupFileText[[LineToEdit[subrow]]] <-str_replace(SetupFileText[LineToEdit[subrow]],
                                                           StringUpdate[row,2],
                                                           StringUpdate[row,3])
      }
   }
}



#---------------------------------------------------------------------------------
# Then rewrite the file
#---------------------------------------------------------------------------------
write_lines(SetupFileText[[1]],file=paste(dir_runset,"Step0_Runset_SetUp.R",sep=sep))
for (m in 2:length(SetupFileText)){
   write_lines(SetupFileText[[m]],file=paste(dir_runset,"Step0_Runset_SetUp.R",sep=sep),append=TRUE)
}  