#!/usr/bin/env python
# coding: utf-8

# In[1]:


#!/usr/bin/env python

"""Initialize OAuth environment for Yahoo! API access.
Sets up your environment with permissions to allow access to the Yahoo! APIs.
It does this by creating a JSON file that can be used for future API requests.
The consumer key/id can be omitted if the JSON file already exists.  In that
mode, this program will verify access with the JSON credentials.
Usage:
  yfa_init_oauth_env [-k <consumer_key>] [-s <consumer_secret>] <json>
  <json>  File to read/write the bearer token
Options:
  -h --help        Show this screen.
  -k, --key=id     The consumer key to use
  -s, --secret=id  The consumer secret to use
"""
from docopt import docopt
from yahoo_oauth import OAuth2
import os
import json

if __name__ == '__main__':
    args = docopt(__doc__, version='1.0')
    
    if args == locals():
        print('Args Exist')
    else:
        print('Args Does not Exist')

    # If the JSON file does not exist, when we init it will redirect to a
    # web-page where you are asked to permit Fantasy Sports read access to this
    # application.  To prevent this from happening each time, we save off extra
    # state in a .json file.  This file is only written if using the
    # `from_file` option to OAuth2.  Setup this file with the minimal info
    # to allow this extra state to be saved.
    if not os.path.exists(args['<json>']):
        if args['--key'] is None:
            raise RuntimeError("Consumer key cannot be read from JSON file."
                               "It must be specified on the command line.")
        if args['--secret'] is None:
            raise RuntimeError("Consumer secret cannot be read from JSON file."
                               "It must be specified on the command line.")
        creds = {}
        creds['consumer_key'] = args['--key']
        creds['consumer_secret'] = args['--secret']
        with open(args['<json>'], "w") as f:
            f.write(json.dumps(creds))
        print("Initialized {}".format(args['<json>']))

    oauth = OAuth2(None, None, from_file=args['<json>'])
    if not oauth.token_is_valid():
        oauth.refresh_access_token()

