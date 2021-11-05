# Meteorological remote sensing standardised repository

## What is this repository?

This code allows a user to create a standardised database of a range of meteorological data.  It is specifically for Dr Helen Greatrex and her work/partners.  For general users, you might find the IRI Data library more user friendly - https://iridl.ldeo.columbia.edu/

## For what data?

1. Currently here on github, the code can process

     - NOAA-ARC v2.0
     - NOAA-RFE 2.0
 
2. TO COME SOON: Code exists, just tidying and putting it on github (future requests also welcome)

     - *UCSB CHIRPS v2.0*
     - *TAMSAT v3.0*   
     - *IMERG v2.0*     
     - *TAMSAT Soil moisture (various parameters) v1.0*  
     - *CCI Soil moisture*
      

## Specifically what does it do?

First, the code first creates a repository of all the data on your own computer in a standardised way. 

 - **Step 1: Automatically download and update the data from source**

     - *The full code currently runs on the Penn State servers. Working out a desktop version now (or an scp option)*
     - *2 years of sample data is preloaded into this repository*

 - **Step 2: Standardises the data, saving each to daily geoTifs with predefined filenames and a custom projections**

     - *Future feature: Standardised spatial grids*

 - **Step 3: Temporally sums the standardised data to a Pentadal (~5 days), Dekadal (~10 days) and Monthly timesteps**
  
     - *You control missing data amounts*

 - **Step 4: Create and save a "Runset" for a cropped region/shapefile of your choice**
  
     - *The runset will contain a child version of the core folder, containing an R project, updated meta data:*

       - *The standardised cropped data* 
       - *Automatically updated meta data and parameter files*
       - *A mini version of the folder structure containing pre-installed code that will make standardised (and custom) statistics and dashboards (code being added as it is debugged)*
       - *FUTURE: Its own github account that is a "child" of the core code.  As new functions/dashboards are written, you can automatically add them into your own runsets with the click of a button, or pull updated data.*
    

**WARNING - RUNNING OUTSIDE THE SAMPLE DATA HERE WILL TAKE SEVERAL Gb SPACE - CONSIDER RUNNING ON A HARD-DRIVE**

## What do I need to run this?

### Software requirements

To run, this needs AT LEAST:

 - R version 4.1.0 (2021-05-18) -- "Camp Pontanezen"
 - R-Studio version Version 1.4.1717 ("Juliet Rose")

To learn more if you are new to R, see here: https://psu-spatial.github.io/Geog364-2021/pg_Tut1_about.html

### Package versions

You also need NEWLY UPDATED (Nov 2021) versions of these packages and their dependencies: *doParallel, dplyr, exactextractr, foreach, leaflet, matlab, ncdf4, parallel, readr, remotes, sp, sf, stringr, tidyverse, tmap, usethis*

You also need this package to be installed from github:  https://github.com/hgreatrex/Greatrex.Functions

#### R code to do this

If you have admin access on your computer, you can do this very fast by updating R/R-Studio, opening R studio and running these commands:

```{r}
 # Install packages from CRAN
 install.packages(c("sp","sf","ncdf4","exactextractr",
                             "tmap"," leaflet","matlab","remotes",
                             "parallel","foreach","doParallel", 
                            "dplyr","stringr", "readr","usethis"),dependencies=TRUE)

 # Then install this package from github:
 remotes::install_github('hgreatrex/Greatrex.Functions',force=TRUE)

```

If you don't have admin access, please work with someone who does to make this happen.

## Instructions

### Clone the repository

Need to add in instructions.  This should download a folder onto your computer with the same folder structure. Make sure the folder is in the place you want it to live forever, for now (Willemijn), consider an external harddrive.

### Open the R Project

 - You should now have R and R-Studio on your computer. Go into the folder and double click the project file, `Step0_Core_PROJECTFILE.Rproj`





