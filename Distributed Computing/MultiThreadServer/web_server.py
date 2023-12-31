#--------------------------------
# this is the webserver that allows
# connections hand handles requests
#--------------------------------
import socket
import sys
import threading
import json
#---------------------------------------------
#  Threads/Request Handling
#---------------------------------------------
# in this method it is deciphered if this is
# a get, post or delete request- or if it isn't
# an implemented request type
def threadActivity(conn,req,):
    #parse request
    headers = req.split('\n')
    words = headers[0].split()
    print(words)

    if(len(words)>0 and words[0]=="GET"):
    	handleGet(conn,req,words)
    elif(len(words)>0 and words[0]=="POST"):
      handlePost(conn,req,words)
    elif(len(words)>0 and words[0]=="DELETE"):
      handleDelete(conn,req,words)
    else:
      response = "HTTP/1.1 400 NOT FOUND\n\nBad Request - 400"
      conn.sendall(response.encode())
      conn.close()
#------------------------------
# handles calls for GET
# GET tweets returns the tweetList,
# otherwise the file is looked for
# and returned if it exists
def handleGet(conn,req,words):
    response = "HTTP/1.1 400 NOT FOUND\n\nBad Request - 400"
    filename = "/"

    if(len(words)>1 and "/api/tweet" == words[1]):
        #get the tweet list
        filename = "/data/tweetSave.json"
    elif(len(words)>1):
        #get the file asked for
        filename = words[1]

    if filename == "/":
         filename="./index.html"
    else:
         filename="."+filename

    try:
        f = open(filename)
        content = f.read()
        f.close()
        response = ReplyStart200 + content

    except FileNotFoundError:
        response = "HTTP/1.1 404 NOT FOUND\n\nFile not found - 404"

    conn.sendall(response.encode())
    conn.close()
#------------------------------
# handles a POST request
# for tweet, adds the tweet to
# the persistant list of tweets
# for login, checks if credentials
# are valid
def handlePost(conn,req,words):

    response = "HTTP/1.1 400 NOT FOUND\n\nBad Request - 400"
    filename = ""

    if(len(words)>1 and "/api/tweet" == words[1]):
        #we wanna update the tweet list
        filename = "./data/tweetSave.json"
        #get the body from the request
        body = req.split("\n")
        body = body[len(body)-1]
        bodyObj = json.loads(body)
        bodyObj["id"]=getID()

        if(bodyObj["id"]=="BAD_ID"): #unable to generate id- the id file was probably modified
            response = "HTTP/1.1 502 BAD GATEWAY\n\nFailed to generate tweet ID - 501"
        else:
            dictTweet = []

            try:
                #get list of tweets as dictionary to add to
                with open(filename) as f:
                    dictTweet = json.load(f)
                dictTweet.append(bodyObj)

                with open(filename,"w") as tweetJson:
                    json.dump(dictTweet,tweetJson,indent=4,separators=(',',': '))

                response = ReplyStart200+"Posted Tweet with id:\n"+bodyObj["id"]
        
            except FileNotFoundError:
               response = "HTTP/1.1 404 NOT FOUND\n\nFile not found - 404"
        
    elif(len(words)>1 and "/api/login"==words[1]):
        #we wanna login
        filename = "./data/accounts.json"
        #get the body from the request
        body = req.split("\n")
        body = body[len(body)-1]

        try:
            f = open(filename,"r")
            accounts = json.load(f)
            f.close()
            bodyObj = json.loads(body)
            
            #see if the given login is valid
            valid = False
            for a in accounts:
                if bodyObj["username"]==a["username"] and bodyObj["password"]==a["password"]:
                   print(a["username"]+" logged in")
                   valid = True
                   response = ReplyStart200+"Login Accepted"
                   break
            if valid == False:
                print("Bad Login")
                response = "HTTP/1.1 401 UNAUTHORIZED\n\nLogin Denied"

        except FileNotFoundError:
             response = "HTTP/1.1 404 NOT FOUND\n\nFile not found - 404"
    elif(len(words)>1):
        #get the file asked for
        filename = "."+words[1]

    conn.sendall(response.encode())
    conn.close()

#------------------------------
# handles a DELETE request
# for tweet, deletes a tweet with
# given id if it exists and if the
# cookie matches the tweet's author
def handleDelete(conn,req,words):
    response = "HTTP/1.1 400 NOT FOUND\n\nBad Request - 400"

    loggedIn = True
    #get who is trying to delete
    cookie = req.split("Cookie: userLogin=")
    if(len(cookie)>1):
       cookie=cookie[1].split("\r")
    else:
       loggedIn = False

    if(loggedIn == True and len(words)>1 and words[1].startswith("/api/tweet/")):
        #we wanna delete from tweetlist

        filename = "./data/tweetSave.json"
        #get the body from the request
        path = words[1].split("/")
        deleteID = path[3]
        response = ReplyStart200

        try:
            # get the tweets
            f = open(filename,"r")
            tweets = json.load(f)
            f.close()

            found = False
            # loop through, delete when we find the tweet
            for idx, obj in enumerate(tweets):
                if(obj["id"]==deleteID and obj["author"]==cookie[0]):
                   print("Removing Tweet ID "+deleteID)
                   tweets.pop(idx)

                   with open(filename,"w") as tweetJson:
                       json.dump(tweets,tweetJson,indent=4,separators=(',',': '))

                   found = True
                   response = ReplyStart200+"Deleted tweet "+deleteID+" successfully"
                   break
            if found == False:
               response = "HTTP/1.1 404 NOT FOUND\n\nTweet not found - 404"

        except FileNotFoundError:
           response = "HTTP/1.1 404 NOT FOUND\n\nFile not found - 404"
        
    elif(len(words)>1 and "/api/login"==words[1]):
        #user told us they wanna logout, suprised that doesn't violate twitter's rules
        response = ReplyStart200

    conn.sendall(response.encode())
    conn.close()

#---------------------------------------------
# generates an id for a tweet we are posting
def getID():
    id = "BAD_ID"
    with open("./data/nextID.txt","r+") as f:
        id = f.read()
        f.seek(0)
        output = str(int(id)+1)
        f.write(output)
    return str(id)

#---------------------------------------------
#   Main
#---------------------------------------------
HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 6889               # Arbitrary non-privileged port

# read in if they gave a new port
if(len(sys.argv)>1 and sys.argv[1].isnumeric()):
     if(int(sys.argv[1])>1024):
        PORT = int(sys.argv[1])
     else:
        print("Provided port should be over 1024 - using default port.")

ReplyStart200 = "HTTP/1.1 200 OK\n\n"
# create socket
serverSock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
serverSock.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
serverSock.bind((HOST,PORT))
serverSock.listen(1)

threads = []

print("Server hosted on port "+str(PORT))
while True:
        try:
            #connect with client
            conn,addr = serverSock.accept()
            #get request
            req = conn.recv(1024).decode()
            print("Connected by ",addr)

            #get contents
            t = threading.Thread(target=threadActivity,args=(conn,req,))
            t.start()
            threads.append(t)

        except KeyboardInterrupt as e:
            print("\nClosing Server.")
            sys.exit(0)

serverSock.close()
