#=========================================================================================
# TEMPLATE FOR THE START OF EVERY SETUP
#=========================================================================================
phonebook <- function(ProductTime,ProductType,ProductFamily,...){
   #------------------------------------------------------------------------------------------
   # Choose the correct folder for the type of data
   #------------------------------------------------------------------------------------------
   if(grepl("RAW|CLIM|ANOM|THRESH",ProductType)){
      if("RAW" %in% toupper(ProductType)){coredir <- dir_data_remote_BGeoTif}
      if("CLIM" %in% toupper(ProductType)){coredir <- dir_data_remote_CDerived_1climate}
      if("ANOM" %in% toupper(ProductType)){coredir <- dir_data_remote_CDerived_2anom}
      if("THRESH" %in% toupper(ProductType)){coredir <- dir_data_remote_CDerived_3thresh}
   }else{
      stop("Your Product type is not one of RAW,CLIM,ANOM or THRESH")
   }
   
   #------------------------------------------------------------------------------------------
   # Then the correct subfolder for the timestamp
   #------------------------------------------------------------------------------------------
   if(grepl("DAILY|PENTAD|DEKAD|MONTH",toupper(ProductTime))){
      coretimedir <- paste(coredir,list.files(coredir)[grep(toupper(ProductTime),toupper(list.files(coredir)))],sep=sep)
      if(length(coretimedir) == 0){stop("The time data folder does not exist")}
   }else{
      stop("Your Product time is not one of DAILY,PENTAD,DEKAD or MONTH")
   }
   
   #------------------------------------------------------------------------------------------
   # Then the correct sub-folders for the products
   #------------------------------------------------------------------------------------------
   Datasetlist   <- paste(coretimedir,list.files(coretimedir),sep=sep)
   
   if(grepl("RAIN|TMIN|TMAX|RHUM|SM",toupper(ProductFamily))){
      ProductDirs <- Datasetlist[grep(tolower(ProductFamily),Datasetlist)]
      if(length(ProductDirs) == 0){stop("The product data folders do not exist for your family")}
   }else{
      stop("Your Product time is not one of RAIN|TMIN|TMAX|RHUM or SM")
   }
   
   #------------------------------------------------------------------------------------------
   # Now make nested output list.
   #------------------------------------------------------------------------------------------
   output <- vector(mode="list",length=5)
   names(output)[1:5] <- c("Data.Type","Data.Time.Res","Data.Family","Data.Products","Data.Files")
   output[[1]] <- toupper(ProductType)
   output[[2]] <- toupper(ProductTime)
   output[[3]] <- toupper(ProductFamily)
   output[[5]] <- lapply(ProductDirs,list.files,recursive=TRUE,pattern=".tif")
   AllProducts    <- stringr::str_split(ProductDirs,sep)
   AllProducts    <- unlist(lapply(AllProducts,"[",length(AllProducts[[1]])))
   names(output[[5]]) <- AllProducts
   
   output[[4]] <- unlist(lapply(stringr::str_split(AllProducts,paste(tolower(ProductFamily),"_",sep="")),"[",2))
   
   print(output[[1]])
   print(output[[2]])
   print(output[[3]])
   print(output[[4]])
   
   return(output)
}