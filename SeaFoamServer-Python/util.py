


def makeResponse(action, result, desc, sessionId, params = []):
	result = '{action:' + action + ', result:' + result + ', desc:' + desc + ', sessionId:' + sessionId
	for x in xrange(0, len(params)):
		result += "," + str(params[x][0]) + ":" + str(params[x][1])
	return result + "}"

def readRequest(data):
	request = {}
	toEdit = data[:].replace("{", "").replace("}", "").replace(" ", "")
	items = toEdit.split(",")
	for item in items:
		data = item.split(":")
		request[data[0]] = data[1]
	return request
	
def getConnectionFromUsername(connections, username):
	for connection in connections:
		if connection.getUser() != None and connection.getUser().getUsername() == username:
			return connection
	return None
	
def getConnectionsFromUsernames(connections, usernames):
	results = []
	for connection in connections:
		if connection.getUser() != None and connection.getUser().getUsername() in usernames:
			results.append(connection)
	print results
	return results