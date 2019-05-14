####################################################################
# Program : KeeperSelection.R
# Author  : Philip Camp
# Date    : 21 Feb 2019
# 
# Purpose : 
#################################################################### 

# Clear environment
rm(list = ls())

##################### Set parameters ###############################

# Source config file
source("KeeperSelectionConfig.R")

# Library necessary packages
lapply(packagesToUse, function(x) library(x, character.only = TRUE))

today <- format(Sys.time(), "%Y%m%d")

##################### Load Data ####################################

# Create a vector storing the path to the potential keeper file
dataPATH <- paste0(dataFolder, dataFile)

# Read-in both sheets (batters first, pitchers second)
for(i in 1:numSheets){
  
  # Read in data and assign each sheet to the correct sheetName
  assign(sheetNames[i], read.xlsx(dataPATH, sheetIndex = i, header = TRUE, stringsAsFactors = FALSE))

}


################# Source CreateStandardizedData.R ##################

commandArgs <- function(...) "SourceFile"
source("CreateStandardizedData.R")

################# Join standardized data to keepers #################

# Join the keeper list with the standardized data
BatPotKeeps   <- left_join(Batters, BatSub, by = c("Batter" = "Name")) %>%
  arrange(desc(SUM))
PitPotKeeps   <- left_join(Pitchers, PitSub, by = c("Pitcher" = "Name")) %>%
  arrange(desc(SUM))

# Rename Batters and Pitchers column to name
colnames(BatPotKeeps)[1]  <- "Name"
colnames(PitPotKeeps)[1]  <- "Name"

# Create a position category
BatPotKeeps$Position      <- "Batter"
PitPotKeeps$Position      <- "Pitcher"

# Find the relevant columns to determine value (set in the config)
batKeepColIX    <- which(colnames(BatPotKeeps) %in% finalKeeperCol)
pitKeepColIX    <- which(colnames(PitPotKeeps) %in% finalKeeperCol)

# Combine the data 
finalKeeperList   <- rbind(BatPotKeeps[, batKeepColIX], PitPotKeeps[, pitKeepColIX])

# Add the projected draft spot for that pick
finalKeeperList                 <- left_join(finalKeeperList, myDraftSpots[,c("Round", "DraftDP")], 
                                   by = c("Draft" = "Round"))


# Add a column for added DPs
finalKeeperList$AddedDPValue    <- finalKeeperList$DraftDP - finalKeeperList$RoundDP


finalKeeperList   <- finalKeeperList %>%
  arrange(desc(SUM))

finalKeeperDF     <- finalKeeperList

################# Create maximum value ##############################

###### Create a vector with all possible combinations ###

allCombos         <- combn(finalKeeperList$Name, 5, simplify = FALSE)

allPossibleKeepers <- function(x){
  
  ############# cat stage #############
  
  # Initialize four logical vectors
  toReturnCat   <- FALSE
  toReturnTop   <- FALSE
  toReturnSec   <- FALSE
  toReturnLast  <- FALSE
  
  # Index the names in finalKeeperList
  idIX <- which(finalKeeperList$Name %in% x)
  
  # Create a frequency table of the position
  catTestTable <- table(finalKeeperList[idIX, "Position"])
  
  # If the table matches our limits of 2-3, or 3-2, return the players
  if(all(catTestTable[1:2] == c(3,2)) || all(catTestTable[1:2] == c(2,3))){
    
    # Return 
    toReturnCat   <- TRUE
    
  } 
  
  ########### top stage ###########

  # Create a frequency table of the position
  draftTestTable <- table(finalKeeperList[idIX, "Draft"])
  
  # Index the draft rounds found
  t1IX      <- which(as.integer(names(draftTestTable)) %in% tier1)
  
  # If there was only 1 round in the top tier
  # assure that there aren't two picks in that round
  if((length(t1IX) == 1 && draftTestTable[t1IX] == 1) || length(t1IX) == 0){
    
    # Return x
    toReturnTop <- TRUE
    
  }
  
  ########### sec stage ###########
  
  # Index the draft rounds found
  t2IX      <- which(as.integer(names(draftTestTable)) %in% tier2)
  
  # If there was only 1 round in the top tier
  # assure that there aren't two picks in that round
  if((length(t2IX) == 1 && draftTestTable[t2IX] == 1) || length(t2IX) == 0){
    
    # Return 
    toReturnSec   <- TRUE
    
  }
  
  ########### last stage ###########
  
  # Index the draft rounds found
  lastIX      <- which(as.integer(names(draftTestTable)) > lowRoundLimit)
  
  # Only return x with a round less than lowRoundLimit
  if(length(lastIX) > 0) toReturnLast <- TRUE
  
  ######### final condition ########
  
  # If all conditions are met, return x
  if(all(c(toReturnCat, toReturnTop, toReturnSec, toReturnLast))){
  
    # cbind(x, sum(finalKeeperList[idIX, "SUM"]))
    data.frame(Player1 = x[1],
               Player2 = x[2],
               Player3 = x[3],
               Player4 = x[4],
               Player4 = x[5],
               SUM = sum(finalKeeperList[idIX, "SUM"]),
               SUMAboveMed = sum(finalKeeperList[idIX, "SUMAboveMed"]),
               SUMAddedDP = sum(finalKeeperList[idIX, "AddedDPValue"]))
    
  }
  
}

# Create a list of all possible keepers that fit the rules (allPossibleKeepers performs this)
allCombosList <- lapply(allCombos, allPossibleKeepers)

# Remove the NULL entries
allCombosList <- compact(allCombosList)

# Name the elements of the list 1 to length(allCombosList)
names(allCombosList) <- paste(1:length(allCombosList))

# Make into a dataframe of all the possible combinations
allCombosDF <- bind_rows(allCombosList)

# Order list in descending value
allCombosDF <- allCombosDF %>%
  arrange(desc(SUM))

allCombosDF$ScaledValue <- as.numeric(scale(allCombosDF$SUM) + scale(allCombosDF$SUMAddedDP))


allCombosDF <- allCombosDF %>%
  arrange(desc(ScaledValue))
#### Testing grounds


