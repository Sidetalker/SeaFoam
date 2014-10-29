import socket 
import util
import threading

# MAIN TODO: Connections should be retained rather than connect/close every message... 

# Client configuration
#host = '50.63.60.10' 
host = '127.0.0.1'
port = 534
size = 4096

# Create the socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

# Connect to the new socket
s.connect((host,port)) 

# Send the message
print "Connected to " + str(host) + " along port " + str(port)


active = True
sessionId = None
recieveThread = None
recievedData = []

# Send a message and print + return the response
def verboseSend(message):
	print "Sending Message:\n" + message
	s.send(message)
	for x in range(0, 100000):
		i = 1
	try:
		return recievedData[-1]
	except:
		return None
	
	
def readSocket():
	global active
	global recievedData
	while(active):
		# Receive the response
		data = s.recv(size)
		print "Revcieved: " + data
	print "Thread Exit"



# Test all login possibilities
#def testLogin():
#	if verboseSend('{action:LOGIN, args:Riley|super, sessionId:}') == None:
#		pass
#	if verboseSend('{action:MSG_CREATE, args:Kevin, sessionId:}') == None:
#		return False
#	if verboseSend('{action:MSG, args:Kevin|test, sessionId:}') == None:
#	return False
# 	if verboseSend('{action:LOGIN, args:Kevin|stupid, sessionId:}') == None:
# 		return False
# 	if verboseSend('{action:LOGIN, args:Riley|super, sessionId:}') == None:
# 		return False
# 	if verboseSend('{action:CREATE_ACCOUNT, args:Riley|super, sessionId:}') == None:
# 		return False
# 	if verboseSend('{action:LOGIN, args:Riley|super, sessionId:}') == None:
# 		return False
#	return True
	
def readInput(inputString):
	global sessionId
	if(inputString.lower().replace(" ", "") == "login"):
		username = raw_input("Please enter username\n>")
		password = raw_input("Please enter password\n>")
		response = verboseSend('{action:LOGIN, args:' + username + '|' + password + ', sessionId:' + str(sessionId) + '}')
		#parsedData = util.readRequest(response)
		#sessionId = int(parsedData['sessionId'])
	elif(inputString.lower().replace(" ", "") == "logout"):
		username = raw_input("Please enter username\n>")
		response = verboseSend('{action:LOGOUT, args:' + username + ', sessionId:' + str(sessionId) + '}')
	elif(inputString.lower().replace(" ", "") == "register"):
		username = raw_input("Please enter username\n>")
		password = raw_input("Please enter password\n>")
		response = verboseSend('{action:CREATE_ACCOUNT, args:' + username + '|' + password + ', sessionId:' + str(sessionId) + '}')
	elif(inputString.lower().replace(" ", "") == "msgcreate"):
		username = raw_input("Please enter target username\n>")
		response = verboseSend('{action:MSG_CREATE, args:' + username + ', sessionId:' + str(sessionId) + '}')
	elif(inputString.lower().replace(" ", "") == "msg"):
		chatDest = raw_input("Please enter target chat\n>")
		chatMessage = raw_input("Please enter chat\n>")
		response = verboseSend('{action:MSG, args:' + chatDest + '|' + chatMessage + ', sessionId:' + str(sessionId) + '}')

# Main function separate so this can be modulized	
def main():
	global active
	global recieveThread
	global recievedData
	
	recieveThread = threading.Thread(target=readSocket)
	recieveThread.daemon = True
	recieveThread.start()
	
	inputString = ""
	while(inputString != "quit"):
		inputString = raw_input("Command\n>")
		readInput(inputString)
	active = False
	s.close()

# Main function separate so this can run as a module
if __name__ == "__main__":
	main()
