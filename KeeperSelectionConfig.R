# KeeperSelectionConfig.R
# Configuration file for KeeperSelection.R

#############################################
# Library packages
packagesToUse <- c("tidyverse","magrittr", "xlsx", "stringi")
#############################################

#############################################
# Keeper data location
dataFolder    <- "../data/"
dataFile      <- "PotentialKeepers2.xlsx"
#############################################

#############################################
# Number of sheets in xlsx
numSheets     <- 2

# Sheet names
sheetNames    <- c("Batters", "Pitchers")
#############################################

#############################################
# Number of keepers
numKeepers    <- 5

# Max number of either batter or pitching category
maxCat        <- 3

# Tier 1
tier1         <- 1:3

# Tier 2
tier2         <- 4:8

# Low round limit
lowRoundLimit <- 14
#############################################

#############################################
finalKeeperCol <- c("Name",
                    "Draft",
                    "ADP",
                    "SUM",
                    "espn_pos",
                    "Position",
                    "SUMAboveMed",
                    "Round",
                    "RoundDP")
#############################################


