#----------------------------------------------------------------
# object to represent a consensus we are waiting on replies for
# includes UUID of this consensus, expiry time, index to query,
# list of replies.  If this is a subconcensus, parent is the
# UUID of the parent concensus and addr is the node that sent
# the parent concensus
class ActiveConsensus:
   def __init__(self,UUID,expires,index,addr,parent):
      self.UUID = UUID
      self.parent = parent
      self.expires = expires
      self.index = index
      self.retAddr = addr
      self.replies = {}

   def __str__(self):
      return f"Consensus : {self.UUID} for index {self.index}. Expires at {self.expires}"
