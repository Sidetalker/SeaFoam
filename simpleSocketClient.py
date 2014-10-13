import socket 

# Client configuration
host = 'localhost' 
port = 5000
size = 4096

# Create the socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

# Connect to the specified socket
s.connect((host,port)) 

# Send some text data
s.send('Hello, world')
s.send(' - This should be appended to the stream')

# Wait for a response and store it (size = buffer) 
data = s.recv(size) 

# Close the socket
s.close() 

# Display result
print 'Received:', data