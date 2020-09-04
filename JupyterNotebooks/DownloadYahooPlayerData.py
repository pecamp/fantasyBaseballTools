#!/usr/bin/env python
# coding: utf-8

# #### Import Modules

# In[27]:


import os
import time
import pandas as pd
import numpy as np
from yahoo_oauth import OAuth2
import yahoo_fantasy_api as yfa


# #### Authorize via Oauth2

# In[28]:


sc = OAuth2(None, None, from_file='oauth2.json')


# #### Set parameters

# In[29]:


# Set the game (e.g. mlb, nba, etc)
gameToUse = 'mlb'

# Set the league ID
leagueToUse = '136325'

# Final columns in the player tables
columnsToUse = ['player_id', 'name', 'eligible_positions']

# Output Folder PATH
outputFolder = r'C:\Users\phili\OneDrive\Documents\DataProjects\data'

# Create a timestamp
today = time.strftime('%Y%m%d')


# #### Read-in Game and League settings for the Yahoo! Fantasy API

# In[30]:


# Construct league code
leagueCode = gameToUse + '.l.' + leagueToUse

# Set-up game collection
gm = yfa.Game(sc, 'mlb')

# Set-up league...
lg = gm.to_league(leagueCode)


# #### Read-in free agent, taken, and waivered players

# In[31]:


##### Free Agents #####

# Batting
battingFAs = lg.free_agents('B')
battingFAs = pd.DataFrame(battingFAs)[columnsToUse]

# Pitching
pitchingFAs = lg.free_agents('P')
pitchingFAs = pd.DataFrame(pitchingFAs)[columnsToUse]

##### Taken #####
takenPlyrs = pd.DataFrame(lg.taken_players())[columnsToUse]

##### Waivered #####
waiverPlyrs = pd.DataFrame(lg.waivers())[columnsToUse]


# #### Combine all the dataframes

# In[32]:


# Combine all dataframes
listOfAvail = [battingFAs, pitchingFAs, waiverPlyrs]
availablePlayers = pd.concat(listOfAvail)

# Rename columns
availablePlayers.rename(columns = {'player_id':'Player_ID','name':'Keeper', 'eligible_positions': 'Eligible_Positions'},
                        inplace = True)

takenPlyrs.rename(columns = {'player_id':'Player_ID','name':'Keeper', 'eligible_positions': 'Eligible_Positions'},
                        inplace = True)

# Reorder columns
availablePlayers = availablePlayers[['Keeper', 'Player_ID', 'Eligible_Positions']]
takenPlyrs = takenPlyrs[['Keeper', 'Player_ID', 'Eligible_Positions']]

# Assure Player_ID is a string
availablePlayers['Player_ID'] = availablePlayers['Player_ID'].astype('str')
takenPlyrs['Player_ID'] = takenPlyrs['Player_ID'].astype('str')

# Construct file paths
availableFilename = 'totalAvailableList_' + today + '.csv'
takenFilename = 'totalKeeperList_' + today + '.csv'

# Write to csv
availablePlayers.to_csv(os.path.join(outputFolder, availableFilename), encoding='utf-8-sig', index = False)
takenPlyrs.to_csv(os.path.join(outputFolder, takenFilename), encoding='utf-8-sig', index = False)

