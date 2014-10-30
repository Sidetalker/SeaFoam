import json

def makeResponse(action, result, desc, userID):
	responseDict = { 'action' : action, 'result' : result, 'desc' : desc, 'userID' : userID }
	return json.dumps(responseDict)

def readData(data):
	#return json.loads(data)
	request = {}
	toEdit = data[:].replace("{", "").replace("}", "").replace(" ", "")
	items = toEdit.split(",")
	for item in items:
		data = item.split(":")
		request[data[0]] = data[1]
	return request
	
# Converts a cursor object (returned from MongoDB request)
# into a list by iterating over it (not super efficient)
def queryToList(cursorObject):
	myList = []
	for document in cursorObject:
		myList.append(document)
	return myList

# Prints a simple string along with address data
def printInfo(message):
	print(message + '\n')