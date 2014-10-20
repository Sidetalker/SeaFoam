import socket  
from pymongo import MongoClient

# Global Server configuration
host = '50.63.60.10' 
port = 505
backlog = 5 
size = 4096 
clients = []
addresses = []

# Converts a cursor object (returned from MongoDB request)
# into a list by iterating over it (not super efficient)
def queryToList(cursorObject):
	myList = []

	for document in cursorObject:
		myList.append(document)

	return myList

# Prints a simple string along with address data
def printInfo(message):
	print 'Address: ' + addresses[-1][0] + ':' + addresses[-1][1]
	print message + '\n'

def main():
	# Get a handle on our MongoDB database
	dbClient = MongoClient('mongodb://seafoam:seafoam@ds041140.mongolab.com:41140/seafoam')
	db = dbClient.seafoam
	users = db.users

	print 'Connected to MongoDB successfully'

	# Create the socket
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

	# Bind the socket and begin listening
	s.bind((host,port)) 
	s.listen(backlog) 

	print 'Server is listening on port ' + str(port)

	# Listen indefinitely
	while 1: 
		# Accept an incoming connection, store the client socket and the conn address
		accepted = s.accept()
		clients.append(accepted[0])		
		addresses.append((str(accepted[1][0]), str(accepted[1][1])))
	    # TODO I converted to string to save work later - might not wanna

	    # Receive the data (size = buffer)
		data = clients[-1].recv(size) 

		print data

	    # Make sure the data was received properly
		if data: 
			clientResponse = '' # Initialize a response container

			# If we've found the login tag...
			if data[0:5] == 'LOGIN':
				# Extract the username and password
				username, password = data[8:].split(':')
				print 'Username: ' + username
				print 'Password: ' + password

				# Query the database for the provide username/password combo
				dbResponse = queryToList(users.find({ 'username' : username, 'password' : password }))
				
				# We received multiple responses - this should be possible
				if len(dbResponse) > 1:
					clientResponse = 'ERROR - We received multiple results for the username ' + username + \
					'this should not be possible unless user was added manually'

					printInfo(clientResponse)
				# We didn't receive any responses...
				elif len(dbResponse) == 0:
					# Check the database for that username (forgotten password)
					# TODO - prompt the user on account creation with that userna,e
					if users.find_one({ 'username': username }) == None:
						clientResponse = 'No user found for username (create option?) ' + username
					else:
						clientResponse = 'Incorrect password for username ' + username

					printInfo(clientResponse)
				# This is the result we expect - it indicates a successful login
				elif len(dbResponse) == 1:
					clientResponse = 'You just got LOGGED THE FUCK ON'
					printInfo(clientResponse)
				# This happens if the cursor object has negative documents - probably impossible
				else:
					clientResponse = 'ERROR: This statement should be impossible to reach'
					printInfo(clientResponse)
			# We didn't recognize this query...
			else:
				clientResponse = 'ERROR: Did not recognize tag'
				printInfo(clientResponse)

	    	# Respond to the client
			clients[-1].send(clientResponse) 

	    # Close the current connection
		clients[-1].close()

# Main function separate so this can run as a module
if __name__ == "__main__":
    main()