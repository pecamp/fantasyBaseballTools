##############################################
# Program name: yahooFantasyHelperFunctions.R
# Author:       Philip Camp
# Date started: 12 Sept 2018
# Description:  This program is meant to
#               to be loaded in and provide
#               useful functions 
# 
# Date updated: 11 Sept 2018
##############################################

yahooFantasy_query <- function(inputUrl,yahoo_token){
  # This function will query the xml yahoo fantasy API
  #
  # See the Yahoo Fantasy API documentation here:
  # https://developer.yahoo.com/fantasysports/guide/
  # 
  # The building blocks of the Yahoo Fantasy API are
  # (1) Resources and (2) Collections. Collections are 
  # simply wrappers of similar Resources. 
  #
  # The format for requesting a Resource will typically look like:
  #   
  #   https://fantasysports.yahooapis.com/fantasy/v2/{resource}/{resource_key}
  # 
  #   List of resources: Game, League, Team, Roster, Player , Transaction, User
  #
  # Inputs:
  #   inputUrl      Desired URL
  #
  #       *There are 6 URLs in the Yahoo Fantasy Sports API, listed below:
  #       *Resources: Game, League, Team, Roster, Player , Transaction, User
  #
  #   yahoo_token   yahoo_token produced by yahooFantasy_get_oauth_token
  #
  # Outputs: 
  #   outNode       xml node object which contains query results
  
  page <-GET(inputUrl,config(token=yahoo_token));
  out <- content(page, as="text", encoding="utf-8");
  
  outXml<-xmlTreeParse(out,useInternal=TRUE);
  outNode <- xmlRoot(outXml);
  
  return(outNode)
}

yahooFantasy_get_gameID <- function(sport,year,yahoo_token){
  # Ask Yahoo for the 3-digit game_ID based on the sport and season.
  #
  # Inputs:
  #   sport: For example, 'mlb' or 'nfl'
  #   year:  For example, 2017
  #   yahoo_token:  yahoo token obtained from yahooFantasy_get_oauth_token
  #
  # Outputs:
  #   game_ID: A string with a 3 digit number
  
  thisUrl <- paste0("http://fantasysports.yahooapis.com/fantasy/v2/game/",sport,'?season=',year);
  thisXml <- yahooFantasy_query(thisUrl,yahoo_token);
  game_ID <- xmlValue(thisXml[["game"]][["game_key"]]);
  return(game_ID)
}



testAPIConnect <- function(command, tokenLocation, queryURL){
  
  # testAPIConnect is a helper function to test if the Yahoo API connection works.
  # It is primarily to be used in accessYahooAPI.R where it calls createYahooToken.R
  # in different situations
  
  # Inputs:
  # command is a string listing the system command to be run
  # queryURL is the test URL to see if the connection with the Yahoo API works
  
  # systemCommand <- paste("cmd /k", "Rscript", paste(tokenProgramLoc,
  #                                                   "createYahooToken.R", sep = ""))

  shell(systemCommand, 
        wait = FALSE, 
        invisible = FALSE)
  
  #Load token
  load(tokenLocation)
  
  # Test if Yahoo Token works with a GET request
  page <-GET(queryURL,config(token=yahoo_token))
  out <- content(page, as="text", encoding="utf-8")
  
  # Determine if token expired
  lengthOfExpired <- grep("token_expired", out)
  
  if(!length(lengthOfExpired) == 0){
    
    print("Yahoo token is still expired")
  } else {
    
    print("Yahoo token is functional")
  }
  
  
}
