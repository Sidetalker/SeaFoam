



class SessionIdController:
	def __init__(self, sessionCap = -1):
		self.maxSessions = sessionCap
		self.sessions = []
		self.bottom = 0
		
	def generateSessionId(self):
		while self.bottom in self.sessions:
			self.bottom += 1
		return self.bottom
		
	def activateSessionId(self, id):
		if (len(self.sessions) < self.maxSessions or self.maxSessions == -1) and id not in self.sessions:
			self.sessions.append(id)
			return True
		return False
		
	def generateAndActivateSessionId(self):
		id = None
		if len(self.sessions) < self.maxSessions or self.maxSessions == -1:
			id = self.generateSessionId()
			self.sessions.append(id)
		return id
		
	def deactivateSessionId(self, id):
		self.sessions.remove(id)
		
	def validate(self, id):
		return id in self.sessions
	