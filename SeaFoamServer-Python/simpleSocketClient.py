import socket 

# MAIN TODO: Connections should be retained rather than connect/close every message... 

# Client configuration
host = '50.63.60.10' 
#host = '127.0.0.1'
port = 534
size = 4096

# Send a message and print + return the response
def verboseSend(message):
	# Create the socket
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

	# Connect to the new socket
	s.connect((host,port)) 

	# Send the message
	print 'Sending: ' + message
	s.send(message)

	# Receive the response
	data = s.recv(size)
	print 'Received: ' + data
	print

	# Close the socket
	s.close()

	# Return the response
	return data

# Test all login possibilities
def testLogin():
	if verboseSend('{action:LOGIN, args:Kevin|test, sessionId:}') == None:
		return False
	if verboseSend('{action:LOGIN, args:Kevin|stupid, sessionId:}') == None:
		return False
	if verboseSend('{action:LOGIN, args:Riley|super, sessionId:}') == None:
		return False

	return True

# Main function separate so this can be modulized	
def main():
	if testLogin():
		print 'We passed all login tests, great job!'

# Main function separate so this can run as a module
if __name__ == "__main__":
	main()
