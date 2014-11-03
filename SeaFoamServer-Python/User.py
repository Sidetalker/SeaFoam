class User:
	def __init__(self, username, password, ID, email = None):
		self.__username = username
		self.__password = password
		self.__email = email
		self.__ID = ID
		
	def validatePassword(self, toValidate):
		return toValidate == self.__password
		
	def getUsername(self):
		return self.__username
		
	def getEmail(self):
		return self.__email
		
	def setEmail(self, newEmail):
		self.__email = newEmail
		
	def isUserID(self, ID):
		return ID == self.__ID
		
	def getUserID(self):
		return self.__ID
		
	def __str__(self):
		return "Username: " + str(self.__username) + ", ID: " + str(self.__ID)