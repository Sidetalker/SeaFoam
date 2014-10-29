from User import *

class ConnectionController:
	def __init__(self, connection):
		self.connection = connection
		self.active     = True
		self.messageQueue = []
		self.sessionId = None
		self.__user = None
		
	def breakConnection(self):
		self.active = False
		self.connection.close()
		if self.__user != None:
			self.__user.makeLoggedOut()
			
			
	def logout(self, username, sessionId):
		print "Attempting logout"
		if sessionId != self.sessionId:
			return False
		if self.__user == None or self.__user.getUsername() == username:
			self.__user.makeLoggedOut()
			self.__user = None
			self.breakConnection()
			return True
		return False
			
	def send(self, message):
		self.messageQueue.append(message)
		
	def maintain(self, dataHandleCallback):
		#try:
		while(self.active):
			data = ""
			tmp = ""
			while len(self.messageQueue) > 0:
				self.connection.send(self.messageQueue.pop(0))
			while not tmp:
				tmp = self.connection.recv(1024)
				data += tmp
			result = dataHandleCallback(data, self)
			self.send(result)
		print "--- Thread Natural Exit ---"
		#except Exception as e:
		#	print "--- Connection Crash ---"
		#	self.breakConnection()
		#	print e
		
	def isActive(self):
		return self.active
		
	def getSessionId(self):
		return self.sessionId
	def setSessionId(self, newId):
		self.sessionId = newId
	def setUser(self, newUser):
		self.__user = newUser
	def getUser(self):
		return self.__user