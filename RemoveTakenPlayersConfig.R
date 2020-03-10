# RemoveTakenPlayersConfig.R
# Configuration file for RemoveTakenPlayers.R

# Library packages
packagesToUse <- c("tidyverse","magrittr")

# Set read-in folder
dataInputFolder   <- "../data/output/"
keeperInputFolder <- "../data/"
roundSelectionsFolder <- "../data/output/selected/"

# Set Batting and Pitching filePaths
batFilePre        <- "Steamer_ScaledBattingData"
pitFilePre        <- "Steamer_ScaledPitchingData"
selBatFilePre     <- "UpdatedBatList"
selPitFilePre     <- "UpdatedPitList"

# My team
myTeamFile        <- "MyTeam.csv"


# Dates used in the data files
fileDate      <- "20190827"

# Round 
roundAt       <- 0

# Are you in midseason
midseason     <- TRUE

################ Keeper information ###################

keeperFileName<- "totalKeeperList_20190827.csv"

