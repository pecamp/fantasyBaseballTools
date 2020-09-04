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

# Batting columns (used for my team evaluations)
battingCols   <- c("HR", "R", "RBI", "SO", "SB", "AVG", "OBP", "SLG", "wOBA")
pitchingCols  <- c("W", "ERA", "IP","HR", "SO", "WHIP", "K.9", "BB.9", "FIP", "WAR")

##################### Read-in data #####################

# Create scale paths
finalBatPATH    <- paste0(dataInputFolder, paste0(batFilePre, "_", fileDate, ".csv"))
finalPitPATH    <- paste0(dataInputFolder, paste0(pitFilePre, "_", fileDate, ".csv"))

# If file paths do not exist, run CreateStndardizeData.R
if(!(file.exists(finalBatPATH) | file.exists(finalPitPATH))){
  
  # Create a path to the script
  print('NOTE: Standardized data does not exist...running program')
  scriptPATH = file.path(scriptFolder, 'CreateStandardizedData.R')
  system(paste('Rscript', 'CreateStandardizedData.R'))
  
}


# Read-in scaled data
battingData     <- read.csv(finalBatPATH, header = TRUE, stringsAsFactors = FALSE)
pitchingData    <- read.csv(finalPitPATH, sep = ",", header = TRUE, stringsAsFactors = FALSE)

# Create total keeper list file path
keeperFilePATH  <- paste0(keeperInputFolder, keeperFileName)

if(midseason == TRUE){
  
  if(!file.exists(keeperFilePATH)){
    
    print('Keeper data does not exists...running program')
    py_run_file('C:\\Users\\phili\\OneDrive\\Documents\\DataProjects\\fantasyBaseballTools\\JupyterNotebooks\\DownloadTakenAndAvailablePlayers.py')
    
  }
  
  keeperData      <- read.csv(keeperFilePATH, header = TRUE, stringsAsFactors = FALSE)
  colnames(keeperData)[1] <- 'Keeper'
  
  
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

# if(length(keptFoundIX) > 0){
if(TRUE){
  
  # Remove players
  finalBatData  <- battingData[-batKeeperIX, ]
  finalPitData  <- pitchingData[-pitKeeperIX,]
  
  # Store keeper players
  finalBatKeeperData    <- battingData[batKeeperIX,]
  finalPitKeeperData    <- pitchingData[pitKeeperIX,]
  
} else {
  
  # Remove players
  finalBatData  <- battingData
  finalPitData  <- pitchingData
  
  # Store keeper players
  finalBatKeeperData    <- battingData
  finalPitKeeperData    <- pitchingData
  
}


##### Read - in my team
myTeam        <- read.csv(paste0("../data/", myTeamFile), header = TRUE, stringsAsFactors = FALSE)
colnames(myTeam)[1] = 'Keeper'

# Index players from my team
batMyTeamIX <- which(battingData$yahoo_id %in% myTeam$Player_ID)
pitMyTeamIX <- which(pitchingData$yahoo_id %in% myTeam$Player_ID)

if(length(batMyTeamIX) > 0 & length(pitMyTeamIX) > 0){
  
  myTeamBat   <- battingData[batMyTeamIX,]
  myTeamPit   <- pitchingData[pitMyTeamIX,]
  
}

# Create write out file path
selectedBatPATH  <- paste0(roundSelectionsFolder, paste0(paste(selBatFilePre, roundAt, sep = "_"), ".csv"))
selectedPitPATH  <- paste0(roundSelectionsFolder, paste0(paste(selPitFilePre, roundAt, sep = "_"), ".csv"))

if(!dir.exists(roundSelectionsFolder)) dir.create(roundSelectionsFolder)

# Examine by position


dataByPos <- split(finalBatData, f = finalBatData$espn_pos)
dataPitPos <- split(finalPitData, f = finalPitData$espn_pos)

dataKeepByPos     <- split(finalBatKeeperData, f = finalBatKeeperData$espn_pos)
dataKeepPitByPos  <- split(finalPitKeeperData, f = finalPitKeeperData$espn_pos)

head(finalBatData, n = 25)
head(finalPitData, n = 25)

posOfI  <- dataByPos[["C"]]
pitPOI  <- dataPitPos[["RP"]]
keepOfI <- dataKeepByPos[["SS"]]

# # Calculation team needs
# apply(select(myTeamBat, all_of(battingCols)), 2, sum)
# apply(select(myTeamPit, all_of(pitchingCols)), 2, sum)

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
