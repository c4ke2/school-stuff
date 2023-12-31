#--------------------------------
# This class represents a known peer
#
# includes address, name and time of last ping
#-------------------------------
class KnownPeer:
   def __init__(self,host,port,name,lastPing):
      self.host = host
      self.port = port
      self.name = name
      self.lastPing = lastPing
      self.database = ["None","None","None","None","None"]

   def __str__(self):
      return f"{self.name} at {self.host}:{self.port} (Last ping: {self.lastPing})\n\tData:{self.database}"
