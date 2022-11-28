#---------------------------------------------------------------------------------
# If you have been playing with this for a while and there are package download errors
# this might be because you have a lock folder invisibly in your libraries folder
# google this or talk to helen - but you just need to delete the folder, restart R
# and run from the start.
#---------------------------------------------------------------------------------

if (verbose) {message("Step 0: Loading RUNSET Parameters")}





#===========================================================================================
# BASIC PARAMETER SET UP.  These are unlikely to ever change.
#===========================================================================================
 #---------------------------------------------------------------------------------
 # DIRECTORY SEPARATER 
 #      It will likely always be "/" but here in case windows is stupid and needs \\
 #---------------------------------------------------------------------------------
  sep <- "/"

 #---------------------------------------------------------------------------------
 # Stop spatial update errors from R. IGNORE
 #---------------------------------------------------------------------------------
  options("rgdal_show_exportToProj4_warnings"="none")

  
  
  
  

#===========================================================================================
# MAIN DIRECTORY SET-UP
#
#  The location of the github download folder.
#  You MUST be running R via opening the R project or have setwd() here
#===========================================================================================

  #--- Auto pull the directory from your location
  if (("Step0_South_Somalia_PROJECT.Rproj" %in% list.files())) {
     dir_main <- substr(getwd(), start = 1, stop = nchar(getwd()) - 5) ->  dir_runset
     
     
  }else{ 
     #---Give a warning and try to autofix 
     if ("dir_main" %in% ls()) {
        if (verbose){ message("Step 0: you were not in dir_main when running this.
                        Weird.\n Are you debugging?\nChanging main directory back")}
        setwd(paste(dir_main, "Core", sep = sep))
        
     } else{
        message(paste("I don't think you opened R by double clicking Step0_South_Somalia_PROJECT.Rproj\n
                  Your current directory is", getwd(),
                      "\n The code is looking for Step0_South_Somalia_PROJECT.Rproj
                  in this directory but can only see:"))
        paste(list.files())
        stop("CLOSE R-STUDIO.  RE-OPEN R-STUDIO BY DOUBLE CLICKING Step0_South_Somalia_PROJECT.Rproj")
     }
  }


  
  
  
  
#===========================================================================================
# SUB-FOLDER FILENAME SET-UP
#===========================================================================================
 #-------------------------------------------------
 # TOP LEVEL
 #-------------------------------------------------
dir_GLOBAL      <- /Users/hlg5155/Documents/GitHub/Somalia/AXA-PSU-Somalia/Core
 dir_core        <- paste(dir_main,"Core",sep=sep)
 dir_code        <- paste(dir_core,"Code",sep=sep)
 
 #-------------------------------------------------
 # DATA SUB-FOLDERS
 #-------------------------------------------------
 if(is.na(RemoteData)){dir_data <- paste(dir_core,"Data",sep=sep)}else{dir_data <- RemoteData}
 
    #-------------------------------------------------
    # Level 2.1: Shapefiles
    #-------------------------------------------------
     if(is.na(RemoteShape)){
        dir_data_shape    <- paste(dir_data,"1_Shapefiles",    sep=sep) 
     }else{ 
        dir_data_shape <- RemoteShape
    }
 
    #-------------------------------------------------
    # Level 2.2: Remote Sensing
    #-------------------------------------------------
    dir_data_remote   <- paste(dir_data,"2_Remote_Sensing",sep=sep)

      #-------------------------------------------------
      # Level 2.2.1 Raw Remote sensing data
      #-------------------------------------------------
       dir_data_remote_ARaw         <- paste(dir_data_remote,"0_Raw_data",sep=sep)
       dir_data_remote_ARaw_missing <- paste(dir_data_remote_ARaw,"All_Missing_Filled_Files",sep=sep)

      #-------------------------------------------------
      # Level 2.2.2 Processed data
      #-------------------------------------------------
       dir_data_remote_BGeoTif         <-  paste(dir_data_remote,"1_Raw_geoTifs",sep=sep)
         dir_data_remote_BGeoTif_daily   <-  paste(dir_data_remote_BGeoTif,"A_QC_data_daily",sep=sep)
         dir_data_remote_BGeoTif_pentad  <-  paste(dir_data_remote_BGeoTif,"B_QC_data_pentad",sep=sep)
         dir_data_remote_BGeoTif_dekad   <-  paste(dir_data_remote_BGeoTif,"C_QC_data_dekad",sep=sep)
         dir_data_remote_BGeoTif_month   <-  paste(dir_data_remote_BGeoTif,"D_QC_data_month",sep=sep)

       #-------------------------------------------------
       # Level 2.2.3 Derived Data. e.g. anomalies
       #-------------------------------------------------
       dir_data_remote_CDerived   <- paste(dir_data_remote,"2_Derived_Data",sep=sep)
          
         dir_data_remote_CDerived_1climate    <-  paste(dir_data_remote_CDerived,"A_Climatologies",sep=sep)
           dir_data_remote_CDerived_1clim_daily   <-  paste(dir_data_remote_CDerived_1climate,"A1_Climate_daily",sep=sep)
           dir_data_remote_CDerived_1clim_pentad  <-  paste(dir_data_remote_CDerived_1climate,"A2_Climate_pentad",sep=sep)
           dir_data_remote_CDerived_1clim_dekad   <-  paste(dir_data_remote_CDerived_1climate,"A3_Climate_dekad",sep=sep)
           dir_data_remote_CDerived_1clim_month   <-  paste(dir_data_remote_CDerived_1climate,"A4_Climate_month",sep=sep)          

         dir_data_remote_CDerived_2anomaly  <-  paste(dir_data_remote_CDerived,"B_Anomalies",sep=sep)
           dir_data_remote_CDerived_2anom_daily   <-  paste(dir_data_remote_CDerived_2anomaly,"B1_Anomalies_daily",sep=sep)
           dir_data_remote_CDerived_2anom_pentad  <-  paste(dir_data_remote_CDerived_2anomaly,"B2_Anomalies_pentad",sep=sep)
           dir_data_remote_CDerived_2anom_dekad   <-  paste(dir_data_remote_CDerived_2anomaly,"B3_Anomalies_dekad",sep=sep)
           dir_data_remote_CDerived_2anom_month   <-  paste(dir_data_remote_CDerived_2anomaly,"B4_Anomalies_month",sep=sep)             

         dir_data_remote_CDerived_3thresh       <-  paste(dir_data_remote_CDerived,"C_ThresholdMask",sep=sep)
           dir_data_remote_CDerived_3thres_daily   <-  paste(dir_data_remote_CDerived_3thresh,"C1_Threshold_daily",sep=sep)
           dir_data_remote_CDerived_3thres_pentad  <-  paste(dir_data_remote_CDerived_3thresh,"C2_Threshold_pentad",sep=sep)
           dir_data_remote_CDerived_3thres_dekad   <-  paste(dir_data_remote_CDerived_3thresh,"C3_Threshold_dekad",sep=sep)
           dir_data_remote_CDerived_3thres_month   <-  paste(dir_data_remote_CDerived_3thresh,"C4_Threshold_month",sep=sep)             
         

       #-------------------------------------------------
       # Level 2.2.4 Output Statistics
       #-------------------------------------------------
       dir_data_remote_DStats     <- paste(dir_data_remote,"3_Statistics",sep=sep)
         
           
           
           
           
           
           
           
           
           

#================================================================================================================
# LIBRARIES AND PACKAGES 
# AUTO INSTALL AND UPDATE
#================================================================================================================
           
  #---------------------------------------------------------------------------------
  # Check if R and R studio are out of date
  #---------------------------------------------------------------------------------
  if ((R.Version()$major < 4) | ((R.Version()$major == 4) & (R.Version()$minor < 2))) {
     warning("Your R version is out of date and this code is likely to break. Consider updating R!\nVisit: https://cran.r-project.org/")
  }

  #---------------------------------------------------------------------------------
  # Package names
  #---------------------------------------------------------------------------------
    cranpackages <- data.frame(Package="doParallel"  ,Version="1.0.16") 
    cranpackages <- rbind(cranpackages,c("foreach"   ,    "1.5.1"  ))
    cranpackages <- rbind(cranpackages,c("leaflet"   ,    "2.0.4.1"))
    cranpackages <- rbind(cranpackages,c("matlab"    ,    "1.0.2"  ))
    cranpackages <- rbind(cranpackages,c("ncdf4"     ,    "1.17"   ))
    cranpackages <- rbind(cranpackages,c("terra"     ,    "1.4.10" ))
    cranpackages <- rbind(cranpackages,c("parallel"  ,    "1.1.0"  )) 
    cranpackages <- rbind(cranpackages,c("raster" ,       "3.5-2"  ))
    cranpackages <- rbind(cranpackages,c("readr"     ,    "2.0.2"  ))
    cranpackages <- rbind(cranpackages,c("remotes"   ,    "2.4.1"  ))
    cranpackages <- rbind(cranpackages,c("sf"        ,    "1.0-2"  ))
    cranpackages <- rbind(cranpackages,c("sp"        ,    "1.4-5"  ))
    cranpackages <- rbind(cranpackages,c("stringr"   ,    "1.4.0"  ))
    cranpackages <- rbind(cranpackages,c("tidyverse" ,    "1.3.1"  ))
    cranpackages <- rbind(cranpackages,c("dplyr"     ,    "1.0.7"  ))
    cranpackages <- rbind(cranpackages,c("terra"     ,    "1.4.10" ))
    cranpackages <- rbind(cranpackages,c("tmap"      ,    "3.3-2"  ))
    cranpackages <- rbind(cranpackages,c("usethis"   ,    "2.1.3"  ))
    cranpackages <- rbind(cranpackages,c("data.table" ,   "1.0.0"  ))
    cranpackages <- rbind(cranpackages,c("rgdal" ,    "1.0.0"  ))
    
    githubpackages <- data.frame(Github="hgreatrex",Package="Greatrex.Functions",Version="0.1.1")
    githubpackages <- rbind(githubpackages,c(Github="gearslaboratory",Package="gdalUtils",version="2.0"))
    githubpackages <- rbind(githubpackages,c(Github="isciences",Package="exactextractr",version="0.1"))
    
    
  #---------------------------------------------------------------------------------
  # Install any packages not yet installed
  #---------------------------------------------------------------------------------
   if(verbose){message("        Checking if packages need to be installed")}
    
    # Check CRAN
    #---------------------------------------------------------------------------------
    installed_packages <- cranpackages$Package %in% rownames(installed.packages())
    if (any(installed_packages == FALSE)) {
       if(verbose){message(paste("           Installing package:",cranpackages$Package[which(installed_packages==FALSE)],"\n"))}
       test <- try(install.packages(cranpackages$Package[!installed_packages],quiet=TRUE,dependencies=TRUE),silent=TRUE)
    }
    
    # Check Github
    #---------------------------------------------------------------------------------
    flag <- TRUE
    if(use_github_repos == TRUE){
       # If you can download from github, autograb the ones you need
      remotes_installed_packages <- githubpackages$Package %in% rownames(installed.packages())
      if (any(remotes_installed_packages == FALSE)) {
        remotes_missing <- githubpackages[!remotes_installed_packages,]
        for(n in 1:nrow(remotes_missing)){
          if(verbose){message(paste("           Installing package from Github:",paste(remotes_missing$Github[n],remotes_missing$Package[n],sep="/"),"\n"))}
          test <- try(remotes::install_github(paste(remotes_missing$Github[n],remotes_missing$Package[n],sep="/"),quiet=TRUE,force=TRUE,upgrade="never"),silent=TRUE)
          if((substr(test[1],1,5) %in% "Error")&&(remotes_missing$Package[n] %in% "Greatrex.Functions")){
            if(verbose){message("WARNING: Unable to load Greatrex.Functions from github\n Loading built in functions:\nTURN github <- FALSE in Step0_Global_Parameters.R to speed up future runs")}
            flag <- FALSE
            dir_functions <- paste(dir_code,"Global Functions",sep=sep)
            for(f in 1:length(list.files(dir_functions))){source(paste(dir_functions,list.files(dir_functions)[f],sep=sep))}
            rm(f)
          }
        }
      }
    }else{
      # If you cannot download from github
      flag <- FALSE
      
      # Grab Greatrex functions from sub-directory
      if(verbose){message(paste("          You selected to not use github, installing functions manually:\n"))}
      dir_functions <- paste(dir_code,"Global Functions",sep=sep)
      for(f in 1:length(list.files(dir_functions))){source(paste(dir_functions,list.files(dir_functions)[f],sep=sep))}
      rm(f)

      # Check for non Greatrex Function ones
      githubpackagestmp <- githubpackages[-which(githubpackages$Package %in% "Greatrex.Functions"),]
      remotes_installed_packages <- githubpackagestmp$Package %in% rownames(installed.packages())
      if(any(remotes_installed_packages == FALSE)){
         message("These non CRAN packages must be installed before proceeding:")
         print(githubpackagestmp[which(remotes_installed_packages==FALSE),])
         stop()
      }
    }
   
  
    #---------------------------------------------------------------------------------
    # Final check
    #---------------------------------------------------------------------------------
    installed_packages <- cranpackages$Package %in% rownames(installed.packages())
    if (any(installed_packages == FALSE)) {
      stop(paste("CRAN Package install failed:",cranpackages$Package[which(installed_packages==FALSE)],"\n"))
    }
    
    if(use_github_repos == TRUE){
      installed_remote_packages <- githubpackages$Package %in% rownames(installed.packages())
      if (any(installed_remote_packages == FALSE)&&(flag==TRUE)) {
        stop(paste("Github Package install failed:",paste(githubpackages$Github[which(installed_remote_packages==FALSE)],githubpackages$Package[which(installed_remote_packages==FALSE)],sep="/"),"\nTURN github <- FALSE in Step0_Global_Parameters.R"))
      }  
    }  
   
    #---------------------------------------------------------------------------------
    # Update any that need updating
    #---------------------------------------------------------------------------------
    if(auto_update_packages){ 
      if(verbose){message("        Checking if packages need to be updated")}
      
      # Function to check version
      package_needsupdating <- function(pkg, than) {
        #https://stackoverflow.com/questions/41495639/r-check-if-package-version-is-greater-than-x-y-z   
        compareVersion(as.character(packageVersion(pkg)), than)
        if(compareVersion(as.character(packageVersion(pkg)), than)<0){
          return(TRUE)
        }else{
          return(FALSE)
        }
      }    
      #Cran
      for(n in 1:nrow(cranpackages)){
        if((package_needsupdating(cranpackages$Package[n],cranpackages$Version[n]))){
          if(verbose){message(paste("           Updating package:",cranpackages$Package[n]))}
          test <- try(install.packages(cranpackages$Package[n]),silent=TRUE)
        }
      }
      #Github
      for(n in 1:nrow(githubpackages)){
        if(githubpackages$Package[n] %in% "Greatrex.Functions"){
          # only try to update if you didn't already download the functions
          if(flag==TRUE){
            if((package_needsupdating(githubpackages$Package[n],githubpackages$Version[n]))){
              if(verbose){message(paste("           Updating package from Github:",paste(githubpackages$Github[n],githubpackages$Package[n],sep="/"),"\n"))}
              test <- try(remotes::install_github(paste(githubpackages$Github[n],githubpackages$Package[n],sep="/"),force=TRUE),silent=TRUE)
            }            
          }
        }else{     
          if((package_needsupdating(githubpackages$Package[n],githubpackages$Version[n]))){
            if(verbose){message(paste("           Updating package from Github:",paste(githubpackages$Github[n],githubpackages$Package[n],sep="/"),"\n"))}
            test <- try(remotes::install_github(paste(githubpackages$Github[n],githubpackages$Package[n],sep="/"),force=TRUE),silent=TRUE)
          }    
        }
      }       
    }else{
      if(verbose){message("        Update packages turned off")}
    }
    
  #---------------------------------------------------------------------------------
  # Load packages into R
  #---------------------------------------------------------------------------------
  if(verbose){message("        Loading packages")}
  out <- lapply(cranpackages$Package, function(x) suppressPackageStartupMessages(library(x, character.only = TRUE)))
  if(verbose){message(paste("           Package loaded:",cranpackages$Package,"\n"))}

  if(flag ==TRUE && use_github_repos == TRUE){
    if(verbose){message(paste("           Github Package loaded:",githubpackages$Package,"\n"))}
    out <- lapply(githubpackages$Package, function(x) suppressPackageStartupMessages(library(x, character.only = TRUE)))
  }else{
    if(verbose){message(paste("           Greatrex.Functions loaded as individual functions rather than package\n"))}
  }
  
  
  
  
  
  
  
 
#=================================================================================
# ACTUALLY CREATE SUB-DIRECTORIES
#=================================================================================
  if(verbose){message("        Setting up directories")}
  
  #---------------------------------------------------------------------------------
  # Removes common errors in dir_main
  #---------------------------------------------------------------------------------
  while(substr(dir_main,start=nchar(dir_main),stop=nchar(dir_main)) %in% c("/","\\")){
     dir_main <- substr(dir_main,start=1,stop=nchar(dir_main)-1)
  }
  while(substr(tolower(dir_main),start=nchar(dir_main)-3,stop=nchar(dir_main)) %in% "core"){
     dir_main <- substr(dir_main,start=1,stop=nchar(dir_main)-5)
  } 
  
  if(getwd() != dir_core){stop(paste("Either you did not open R-studio through double clicking Step0_South_Somalia_PROJECT.Rproj..\n
                                      Or you incorrectly typed the location of your main directory in parameters\n
                                      Your current directory is:\n", getwd(),"\nBut the code was expecting:\n",dir_core)) }
  
  #---------------------------------------------------------------------------------
  # Create folders using my conditional create function
  #---------------------------------------------------------------------------------
   #Level 0
   create <- sapply(c(dir_core,dir_runset),conditionalcreate,silent=TRUE)
  
   #Code
   create <- sapply(c(dir_data,dir_code),conditionalcreate,silent=TRUE)
 
   #Data
   create <- sapply(c(dir_data_shape,dir_data_remote),conditionalcreate,silent=TRUE)
   
   #Raw data
   create <- sapply(c(dir_data_remote_ARaw,
                        dir_data_remote_ARaw_missing),conditionalcreate,silent=TRUE)
   
   #Processed data
   create <- sapply(c(dir_data_remote_BGeoTif,
                        dir_data_remote_BGeoTif_daily,
                        dir_data_remote_BGeoTif_pentad,
                        dir_data_remote_BGeoTif_dekad,
                        dir_data_remote_BGeoTif_month),conditionalcreate,silent=TRUE)
   
   #Derived data
   create <- sapply(c(dir_data_remote_CDerived),conditionalcreate,silent=TRUE)
   
   create <- sapply(c(dir_data_remote_CDerived_1climate,
                         dir_data_remote_CDerived_1clim_daily,
                         dir_data_remote_CDerived_1clim_pentad,
                         dir_data_remote_CDerived_1clim_dekad,
                         dir_data_remote_CDerived_1clim_month),conditionalcreate,silent=TRUE)
   
   create <- sapply(c(dir_data_remote_CDerived_2anomaly,
                      dir_data_remote_CDerived_2anom_daily,
                      dir_data_remote_CDerived_2anom_pentad,
                      dir_data_remote_CDerived_2anom_dekad,
                      dir_data_remote_CDerived_2anom_month),conditionalcreate,silent=TRUE)
   
   create <- sapply(c(dir_data_remote_CDerived_3thresh,
                      dir_data_remote_CDerived_3thres_daily,
                      dir_data_remote_CDerived_3thres_pentad,
                      dir_data_remote_CDerived_3thres_dekad,
                      dir_data_remote_CDerived_3thres_month),conditionalcreate,silent=TRUE)
   
   #Output Statistics
   create <- sapply(c(dir_data_remote_DStats),conditionalcreate,silent=TRUE)
   

   
   
   
   
   
   
#================================================================================================================
# PARALLEL COMPUTING
#================================================================================================================
   if(verbose){message("        Setting up parallel computing")}
   #---------------------------------------------------------------------------------
   # Set up parallel computing
   #---------------------------------------------------------------------------------
   if(PSUSuperComputer){
     suppressPackageStartupMessages(library(doMPI))
     cl <- startMPIcluster()
     registerDoMPI(cl)
   }else{
     ncores <- detectCores(logical = FALSE)
     registerDoParallel(cores=(ncores-2))
   }

   
   #---------------------------------------------------------------------------------
   # Odd useful function
   #---------------------------------------------------------------------------------
    source(paste(dir_code,"0_GeneralFunctions.R",sep=sep))
   
   
   
   
   
#================================================================================================================
# Tidy up
#================================================================================================================
   suppressWarnings(try(rm(create)))
   suppressWarnings(try(rm(cranpackages)))
   suppressWarnings(try(rm(githubpackages)))
   suppressWarnings(try(rm(installed_packages)))
   suppressWarnings(try(rm(installed_remote_packages)))
   suppressWarnings(try( rm(n)))
   suppressWarnings(try(rm(out)))
   suppressWarnings(try(rm(package_needsupdating)))
   suppressWarnings(try(rm(packages)))
   suppressWarnings(try( rm(remotes_installed_packages)))
   suppressWarnings(try( rm(auto_update_packages)))
   
   


   
   
   
