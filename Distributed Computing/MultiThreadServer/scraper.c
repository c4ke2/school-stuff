/*--------------------------------
 this is the system test for the webserver
 it include parts 2 and 3 of the assignment
 
 this program attempts to connect
 to the webserver, then login using
 the given credentials. if this
 succeeds, it posts a tweet then
 tries to delete it with another user
 then deletes it with the user who
 posted it.
--------------------------------*/
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h> // For getaddrinfo
#include <unistd.h> // for close
#include <stdlib.h> // for exit
//-----------------------------------------
int main(int argc, char* argv[])
{
    char* HOST = "127.0.0.1"; //local host
    int PORT = 6889;

    if(argc<4)
    {
        printf("Please run with arguments like:\n");
        printf("./scraper username password here are words to post\n");
        printf("test: %s\n",argv[0]);
    }
    else
    {
            char tweetContent[256] = "";
            for(int i=3;i<argc;i++)
            {
               strcat(tweetContent,argv[i]);
               if(i<argc-1)
                 strcat(tweetContent," ");
            }

	    int socket_desc;
	    struct sockaddr_in server_addr;
	    char server_message[4096], client_message[2000];
	    char address[100];

	    struct addrinfo *result;
	    // Clean buffers:
	    memset(server_message,'\0',sizeof(server_message));
	    memset(client_message,'\0',sizeof(client_message));
	    
	    // Create socket:
	    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
	    
	    if(socket_desc < 0){
		printf("Unable to create socket\n");
		return -1;
	    }
	    
	    struct addrinfo hints;
	    memset (&hints, 0, sizeof (hints));
	    hints.ai_family = PF_UNSPEC;
	    hints.ai_socktype = SOCK_STREAM;
	    hints.ai_flags |= AI_CANONNAME;
	    
	    // get the ip of the page we want to scrape
	    int out = getaddrinfo (HOST, NULL, &hints, &result);
	    // fail gracefully
	    if (out != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(out));
		exit(EXIT_FAILURE);
	    }
	    
	    struct sockaddr_in *serverDetails =  (struct sockaddr_in *)result->ai_addr;
	    
	    // Set port and IP the same as server-side:
	    server_addr.sin_family = AF_INET;
	    server_addr.sin_port = htons(PORT);
	    server_addr.sin_addr.s_addr = inet_addr(HOST);
	    server_addr.sin_addr = serverDetails->sin_addr;
	    
	    // converts to octets
	    inet_ntop (server_addr.sin_family, &server_addr.sin_addr, address, 100);
	    // Send connection request to server:
	    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0)
            {
		printf("Unable to connect\n");
		exit(EXIT_FAILURE);
	    }
//-----------------------------------------------------------------
// login with given
//-----------------------------------------------------------------
            printf("Checking login...\n");
            char loginReq[100] = "POST /api/login HTTP/1.1\r\n\r\n{\"username\":\"";
            strcat(loginReq,argv[1]);
            strcat(loginReq,"\",\"password\":\"");
            strcat(loginReq,argv[2]);
            strcat(loginReq,"\"}");

	    if(send(socket_desc, loginReq, strlen(loginReq), 0) < 0){
		printf("Unable to send message\n");
		return -1;
	    }
	    
	    // Receive the server's response:
	    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
		printf("Error while receiving server's msg\n");
		return -1;
	    }
	   
            char* loginCheck = strstr(server_message,"200");
            if(loginCheck)
            {
                 printf("Login successful.\n");
            }
            else
            {
                 printf("Login failed.\n");
            }

            // Close the socket:
            close(socket_desc);
//----------------------------------------------------------------
            if(loginCheck)
	    {
		    // Clean buffers:
		    memset(server_message,'\0',sizeof(server_message));
		    memset(client_message,'\0',sizeof(client_message));
		    // Create socket:
		    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
		    if(socket_desc < 0)
                    {
			printf("Unable to create socket\n");
			return -1;
		    }
		    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0)
                    {
			printf("Unable to connect\n");
			exit(EXIT_FAILURE);
		    }
//--------------------------------------------------------------------------------------
// try to post tweet
//--------------------------------------------------------------------------------------
                    char postReq[256] = "POST /api/tweet HTTP/1.1\r\nCookie: userLogin=";
                    strcat(postReq,argv[1]);
                    strcat(postReq,"\r\n\r\n{\"content\":\"");
                    strcat(postReq,tweetContent);
                    strcat(postReq,"\",\"author\":\"");
                    strcat(postReq,argv[1]);
                    strcat(postReq,"\"}");
                    
		    if(send(socket_desc, postReq, strlen(postReq), 0) < 0){
			printf("Unable to send message\n");
			return -1;
		    }

		    // Receive the server's response:
		    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
			printf("Error while receiving server's msg\n");
			return -1;
		    }

                    char* postCheck = strstr(server_message,"200");
                    char tweetID[16];
                    if(postCheck)
                    {//NOTE: this destroys the server_message for this request
                       //get id of posted tweet
                       char* last;
                       char* token = strtok(server_message, "\n");
		       while( token != NULL ) 
                       {
     		              last = token;
      		  	      token = strtok(NULL, "\n");
		       }
                       memcpy(tweetID,last,strlen(last));
                       printf("Tweet posted, has id: %s\n",tweetID);
                    }
                    else
                    {
                       printf("<!> Failed to generate tweet.\n");
                    }
		    close(socket_desc);
//----------------------------------------------------------------------------------
                    // Clean buffers:
                    memset(server_message,'\0',sizeof(server_message));
                    memset(client_message,'\0',sizeof(client_message));
                    // Create socket:
                    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
                    if(socket_desc < 0)
                    {
                        printf("Unable to create socket\n");
                        return -1;
                    }
                    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0)
                    {
                        printf("Unable to connect\n");
                        exit(EXIT_FAILURE);
                    }
//--------------------------------------------------------------------------------------
// get to check we posted it good
//--------------------------------------------------------------------------------------
                    char getReq[256] = "GET /api/tweet HTTP/1.1\r\n\r\n";
                    if(send(socket_desc, getReq, strlen(getReq), 0) < 0){
                        printf("Unable to send message\n");
                        return -1;
                    }

                    // Receive the server's response:
                    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
                        printf("Error while receiving server's msg\n");
                        return -1;
                    }

                    char* getCheck1 = strstr(server_message,tweetContent);
                    if(getCheck1)
                    {
                        printf("Tweet found in GET call as expected.\n");
                    }
                    else
                    {
                        printf("<!> Could not find posted tweet in GET call, it should be there.\n");
                    }

                    // Close the socket:
                    close(socket_desc);
//-----------------------------------------------------------------
                    // Clean buffers:
                    memset(server_message,'\0',sizeof(server_message));
                    memset(client_message,'\0',sizeof(client_message));
                    // Create socket:
                    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
                    if(socket_desc < 0){
                        printf("Unable to create socket\n");
                        return -1;
                    }
                    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0){
                        printf("Unable to connect\n");
                        exit(EXIT_FAILURE);
                    }
//--------------------------------------------------------------------------------------
// try to delete with the wrong account
//--------------------------------------------------------------------------------------
                    char badDelReq[256] = "DELETE /api/tweet/";
                    strcat(badDelReq,tweetID);
                    strcat(badDelReq," HTTP/1.1\r\nCookie: userLogin=NotRealUser\r\n\r\n");
                    if(send(socket_desc, badDelReq, strlen(badDelReq), 0) < 0){
                        printf("Unable to send message\n");
                        return -1;
                    }

                    // Receive the server's response:
                    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
                        printf("Error while receiving server's msg\n");
                        return -1;
                    }

                    printf("Attempted to delete with wrong user:\n");
                    char* delCheck1 = strstr(server_message,"200");
                    if(delCheck1)
                    {
                        printf(" <!> Tweet was deleted, it should not have been.\n");
                    }
                    else
                    {
                        printf(" Delete call failed, as expected.\n");
                    }

                    // Close the socket:
                    close(socket_desc);
//----------------------------------------------------------------------------------
                    // Clean buffers:
                    memset(server_message,'\0',sizeof(server_message));
                    memset(client_message,'\0',sizeof(client_message));
                    // Create socket:
                    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
                    if(socket_desc < 0)
                    {
                        printf("Unable to create socket\n");
                        return -1;
                    }
                    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0)
                    {
                        printf("Unable to connect\n");
                        exit(EXIT_FAILURE);
                    }
//--------------------------------------------------------------------------------------
// get to check delete failed
//--------------------------------------------------------------------------------------
                    if(send(socket_desc, getReq, strlen(getReq), 0) < 0){
                        printf("Unable to send message\n");
                        return -1;
                    }

                    // Receive the server's response:
                    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
                        printf("Error while receiving server's msg\n");
                        return -1;
                    }

                    char* getCheck2 = strstr(server_message,tweetContent);
                    if(getCheck2)
                    {
                        printf(" Tweet found in GET call as expected.\n");
                    }
                    else
                    {
                        printf(" <!> Could not find posted tweet in GET call, it should be there.\n");
                    }

                    // Close the socket:
                    close(socket_desc);
//--------------------------------------------------------------------------------
                    // Clean buffers:
                    memset(server_message,'\0',sizeof(server_message));
                    memset(client_message,'\0',sizeof(client_message));
                    // Create socket:
                    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
                    if(socket_desc < 0){
                        printf("Unable to create socket\n");
                        return -1;
                    }
                    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0){
                        printf("Unable to connect\n");
                        exit(EXIT_FAILURE);
                    }
//--------------------------------------------------------------------------------------
// try to delete with correct account
//--------------------------------------------------------------------------------------
                    char delReq[256] = "DELETE /api/tweet/";
                    strcat(delReq,tweetID);
                    strcat(delReq," HTTP/1.1\r\nCookie: userLogin=");
                    strcat(delReq,argv[1]);
                    strcat(delReq,"\r\n\r\n");
                    if(send(socket_desc, delReq, strlen(delReq), 0) < 0){
                        printf("Unable to send message\n");
                        return -1;
                    }

                    // Receive the server's response:
                    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
                        printf("Error while receiving server's msg\n");
                        return -1;
                    }

                    printf("Attempted to delete with correct user:\n");
                    char* delCheck2 = strstr(server_message,"200");
                    if(delCheck2)
                    {
                        printf(" Tweet was deleted, as expected.\n");
                    }
                    else
                    {
                        printf(" <!> Delete failed, but it shouldn't have.\n");
                    }

                    // Close the socket:
                    close(socket_desc);
//----------------------------------------------------------------------------------
                    // Clean buffers:
                    memset(server_message,'\0',sizeof(server_message));
                    memset(client_message,'\0',sizeof(client_message));
                    // Create socket:
                    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
                    if(socket_desc < 0)
                    {
                        printf("Unable to create socket\n");
                        return -1;
                    }
                    if(connect(socket_desc, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0)
                    {
                        printf("Unable to connect\n");
                        exit(EXIT_FAILURE);
                    }
//--------------------------------------------------------------------------------------
// get to check delete worked
//--------------------------------------------------------------------------------------
                    if(send(socket_desc, getReq, strlen(getReq), 0) < 0){
                        printf("Unable to send message\n");
                        return -1;
                    }

                    // Receive the server's response:
                    if(recv(socket_desc, server_message, sizeof(server_message), 0) < 0){
                        printf("Error while receiving server's msg\n");
                        return -1;
                    }

                    char* getCheck3 = strstr(server_message,tweetContent);
                    if(getCheck3)
                    {
                        printf(" <!> Tweet still exists, it should not.\n");
                    }
                    else
                    {
                        printf(" Tweet was not present in GET call, as expected.\n");
                    }

                    // Close the socket:
                    close(socket_desc);
         }
//-----------------------------------------------------------------
    }

    return 0;
}
