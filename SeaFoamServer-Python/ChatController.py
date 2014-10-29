from Chat import *

#This should probs be a database

#and the id needs to become a hash as opposed to an index

class ChatController:
	def __init__(self):
		self.chats = []
		
	def makeChat(self, connections):
		self.chats.append(Chat(len(self.chats)))
		for connection in connections:
			self.chats[-1].addConnection(connection)
		return len(self.chats)-1
		
	def __getitem__(self, key):
		return self.chats[key]