: '
WARNING: this script can download a *lot* of data. Please
make sure you have bandwidth and diskspace before using.
One day of our soil mositure product is about 3.5Mb.

Bulk download NCEO/TAMSAT soil mositure data. Copy this file 
into the directory where you want to download data

Examples:

1) download all soil moisture data

bash sm_downloader.sh

2) download all soil mosture data from 2015 onward:

bash sm_downloader.sh 2015

3) download all soil mosture data from 2015 to 2017 (inclusive):

bash sm_downloader.sh 2015 2017

4) download soil mosture data from 2015 only:

bash sm_downloader.sh 2015 2015

5) download all soil mosture upto and including 2015:

bash sm_downloader.sh x 2015


Note - files that have already been downloaded and are in the
directory from which the script is executed willl be skipped.
This has been implemented to preserve bandwidth.
If you want to re-download a file you need to delete the local
copy first (or work in a new directory).

Requires a minimal set of unix/linux tools to be installed: bash, wget and rev 
(n.b. these typically come by default with a moder linux installation)

Tristan Quaife 24/11/20
t.l.quaife@reading.ac.uk
'

#command line options:
BEGYR=${1:-"x"}
ENDYR=${2:-"x"}

#url and name of file containing list
URL="http://gws-access.jasmin.ac.uk/public/odanceo/soil_moisture/nc/"
FILE_LIST="sm_file_list.txt"

#down load the list of files on the server:
wget $URL/$FILE_LIST -O $FILE_LIST

#download files
cat $FILE_LIST | while read TMP ; do
    
    #strip out the file name:
    SM_FILE=$(basename $TMP)
    
    #workout the year:
    TMP=$(echo $SM_FILE|rev)
    YEAR=$(echo ${TMP:7:4}|rev)

    #skip download if outside year range
    [ $BEGYR != "x" ] && [ $YEAR -lt $BEGYR ] && continue
    [ $ENDYR != "x" ] && [ $YEAR -gt $ENDYR ] && continue

    #download files, skipping any that have 
    #already been downloaded 
    [ ! -f $SM_FILE ] && wget $URL/$SM_FILE

done


