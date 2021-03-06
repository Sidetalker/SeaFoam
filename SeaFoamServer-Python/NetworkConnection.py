from User import *
import json

class NetworkConnection:
	def __init__(self, connection, server = None):
		self.connection   = connection
		self.alive        = True
		self.__server     = server
		self.messageQueue = []
		
	def breakConnection(self):
		self.alive = False
		self.connection.close()
		
	def send(self, message):
		self.messageQueue.append(json.dumps(message))
		self.messageQueue.append("\r\n")
		
	def maintain(self, dataHandleCallback):
		try:
			while(self.alive):
				data = ""
				tmp = ""
				while len(self.messageQueue) > 0:
					message = self.messageQueue.pop(0)
					print "Message has been sent"
					self.connection.send(message)
				while not tmp:
					tmp = self.connection.recv(1024)
					data += tmp
				result = dataHandleCallback(data, self)
				self.send(result)
		except Exception as e:
			print "--- Connection Crash ---"
			self.breakConnection()
			index = self.__server.activeConnections.index(self)
			self.__server.activeConnections.pop(index)
			self.__server.activeThreads.pop(index)
			for key in self.__server.activeUsers.keys():
				if(not self.__server.activeUsers[key].isAlive()):
					del self.__server.activeUsers[key]
			print e
		
	def isAlive(self):
		return self.alive