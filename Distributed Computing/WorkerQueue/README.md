#  Distributed Worker Queue

This folder contains
 - README.md (this document)
 - server.py
 - worker.py
 - client.py

# On one command window, run the server with
  python3 server.py
or
  python3 server.py client-port
or
  python3 server.py client-port worker-port

example specifying ports:
  python3 server.py 4444 5555

the server will use default ports if they are not specified. These print on startup.

# Client(s) can be started on other command windows like
  python3 client.py examplebird.cs.umanitoba.ca:client-port

example:
  python3 client.py eagle.cs.umanitoba.ca:6889

clients will prompt for input, accepting commands like
  status 1
  job here are words\n
  quit

# Worker(s) can be started on other command windows like
  python3 worker.py examplebird.cs.umanitoba.ca:worker-port
or
  python3 worker.py examplebird.cs.umanitoba.ca:worker-port output-port
or
  python3 worker.py examplebird.cs.umanitoba.ca:worker-port output-port syslog-port

example:
  python3 client.py eagle.cs.umanitoba.ca:6889 4680 4321

workers will print what ports they are using to connect (they use defaults if not specified).
workers will not recieve work if they are connected to the client port of the server.
workers send messages on their progress to syslog-port, and work on their jobs to output-port on localhost.
