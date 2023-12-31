#--------------------------------
# this program acts as a node in
# the peer-to-peer network.
# it participates in Consenseses,
# gossips, and accepts other commands
# to deal with its 5 word database.
#-------------------------------

import sys
import select
import json
import socket
import time
import random
import uuid

from peerObj import KnownPeer
from consensusObj import ActiveConsensus

#---------------------------------------------------------
HOST = ''
PORT = random.randint(8115, 8119) # random selection from my ports in the port listings

if(len(sys.argv)>1 and sys.argv[1].isnumeric()): # set port if specified
    PORT = int(sys.argv[1])

NODE_NAME = "Not Violently Unfinished"
MY_IP = socket.gethostbyname(socket.gethostname())
HEARTBEAT_TIME = 60

# will try to gossip to all of these on start up,
# uncomment to ask all instead of just the 2
WELL_KNOWN = [
#{"ip":"eagle.cs.umanitoba.ca","port":16000},
#{"ip":"hawk.cs.umanitoba.ca","port":16000},
{"ip":"silicon.cs.umanitoba.ca","port":16000},
{"ip":"osprey.cs.umanitoba.ca","port":16000}
]

lieWord = "pancakes"
lying = False

WORDS = [
"unfortunate","misery","clueless","pain","university"
]

peerArray = []		# array of known active peers
activeConsenses = []	# array of running consensuses
recentUUIDs = []	# remember the last few UUIDs, to ignore double-sending gossips
MAX_STORE_UUID = 25	# how many UUIDs back we remember
MAX_GOSSIP_TO = 3	# how many peers to try spread gossip to

#---------------------------------------------------------
# message templates
# these get modified before sending a message
#---------------------------------------------------------

GOSSIP ={
  "command": "GOSSIP",
  "host": MY_IP,
  "port": PORT,
  "name": NODE_NAME,
  "messageID": "uuid go here"
}

GOSSIP_REPLY = {
  "command": "GOSSIP_REPLY",
  "host": MY_IP,
  "port": PORT,
  "name": NODE_NAME
}

QUERY ={
"command":"QUERY"
}

QUERY_REPLY={
"command":"QUERY-REPLY",
"database":WORDS
}

CONSENSUS = {
"command":"CONSENSUS",
"OM":0,
"index":1,
"value":"word",
"peers":[],
"messageID":"uuid goes here",
"due":0
}

CONSENSUS_REPLY ={
"command":"CONSENSUS-REPLY",
"value":"word",
"reply-to":"uuid goes here"
}
#--------------------------------------------------------
# handling a command to the UDP socket (from a peer)
# deciphers data and hands it off to be handled
def readUDP(sock):
      
      data, addr = sock.recvfrom(1024)
      
      try:
        jsonData = json.loads(data.decode('utf-8'))

        if(jsonData["command"]=="GOSSIP_REPLY"):
            handleGossipReply(jsonData,sock)
        elif (jsonData["command"]=="GOSSIP"):
            handleGossip(jsonData,sock)
        elif (jsonData["command"]=="QUERY"):
            handleQuery(sock,addr)
        elif (jsonData["command"]=="QUERY-REPLY"):
            handleQueryReply(jsonData,sock,addr)
        elif (jsonData["command"]=="SET"):
            handleSet(jsonData)
        elif(jsonData["command"]=="CONSENSUS"):
            handleConsensus(sock,addr,jsonData)
        elif(jsonData["command"]=="CONSENSUS-REPLY"):
            handleConsensusReply(jsonData,addr)
        else:
            print("Unknown command: "+jsonData["command"])

      except Exception as e:
        print("Exception in readUDP")
        print(e)
        print("\ndata:")
        print(data.decode('utf-8'))
        pass

#--------------------------------------------------------
# handles a consensus command by replying or creating a sub-concensus
def handleConsensus(sock,addr,data):
   global lying
   try:
      if(lying==False):
         if(data["OM"]==0):
            #just use and reply with the general
            CONSENSUS_REPLY["value"]=data["value"]
            WORDS[data["index"]]=data["value"]
            CONSENSUS_REPLY["reply-to"]=data["messageID"]
            send = json.dumps(CONSENSUS_REPLY).encode("utf-8")
            try:
               sock.sendto(send,addr)
            except Exception as e:
               pass

         elif(data["OM"]>0):
            #we gotta do a subconsensus
            CONSENSUS["OM"] = data["OM"]-1
            CONSENSUS["index"]=data["index"]
            CONSENSUS["value"]=data["value"]
            CONSENSUS["messageID"]=str(uuid.uuid4())
            CONSENSUS["due"]=(data["due"]-2)
            CONSENSUS["peers"].clear()

            # peers minus self and sender
            for peer in data["peers"]:
               combo = peer.split(":")
               if(combo[0]==MY_IP and int(combo[1])==PORT) or (combo[0]==addr[0] and int(combo[1])==addr[1]):
                  pass
               else:
                  CONSENSUS["peers"].append(peer)

            newConsensus = ActiveConsensus(CONSENSUS["messageID"],CONSENSUS["due"],CONSENSUS["index"],addr,data["messageID"])
            activeConsenses.append(newConsensus)
            send = json.dumps(CONSENSUS).encode("utf-8")
            #send to all the people
            for peer in CONSENSUS["peers"]:
               try:
                  parts = peer.split(":")
                  sock.sendto(send,(parts[0],int(parts[1])))
               except Exception as e:
                  pass
            
      else:
         # we are lying, just send back the lie
         CONSENSUS_REPLY["value"]=lieWord;
         CONSENSUS_REPLY["reply-to"]=data["messageID"]
         send = json.dumps(CONSENSUS_REPLY).encode("utf-8")
         try:
             sock.sendto(send,addr)
         except Exception as e:
             pass
   except Exception as e:
         print("Exception in consensus for OM "+str(data["OM"]))
         print(e)
         pass

# adds the value of the reply to the tally of answers for
# the concensus
def handleConsensusReply(data,addr):
   #check if this reply is part of an active consensus and add it
   
   for con in activeConsenses:
     if(data["reply-to"]==con.UUID and con.expires>=time.time()):
       # add this reply to con
       con.replies[data["value"]] = con.replies.get(data["value"],0)+1
       # update the word in the peer
       for peer in peerArray:
          if(peer.host==addr[0] and peer.port==int(addr[1])):
             if not (peer.database[int(con.index)]==data["value"]):
                peer.database[int(con.index)]=data["value"]
                print("updated one of "+peer.name+"'s words to "+data["value"])
                break
       break

# checks all active consenses to see if they have ended
# and sends reply back to the original consensus if so
def checkConsensus(sock):
  for con in activeConsenses:
    if(con.expires<time.time()):
       # consensus time is out, get the results
       winner = WORDS[con.index]
       if con.replies:
          winner = max(con.replies)
          WORDS[con.index]=winner #steal for self
       
       # reply to origin if exists
       if (not (con.retAddr == None) and not (con.parent == None) and not (con.retAddr == (MY_IP,PORT))):
          CONSENSUS_REPLY["value"]=winner
          CONSENSUS_REPLY["reply-to"]=con.parent
          try:
             send = json.dumps(CONSENSUS_REPLY).encode("utf-8")
             sock.sendto(send,con.retAddr)

          except Exception as e:
             pass

       activeConsenses.remove(con)
    
# creates a new consensus for a given index
# this returns a message to send to the cleint that requested this
def createConsensus(sock,index):
   msg = "Starting consensus for index " + str(index)
   print(msg)
   try:
            OM = (len(peerArray)/2)
            if(len(peerArray)%2==0):
               OM = OM-1
            CONSENSUS["OM"] = int(OM)

            CONSENSUS["index"] = index
            CONSENSUS["value"] = WORDS[index]
            CONSENSUS["messageID"] = str(uuid.uuid4())
            CONSENSUS["due"] = time.time() + 20
            CONSENSUS["peers"] = []
            for peer in peerArray:
                addPeer = peer.host +":"+ str(peer.port)
                CONSENSUS["peers"].append(addPeer)

            newConsensus = ActiveConsensus(CONSENSUS["messageID"],CONSENSUS["due"],CONSENSUS["index"],None,None)
            
            activeConsenses.append(newConsensus)
            send = json.dumps(CONSENSUS).encode("utf-8")
            
            #send to all the people
            for peer in CONSENSUS["peers"]:
               try:
                  parts = peer.split(":")
                  sock.sendto(send,(parts[0],int(parts[1])))
               except Exception as e:
                  pass
            
   except Exception as e:
      print("exception in createConcensus")
      print(e)
      msg = "Problem creating consensus"

   return msg
#--------------------------------------------------------
# sends the current word list to asker
def handleQuery(sock,addr):
   #asks for all the words of this node - send a query reply to sock
   if(lying==True):
      QUERY_REPLY["database"]=WORDS
   else:
      QUERY_REPLY["database"]=[lieWord,lieWord,lieWord,lieWord,lieWord]
   try:
      send = json.dumps(QUERY_REPLY).encode("utf-8")
      sock.sendto(send,addr)
   except Exception as e:
      pass

#-------------------------------------------------------
# updates word list of replying peer
def handleQueryReply(data,sock,addr):
   #we got reply for our query, add to peer
   try:
     #look for peer to update
     for peer in peerArray:
        if((peer.host,peer.port)==addr):
          print("Query reply from "+peer.name+", updating...")
          peer.database = data["database"] 
          break
      
   except Exception as e:
     pass
#--------------------------------------------------------
# sets the word at index to a new value as specified in data
def handleSet(data):
   try:
     print("Setting my "+str(data["index"])+"th word to "+data["value"])
     WORDS[int(data["index"])]=data["value"]
   except Exception as e:
     print("Exception in handleSet:")
     print(e)
#--------------------------------------------------------
# returns true if the given UUID has been seen recently
# if not, this uuid is marked as seen and this function
# returns false
def rememberUUID(uuid):
    
    if(uuid in recentUUIDs): #we recognize the uuid
       return True
    else: #remember the uuid
       recentUUIDs.append(uuid)
       while(MAX_STORE_UUID<len(recentUUIDs)):
          recentUUIDs.pop(0)
       return False
    
# recieved gossip- adds or updates the peer and
# spreads the gossip
def handleGossip(data,sock):
      
    if(rememberUUID(data["messageID"])==False): #we ignore if we recognize the UUID
      #reply to the GOSSIP 
      try:
        send = json.dumps(GOSSIP_REPLY).encode("utf-8")
        sock.sendto(send,(data["host"],data["port"]))
      except Exception as e:
        pass
      #spread the GOSSIP unless it is this node's
      try:
         if((data["host"] == MY_IP) and (data["port"] == PORT)):
           print("Recieved own GOSSIP, ignoring")
         else:
           updatePeer(data,sock)
           spreadTo = min(len(peerArray),MAX_GOSSIP_TO)
           chosen = []
           for i in range(0,spreadTo):
              try:
                 j = random.randint(0,len(peerArray)-1)
                 while (j in chosen):
                    j =  random.randint(0, len(peerArray)-1)
                 chosen.append(j)              

                 send = json.dumps(data).encode("utf-8")
                 sock.sendto(send,(data["host"],data["port"]))
              
              except Exception as e:
                 pass
           chosen.clear()
      except Exception as e:
         print("exception in gossip:")
         print(e)

# handles a gossip reply
def handleGossipReply(data,sock):
    updatePeer(data,sock)

# updates the list of peers with new info, either adding a new peer
# or updating the lastPing of a known peer
def updatePeer(data,sock):
    #add to peerArray if not already there, or update time
    found = False
    for peer in peerArray:
      if(data["host"]==peer.host and data["port"]==peer.port):
        #known host
        found = True
        peer.lastPing = time.time()
        
    if(found==False):
        #new peer
        if(not (data["host"] == MY_IP) and not (data["port"] == PORT)):
           peer = KnownPeer(data["host"],data["port"],data["name"],time.time())
           peerArray.append(peer)
           try:
              send = json.dumps(QUERY).encode("utf-8")
              sock.sendto(send,(peer.host,peer.port))
              print("Added new peer "+peer.name)
           except Exception as e:
              print("Exception sending to new peer:")
              print(e)
#----------------------------------------------------------
# checks for peers that haven't send a gossip in a while
# and removes the ones that are 'expired'
def checkTimeOuts():
      end = len(peerArray)-1
      for i in range(0,end):
         try:
             if(time.time() - peerArray[i].lastPing >= (HEARTBEAT_TIME*(2))): # heartbeat is 2* here since on the assignment it says
                                                                              # we should ping every minute, but the websites
                 if(i<len(peerArray)-1):                                      # seem to allow 2 minutes before dropping
                   print("Removing expired peer "+peerArray[i].name)
                   peerArray.pop(i)
         except Exception as e:
            pass
         
# sends gossip to stay in the network
def heartBeat(sock):
   try:
      if(len(peerArray)>0):
         GOSSIP["messageID"] = str(uuid.uuid4())
         send = json.dumps(GOSSIP).encode('utf-8')

         for peer in peerArray:
            sock.sendto(send,(peer.host,peer.port))

   except Exception as e:
      print("Exception in HeartBeat")
      print(e)
#--------------------------------------------------------
# parses message from the TCP clients and acts accordingly
def parseClientMsg(sock,data):
   msg = "Invalid Command "+data
   parts = data.split()
   global lying
   
   match parts[0]:
      case "peers":
         msg="Current peer list: \n"
         for peer in peerArray:
            msg+="  "+peer.name+" at "+peer.host+":"+str(peer.port)+" (Last Ping:"+str(peer.lastPing)+")\n"
            msg+="  \tWords: "+str(peer.database)+"\n"
      case "current":
         if(lying==True):
            msg="Current word list (node is lying):\n[\'"+lieWord+"\',"+lieWord+"\',"+lieWord+"\',"+lieWord+"\',"+lieWord+"\']"
         else:
            msg="Current word list:\n"+str(WORDS)
      case "consensus":
         if(len(parts)>=2 and parts[1].isnumeric() and int(parts[1])>=0 and int(parts[1])<=4):
            msg = createConsensus(sock,int(parts[1]))
         else:
            msg = "Consensus command requires an index between one and four, like 'consensus 1'"
      case "lie":
         lying = True
         print("Node is now lying")
         msg="Node is now lying."
      case "truth":
         lying = False
         print("Node is telling the truth")
         msg="Node is now truthful."
      case "set":
         if(len(parts)>=3 and parts[1].isnumeric() and int(parts[1])>=0 and int(parts[1])<=4):
           print("Setting word at "+parts[1]+" to "+parts[2])
           WORDS[int(parts[1])] = parts[2]
           msg="Word is now "+parts[2]
         else:
           msg="set needs augments like 'set x y' where x is an index 0-4 and y is a word"
   return msg
#--------------------------------------------------------
if(__name__=="__main__"):

  # create the sockets
  udpSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  udpSocket.bind((HOST,PORT))

  tcpSocket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
  tcpSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)
  tcpSocket.bind((HOST,PORT))
  tcpSocket.listen()

  # enter the peer network

  GOSSIP["messageID"] = str(uuid.uuid4())
  send = json.dumps(GOSSIP).encode("utf-8")
  for known in WELL_KNOWN:
      udpSocket.sendto(send,(known["ip"],known["port"]))

  print("Starting on "+MY_IP+":"+str(PORT))

  readables = [udpSocket,tcpSocket]
  writeables = []
  clients = []

  lastBeat = time.time()

  # main loop
  while True:
     try:
        # check timeouts
        if(time.time()-lastBeat >= HEARTBEAT_TIME):
           heartBeat(udpSocket)
           lastBeat = time.time()
        checkTimeOuts()
        checkConsensus(udpSocket)

        # read sockets
        readable,writeable,exceptions = select.select(
              readables+clients,writeables,readables,5)
   
        for eachSocket in readable:
           if eachSocket is udpSocket: # peer
               readUDP(eachSocket)
           elif eachSocket is tcpSocket: # new client
                conn, addr = tcpSocket.accept()
                print('Connected by client ', addr)
                clients.append(conn)
           elif eachSocket in clients: # known client
                #read
                data = eachSocket.recv(1024)
                datastr = data.decode('utf-8')

                if data:
                    message = parseClientMsg(udpSocket,datastr.lower())
                    eachSocket.sendall(message.encode('utf-8'))
                    clean = datastr.strip()
                    if clean == '' or clean == 'quit':
                        eachSocket.close()
                        clients.remove(eachSocket)
                else:
                    # client closed, drop them
                    print('Removing client')
                    clients.remove(eachSocket)

     except KeyboardInterrupt as e:
        print("Closing Node.")
        tcpSocket.close()
        udpSocket.close()

        sys.exit(0)
     except Exception as e:
        print("There was an exception.")
        print(e)   
