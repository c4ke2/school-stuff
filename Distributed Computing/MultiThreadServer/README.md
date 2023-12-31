# Not Twitter

This folder contains:
 - the data folder
 - scraper.c
 - makefile (for scraper)
 - index.html
 - web_server.py
 - README.md (this)

The data folder contains:
 - accounts.json, which lists all user accounts
 - tweetSave.json, which lists all tweets in the system
 - nextID.txt, which is the id to be given to the next tweet

## Part 1

Note: default port for everything is 6889, since it was less busy

Run the webserver on port 6889 with:
  python3 web_server.py
or specify a port with, for example:
  python3 web_server.py 8000

  NOTE: scraper uses port 6889 (the parameters in the outline didn't include a port)
        can be changed by changing PORT near the top of the file to whatever number

Once the server is running, open a browser and connect (to either localhost if on remote, address:PORT)
ex. localhost:6889

Server can be stopped with ctrl+c

Use one of these logins to interact with tweets:
### Logins
username: Local_Geologist
password: rocksrock

username: nole
password: alseT

username:coolPerson432
password:test123
 
Logins can also be found within accounts.json

## Parts 2 and 3
Both included in scraper.c

compile with make

run with
./scraper username password here are words to tweet
ex.
./scraper nole alseT here is a test tweet 

NOTE: the webserver must be running or connection will fail (duh, but I forgot a few times...)

NOTE: the scrapper connects to localhost:6889, so ensure the webserver is hosted on the same machine.

It checks that the login provided is valid.  If it is, it posts the tweet
under that account.  It tries to delete the tweet with a different user, which should fail,
and then deletes the tweet with the account that just posted it, which should succeed.
