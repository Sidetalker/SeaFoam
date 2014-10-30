import socket 

# Client configuration
host = '50.63.60.10' 
# host = '127.0.0.1'
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

	# Return the response
	return data

# Main function separate so this can be modulized	
def main():
	while True:
		print 'Select the test action:'
		print '(1) Login'
		print '(2) Create Account'
		print '(3) List chats'
		print '(4) List chat contents'
		print '(5) Add new chat'
		print '(6) Remove chat'
		print '(7) Add user to chat'
		print '(8) Remove user from chat'
		print '(9) Add message to chat'

		selection = int(raw_input('Make a selection: '))

		if selection == 1:
			username = raw_input('Username: ')
			password = raw_input('Password: ')
			if verboseSend('{action:LOGIN, args:' + username + '|' + password + ', userID:}') == None:
				print 'Failed'
		elif selection == 2:
			username = raw_input('Username: ')
			password = raw_input('Password: ')
			email = raw_input('Email: ')
			if verboseSend('{action:CREATE_ACCOUNT, args:' + username + '|' + password + '|' + email + ', userID:}') == None:
				print 'Failed'
			if verboseSend('{action:CREATE_ACCOUNT, args:Riley|super|email@email.com}') == None:
				print 'Failed'
		elif selection == 3:
			userID = raw_input('List chats for userID: ')
			if verboseSend('{action:LIST_CHATS, args:, userID:' + userID + '}') == None:
				print 'Failed'
		elif selection == 4:
			chatID = raw_input('List chats contents for chatID: ')
			if verboseSend('{action:LIST_CHAT_CONTENTS, args:' + chatID + ', userID:}') == None:
				print 'Failed'
		elif selection == 5:
			name = raw_input('Chat name: ')
			userID = raw_input('Chat creator userID: ')
			if verboseSend('{action:ADD_CHAT, args:' + name + ', userID:' + userID + '}') == None:
				print 'Failed'
		elif selection == 6:
			chatID = raw_input('ChatID: ')
			if verboseSend('{action:REMOVE_CHAT, args:' + chatID + ', userID:}') == None:
				print 'Failed'
		elif selection == 7:
			chatID = raw_input('ChatID: ')
			userID = raw_input('userID: ')
			if verboseSend('{action:ADD_CHAT_USER, args:' + chatID + ', userID: ' + userID + '}') == None:
				print 'Failed'
		elif selection == 8:
			chatID = raw_input('ChatID: ')
			userID = raw_input('userID: ')
			if verboseSend('{action:REMOVE_CHAT_USER, args:' + chatID + ', userID: ' + userID + '}') == None:
				print 'Failed'
		elif selection == 9:
			userID = raw_input('UserID: ')
			chatID = raw_input('ChatID: ')
			message = raw_input('Message: ')
			if verboseSend('{action:UPDATE_CHAT, args:' + chatID + '|' + message + ', userID:' + userID + '}') == None:
				print 'Failed'

# Main function separate so this can run as a module
if __name__ == "__main__":
	main()
