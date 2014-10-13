import socket

# Server configuration
host = 'localhost' 
port = 5000
backlog = 5 
size = 4096 
client = None

# Create the socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

# Bind the socket and begin listening
s.bind((host,port)) 
s.listen(backlog) 

# Listen indefinitely
while 1: 
	# Accept an incoming connection, store the
	# socket object (client) and the conn address
	client, address = s.accept() 
    
    # Receive the data (size = buffer)
	data = client.recv(size) 

    # Make sure the data was received properly
	if data: 
    	# Echo it back to the client
		print 'Oooo I got: ' + data
		client.send(data) 

    # Close the current connection
	client.close()