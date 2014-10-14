import socket  
from pymongo import MongoClient

# Server configuration
host = 'localhost' 
port = 5008
backlog = 5 
size = 4096 
clients = []
addresses = []

# Get a handle on our MongoDB database
dbClient = MongoClient('mongodb://seafoam:seafoam@ds041140.mongolab.com:41140/seafoam')
db = dbClient.seafoam
users = db.users

# Create the socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

# Bind the socket and begin listening
s.bind((host,port)) 
s.listen(backlog) 

# Listen indefinitely
while 1: 
	# Accept an incoming connection, store the client socket and the conn address
	accepted = s.accept()
	clients.append(accepted[0])		# Socket
	addresses.append(accepted[1])	# Address
    
    # Receive the data (size = buffer)
	data = clients[-1].recv(size) 

    # Make sure the data was received properly
	if data: 
		if data[0:5] == 'LOGIN':
			username, password = data[8:].split(':')
			print 'Username: ' + username
			print 'Password: ' + password

			currentUser = users.find( {u'password' : password} )

			

			for password in allPasswords:
				print password

			print users.find_one()


    	# Echo it back to the client
		print 'Oooo I got: ' + data
		clients[-1].send(data) 

    # Close the current connection
	clients[-1].close()

	#'mongodb://seafoam:seafoam@ds041140.mongolab.com:41140/seafoam')