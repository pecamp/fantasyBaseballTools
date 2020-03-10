####################################################################
# Program : RemoveTakenPlayers.R
# Author  : Philip Camp
# Date    : 22 March 2019
# 
# Purpose : Remove players from the Scaled Batting and Pitching
#           data sheets
##################################################################### 

# Clear work environment
rm(list = ls())

##################### Set parameters ###############################

# Source config file
source("RemoveTakenPlayersConfig.R")

# Library necessary packages
lapply(packagesToUse, function(x) library(x, character.only = TRUE))

today <- format(Sys.time(), "%Y%m%d")

##################### Read-in data #####################

# Create scale paths
finalBatPATH    <- paste0(dataInputFolder, paste0(batFilePre, "_", fileDate, ".csv"))
finalPitPATH    <- paste0(dataInputFolder, paste0(pitFilePre, "_", fileDate, ".csv"))

# Read-in scaled data
battingData     <- read.table(finalBatPATH, sep = ",", header = TRUE, stringsAsFactors = FALSE)
pitchingData    <- read.table(finalPitPATH, sep = ",", header = TRUE, stringsAsFactors = FALSE)

# Create total keeper list file path
keeperFilePATH  <- paste0(keeperInputFolder, keeperFileName)

if(midseason == TRUE){
  
  keeperData      <- read.table(keeperFilePATH, sep = ",", header = TRUE, stringsAsFactors = FALSE)
  
  
} else {
 
  # Read-in keeper data
  keeperData      <- read.table(keeperFilePATH, sep = ",", header = TRUE, stringsAsFactors = FALSE) %>%
                              select(Keeper) 
  
}

##################### Remove players from Scaled Data #####################

# Create a name matching index

# batKeeperIX <- which(keeperData$Keeper %in% battingData$Name)
# pitKeeperIX <- which(keeperData$Keeper %in% pitchingData$Name)

# If running midseason analysis, use the player id from yahoo
if(midseason == TRUE){
  
  batKeeperIX <- which(battingData$yahoo_id %in% keeperData$Player_ID)
  pitKeeperIX <- which(pitchingData$yahoo_id %in% keeperData$Player_ID)
  
  # Print which keepers were not found
  keptFound   <- c(battingData[batKeeperIX, "yahoo_id"], pitchingData[pitKeeperIX, "yahoo_id"])
  keptFoundIX <- which(keeperData$Keeper %in% keptFound)
  
} else {
  
  batKeeperIX <- which(battingData$Name %in% keeperData$Keeper)
  pitKeeperIX <- which(pitchingData$Name %in% keeperData$Keeper)
  
  # Print which keepers were not found
  keptFound   <- c(battingData[batKeeperIX, "Name"], pitchingData[pitKeeperIX, "Name"])
  keptFoundIX <- which(keeperData$Keeper %in% keptFound)
  
}



### REMEMBER TO SWITCH TO OBTAIN IDS (NOT NAMES) WHEN EXTRACTING FROM YAHOO
print(keeperData$Keeper[-keptFoundIX])

# Remove players
finalBatData  <- battingData[-batKeeperIX, ]
finalPitData  <- pitchingData[-pitKeeperIX,]

# Store keeper players
finalBatKeeperData    <- battingData[batKeeperIX,]
finalPitKeeperData    <- pitchingData[pitKeeperIX,]

##### Read - in my team
myTeam        <- read.table(paste0("../data/", myTeamFile), 
                            sep = ",", header = TRUE, stringsAsFactors = FALSE)

# Index players from my team
batMyTeamIX <- which(battingData$Name %in% myTeam$Name)
pitMyTeamIX <- which(pitchingData$Name %in% myTeam$Name)

myTeamBat   <- battingData[batMyTeamIX,]
myTeamPit   <- pitchingData[pitMyTeamIX,]

# Create write out file path
selectedBatPATH  <- paste0(roundSelectionsFolder, paste0(paste(selBatFilePre, roundAt, sep = "_"), ".csv"))
selectedPitPATH  <- paste0(roundSelectionsFolder, paste0(paste(selPitFilePre, roundAt, sep = "_"), ".csv"))

if(!dir.exists(roundSelectionsFolder)) dir.create(roundSelectionsFolder)

dataByPos <- split(finalBatData, f = finalBatData$espn_pos)
dataPitPos <- split(finalPitData, f = finalPitData$espn_pos)

dataKeepByPos     <- split(finalBatKeeperData, f = finalBatKeeperData$espn_pos)
dataKeepPitByPos  <- split(finalPitKeeperData, f = finalPitKeeperData$espn_pos)

posOfI  <- dataByPos[["CF"]]
pitPOI  <- dataPitPos[["RP"]]
keepOfI <- dataKeepByPos[["SS"]]

pitPOI$ThreeCatsSUM <- pitPOI$ERA + pitPOI$K.9 + pitPOI$BB.9 
finalPitData$ThreeCatsSUM <- finalPitData$ERA + finalPitData$K.9 + finalPitData$BB.9 + finalPitData$FIP
bigInningPitchers <- filter(finalPitData, IP > 0)

myTeamBat$ThreeCatSUM <- myTeamBat$RBI + myTeamBat$SO + myTeamBat$SB
finalBatKeeperData$TwoCatsSUM <- finalBatKeeperData$RBI + finalBatKeeperData$SO + finalBatKeeperData$SB
finalBatData$TwoCatsSUM <- finalBatData$RBI + finalBatData$SO + finalBatData$SB
posOfI$TwoCatsSUM <- posOfI$RBI + posOfI$SO + posOfI$SB

onlyGoodHitters <- filter(finalBatData, SUM > 2)

# Write out file
write.table(finalBatData, selectedBatPATH, sep = ",", col.names = TRUE, row.names = FALSE)
write.table(finalPitData, selectedPitPATH, sep = ",", col.names = TRUE, row.names = FALSE)
