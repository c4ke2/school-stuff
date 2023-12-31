# Peer Node

NOTE: the network this node was intended to run on is no longer up, so the node will
not connect to anything.  It is here because it was an interesting assignment.

This node was meant to act in a modified version of the Byzantine Generals Problem.
It would store 5 words and respond with them when it was asked by a peer.

The previous readme is below but the instructions no longer work:

This directory contains:
 - README.md (this)
 - node.py
 - peerObj.py
 - consensusObj.py
 - client.py

When running, another directory is created automatically, which I believe acts as a cache for object classes.

peerObj.py and consensusObj.py are just object classes, for a known peer and an active consensus respectively.

To run:

  python3 node.py
or
  python3 node.py PORTNUMBER
ex.
  python3 node.py 16000


To use the client, host the node and open another tab:
  python3 client.py address:port
ex.
  python3 client.py eagle.cs.umanitoba.ca:8115

Commands for the client are:

peers
current
consensus x
lie
truth
set x y
exit

as listed in the assignment
