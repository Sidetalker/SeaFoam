import socket  
import threading
import util
from pymongo import MongoClient
from SessionIdController import *
from ConnectionController import *
from ChatController import *
from User import *

'''
The response framwork is below, this is the format for the responses that the server will be sending
{action:LOGIN, result:SUCCESS, desc:, sessionId:1234}
{action:LOGIN, result:FAILURE, desc:We couldnt do it, sessionId:}
{action:MSG,   result:SUCCESS, sessionId:1234}
{action:MSG_CREATE, result:SUCCESS, desc:We did it!, chatId:1234}

This is the message framework, this is the format the server will now be recieving messages in
{action:LOGIN, args:username|password, sessionId:}
{action:MSG, args:dest|content, sessionId:1234}
{action:MSG_CREATE, args:dest1|dest2|dest3, sessionId:1234}
'''

class Server:
	def __init__(self):
		# Global Server configuration
		#self.host = '50.63.60.10' 
		self.host = '127.0.0.1'
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
		self.chatController      = ChatController()
		
	# Converts a cursor object (returned from MongoDB request)
	# into a list by iterating over it (not super efficient)
	def queryToList(self, cursorObject):
		myList = []
		for document in cursorObject:
			myList.append(document)
		return myList
		
		
	# Prints a simple string along with address data
	def printInfo(self, message):
		print("Message: " + message + '\n')
		
	def processData(self, data, connection):
		#try:
		print "Parsing: " + data 
		if data:                                                              # Make sure the data was received properly
			request = util.readRequest(data)
			clientResponse = ''                                               # Initialize a response container
			if request['action'] == 'LOGIN':                                  # If we've found the login tag...
				username, password = request["args"].split('|')               # Extract the username and password
				print('Username: ' + username)
				print('Password: ' + password)
				dbResponse = self.queryToList(self.users.find({ 'username' : username, 'password' : password }))  # Query the database for the provide username/password combo
				if connection.getUser() != None:
					clientResponse = util.makeResponse(request['action'], "FAILURE", "You are already logged in under a different account", str(connection.getSessionId()))
				elif len(dbResponse) > 1:                                     # We received multiple responses - this should be possible
					clientResponse = util.makeResponse(request['action'], "FAILURE", "We received multiple results for the username" + username, str(connection.getSessionId()))
				elif len(dbResponse) == 0:                                    # We didn't receive any responses...
					if self.users.find_one({ 'username': username }) == None: # Check the database for that username (forgotten password)
						clientResponse = util.makeResponse(request['action'], "FAILURE", "No user found for username (create option?) " + username, str(connection.getSessionId()))
					else:
						clientResponse = util.makeResponse(request['action'], "FAILURE", "Incorrect password for username " + username, str(connection.getSessionId()))
				elif len(dbResponse) == 1:                                    # This is the result we expect - it indicates a successful login
					connection.setUser(User(username, password))
					clientResponse = util.makeResponse(request['action'], "SUCCESS", "You just logged THE FUCK ON", str(connection.getSessionId()))
				else:                                                         # This happens if the cursor object has negative documents - probably impossible
					clientResponse = util.makeResponse(request['action'], "FAILURE", "UNKNOWN ERROR - STATEMENT UNREACHABLE", str(connection.getSessionId()))
			elif request['action'] == 'LOGOUT':
				result = connection.logout(request['args'], int(request['sessionId']))
				if(result):
					clientResponse = util.makeResponse(request['action'], "SUCCESS", "You have been logged out", str(connection.getSessionId()))
				else:
					clientResponse = util.makeResponse(request['action'], "FAILURE", "You either not logged in or you used the wrong credentials", str(connection.getSessionId()))
			elif request['action'] == 'CREATE_ACCOUNT':
				username, password = request["args"].split('|') 
				print "Creating new Account"
				print "Validating new username"
				dbResponse = self.queryToList(self.users.find({ 'username' : username }))  # Query the database for the provide username
				if len(dbResponse) >= 1:                                                   # If it already exists
					clientResponse = util.makeResponse(request['action'], "FAILURE", "We received one or more results for the username" + username + ", username is already taken", str(connection.getSessionId()))
				else:
					self.users.insert({ 'username' : username, 'password' : password })
					clientResponse = util.makeResponse(request['action'], "SUCCESS", "The username " + username + " has been registered with the entered passowrd", str(connection.getSessionId()))
			elif request['action'] == "MSG":
				if(connection.getUser() == None or connection.getUser().isLoggedIn()):
					chatDest, chatMessage = request["args"].split('|')
					try:
						self.chatController[int(chatDest)].addMessage(chatMessage, connection)
						self.chatController[int(chatDest)].updateConnections()
						clientResponse = util.makeResponse(request['action'], "SUCCESS", "The message has been sent", str(connection.getSessionId()))
					except:
						clientResponse = util.makeResponse(request['action'], "FAILURE", "Requested chat does not exist", str(connection.getSessionId()))
				else:
					chientResponse = util.makeResponse(request['action'], "FAILURE", "The user must be logged in to send messages", str(connection.getSessionId()))
				print clientResponse
			elif request['action'] == "MSG_CREATE":
				if(connection.getUser() == None or connection.getUser().isLoggedIn()):
					targets = request["args"].split('|')
					id = self.chatController.makeChat(util.getConnectionsFromUsernames(self.activeConnections, targets))
					clientResponse = util.makeResponse(request['action'], "SUCCESS", "The chat has been created", "", [["chatId", str(id)]])
				else:
					chientResponse = util.makeResponse(request['action'], "FAILURE", "The user must be logged in to create chats", str(connection.getSessionId()))
			else:                                                             # We didn't recognize this query...
				clientResponse = util.makeResponse(request['action'], "FAILURE", "ACTION UNDEFINED", str(connection.getSessionId()))
			self.printInfo(clientResponse)
			return clientResponse
		return util.makeResponse("NO_DATA_RECIEVED", "FAILURE", "", str(connection.getSessionId()))
		#except Exception as e:
		#	return util.makeResponse("CRASH", "FAILURE", str(e), str(connection.getSessionId()))
		
	
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
			
			print "New connection from " + str(accepted[1][0]) + " along " + str(accepted[1][1])
			
			self.activeConnections.append(ConnectionController(self.clients[-1]))
			self.activeConnections[-1].setSessionId(self.sessionIdController.generateAndActivateSessionId())
			
			#Spawn the threads, the threads exit when the connection is closed.
			self.activeThreads.append(threading.Thread(target=self.activeConnections[-1].maintain, args=(self.processData,)))
			self.activeThreads[-1].daemon = True
			self.activeThreads[-1].start()

# Main function separate so this can run as a module
if __name__ == "__main__":
	instance = Server()
	instance.run()