import socket  
import threading
from pymongo import MongoClient
from bson.objectid import ObjectId
from SessionIdController import *
from ConnectionController import *


'''
The response framwork is below, this is the format for the responses that the server will be sending
{action:LOGIN, result:SUCCESS, desc:, userID:1234}
{action:LOGIN, result:FAILURE, desc:We couldnt do it, userID:}
{action:MSG,   result:sender|content, userID:1234}

This is the message framework, this is the format the server will now be recieving messages in
{action:LOGIN, args:username|password}
{action:CREATE_ACCOUNT, args:username|password}
{action:MSG, args:dest|content, userID:1234}
{action:UPDATE_CHAT, args:chatID|text, userID:1234}
'''

class Server:
	def __init__(self):
		# Global Server configuration
		self.host = '50.63.60.10' 
		# self.host = '127.0.0.1'
		self.port = 534
		self.backlog = 5 
		self.size = 4096 
		
		self.clients = []
		self.addresses = []
		self.activeConnections = []
		self.activeThreads = []
		
		# Get a handle on our MongoDB database
		self.dbClient = MongoClient('mongodb://seafoam:seafoam@ds041140.mongolab.com:41140/seafoam')
		self.db = self.dbClient.seafoam
		self.users = self.db.users
		print('Connected to MongoDB successfully')
		
		self.sessionIdController = SessionIdController()
		
	def makeResponse(self, action, result, desc, userID):
		return '{action:' + action + ', result:' + result + ', desc:' + desc + ', userID:' + userID + '}'
	
	def readData(self, data):
		request = {}
		toEdit = data[:].replace("{", "").replace("}", "").replace(" ", "")
		items = toEdit.split(",")
		for item in items:
			data = item.split(":")
			request[data[0]] = data[1]
		return request
		
	# Converts a cursor object (returned from MongoDB request)
	# into a list by iterating over it (not super efficient)
	def queryToList(self, cursorObject):
		myList = []
		print 'begin Query'
		for document in cursorObject:
			print document
			myList.append(document)
		print 'end Query'
		return myList
		
	# Prints a simple string along with address data
	def printInfo(self, message):
		print(message + '\n')
		
	def processData(self, data):
		try:
			if data:                                                              # Make sure the data was received properly
				request = self.readData(data)                                             # Initialize a response container
				if request['action'] == 'LOGIN':                                  # If we've found the login tag...
					return self.login(request)
				elif request['action'] == 'CREATE_ACCOUNT':
					return self.createAccount(request)
				elif request['action'] == "UPDATE_CHAT":
					chatID, text = request['args'].split('|')
					userID = request['userID']
					return self.updateChat(chatID, userID, text)
				else:                                                             # We didn't recognize this query...
					clientResponse = self.makeResponse(request['action'], "FAILURE", "ACTION UNDEFINED", "")
					self.printInfo(clientResponse)
				return clientResponse
			return self.makeResponse("NO_DATA_RECIEVED", "FAILURE", "", "")
		except Exception as e:
			return self.makeResponse("CRASH", "FAILURE", str(e), "")

	# This should be used internally to update the
	def updateChat(self, chatID, userID, text):
		chats.update({'_id' : ObjectId(chatID)}, {'$push': {'messages' : {'userID' : userID, 'text' : text}}})

	# Attempts to create an account for the user
	def createAccount(self, request):
		username, password, email = request["args"].split('|') 
		print "Creating new Account"
		print "Validating new username"
		dbResponse = self.queryToList(self.users.find({ 'username' : username }))  # Query the database for the provide username/password combo
		if len(dbResponse) >= 1:                                       # We received multiple responses - this should be possible
			clientResponse = self.makeResponse(request['action'], "FAILURE", "We received one or more results for the username" + username + ", username is already taken", "")
			self.printInfo(clientResponse)
		else:
			self.users.insert({ 'username' : username, 'password' : password, 'email' : email })
			clientResponse = self.makeResponse(request['action'], "SUCCESS", "The username " + username + " has been registered with the entered passowrd", "")
			self.printInfo(clientResponse)

		return clientResponse

	# Attempts to log a user in
	def login(self, request):
		username, password = request["args"].split('|')               # Extract the username and password
		print('Username: ' + username)
		print('Password: ' + password)
		dbResponse = self.queryToList(self.users.find({ 'username' : username, 'password' : password }))  # Query the database for the provide username/password combo
		if len(dbResponse) > 1:                                       # We received multiple responses - this should be possible
			clientResponse = self.makeResponse(request['action'], "FAILURE", "We received multiple results for the username" + username, "")
			self.printInfo(clientResponse)
		elif len(dbResponse) == 0:                                    # We didn't receive any responses...
			if self.users.find_one({ 'username': username }) == None:      # Check the database for that username (forgotten password)
				clientResponse = self.makeResponse(request['action'], "FAILURE-UN", "No user found for username (create option?) " + username, "")
			else:
				clientResponse = self.makeResponse(request['action'], "FAILURE-PW", "Incorrect password for username " + username, "")
			self.printInfo(clientResponse)
		elif len(dbResponse) == 1:                                    # This is the result we expect - it indicates a successful login
			clientResponse = self.makeResponse(request['action'], "SUCCESS", "You just logged THE FUCK ON", str(dbResponse[0]['_id']))
			self.printInfo(clientResponse)
		else:                                                         # This happens if the cursor object has negative documents - probably impossible
			clientResponse = self.makeResponse(request['action'], "FAILURE", "UNKNOWN ERROR - STATEMENT UNREACHABLE", "")
			self.printInfo(clientResponse)

		return clientResponse
		
	
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
			
			print "New Connection by " + str(accepted[1][0]) + " on port " + str(accepted[1][1])
			
			self.activeConnections.append(ConnectionController(self.clients[-1]))
			
			#Spawn the threads, the threads exit when the connection is closed.
			self.activeThreads.append(threading.Thread(target=self.activeConnections[-1].maintain, args=(self.processData,)))
			self.activeThreads[-1].daemon = True
			self.activeThreads[-1].start()

# Main function separate so this can run as a module
if __name__ == "__main__":
	instance = Server()
	instance.run()