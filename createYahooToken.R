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

# Set in debug mode or not
debugMode <- FALSE

# Set an expired logical
expired       <- FALSE
doesNotExist  <- FALSE


# First, check to see if a Yahoo token exists.
# If it doesn't exist, create a token. If it does exist,
# check to see if it's expired. If it's expired create a token.

print("Looking for ../nonCommittedItems/yahoo_token.Rdata")
if(file.exists("../nonCommittedItems/yahoo_token.Rdata")){
  
  print("Found Yahoo Token...")
  print("Checking if it's expired...")
  print("...")
  print("...")
  print("...")
  load("../nonCommittedItems/yahoo_token.Rdata")
  
  # Check if yahoo_token was actually loaded and if it's a token class
  if(exists("yahoo_token") & length(grep("Token", class(yahoo_token))) > 0){
    
    # Store the time the yahoo token will expire (in seconds)
    tokenExpires  <- as.numeric(yahoo_token$credentials$oauth_expires_in)
    
    # Store now
    timeNow       <-  now()
    creationTime  <- file.info("../nonCommittedItems/yahoo_token.Rdata")$ctime
    
    if(as.numeric(difftime(timeNow, creationTime, units = "secs")) > tokenExpires){
      
      print("Yahoo Token expired")
      print("Creating Yahoo Token through oauth authentication")
      print("...")
      print("...")
      print("...")
      expired <- TRUE
      
    } else {
      print("Yahoo Token is current")
      print("Use token")
      load("../nonCommittedItems/yahoo_token.Rdata")
      
    }
  }
  

} else {
  
  print("Cannot find Yahoo Token...")
  print("Creating Yahoo Token through oauth authentication")
  print("...")
  print("...")
  print("...")
  doesNotExist <- TRUE
} 

# CREATE A YAHOO TOKEN THROUGH OAUTH AUTHENTICATION
if(doesNotExist | expired){
  
  # Read security credentials from an input text file (a credential key and secret provided 
  # from https://developer.yahoo.com/apps/create)
  
  
  if(debugMode == TRUE){
    inputArgs <- "C:/Users/phili/Documents/Repos/nonCommittedItems/YahooKey3.txt"
    
  } else {
    
    # Prompt user to enter security file path 
    cat("Enter the security file path as copied from Windows Explorer\n")
    inputArgs <- readLines(file("stdin"), n = 1L)
    inputArgs <- gsub("\\\\", "/", inputArgs)
    print("...")
    print("...")
    print("...")
    
    # echo results to console
    cat(paste("You entered", inputArgs, "\n"))
    
  }
  
  # If file does not exist, echo a warning and stop the program
  if(!file.exists(inputArgs)){
    
    # Print warning
    print("WARNING: Cannot find file")
    break
    
  }
  
  # Read table into R
  
  # Set input parameters
  # Specify the text separater
  SEP <- " "
  CredKey     <- as.character(read.table(inputArgs, header = FALSE, sep = SEP)[1,1])
  CredSecret  <- as.character(read.table(inputArgs, header = FALSE, sep = SEP)[1,2])
  
  # Create a folder to store yahoo token
  if(!dir.exists("../nonCommittedItems/")){
    
    dir.create("../nonCommittedItems/")
  }
  
  # Authorize with Yahoo API and create a token
    
  # Set the token url:
  # token.url <- "https://api.login.yahoo.com/oauth2"
  
  yahoo <- oauth_endpoints("yahoo")
  
  personalApp <- oauth_app("yahoo", key=CredKey, secret=CredSecret, redirect_uri = "oob")
  yahoo_token<- oauth1.0_token(yahoo, personalApp, cache = TRUE)
  
  
  save(yahoo_token,file="../nonCommittedItems/yahoo_token.Rdata") 
  print("YAHOO TOKEN SUCCESSFULLY CREATED")
  
  
} else {
    
    load("../nonCommittedItems/yahoo_token.Rdata")
    print("YAHOO TOKEN ALREADY CREATED")
    
  
}
