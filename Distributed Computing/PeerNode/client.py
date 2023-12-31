#--------------------------------
# this program is a client
# that connects to a node in the network
# it can issue commands like set and
# tell the node to lie or not
#-------------------------------
import socket
import sys
#-----------------------------
# the main loop for the client
def client_loop():
    #args are validated in main
    arg = sys.argv[1].split(':')
    HOST = arg[0]
    PORT = int(arg[1])

    #TCP socket setup
    print('Type \'exit\' to exit')
    print('Attempting to connect to '+HOST+' on port '+str(PORT))
    client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    client_socket.connect((HOST, PORT))  # connect to the server

    message = input(' > ')

    while message.lower().strip() != 'exit':
        client_socket.send(message.encode('utf-8'))  # send message
        data = client_socket.recv(4096).decode('utf-8')  # receive response
        if data:
           print('Received from server: ' + data)  # show in terminal
           message = input(' > ')  # again take input
        else:
           print('Node went offline, exiting')
           message = 'exit'

    client_socket.close()  # close the connection

#----------------------------------------
if __name__ == '__main__':
    #validate args
    if len(sys.argv) > 1:
        hostPort = sys.argv[1].split(':')
        if(len(hostPort)<2 or hostPort[1].isnumeric()==False):
            print('Please give augments like: python3 client.py eagle.cs.umanitoba.ca:8115')
        elif(int(hostPort[1])<1025):
            print('Port number must be more than 1024.')
        else:
            client_loop()
    else:
        print('Please put host and port to connect to.')
        print('Example: python3 client.py eagle.cs.umanitoba.ca:8115')
