# Meteorological remote sensing standardised repository

## What is it

This code allows a user to create a standardised database of a range of meteorological data.  It is specifically for Dr Helen Greatrex and her work/partners.  For general users, you might find the IRI Data library more user friendly - https://iridl.ldeo.columbia.edu/

## For what data?

1. Currently here on github:
   a) NOAA-ARC 2.0
   b) NOAA-RFE 2.0
 
2. Code exists, just putting it on github
   a) UCSB CHIRPS
   b) TAMSAT v3
   c) TAMSAT Soil moisture
   d) CCI Soil moisture
   
## What does it do?

First, the code first creates a repository of all the data on your own computer in a standardised way.  

 1. Automatically downloads data from source (code exists, working out Github) - Sample data is preloaded into this repository
 2. Standardises the data to a daily geoTif with predefined filenames and a custom projections (FUTURE FEATURE: standardized grids)
 3. Temporally sums the data to a Pentadal (~5 days), Dekadal (~10 days) and Monthly timesteps, where you control missing data

Second, the code 
 
        

     +   
 3. Standardise, temporally sum and subset

**WARNING - RUNNING OUTSIDE THE SAMPLE DATA HERE WILL TAKE SEVERAL Gb SPACE - CONSIDER RUNNING ON A HARD-DRIVE**


To run, this needs AT LEAST
R version 4.1.0 (2021-05-18) -- "Camp Pontanezen"
R-Studio version Version 1.4.1717 ("Juliet Rose")

Updated versions of these packages AND THEIR DEPENDENCIES
doParallel
dplyr
exactextractr
foreach
leaflet
matlab
ncdf4
parallel
readr
remotes
sp
sf
stringr
tidyverse
tmap
usethis
This package to be installed from github:
https://github.com/hgreatrex/Greatrex.Functions

AKA if you can get someone to run this code, it can happen very fast!

install.packages(c("sp","sf","ncdf4","exactextractr",
                             "tmap"," leaflet","matlab","remotes",
                             "parallel","foreach","doParallel", 
                            "dplyr","stringr", "readr","usethis"),dependencies=TRUE)

#This package to be installed from github:
remotes::install_github('hgreatrex/Greatrex.Functions',force=TRUE)
