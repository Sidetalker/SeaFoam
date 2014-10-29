

class User:
	def __init__(self, username, password, isLoggedIn = True):
		self.__username = username
		self.__password = password
		self.__isLoggedIn = isLoggedIn
		
	def validatePassword(self, toValidate):
		return toValidate == self.__password
		
	def getUsername(self):
		return self.__username
		
	def isLoggedIn(self):
		return self.__isLoggedIn
		
	def makeLoggedOut(self):
		self.__isLoggedIn = False
		
	def makeLoggedIn(self):
		self.__isLoggedIn = True
		
		