

class ConnectionController:
	def __init__(self, connection):
		self.connection = connection
		self.active     = True
		self.messageQueue = []
		self.sessionId = None
		
	def breakConnection(self):
		self.active = False
		self.connection.close()
		
	def send(self, message):
		self.messageQueue.append(message)
		
	def maintain(self, dataHandleCallback):
		try:
			while(self.active):
				data = ""
				tmp = ""
				while len(self.messageQueue) > 0:
					self.connection.send(self.messageQueue.pop(0))
				while not tmp:
					tmp = self.connection.recv(1024)
					data += tmp
				result = dataHandleCallback(data)
				if "SUCCESS" in result:
					id = result.split(",")[-1].split(":")[-1][:-1]
					self.setSessionId(id)
				self.send(result)
		except Exception as e:
			print "--- Connection Crash ---"
			self.breakConnection()
			print e
		
	def isActive(self):
		return self.active
		
	def getSessionId(self):
		return self.sessionId
		
	def setSessionId(self, newId):
		self.sessionid = newId