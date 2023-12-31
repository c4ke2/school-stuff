#--------------------------------
# this is a client for the work queue
# they can create jobs and ask for their
# status.
#--------------------------------

import socket
import sys

#--------------------------------
# this method validates the input
# to find problems before sending
# to server, to ensure we are
# giving a valid command
def validate_input(message):
    words = message.split()
    valid = True
    first = words[0].lower()
    if first != 'quit' and first != 'job' and first!='status':
         print('Invalid command. Please use job, status, or quit.')
         valid=False
    if first == 'status' and len(words)<2:
         print('Status requires a number as augment, like status 1')
         valid=False
    elif first=='status' and words[1].isnumeric()!=True:
         print('Provided augment for status is not numeric')
         valid=False
    elif first=='job' and len(words)<2:
         print('Please provide some words with the job, example: job here are words')
         valid=False
    elif first == 'job' and '\n'==words[len(words)-1][-1]:
         print('Jobs should end with \\n.')
         valid=False
    return valid
         
#-----------------------------
# the main loop for the client
def client_loop():
    #args are validated in main
    arg = sys.argv[1].split(':')
    HOST = arg[0]
    PORT = int(arg[1])

    #socket setup
    print('Attempting to connect to '+HOST+' on port '+str(PORT))
    client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)  # instantiate
    client_socket.connect((HOST, PORT))  # connect to the server

    #begin
    message = input(' -> ')  # take input
    valid_input = validate_input(message)

    #the main loop
    while message.lower().strip() != 'quit':
        if valid_input==True:
            client_socket.send(message.encode('utf-8'))  # send message
            data = client_socket.recv(1024).decode('utf-8')  # receive response
            print('Received from server: ' + data)  # show in terminal

        message = input(' -> ')  # again take input
        valid_input = validate_input(message)

    client_socket.close()  # close the connection

#----------------------------------------
if __name__ == '__main__':
    #validate args
    if len(sys.argv) > 1:
        hostPort = sys.argv[1].split(':')
        if(len(hostPort)<2 or hostPort[1].isnumeric()==False):
            print('Please give augments like: python3 client.py eagle.cs.umanitoba.ca:6889')
        elif(int(hostPort[1])<1025):
            print('Port number must be more than 1024.')
        else:
            client_loop()
    else:
        print('Please put host and port to connect to.')
        print('Example: python3 client.py eagle.cs.umanitoba.ca:6889')
