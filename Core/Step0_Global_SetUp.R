
#================================================================================================================
# 1. MAIN FOLDER AND PARALLEL COMPUTING
#================================================================================================================
if(verbose){message("Step 0: Loading Global Parameters")}

   #---------------------------------------------------------------------------------
   # Just stops spatial update errors from R. IGNORE
   #---------------------------------------------------------------------------------
    options("rgdal_show_exportToProj4_warnings"="none")

   #---------------------------------------------------------------------------------
   # Run admin updates if it's Helen running this
   #---------------------------------------------------------------------------------
    if(length((grep("hlg5155", dir_main))>0) | (length(grep("hgreatrex", dir_main))>0)){
      if(verbose){message("Step 0: HELEN'S COMPUTER RUN. Running admin updates")}
      functionloc <- "/Users/hlg5155/Dropbox/My Mac (E2-GEO-WKML011)/Documents/GitHub/My code/Greatrex.Functions/R"
      functionstomove <- list.files(functionloc)
      functionstomove <- functionstomove[grep(".R",toupper(functionstomove))]
      for(n in 1:length(functionstomove)){ file.copy(from=paste(functionloc,functionstomove[n],sep=sep),to=paste(dir_code,"Global Functions",functionstomove[n],sep=sep),overwrite = TRUE)}
    }

#================================================================================================================
# 2. LIBRARIES AND PACKAGES GENERAL
# AUTO INSTALL AND UPDATE
#================================================================================================================

  #---------------------------------------------------------------------------------
  # Package names
  #---------------------------------------------------------------------------------
    cranpackages <- data.frame(Package="doParallel",Version="1.0.16") 
    cranpackages <- rbind(cranpackages,c("exactextractr" ,"0.7.1" ))
    cranpackages <- rbind(cranpackages,c("foreach" ,      "1.5.1"  ))
    cranpackages <- rbind(cranpackages,c("leaflet"   ,    "2.0.4.1"))
    cranpackages <- rbind(cranpackages,c("matlab"     ,   "1.0.2"  ))
    cranpackages <- rbind(cranpackages,c("ncdf4"     ,    "1.17"   ))
    cranpackages <- rbind(cranpackages,c("parallel"  ,    "4.1.0"  )) 
    cranpackages <- rbind(cranpackages,c("raster" ,       "3.5-2"  ))
    cranpackages <- rbind(cranpackages,c("readr"     ,    "2.0.2"  ))
    cranpackages <- rbind(cranpackages,c("remotes"   ,    "2.4.1"  ))
    cranpackages <- rbind(cranpackages,c("sf"        ,    "1.0-3"  ))
    cranpackages <- rbind(cranpackages,c("sp"        ,    "1.4-5"  ))
    cranpackages <- rbind(cranpackages,c("stringr"   ,    "1.4.0"  ))
    cranpackages <- rbind(cranpackages,c("tidyverse" ,    "1.3.1"  ))
    cranpackages <- rbind(cranpackages,c("dplyr"     ,    "1.0.7"  ))
    cranpackages <- rbind(cranpackages,c("terra"     ,    "1.4.11"  ))
    cranpackages <- rbind(cranpackages,c("tmap"      ,    "3.3-2"  ))
    cranpackages <- rbind(cranpackages,c("usethis"   ,    "2.1.3"  ))
   
    githubpackages <- data.frame(Github="hgreatrex",Package="Greatrex.Functions",Version="0.1.1")
    
    #---------------------------------------------------------------------------------
    # Install packages not yet installed
    #---------------------------------------------------------------------------------
    if(verbose){message("        Checking if packages need to be installed")}
    
    # Ones from CRAN
    installed_packages <- cranpackages$Package %in% rownames(installed.packages())
    
    if (any(installed_packages == FALSE)) {
       if(verbose){message(paste("           Installing package:",cranpackages$Package[which(installed_packages==FALSE)],"\n"))}
       test <- try(install.packages(cranpackages$Package[!installed_packages],quiet=TRUE,dependencies=TRUE),silent=TRUE)
    }
    
    
    # Ones from Github
    flag <- TRUE
    remotes_installed_packages <- githubpackages$Package %in% rownames(installed.packages())
    if (any(remotes_installed_packages == FALSE)) {
       remotes_missing <- githubpackages[!remotes_installed_packages,]
       
       for(n in 1:nrow(remotes_missing)){
          if(verbose){message(paste("           Installing package from Github:",paste(remotes_missing$Github[n],remotes_missing$Package[n],sep="/"),"\n"))}
          test <- try(remotes::install_github(paste(remotes_missing$Github[n],remotes_missing$Package[n],sep="/"),quiet=TRUE,force=TRUE,upgrade="never"),silent=TRUE)
          if((substr(test[1],1,5) %in% "Error")&&(remotes_missing$Package[n] %in% "Greatrex.Functions")){
              if(verbose){message("WARNING: Unable to load Greatrex.Functions from github\n Loading built in functions:\n")}
              flag <- FALSE
              dir_functions <- paste(dir_code,"Global Functions",sep=sep)
              for(f in 1:length(list.files(dir_functions))){source(paste(dir_functions,list.files(dir_functions)[f],sep=sep))}
              rm(f)
          }
       }
    }
    
    #---------------------------------------------------------------------------------
    # Final check
    #---------------------------------------------------------------------------------
    installed_packages <- cranpackages$Package %in% rownames(installed.packages())
    if (any(installed_packages == FALSE)) {
      stop(paste("CRAN Package install failed:",cranpackages$Package[which(installed_packages==FALSE)],"\n"))
    }
    installed_remote_packages <- githubpackages$Package %in% rownames(installed.packages())
    if (any(installed_remote_packages == FALSE)&&(flag==TRUE)) {
      stop(paste("Github Package install failed:",paste(githubpackages$Github[which(installed_remote_packages==FALSE)],githubpackages$Package[which(installed_remote_packages==FALSE)],sep="/"),"\n"))
    }      
   
    #---------------------------------------------------------------------------------
    # Update any that need updating
    #---------------------------------------------------------------------------------
    if(updatepackage){ 
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
    }
    
    

    
   
  #---------------------------------------------------------------------------------
  # Load packages into R
  #---------------------------------------------------------------------------------
  if(verbose){message("        Loading packages")}
  out <- lapply(cranpackages$Package, function(x) suppressPackageStartupMessages(library(x, character.only = TRUE)))
  if(verbose){message(paste("           Package loaded:",cranpackages$Package,"\n"))}
  if(flag ==TRUE){
    if(verbose){message(paste("           Package loaded:",githubpackages$Package,"\n"))}
    out <- lapply(githubpackages$Package, function(x) suppressPackageStartupMessages(library(x, character.only = TRUE)))
  }else{
    if(verbose){message(paste("           Greatrex.Functions loaded as individual functions rather than package"))}
  }
  
  
#=================================================================================
# DIRECTORIES SUB STRUCTURE - you can edit sub-folder names here. 
# It will also auto-create any that don't exist
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
  
   #Level 0 
   create <- sapply(c(dir_core,dir_runset),conditionalcreate,silent=TRUE)
   if(getwd() != dir_core){
      stop(paste("Either you did not open R-studio through double clicking Step0_Core_PROJECTFILE.Rproj..\nOr you incorrectly typed the location of your main directory in parameters\nYour current directory is:\n",
                 getwd(),"\nBut the code was expecting:\n",dir_core))
   }
  
   #Data Level 1
   create <- sapply(c(dir_data,dir_code),conditionalcreate,silent=TRUE)
 
   #Data Level 2
   create <- sapply(c(dir_data_shape,dir_data_remote),conditionalcreate,silent=TRUE)
   
   #Data Level 3
   create <- sapply(c(dir_data_remote_ARaw,dir_data_remote_BGeoTif),conditionalcreate,silent=TRUE)
   
   #Data Level 4
   create <- sapply(c(dir_data_remote_BGeoTif_daily,
                      dir_data_remote_BGeoTif_pentad,
                      dir_data_remote_BGeoTif_dekad,
                      dir_data_remote_BGeoTif_month),conditionalcreate,silent=TRUE)
   
   
#================================================================================================================
# 3. PARALLEL COMPUTING
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
   suppressWarnings(try( rm(updatepackage)))
   
   if (rstudioapi::versionInfo()$version < "1.4.17") {
     warning("Your R-Studio is out of date and this code might not work. Consider updating R-studio!\nVisit: \nhttps://www.rstudio.com/products/rstudio/download/#download")
   }
   if(R.Version()$major < 4){
     warning("Your R version is VERY out of date and this code is likely to break. Consider updating R!\nVisit: https://cran.r-project.org/")
   }
   

   
   
   
