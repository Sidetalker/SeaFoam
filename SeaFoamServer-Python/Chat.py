import util

#This should probs be a database
MESSAGE = 0
CONNECTION = 1
SENT = 2

class Chat:
	def __init__(self, chatId = None):
		self.__chatId = chatId
		self.__messages = []
		self.__connections = []
		self.__sendIndex = 0
		
	def addMessage(self, message, connection):
		self.__messages.append([message, connection, False])
		
	def addConnection(self, connection):
		self.__connections.append(connection)
		
	def updateConnections(self):
		for x in xrange(self.__sendIndex, len(self.__messages)):
			message = self.__messages[x]
			if(not message[SENT]):
				for connection in self.__connections:
					connection.send(util.makeResponse("MSG", "SUCCESS", message[CONNECTION].getUser().getUsername()+"|"+message[MESSAGE], str(connection.getSessionId())))
				message[SENT] = True
			self.__sendIndex = x