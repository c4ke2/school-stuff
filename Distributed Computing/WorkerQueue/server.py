#--------------------------------
# this is the server for the job queue
# it takes and handles messages from
# clients and workers to create and
# distribute jobs.
#--------------------------------

import socket
import sys
import select

#--------------------------
# this method parses a message
# recieved from a client, ensuring
# its contents are a valid command
# and handling commands as appropriate
def parse_client_msg(data):
     words = data.split();
     if words[0].lower() == 'job':
          msg = create_job(data.split(' ',1)[1])
          return msg
     elif words[0].lower() == 'status' and len(words)>1 and words[1].isnumeric():
          msg = check_job(int(words[1]))
          return msg
     else:
          return 'Command '+words[0]+' is not valid.'

#--------------------------
# this method parses a message from a worker
# to ensure the request is valid,
# and handling those commands appropriately
# and returning the result
def parse_worker_msg(data):
    global jobList
    words = data.split()
    if(words[0].lower() == 'pull'):
        return pull_job()
    elif(words[0].lower()=='complete' and len(words)>1 and words[1].isnumeric()):
        return complete_job(int(words[1]))
    else:
        return 'invalid'

#-------------------------
# this method creates a new
# job and adds it to the joblist
# and returns a message with the new
# job's id
def create_job(request):
    global NUM_JOBS
    global jobList
    NUM_JOBS =  NUM_JOBS + 1
    jobList[NUM_JOBS] = ["WAITING",request]
    msg = 'Created job '+str(NUM_JOBS)
    print(msg)
    return msg

#--------------------------
# this method checks and returns
# the status of a job by id
def check_job(jobID):
    print('Client requested status of Job '+str(jobID))
    try:
        global jobList
        stat = jobList[jobID]
        return 'Job '+str(jobID)+' has status '+str(jobList[jobID][0])
    except:
        return 'Job '+str(jobID)+' does not exist.'
    
#--------------------------
# this method searches the joblist
# for any unassigned jobs and
# returns the first waiting job.
# jobs are found on a FIFO basis.
def pull_job():
   global jobList
   assigned = False
   count = 1
   message = 'none'
   while assigned == False and count<=len(jobList):
       if jobList[count][0] == 'WAITING':
             assigned=True
             print('Assigned Job '+str(count)+' to a worker.')
             jobList[count][0]='RUNNING'
             message = str(count) + ' '+jobList[count][1]
       count = count+1
   return message

#----------------------------
# complete job
# marks a running job as complete
# as specified by the jobID
def complete_job(jobID):
   global jobList
   try:
      if jobList[jobID][0]=='RUNNING':
         jobList[jobID][0]='COMPLETE'
         print('Worker completed Job '+str(jobID))
         return 'Server marked Job '+str(jobID)+' as complete.'
      else:
         return 'Job '+str(jobID)+' cannot be completed.'
   except:
         return 'Job '+str(jobID)+' does not exist'

#----------------------------
HOST = ''                 # all available interfaces
PORT = 6889               # non-privileged port
WORKER_PORT = 7210
     
NUM_JOBS = 0              #counter for jobs in the system

jobList = {
                  # 0: ["status","text goes here"]
          }

#set up sockets
serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serverSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

workerSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
workerSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR,1)

if(len(sys.argv)>1):
    if(int(sys.argv[1])<1025):
       print('Client port should be over 1024. Using default value.')
    else:
       PORT = int(sys.argv[1])
if(len(sys.argv)>2):
    if(int(sys.argv[2])<1025):
       print('Worker port should be over 1024. Using default value.')
    else:
       WORKER_PORT = int(sys.argv[2])
if(WORKER_PORT==PORT):
   print('Given ports are the same: incrementing Worker Port')
   WORKER_PORT = WORKER_PORT + 1

serverSocket.bind((HOST, PORT))
serverSocket.listen()
workerSocket.bind((HOST,WORKER_PORT))
workerSocket.listen()
myReadables = [serverSocket,workerSocket] # not transient
myWriteables = []

myClients = [] # are transient
myWorkers = []

#begin
print('Server started with Client Port '+str(PORT)+' and Worker Port '+str(WORKER_PORT))
while True:
    try:
        readable, writeable, exceptions = select.select(
            myReadables + myClients + myWorkers,
            myWriteables + myWorkers,
            myReadables,
            5
        )
        
        for eachSocket in readable:
            if eachSocket is serverSocket:
                #new client
                conn, addr = serverSocket.accept()
                print('Connected by client ', addr)
                myClients.append(conn)
            elif eachSocket is workerSocket:
                #new worker
                conn,addr = workerSocket.accept()
                print('Connected by worker ',addr)
                myWorkers.append(conn)
            elif eachSocket in myClients:
                #read
                data = eachSocket.recv(1024)
                datastr = data.decode('utf-8') # be a string

                if data:
                    message = parse_client_msg(datastr)

                    eachSocket.sendall(message.encode('utf-8'))
                    clean = datastr.strip()
                    if clean == '' or clean == 'quit':
                        eachSocket.close()
                        myClients.remove(eachSocket)
                else:
                    # client closed, drop them
                    print('Removing client')
                    myClients.remove(eachSocket)
            elif eachSocket in myWorkers:
                # read 
                data = eachSocket.recv(1024)
                datastr = data.decode('utf-8') # be a string
                
                if data:
                    message = parse_worker_msg(datastr)
                    eachSocket.sendall(message.encode('utf-8'))
                    clean = datastr.strip()
                    if clean == '' or clean == 'quit':
                        eachSocket.close()
                        myWorkers.remove(eachSocket)
                else:
                    # worker closed, drop them
                    print('Removing worker')
                    myWorkers.remove(eachSocket)

        for problem in exceptions:
            print('There is a problem')
            if problem in myClients:
                myClients.remove(problem)
            if problem in myWorkers:
                myWorkers.remove(problem)
            
    except KeyboardInterrupt as e:
        print('Closing Server.')
        sys.exit(0)
    except Exception as e:
        print('There was an exception.')
        print(e)

