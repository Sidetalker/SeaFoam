import socket  
import threading
import util
import datetime
from pymongo import MongoClient
from bson.objectid import ObjectId
from NetworkConnection import *
from User import *

'''
The response framwork is below, this is the format for the responses that the server will be sending
{action:LOGIN,       result:SUCCESS, desc:, userID:1234}
{action:LOGIN,       result:FAILURE, desc:We couldnt do it, userID:}
{action:UPDATE_CHAT, result:sender|content|chatID, userID:1234}

This is the message framework, this is the format the server will now be recieving messages in
{action:LOGIN, args:username|password}
{action:CREATE_ACCOUNT, args:username|password}
{action:MSG, args:dest|content, userID:1234}
{action:UPDATE_CHAT, args:chatID|text, userID:1234}
{action:ADD_CHAT_USER, args:chatID, userID:1234}
{action:REMOVE_CHAT_USER, args:chatID, userID:1234}
{action:ADD_CHAT, args:name, userID:1234}
{action:REMOVE_CHAT, args:chatID, userID:1234}
{action:LIST_CHATS, args:, userID:1234}
{action:LIST_CHAT_CONTENTS, args:chatID, userID:1234}
'''

class Server:
	def __init__(self):
		# Global Server configuration
		self.host = '50.63.60.10' 
		self.host = '127.0.0.1'
		self.port = 534
		self.backlog = 5 
		self.size = 65536 
		
		self.clients = []
		self.addresses = []
		self.activeConnections = []
		self.activeThreads = []
		self.activeUsers = {}
		
		# Get a handle on our MongoDB database
		self.dbClient = MongoClient('mongodb://seafoam:seafoam@ds041140.mongolab.com:41140/seafoam')
		self.db = self.dbClient.seafoam
		self.users = self.db.users
		self.chats = self.db.chats
		print('Connected to MongoDB successfully')
		
	def processData(self, data, connection):
		print "Processing " + data
		try:
			if data:                                                              # Make sure the data was received properly
				request = util.readData(data)                                     # Initialize a response container
				print request
				if request['action'] == 'LOGIN':                                  # If we've found the login tag...
					return self.login(request, connection)
				elif request['action'] == 'CREATE_ACCOUNT':
					return self.createAccount(request)
				elif request['action'] == "UPDATE_CHAT":
					return self.updateChat(request)
				elif request['action'] == "ADD_CHAT_USER":
					return self.addUserToChat(request)
				elif request['action'] == "REMOVE_CHAT_USER":
					return self.removeUserFromChat(request)
				elif request['action'] == "LIST_CHATS":
					return self.listChats(request)
				elif request['action'] == "LIST_CHAT_CONTENTS":
					return self.listChatContents(request)
				elif request['action'] == "ADD_CHAT":
					return self.makeChat(request)
				elif request['action'] == "REMOVE_CHAT":
					return self.removeChat(request)
				else:                                                             # We didn't recognize this query...
					clientResponse = util.makeResponse(request['action'], "FAILURE", { "info" : "ACTION UNDEFINED" }, "")
					util.printInfo(clientResponse)
					return clientResponse
				return util.makeResponse("NO_DATA_RECIEVED", "FAILURE", { "info" : "No data received" }, "")
		except Exception as e:
			return util.makeResponse("CRASH", "FAILURE", { "info" : str(e) }, "")
	
	def updateChat(self, request):
		chatID, text = request['args'].split('|')
		userID = request['userID']
		self.chats.update({'_id' : ObjectId(chatID)}, {'$push': {'messages' : {'userID' : userID, 'text' : text, 'timestamp': str(datetime.datetime.now())}}})
		message = util.makeResponse(request['action'], "SUCCESS", { "sender" : str(userID), "content" : text, "chatID": str(chatID) }, "")
		
		chatMembers = util.queryToList(self.chats.find({'_id' : ObjectId(chatID)}, {"members": 1}))#, {'members' : 1}
		for memberID in chatMembers[0]["members"]:
			print str(memberID)
			if(memberID != userID):
				try:
					self.activeUsers[str(memberID)].send(message)
					print "Sending message to " + str(memberID)
				except:
					pass
			else:
				print "Ignoring sender"
		
		clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "Chat " + chatID + " has been updated" }, "")
		util.printInfo(clientResponse)
		return clientResponse
		
	def addUserToChat(self, request):
		chatID = request['args']
		userID = request['userID']
		self.chats.update({'_id' : ObjectId(chatID)}, {'$push': {'members' : userID}})
		clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "The user " + userID + " has been added to chat " + chatID }, "")
		util.printInfo(clientResponse)
		return clientResponse
		
	def removeUserFromChat(self, request):
		chatID = request['args']
		userID = request['userID']
		self.chats.update({'_id' : ObjectId(chatID)}, {'$pull': {'members' : userID}})
		clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "The user " + userID + " has been removed from chat " + chatID }, "")
		util.printInfo(clientResponse)
		return clientResponse
		
	def listChats(self, request):
		userID = request['userID']
		chatsList = util.queryToList(self.chats.find({'members': {'$in' : {'userID': userID}}}))
		# We want chatID, name, creator, members and the latest message
		chatInfo = []
		for chat in chatsList:
			curChatInfo = {}
			curChatInfo['_id'] = str(chat['_id'])
			curChatInfo['members'] = chat['members']
			if len(chat['messages']) != 0:
				curChatInfo['latestMessage'] = chat['messages'][-1]
			else:
				curChatInfo['latestMessage'] = ""
			curChatInfo['name'] = chat['name']
			curChatInfo['creator'] = chat['creator']
			chatInfo.append(curChatInfo)
		clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : chatInfo }, "")
		util.printInfo(clientResponse)
		return clientResponse
		
	def listChatContents(self, request):
		chatID = request['args']
		chatContents = util.queryToList(self.chats.find({'_id': ObjectId(chatID)}))
		clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : chatContents[0]['messages'] }, "")
		util.printInfo(clientResponse)
		return clientResponse
		
	def makeChat(self, request):
		name = request['args']
		userID = request['userID']
		dbResponse = util.queryToList(self.chats.find({ 'name' : name }))
		if len(dbResponse) >= 1:
			clientResponse = util.makeResponse(request['action'], "FAILURE", { "info" : "A chatroom with the name " + name + " already exists", "name" : name }, "")
			self.printInfo(clientResponse)
		else:
			self.chats.insert({'creator' : userID, 'name' : name, 'members' : [userID], 'messages' : []})
			clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "Created a chatroom named " + name}, "")
		return clientResponse
		
	def removeChat(self, request):
		name = request['args']
		userID = request['userID']
		dbResponse = util.queryToList(self.chats.find({'name' : name, 'creator' :userID}))
		if(len(dbResponse) > 0):
			print self.chats.remove({'name' : name})
			clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "The chatroom " + name + " has been removed"}, "")
			return clientResponse
		return self.removeUserFromChat(request)
			
		
	# Attempts to create an account for the user
	def createAccount(self, request):
		username, password, email = request["args"].split('|') 
		print "Creating new Account"
		print "Validating new username"
		dbResponse = util.queryToList(self.users.find({ 'username' : username }))  # Query the database for the provide username/password combo
		if len(dbResponse) >= 1:                                       # We received multiple responses - this should be possible
			clientResponse = util.makeResponse(request['action'], "FAILURE", { "info" : "We received one or more results for the username" + username + ", username is already taken" }, "")
			util.printInfo(clientResponse)
		else:
			self.users.insert({ 'username' : username, 'password' : password, 'email' : email })
			clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "The username " + username + " has been registered with the entered password" }, "")
			util.printInfo(clientResponse)
		return clientResponse

	# Attempts to log a user in
	def login(self, request, connection):
		username, password = request["args"].split('|')               # Extract the username and password
		print('Username: ' + username)
		print('Password: ' + password)
		dbResponse = util.queryToList(self.users.find({ 'username' : username, 'password' : password }))  # Query the database for the provide username/password combo
		if len(dbResponse) > 1:                                       # We received multiple responses - this should be possible
			clientResponse = util.makeResponse(request['action'], "FAILURE", { "info" : "We received multiple results for the username" + username }, "")
			util.printInfo(clientResponse)
		elif len(dbResponse) == 0:                                    # We didn't receive any responses...
			if self.users.find_one({ 'username': username }) == None:      # Check the database for that username (forgotten password)
				clientResponse = util.makeResponse(request['action'], "FAILURE-UN", { "info" : "No user found for username " + username }, "")
			else:
				clientResponse = util.makeResponse(request['action'], "FAILURE-PW", { "info" : "Incorrect password for username " + username }, "")
			util.printInfo(clientResponse)
		elif len(dbResponse) == 1:                                    # This is the result we expect - it indicates a successful login
			clientResponse = util.makeResponse(request['action'], "SUCCESS", { "info" : "You just logged THE FUCK ON" }, str(dbResponse[0]['_id']))
			util.printInfo(clientResponse)
			self.activeUsers[str(dbResponse[0]['_id'])] = connection
		else:                                                         # This happens if the cursor object has negative documents - probably impossible
			clientResponse = util.makeResponse(request['action'], "FAILURE", { "info" : "UNKNOWN ERROR - STATEMENT UNREACHABLE" }, "")
			util.printInfo(clientResponse)
		print "done"
		return clientResponse
		
	def cleanActiveData(self):
		x = 0
		while(x < len(self.activeConnections)):
			if(not self.activeConnections[x].isAlive()):
				self.activeConnections.pop(x)
				self.activeThreads.pop(x)
				x -= 1
			x += 1
		for key in self.activeUsers.keys():
			if(not self.activeUsers[key].isAlive()):
				del self.activeUsers[key]
	
	def run(self):
		# Create the socket
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
	
		# Bind the socket and begin listening
		s.bind((self.host,self.port)) 
		s.listen(self.backlog) 
		print('Server is listening on port ' + str(self.port))
	
		# Listen indefinitely
		while 1: 
			# Accept an incoming connection, store the client socket and the conn address
			accepted = s.accept()
			self.clients.append(accepted[0])		
			self.addresses.append((str(accepted[1][0]), str(accepted[1][1])))
			
			print "New Connection by " + str(accepted[1][0]) + " on port " + str(accepted[1][1]) + " has been accepted"
			
			self.activeConnections.append(NetworkConnection(self.clients[-1], self))
			
			#Spawn the threads, the threads exit when the connection is closed.
			self.activeThreads.append(threading.Thread(target=self.activeConnections[-1].maintain, args=(self.processData,)))
			#self.activeThreads[-1].daemon = True
			self.activeThreads[-1].start()

# Main function separate so this can run as a module
if __name__ == "__main__":
	instance = Server()
	instance.run()