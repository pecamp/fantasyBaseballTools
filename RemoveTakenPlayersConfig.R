# RemoveTakenPlayersConfig.R
# Configuration file for RemoveTakenPlayers.R

# Library packages
packagesToUse <- c("tidyverse","magrittr", "reticulate")

# Set read-in folder
dataInputFolder   <- "../data/output/"
keeperInputFolder <- "../data/"
scriptFolder      <- "C:/Users/phili/OneDrive/Documents/DataProjects/fantasyBaseballTools"
roundSelectionsFolder <- "../data/output/selected/"

# Set Batting and Pitching filePaths
batFilePre        <- "Steamer_ScaledBattingData"
pitFilePre        <- "Steamer_ScaledPitchingData"
selBatFilePre     <- "UpdatedBatList"
selPitFilePre     <- "UpdatedPitList"

# My team
myTeamFile        <- "MyTeam.csv"


# Dates used in the data files
fileDate      <- format(Sys.time(), '%Y%m%d')

# Round 
roundAt       <- 0

# Are you in midseason
midseason     <- TRUE

################ Keeper information ###################

keeperFileName<- paste0("totalKeeperList_", fileDate, ".csv")

