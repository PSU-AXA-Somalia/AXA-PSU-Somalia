

#------------------------------------------------------------------------------------------
# DEKAD SCRIPTS
#------------------------------------------------------------------------------------------
for(n_data in seq_along(Dekad_datasetlist)){
   dataset <- Dekad_datasetlist[n_data]   
   
   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   res <- makeanomalydekadclimate(dataset,minyear,maxyear,missinglimit,
                                  dir_data_remote_BGeoTif_dekad,dir_data_remote_CDerived_dekad_anom,
                                  dir_data_remote_CDerived_dekad_clim,overwrite)
}

#------------------------------------------------------------------------------------------
# MONTH SCRIPTS
#------------------------------------------------------------------------------------------
for(n_data in seq_along(Month_datasetlist)){

   dataset <- Month_datasetlist[n_data]   

   if(verbose %in% c(TRUE,"Limited")){message(paste("\n Dataset: ",dataset))}
   
   res <- makeanomalymonthclimate(dataset,minyear,maxyear,missinglimit,
                                  dir_data_remote_BGeoTif_month,dir_data_remote_CDerived_month_anom,
                                  dir_data_remote_CDerived_month_clim,overwrite)
}

#------------------------------------------------------------------------------------------
# PENTAD SCRIPTS TWEAK 6
# https://workflowy.com/#/dca35f82c8d4
#------------------------------------------------------------------------------------------


