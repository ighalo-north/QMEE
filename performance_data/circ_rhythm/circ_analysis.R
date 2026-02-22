#https://rethomics.github.io/damr.html
#https://cran.r-project.org/web/packages/damr/damr.pdf
#documentation for damr package with examples <3 <3 <3

#DAM: Drosophila Activity Monitor
library(damr) #main pkg
library(sleepr) #identifies when an animal is asleep or not (tied to behavr pkg)
library(lubridate) #fix date format for damr
library(ggetho) #graphing activity
library(readr)

'
basic starting stuff feb 22 - from ciracadian_analysis.R

i measured the activity of each of my 8 replicate lineages using 2 monitors at a time

2 independent monitors, each connected to their own 
  laptop running the DAM software. We tested pairs of replicates
    simultaneously.

Trials (times are approximate here, exact in metadata)
S1 C1 9am Feb 6 - 8am Feb 8
S2 C2 9am Feb 8 - 8am Feb 10
S3 C3 8am Feb 10 - 8am Feb 12
S4 C4 9am Feb 12 - 5pm Feb 14

only analyze 24 hours of data for each trial (9pm to 9pm) 
  the 13 hours beforehand allows the flies to acclimate to the environment.
'

metadata <- fread("metadata.csv")
metadata

#reformat start and end time into the format damr wants
metadata$start_datetime <- format(
  ymd_hm(metadata$start_datetime),
  "%Y-%m-%d %H:%M:%S"
)
metadata$stop_datetime <- format(
  ymd_hm(metadata$stop_datetime),
  "%Y-%m-%d %H:%M:%S"
)

#link the dam data
metadata <- link_dam_metadata(metadata, result_dir = "C:/Users/kigha/QMEE/performance_data/circ_rhythm/")
metadata #view the dam data sanity check

#create a column for TrtLin (S1, S2, etc instead of S and 1 in dff cols)
metadata$TrtLin <- factor(paste(metadata$treatment, metadata$lineage, sep = ""))

#treat all of these factors as factors
metadata$lineage <- as.factor(metadata$lineage)
metadata$treatment <- as.factor(metadata$treatment)
metadata$TrtLin <- as.factor(metadata$TrtLin)
metadata$sex <- as.factor(metadata$sex)
#metadata$region_id <- as.factor(metadata$region_id)

dt <- load_dam(metadata[status=="OK"], FUN = sleepr::sleep_dam_annotation) #load only good data
summary(dt) 

#shows one replicate at a time
ggetho(dt[xmv(TrtLin) == 'C1'], aes(z=activity)) +
  stat_tile_etho() + #shows the response var in the (colour) z axis
  stat_ld_annotations()

#show all
allplot <- ggetho(dt, aes(x=t, y=TrtLin, z=moving)) + stat_bar_tile_etho()
allplot



