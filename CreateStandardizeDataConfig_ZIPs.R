# CreateStandardizeDataConfig.R
# Configuration file for CreateStandardizedData.R

# Library packages
packagesToUse <- c("tidyverse","magrittr")

# Set number of players
numPlayers  <- 11
numRounds   <- 25

# Draft position
draftSpot   <- 3

# Set logical paramters to use which projection data
useDepthC   <- FALSE
useZIPs     <- TRUE
useFAN      <- FALSE
useSteamer  <- FALSE

# Set a paramter to download variables or not
toDownload  <- FALSE

# Are you in midseason
midseason <-TRUE

# Set a parameter to write out table
toWrite     <- TRUE

# Set a vector with the TYPE variable to paste into the link
typeVector  <- c("fangraphsdc", "zips", "fan", "steamer")

# Set a vector with the read-in TYPE variable to paste into the link
readVector  <- c("DepthC", "ZIPs", "FAN", "Steamer")

# Set download pathways
baseBatURL  <- "https://www.fangraphs.com/projections.aspx?pos=all&stats=bat&type=TYPESYS"
basePitURL  <- "https://www.fangraphs.com/projections.aspx?pos=all&stats=pit&type=TYPESYS&team=0&lg=all&players=0"

# Set read-in pathways
baseBatRead <- "TYPESYSBat_20200228.csv"
basePitRead <- "TYPESYSPit_20200228.csv"

# Set master ID pathway
IDsFILE     <- "masterIDs_20190414.csv"

# Set storage pathways
storePATH   <- "../data/"
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
ipLimit         <- 25
paLimit         <- 200



