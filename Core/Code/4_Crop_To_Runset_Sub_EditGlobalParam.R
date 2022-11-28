
# HERE IS WHERE YOU CHANGE THE GLOBAL PARAMETERS TO THE RUNSET
#---------------------------------------------------------------------------------
# Read in and store runset parameters, editing as necessary
#---------------------------------------------------------------------------------
if(verbose){message("  3. Creating runset parameters, saved as Step0_Runset_Parameters.R")}

#---------------------------------------------------------------------------------
# and add here all the lines you want to fully replace
#---------------------------------------------------------------------------------

# Update date
FindReplace <- data.frame(LineToEdit = "globalparams_lastupdated",
                          Replace = paste("# runsetparams_lastupdated <-",Sys.Date()))

# Add runset name
FindReplace <- rbind(FindReplace,c("runsetparamdate_DONOTDELETE",
                                   paste("# RUNSET PARAMETERS, Runset name:",Runset)))  

# Change top lines
FindReplace <- rbind(FindReplace,c("# GLOBAL PARAMETERS",
                                   paste("# RUNSET PARAMETERS, Runset name:",Runset)))  




StringUpdate <-  data.frame(LineToEdit = "Step0_Global_SetUp",
                            TextToReplace = "Step0_Global_SetUp",
                            With = "Step0_Runset_SetUp")

#---------------------------------------------------------------------------------
# Read in the parameter file and replace them
#---------------------------------------------------------------------------------
ParamFileText <- readLines("Step0_Global_Parameters.R")

# Work through each full row that needs replacing
for(row in 1:nrow(FindReplace)){
   LineToEdit <- grep(FindReplace[row,1],ParamFileText)
   ParamFileText[[LineToEdit]] <- FindReplace[row,2]
}

# And each row that needs updating
for(row in 1:nrow(StringUpdate)){
   LineToEdit <- grep(StringUpdate[row,1],ParamFileText)
   ParamFileText[[LineToEdit]] <-str_replace(ParamFileText[LineToEdit],
                                             StringUpdate[row,2],
                                             StringUpdate[row,3])
}

#---------------------------------------------------------------------------------
# Then rewrite the file
#---------------------------------------------------------------------------------
write_lines(ParamFileText[[1]],file=paste(dir_runset,"Step0_Runset_Parameters.R",sep=sep))
for (m in 2:length(ParamFileText)){
   write_lines(ParamFileText[[m]],file=paste(dir_runset,"Step0_Runset_Parameters.R",sep=sep),append=TRUE)
}  