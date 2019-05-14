########################################
# Program name: createYahooToken.R
# Author:       Philip Camp
# Date started: 24 Aug 2018
# Description:  This program authorizes 
#               a Yahoo token to obtain
#               league-specific data of
#               Yahoo fantasy teams.
# 
# Date updated: 11 Sept 2018
########################################

# Clear environment
rm(list = ls())

# Library packages
library(httr)
library(httpuv)
library(XML)
library(lubridate)

# Set the token location 
tokenLoc  <-  "../nonCommittedItems/yahoo_token.Rdata"

# Source in yahoo helper functions
source("yahooFantasyHelperFunctions.R")

# Read table into R
inputArgs <- "C:/Users/phili/Documents/Repos/nonCommittedItems/YahooKey.txt"



# Set input parameters
# Specify the text separater
SEP <- " "
CredKey     <- as.character(read.table(inputArgs, header = FALSE, sep = SEP)[1,1])
CredSecret  <- as.character(read.table(inputArgs, header = FALSE, sep = SEP)[1,2])

b_url <- "https://fantasysports.yahooapis.com" #base url

#Create Endpoint
yahoo <- httr::oauth_endpoint(authorize = "https://api.login.yahoo.com/oauth2/request_auth"
                              , access = "https://api.login.yahoo.com/oauth2/get_token"
                              , base_url = b_url)
#Create App
myapp <- httr::oauth_app("yahoo", key=CredKey, secret = CredSecret,redirect_uri = "oob")

#Open Browser to Authorization Code
httr::BROWSE(httr::oauth2.0_authorize_url(yahoo, myapp, scope="fspt-r"
                                          , redirect_uri = myapp$redirect_uri))

#Create Token
yahoo_token <- httr::oauth2.0_access_token(yahoo,myapp,code="fp3egzf")
save(yahoo_token,file="../nonCommittedItems/yahoo_token.Rdata")

load(tokenLoc)

# Set parameters 
league_sport  <- "mlb"
league_year   <- 2019
league_ID     <- 53679


leagueKey <- paste0(league_sport,'.l.',league_ID)

# baseURL     <- "https://fantasysports.yahooapis.com/fantasy/v2/league/"
# subResource <- ";status=T"
# playersURL <- paste0(baseURL, leagueKey, "/players", subResource)
# players_page <- GET(playersURL,
#                       add_headers(Authorization=paste0("Bearer ", yahoo_token$access_token)))
# 
# 
# out  <- content(players_page, as="text", encoding="utf-8")
# outXml<-xmlTreeParse(out,useInternal=TRUE)
# # outXml<-xmlParse(out)
# outNode <- xmlRoot(outXml)
# 
# test <- xmlToList(outNode[["league"]][["players"]])
# # x <- test[[1]]
# # test <- xmlToDataFrame(outNode[["league"]][["players"]])
# if(length(test) == 26) test <- test[-26]
# # testdf <- data.frame(sapply(test, function(x) x[c("name", "full")][[1]][[1]]))
# # testdf <- sapply(test, function(x) data.frame(x))
# testdf <- data.frame(Keeper = t(sapply(test, function(x) c(x[c("name", "full")][[1]][[1]], 
#                                                            Player_ID = x["player_id"][[1]]))))

yahooFantasy_get_allRelievers <- function(leagueKey,yahoo_token){
  # Ask yahoo for the list of all relief pitchers in your baseball lauge.
  
  i <- 0;
  tempDF <- data.frame(0);
  # while (nrow(tempDF)!=0 | i > 400){
  while (i < 500){
    # thisUrl <- paste0("https://fantasysports.yahooapis.com/fantasy/v2/league/",leagueKey,'/players?&position=RP&start=',i);
    thisUrl <- paste0("https://fantasysports.yahooapis.com/fantasy/v2/league/",leagueKey,'/players?status=T&start=',i);
    thisXml <- yahooFantasy_query(thisUrl,yahoo_token);
    # tempTbl <- xmlToDataFrame(thisXml[["league"]][["players"]]);
    tempList <- xmlToList(thisXml[["league"]][["players"]])
    # tempTbl <- tempTbl[,!names(tempTbl)=='has_recent_player_notes'];
    if(length(tempList) == 26) tempList <- tempList[-26]
    # tempDF <- data.frame(sapply(tempList, function(x) x[c("name", "full")][[1]][[1]]))
    tempDF <- data.frame(Keeper = t(sapply(tempList, function(x) c(x[c("name", "full")][[1]][[1]], 
                                                               Player_ID = x["player_id"][[1]]))))
    if (i==0) {
      playerTbl <- tempDF;
    } else {
      playerTbl <- rbind(playerTbl,tempDF)
    }
    i <- i+25;
    cat(paste0('count=',i));
  }
  playerTbl
}
test <- yahooFantasy_get_allRelievers(leagueKey = leagueKey, yahoo_token = yahoo_token)
test<- test[-which(is.na(test[,1])),]

colnames(test) <- c("Keeper", "Player_ID")

# Remove accents, tildes etc
test$Keeper <- iconv(test[, "Keeper"],from="UTF-8",to="ASCII//TRANSLIT")

test$Keeper <- gsub(" \\(Batter\\)| \\(Pitcher\\)", "", test[,"Keeper"])

# Get a timestamp
today <- format(Sys.time(), "%Y%m%d")

outputFolder <- "C:\\Users\\phili\\Documents\\Repos\\data\\"

write.csv(test, file = paste0(outputFolder, paste0("totalKeeperList_", today, ".csv")),
          row.names = FALSE)
