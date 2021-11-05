# Remote sensing core dashboards

This code allows a user to create standardised subsets of a range of meteorological data.  Specifically it:

 1. Automatically downloads data from a range of sources 
     +   
 3. Standardise, temporally sum and subset


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
