# %%
from docopt import docopt
from yahoo_oauth import OAuth2
import os
import json

if __name__ == '__main__':
    args = {'--key':'dj0yJmk9U0JlNGJrc0JiR243JmQ9WVdrOVpVMDViMVp0TlRBbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iNQ--',
            '--secret':'8d8aa0e365b81ae8f2b4f41d07c5dd46c26f5c38',
           '<json>':'oauth2.json'}
    
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