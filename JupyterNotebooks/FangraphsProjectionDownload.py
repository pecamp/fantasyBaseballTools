#!/usr/bin/env python
# coding: utf-8

# # Download Fangraphs Projection data
# 
# The purpose of this script is to download [Fangraphs](https://www.fangraphs.com/) collection of rest-of-season (ROS) projections, specifically focusing on ZIPs and Steamer projections. The intented purpose is the pair the data with the Yahoo! Fantasy API to analyze future prospects. 
# 
# The `input` is a link to a website to download baseball projection data. The `output` is a csv of said baseball projection data stored in the folder of interest.

# **Note:** The current script runs in "headless" mode where a browser does not visibly open. There were some problems downloading while in headless and thus I used a solution outlined [here.](https://stackoverflow.com/questions/57599776/download-file-through-google-chrome-in-headless-mode)

# ## Set-up script

# #### Import modules

# In[6]:


# Import modules
import os
import shutil
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


# #### Set URL and file paths

# In[7]:


# Set driver and url paths
chromeDriverPATH = r'C:\Users\phili\chromedriver_win32\chromedriver'

# Set base URL path to build off of
baseURL = r"https://www.fangraphs.com/projections.aspx?pos=all&stats={0}&type={1}&team=0&lg=all&players=0"

# Create a projection system 'type' dictionary
# This is used to build url paths programmatically off of baseURL to fill the 'type=' argument in the url path
typeDict = {'ZIPs':'rzips',
           'Steamer':'steamerr',
           'DepthC':'rfangraphsdc',
           'TheBat':'rthebat'}

# Players are broken up by pit and bat, representing pitchers and batters
typePlayers = ['bat', 'pit']

# The ID of the csv on Fangraphs (found via right-click > Inspect)
IDElement = r'ProjectionBoard1_cmdCSV'

# Set output paths
outputFolder = r'C:\Users\phili\OneDrive\Documents\DataProjects\data'

# Set addtional parameters

# Time delay to wait before closing driver
delay = 10

# Create a timestamp
today = time.strftime('%Y%m%d')


# #### Set webdriver options

# In[8]:


# Options for selenium webdriver (chrome)
chrome_options = Options()  
chrome_options.add_argument("--headless")
chrome_options.add_argument('window-size=1600,1100')
chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
chrome_options.add_experimental_option('useAutomationExtension', False)

# # Change the download directory
# prefs = {"download.default_directory" : outputFolder}
# chrome_options.add_experimental_option("prefs",prefs)


# ## Download data

# #### Set script parameters

# In[9]:


# Set projections to download (must match name in typeDict)
prjsToDownload = ['ZIPs', 'Steamer']


# #### Open webdriver and download data

# In[10]:


# Determine number of output files
numFiles = len(prjsToDownload * len(typePlayers))
print(str(numFiles) + ' files expected')

# Create tracking variables
totalFilesComp = 0
progress = 0

# Download...

for prj in prjsToDownload:
    
    for plyrType in typePlayers:
        
        # Track progress
        progress += 1
        print('Attempting ' + str(progress) + ' out of ' + str(numFiles) + ' files')
        
        ##### DOWNLOAD CSV #####
        # Construct a type-specific URL from the baseURL
        prjURL = baseURL.format(plyrType, typeDict[prj])
        
        # Connect to driver
        driver = webdriver.Chrome(chromeDriverPATH, options=chrome_options)
        
        # Set settings for downloading under headless
        params = {'behavior': 'allow', 'downloadPath': outputFolder}
        driver.execute_cdp_cmd('Page.setDownloadBehavior', params)
        
        # Create a webdriver wait to download the data
        wait = WebDriverWait(driver, delay)       
                
        # Get PATH
        driver.get(prjURL)
        
        # Execute script for headless downloading
        driver.execute_script("scroll(0, 250)"); 
        
        # Wait, find the element, "click" it, and then close the driver
        wait.until(EC.presence_of_element_located((By.ID, IDElement)))    
        button = driver.find_element_by_id(IDElement)
        button.click()
        time.sleep(5)
        driver.close()
        
        ##### RENAME CSV #####
        
        # Find the most recently downloaded file and change the name to our desired structure
        filename = max([outputFolder + "\\" + f for f in os.listdir(outputFolder)],key=os.path.getctime)
        
        if(os.path.splitext(filename)[1] != r'.csv'):
            print('WARNING: Not a CSV. Probably did not download')
            print(os.path.splitext(filename))
            
        else:
            # Track number of files completed
            totalFilesComp += 1
            
            # Echo progress
            print(str(totalFilesComp) + ' file completed out of ' + str(progress) + ' files attempted')
            
            # Construct file name
            prjFilename = prj + plyrType.capitalize() + '_' + today + '.csv'
            shutil.move(filename,os.path.join(outputFolder, prjFilename))
        
        

