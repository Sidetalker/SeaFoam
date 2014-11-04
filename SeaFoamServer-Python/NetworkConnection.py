from User import *
import json

class NetworkConnection:
	def __init__(self, connection):
		self.connection = connection
		self.alive      = True
		self.messageQueue = []
		
	def breakConnection(self):
		self.alive = False
		self.connection.close()
		
	def send(self, message):
		self.messageQueue.append(json.dumps(message))
		
	def maintain(self, dataHandleCallback):
		try:
			while(self.alive):
				data = ""
				tmp = ""
				while len(self.messageQueue) > 0:
					self.connection.send(self.messageQueue.pop(0))
				while not tmp:
					tmp = self.connection.recv(1024)
					data += tmp
				result = dataHandleCallback(data, self)
				self.send(result)
		except Exception as e:
			print "--- Connection Crash ---"
			self.breakConnection()
			print e
		
	def isAlive(self):
		return self.alive