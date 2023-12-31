#--------------------------------
# this is a worker for the job queue
# it tries to pull jobs from the server
# and when it gets one, prints the
# job one word at a time to a specified port.
# it sends back to the server on job completion
#--------------------------------

import socket
import sys
import time

#--------------------------------
# this method does work on a job,
# printing one word at a time to
# the specified port
def do_job(words,out_socket,PORT):
    working = True
    words = words.split(' ')
    count = 0
    while count<len(words):
        time.sleep(0.25)
        out_socket.sendto(words[count].encode('utf-8'),('127.0.0.1',PORT))
        count = count+1

    working = False
    return 'completed job'

#--------------------------------
# main loop for a worker
def worker_loop():
    #get host and port of server
    args = sys.argv[1].split(":")
    HOST = args[0]
    PORT = int(args[1])

    #set up UDP ports
    LOCAL_HOST = '127.0.0.1'
    OUTPUT_PORT = 4680
    if len(sys.argv)>2 and sys.argv[2].isnumeric():
         OUTPUT_PORT = int(sys.argv[2])
    SYSLOG_PORT = 5140
    if len(sys.argv)>3 and sys.argv[3].isnumeric():
         SYSLOG_PORT = int(sys.argv[3])

    working = False

    print('Attempting to connect to '+HOST+' on port '+str(PORT))
    print('Using output port '+str(OUTPUT_PORT)+' and syslog port '+str(SYSLOG_PORT))

    #create sockets
    client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)  # instantiate
    client_socket.connect((HOST, PORT))  # connect to the server
    
    log_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    out_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    print("Connected to "+HOST)
    message = 'pull'
    #the main loop
    while message.lower().strip() != 'quit':
            #poll for job
            client_socket.send(message.encode('utf-8'))  # send message
            data = client_socket.recv(1024).decode('utf-8')  # receive response
            
            if data != 'none':
                 #we have a job to do
                 log = 'fetched job'
                 log_socket.sendto(log.encode('utf-8'),(LOCAL_HOST,SYSLOG_PORT))
                 
                 words = data.split(' ',1)

                 log = 'starting job'
                 log_socket.sendto(log.encode('utf-8'),(LOCAL_HOST,SYSLOG_PORT))
                 #do the job
                 log = do_job(words[1],out_socket,OUTPUT_PORT)
                 log_socket.sendto(log.encode('utf-8'),(LOCAL_HOST,SYSLOG_PORT))
                 #send back to server
                 message = 'complete '+str(words[0])
                 client_socket.send(message.encode('utf-8'))      # send message
                 data = client_socket.recv(1024).decode('utf-8')  # receive response
                 
            else:
                 #wait a bit and pull again
                 time.sleep(1)
            message = 'pull'

    client_socket.close()  # close the connection

#----------------------------
#main
if __name__ == '__main__':
    #parse provided augments
    if len(sys.argv) > 1:
        hostPort = sys.argv[1].split(':')
        if(len(hostPort)<2 or hostPort[1].isnumeric()==False):
            print('Please give augments like: python3 worker.py eagle.cs.umanitoba.ca:6889')
        elif(int(hostPort[1])<1025):
            print('Port number must be more than 1024.')
        else:
            #server address and port okay. will use defaults if other ports not provided.
            worker_loop()
    else:
        print('Please put host and port to connect to, as well as output and syslog ports.')
        print('Example: python3 worker.py eagle.cs.umanitoba.ca:6889 3000 4000')
