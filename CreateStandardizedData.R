####################################################################
# Program : CreateStandardizedData.R
# Author  : Philip Camp
# Date    : 18 Feb 2019
# 
# Purpose : This program will create a standardized dataset 
#           of the desired baseball projection sets
#################################################################### 

# If the script is being sourced...do not clear environment
scriptArgs      <- commandArgs(trailingOnly = TRUE)

if(length(scriptArgs) != 0 && scriptArgs == "SourceFile"){
  
  print("Sourcing CreateStandardizedData.R")
  isBeingSourced <- TRUE
  
} else {
 
  isBeingSourced  <- FALSE 
}

if(isBeingSourced == FALSE){
  
  # Clear environment
  rm(list = ls())
  
}


##################### Set parameters ###############################

# Source config file
source("CreateStandardizeDataConfig.R")

# Library necessary packages
lapply(packagesToUse, function(x) library(x, character.only = TRUE))

today <- format(Sys.time(), "%Y%m%d")

##################### Download or read-in data #####################

# Create a data folder if there isn't one
dir.create(storePATH, showWarnings = FALSE)

# Determine which dataset to use
dataIX  <-  which(c(useDepthC, useZIPs, useFAN, useSteamer) == TRUE)

if(length(dataIX) > 0){
  
  # Echo what data is being used
  print(paste("Using", readVector[dataIX[1]]))
  
} else {
  
  # Echo a warning that no data was selected
  print("WARNING: No data selected")
  break
}

# Download data or else read-in
if(toDownload == TRUE){
  
  print("Downloading data")
  
} else {
  
  print("Reading-in data..")
  
  # Create read-in bat pathway
  tempCSV       <- gsub("TYPESYS", readVector[dataIX[1]], baseBatRead)
  tempBAT.PATH  <- paste0(storePATH, tempCSV)
  
  # Create read-in pitch pathway
  tempCSV       <- gsub("TYPESYS", readVector[dataIX[1]], basePitRead)
  tempPIT.PATH  <- paste0(storePATH, tempCSV)
  
  # Echo location of data
  print(paste("...from:", tempBAT.PATH))
  print(paste("...from:", tempPIT.PATH))
  
  # Read-in bat data
  BatData   <- read.csv(tempBAT.PATH, header = TRUE, stringsAsFactors = FALSE)
  PitData   <- read.csv(tempPIT.PATH, header = TRUE, stringsAsFactors = FALSE)
}

# Fix column names
colnames(BatData)[1] <- "Name"
colnames(PitData)[1] <- "Name"

######################## Clean data ################################

# Remove any rows that are below the ipLimit and paLimit
BatData       <- BatData %>% 
                    filter(PA > paLimit)

PitData       <- PitData %>% 
                    filter(IP > ipLimit)

# Convert SO to SO per PA
BatData$SO    <- BatData$SO / BatData$PA


######################## Scale data ################################

# Create indices for columns of interest
batNamIX      <- which(colnames(BatData) %in% namingVec)
batRespIX     <- which(colnames(BatData) %in% battingStats)

pitNamIX      <- which(colnames(PitData) %in% namingVec)
pitRespIX     <- which(colnames(PitData) %in% pitchingStats)

# Subset data to the columns needed
BatSub  <- BatData %>%
              select(c(batNamIX, batRespIX))

PitSub  <- PitData %>%
              select(c(pitNamIX, pitRespIX))


# Find the columns in the subsetted variables
batSubIX            <- which(colnames(BatSub) %in% battingStats)
pitSubIX            <- which(colnames(PitSub) %in% pitchingStats)
        
# Scale the data of the data variables

# Echo process to the console
print("...scaling data")

BatSub[, batSubIX]  <- apply(BatSub[, batSubIX], 2, scale)
PitSub[, pitSubIX]  <- apply(PitSub[, pitSubIX], 2, scale)

# Multiply pitching WAR by a WAR multiplication factor

# Echo process to the console
print(paste("...WAR multiplication factor of:", pitWarFactor))

warColIX            <- grep("WAR", colnames(PitSub))
PitSub[, warColIX]  <- PitSub[, warColIX] * pitWarFactor 

# Change the direction of the variable because of lower variables

# NOTE: NEED TO CREATE A K/GP variables
for(i in seq_along(batSubIX)){
  
  if(colnames(BatSub)[batSubIX[i]] %in% lowerBatVars) BatSub[, batSubIX[i]] <- -BatSub[, batSubIX[i]]
}

for(i in seq_along(pitSubIX)){
  
  if(colnames(PitSub)[pitSubIX[i]] %in% lowerPitVars) PitSub[, pitSubIX[i]] <- -PitSub[, pitSubIX[i]]
}



# Create a column with the most standard deviation obtained
BatSub$SUM    <- BatSub %>%
                  select(batSubIX) %>%
                  rowSums(na.rm = TRUE)

PitSub$SUM    <- PitSub %>%
                  select(pitSubIX) %>%
                  rowSums(na.rm = TRUE)

# Order the variables by SUM
BatSub        <- BatSub %>%
                  arrange(desc(SUM))

PitSub        <- PitSub %>%
                  arrange(desc(SUM))


# Read-in masterIDs
masterIDs     <- read.csv(paste0(storePATH, IDsFILE), header = TRUE, stringsAsFactors = FALSE)

if(useZIPs){
  
  masterIDs[, "fg_id"] <- as.integer(masterIDs[, "fg_id"])
  
}
# Add position to the data using ESPN designated positions. They are the closest to Yahoo Fantasy
# positions, and are cleaner than Yahoo's here.

print("...adding position via ESPN using the masterID table")

BatSub        <- left_join(BatSub, masterIDs[,c("fg_id", "fg_name", "espn_pos", "yahoo_id")],
                           by = c("playerid" = "fg_id"))
PitSub        <- left_join(PitSub, masterIDs[,c("fg_id", "fg_name", "espn_pos", "yahoo_id")],
                           by = c("playerid" = "fg_id"))

######### If in mid-season mode, ignore ######################
if(midseason == FALSE){
  
  ######### Create a drafting grid ##############################
  
  # Create a draft grid
  draftingGrid  <- data.frame(t(array(1:(numPlayers * numRounds), c(numPlayers, numRounds))))
  
  # Extract even rows
  evenRounds              <- paste(seq(2, (numPlayers * numRounds), by = 2))
  
  # Create even row index
  evenIX                  <- which(rownames(draftingGrid) %in% evenRounds)
  
  # Reverse the order of the even rows
  draftingGrid[evenIX, ]  <- rev(draftingGrid[evenIX,])
  
  # Set row and column names
  colnames(draftingGrid)  <- paste0("Player", 1:numPlayers)
  
  # Extract my rounds
  myDraftSpots            <- data.frame(Round = as.integer(rownames(draftingGrid)), 
                                        RoundDP = draftingGrid[,draftSpot],
                                        DraftDP = draftingGrid[,draftSpot])
  
  ######### Create value metric relative to round #####################
  
  # Create a value metric above the average value of that position
  
  # Create a vector with round and ADP values
  draftRoundStart       <- c(seq(1, (numPlayers * numRounds), by = numPlayers),999)
  draftRoundNames       <- 1:(length(draftRoundStart) - 1)
  
  # Create a column with the projected draft round in our league
  BatSub$Round          <- cut(BatSub$ADP, breaks = draftRoundStart, labels = draftRoundNames)
  PitSub$Round          <- cut(PitSub$ADP, breaks = draftRoundStart, labels = draftRoundNames)
  
  if(class(BatSub$Round) == "factor") BatSub$Round <- draftRoundNames[BatSub$Round]
  if(class(PitSub$Round) == "factor") PitSub$Round <- draftRoundNames[PitSub$Round]
  
  
  # Create a df with the average SUM per draft round
  averageBatSUMPerRound <- BatSub %>% 
    group_by(Round) %>%
    summarize(N = n(),
              AVG_SUM = mean(SUM),
              MED_SUM = median(SUM))
  
  averagePitSumPerRound <- PitSub %>%
    group_by(Round) %>%
    summarize(N = n(),
              AVG_SUM = mean(SUM),
              MED_SUM = median(SUM))
  
  
  # Add SUM above median 
  BatSub                <- left_join(BatSub, averageBatSUMPerRound[,c("Round", "MED_SUM")], 
                                     by = c("Round" = "Round"))
  
  PitSub                <- left_join(PitSub, averagePitSumPerRound[,c("Round", "MED_SUM")], 
                                     by = c("Round" = "Round"))
  
  
  # Create column of SUM above MED
  BatSub$SUMAboveMed    <- BatSub$SUM - BatSub$MED_SUM
  PitSub$SUMAboveMed    <- PitSub$SUM - PitSub$MED_SUM
  
  # Add the projected draft spot for that pick
  BatSub                <- left_join(BatSub, myDraftSpots, by = c("Round" = "Round"))
  PitSub                <- left_join(PitSub, myDraftSpots, by = c("Round" = "Round"))
  
}


#################### Write out code #####################

# If a toWrite is true, the program will write out two .csv for Batting
# and Pitching data

if(toWrite == TRUE){
  
  # Create a filename
  
  if(useDepthC == TRUE){
   
    batName       <- paste0("DepthC_ScaledBattingData", "_", today, ".csv")
    pitName       <- paste0("DepthC_ScaledPitchingData", "_", today, ".csv")
    
     
  }
  
  if(useSteamer == TRUE){
    
    batName       <- paste0("Steamer_ScaledBattingData", "_", today, ".csv")
    pitName       <- paste0("Steamer_ScaledPitchingData", "_", today, ".csv")
    
    
  }
  
  if(useZIPs == TRUE){
    
    batName       <- paste0("ZIPs_ScaledBattingData", "_", today, ".csv")
    pitName       <- paste0("ZIPs_ScaledPitchingData", "_", today, ".csv")
    
    
  }
  
  
  # Create the output folder name
  outputFolder  <- paste0(storePATH, "output/")
  
  # Assure that the output folder exists
  if(!dir.exists(outputFolder)){
    
    dir.create(outputFolder)
  }
  
  # Create final PATH
  batPATH       <- paste0(outputFolder, batName)
  pitPATH       <- paste0(outputFolder, pitName)
  
  # Write out tables
  write.table(BatSub, batPATH, sep = ",", col.names = TRUE, row.names = FALSE)
  write.table(PitSub, pitPATH, sep = ",", col.names = TRUE, row.names = FALSE)
  
}

