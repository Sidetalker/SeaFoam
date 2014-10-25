import socket  
import threading
from pymongo import MongoClient
from SessionIdController import *
from ConnectionController import *


'''
The response framwork is below, this is the format for the responses that the server will be sending
{action:LOGIN, result:SUCCESS, desc:, sessionId:1234}
{action:LOGIN, result:FAILURE, desc:We couldnt do it, sessionId:}
{action:MSG,   result:sender|content, sessionId:1234}

This is the message framework, this is the format the server will now be recieving messages in
{action:LOGIN, args:username|password, sessionId:}
{action:MSG, args:dest|content, sessionId:1234}
'''

class Server:
	def __init__(self):
		# Global Server configuration
		self.host = '50.63.60.10' 
		#self.host = '127.0.0.1'
		self.port = 534
		self.backlog = 5 
		self.size = 4096 
		
		self.clients = []
		self.addresses = []
		self.activeConnections = []
		self.activeThreads = []
		
		# Get a handle on our MongoDB database
		dbClient = MongoClient('mongodb://seafoam:seafoam@ds041140.mongolab.com:41140/seafoam')
		db = dbClient.seafoam
		self.users = db.users
		print('Connected to MongoDB successfully')
		
		self.sessionIdController = SessionIdController()
		
	def makeResponse(self, action, result, desc, sessionId):
		return '{action:' + action + ', result:' + result + ', desc:' + desc + ', sessionId:' + sessionId + '}'
	
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
		for document in cursorObject:
			myList.append(document)
		return myList
		
		
	# Prints a simple string along with address data
	def printInfo(self, message):
		print('Address: ' + self.addresses[-1][0] + ':' + self.addresses[-1][1])
		print(message + '\n')
		
	def processData(self, data):
		if data:                                                              # Make sure the data was received properly
			request = self.readData(data)
			clientResponse = ''                                               # Initialize a response container
			if request['action'] == 'LOGIN':                                  # If we've found the login tag...
				username, password = request["args"].split('|')               # Extract the username and password
				print('Username: ' + username)
				print('Password: ' + password)
				dbResponse = self.queryToList(self.users.find({ 'username' : username, 'password' : password }))  # Query the database for the provide username/password combo
				if len(dbResponse) > 1:                                       # We received multiple responses - this should be possible
					clientResponse = self.makeResponse("LOGIN", "FAILURE", "We received multiple results for the username" + username, "")
					self.printInfo(clientResponse)
				elif len(dbResponse) == 0:                                    # We didn't receive any responses...
					if self.users.find_one({ 'username': username }) == None:      # Check the database for that username (forgotten password)
						clientResponse = self.makeResponse("LOGIN", "FAILURE", "No user found for username (create option?) " + username, "")
					else:
						clientResponse = self.makeResponse("LOGIN", "FAILURE", "Incorrect password for username " + username, "")
					self.printInfo(clientResponse)
				elif len(dbResponse) == 1:                                    # This is the result we expect - it indicates a successful login
					clientResponse = self.makeResponse("LOGIN", "SUCCESS", "You just logged THE FUCK ON", str(self.sessionIdController.generateAndActivateSessionId()))
					self.printInfo(clientResponse)
				else:                                                         # This happens if the cursor object has negative documents - probably impossible
					clientResponse = self.makeResponse("LOGIN", "FAILURE", "UNKNOWN ERROR - STATEMENT UNREACHABLE", "")
					self.printInfo(clientResponse)
			else:                                                             # We didn't recognize this query...
				clientResponse = self.makeResponse("UNKNOWN", "UNKNOWN", "UNKNOWN", "")
				self.printInfo(clientResponse)
			return clientResponse
		return ''
		
	
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
			
			self.activeConnections.append(ConnectionController(self.clients[-1]))
			
			#Spawn the threads, the threads exit when the connection is closed.
			self.activeThreads.append(threading.Thread(target=self.activeConnections[-1].maintain, args=(self.processData,)))
			self.activeThreads[-1].daemon = True
			self.activeThreads[-1].start()

# Main function separate so this can run as a module
if __name__ == "__main__":
	instance = Server()
	instance.run()