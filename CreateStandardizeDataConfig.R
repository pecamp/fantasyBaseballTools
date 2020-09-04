# CreateStandardizeDataConfig.R
# Configuration file for CreateStandardizedData.R

# Library packages
packagesToUse <- c("tidyverse","magrittr", 'data.table', 'reticulate')

# Set number of players
numPlayers  <- 11
numRounds   <- 25

# Draft position
draftSpot   <- 3

# Set logical paramters to use which projection data
useDepthC   <- FALSE
useZIPs     <- FALSE
useFAN      <- FALSE
useSteamer  <- TRUE

# Set a paramter to download variables or not
toDownload  <- FALSE

# Are you in midseason
midseason <- TRUE

# Set a parameter to write out table
toWrite     <- TRUE

# Set a vector with the TYPE variable to paste into the link
typeVector  <- c("fangraphsdc", "zips", "fan", "steamer")

# Set a vector with the read-in TYPE variable to paste into the link
readVector  <- c("DepthC", "ZIPs", "FAN", "Steamer")

# Set download pathways
baseBatURL  <- "https://www.fangraphs.com/projections.aspx?pos=all&stats=bat&type=TYPESYS"
basePitURL  <- "https://www.fangraphs.com/projections.aspx?pos=all&stats=pit&type=TYPESYS&team=0&lg=all&players=0"

# Create a today timestamp for config
todayConfig = format(Sys.time(), '%Y%m%d')

# Set read-in pathways
baseBatRead <- paste0('TYPESYSBat_', todayConfig, '.csv')
basePitRead <- paste0('TYPESYSPit_', todayConfig, '.csv')

# ADP parameters

# Logical vector to detemine if there is no ADP data in projections
NoADP       <- FALSE

# ADP filename
adpREAD     <- "ADP_20200229.csv"



# Set master ID pathway
IDsFILE     <- "master_20200901.csv"

# Set storage pathways
storePATH   <- "../data"
dataPATH    <- ""



##################################

# Naming vector
namingVec     <- c("Name", "playerid", "ADP")

if(useDepthC == TRUE | useZIPs == TRUE | useFAN == TRUE){
  
  # Data parameters
  battingStats  <- c("PA",
                     "R", 
                     "HR", 
                     "RBI",
                     "SB",
                     "SO",
                     "AVG",
                     "OBP",
                     "SLG",
                     "wOBA")
  
  pitchingStats <- c("IP",
                     "W", 
                     "SO",
                     "ERA",
                     "WHIP",
                     "K.9",
                     "BB.9",
                     "FIP",
                     "HR",
                     "WAR")
}


if(useSteamer == TRUE){
  
  # Data parameters
  battingStats  <- c("PA",
                     "R", 
                     "HR", 
                     "RBI",
                     "SB",
                     "SO",
                     "AVG",
                     "OPS",
                     "wOBA",
                     "wRC.")
  
  pitchingStats <- c("IP",
                     "W", 
                     "SO",
                     "ERA",
                     "WHIP",
                     "K.9",
                     "BB.9",
                     "FIP",
                     "RA9.WAR",
                     "WAR")
}



# Create a vector telling R if higher is better or lower is better
# for the stat

lowerBatVars  <- c("SO")
lowerPitVars  <- c("ERA", "WHIP", "BB.9", "FIP", "HR")

######################################################################

# WAR multiplication factor
pitWarFactor    <- 1.0

# Data removal thresholds. I need to come up with a method for selecting this number
ipLimit         <- 8
paLimit         <- 50

# Limit by quantile after remove all above 1
ipQuantile         <- .5
paQuantile         <- .5

# Limit method
limitMethod = 'Quantile'
