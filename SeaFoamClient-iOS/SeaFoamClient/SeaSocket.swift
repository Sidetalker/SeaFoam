import Foundation

struct portResponse {
    var action: String
    var result: String
    var description: NSDictionary
    var userID: String
}

protocol SeaSocketDelegate {
    func connectedToSocket(message: String)
    func loginSent()
    func registerSent()
    func chatSent(type: String)
    func loginResponse(message: portResponse)
    func registerResponse(message: portResponse)
    func listChatResponse(chats: [ChatInfo])
    func addChatResponse(message: portResponse)
    func disconnectError(message: String)
}

class SeaSocket: GCDAsyncSocketDelegate {
    // Connection variables
    var socket: GCDAsyncSocket = GCDAsyncSocket()
    var host: NSString?
    var port: UInt16?
    var timeout: NSTimeInterval = 5
    
    // Data management variables
    var curTag = 0
    var tagDict = [Int : String]()
    var dataDict = [Int : NSData]()
    
    // Delegate
    var delegate: SeaSocketDelegate?
    
    init(host: NSString, port: UInt16) {
        // Store the initializer values
        self.host = host
        self.port = port
        
        // Initalize our asynchronous socket
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        DDLog.logInfo("GCDAsyncSocket created with delegate: \(self)")
        
//        tagDict[0] = "alert"
//        dataDict[0] = NSData()
//        socket.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: -1, tag: curTag)
//        curTag++
//        print("Alert tag read is ready\n")
    }
    
    // MARK: - Utility Functions
    
    // Connect to the host
    func connect() -> NSError? {
        DDLog.logInfo("Connection Initiated")
        
        // If we're already connected return nil
        if !socket.isDisconnected() {
            return nil
        }
        
        var connectionError: NSError?
        
        // If we have an error during connection initialization return that error
        if socket.connectToHost(host, onPort: port!, withTimeout: timeout, error: &connectionError) == false {
            DDLog.logError("Unable to connect to host \(host):\(port) - Error: \(connectionError.debugDescription)")
            return connectionError
        }
        return nil
    }

    // Send a message to the server
    func sendString(message: String, descriptor: String) -> Bool {
        print("Sending string with descriptor \(descriptor)\n")
        print("And the message: \(message)")
        
        // If the socket isn't connected we can't do jack
        if socket.isDisconnected() {
            return false
        }
        
        // Convert the string to NSData
        let dataMessage = stringToData(message)
        
        // Make sure the conversion was successful
        if dataMessage == nil {
            return false
        }
        
        // Create the tag used to track and store it in the dictionary
        let returnData: NSData! = NSData()
        
        tagDict[curTag] = descriptor
        dataDict[curTag] = returnData
        
        // Write the data to our socket connection
        socket.writeData(dataMessage, withTimeout: timeout, tag: curTag)
        
        // Set up the following read operation
        socket.readDataToData(GCDAsyncSocket.CRLFData(), withTimeout: timeout, tag: curTag)
        curTag++
        
        return true
    }
    
    func sendLogin(username: String, password: String) {
        let request = buildRequest("LOGIN", args: "\(username)|\(password)", userID: "")
        DDLog.logInfo("Logging in with: \(request)")
        
        sendString("\(request)", descriptor: "Login Request")
    }
    
    func sendRegister(username: String, password: String, email: String) {
        let request = buildRequest("CREATE_ACCOUNT", args: "\(username)|\(password)|\(email)", userID: "")
        DDLog.logInfo("Registering with: \(request)")
        
        sendString("\(request)", descriptor: "Register Request")
    }
    
    func sendMessage(userID: String, chatID: String, text: String) {
        let request = buildRequest("UPDATE_CHAT", args:"\(chatID)|\(text)", userID: "\(userID)")
        DDLog.logInfo("Updating chatroom \(chatID) with text: \(text)")
        
        sendString("\(request)", descriptor: "Update Chat Request")
    }
    
    func createChat(chatName: String, userID: String) {
        let request = buildRequest("ADD_CHAT", args: "\(chatName)", userID: "\(userID)")
        DDLog.logInfo("Creating chatroom \(chatName) for userID \(userID)")
        
        sendString("\(request)", descriptor: "Add Chat Request")
    }
    
    func removeChat(chatID: String, userID: String) {
        let request = buildRequest("REMOVE_CHAT", args: "\(chatID)", userID: "\(userID)")
        DDLog.logInfo("Removing chatroom \(chatID) for userID \(userID)")
        
        sendString("\(request)", descriptor: "Remove Chat Request")
    }
    
    func getChats(userID: String) {
        let request = buildRequest("LIST_CHATS", args: "", userID: userID)
        DDLog.logInfo("Requesting chats for userID \(userID)")
        
        sendString("\(request)", descriptor: "Chat List Request")
    }
    
    // MARK: - Helper Functions
    
    // Builds a request
    func buildRequest(action: String, args: String, userID: String) -> String {
        return "{action:\(action), args:\(args), userID:\(userID)}"
    }
    
    // Converts a String into NSData
    func stringToData(input: String) -> NSData? {
        return input.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    }
    
    // Convert NSData to a String
    func dataToString(input: NSData) -> String {
        return NSString(data: input, encoding: NSUTF8StringEncoding)!
    }
    
    // Convert NSData into a portResponse
    func dataToPortResponse(input: NSData) -> portResponse {
        // Prepare the portResponse variables
        var action = ""
        var result = ""
        var description = [:]
        var userID = ""
        
        var conversionError: NSError?
        let jsonData: NSDictionary = NSJSONSerialization.JSONObjectWithData(input, options: NSJSONReadingOptions.MutableContainers, error: &conversionError) as NSDictionary
        
        if conversionError != nil {
            DDLog.logInfo("Error parsing JSON: \(conversionError?.localizedDescription)")
        }
        
        DDLog.logInfo("Our JSON response is:\n\(jsonData)")
        
        action = jsonData.objectForKey("action") as String
        result = jsonData.objectForKey("result") as String
        description = jsonData.objectForKey("desc") as NSDictionary
        userID = jsonData.objectForKey("userID") as String
        
        return portResponse(action: action, result: result, description: description, userID: userID)
    }
    
    // MARK: - GCDAsyncSocket Delegates
    
    // Called upon successful socket connection
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        delegate?.connectedToSocket("Socket is connected to \(socket.connectedHost()):\(socket.connectedPort())")
    }
    
    // Called upon a successful write to the socket
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        DDLog.logInfo("Successfully wrote data with descriptor: \(tagDict[tag])")
        
        if tagDict[tag] == "Login Request" {
            delegate?.loginSent()
        }
        else if tagDict[tag] == "Register Request" {
            delegate?.registerSent()
        }
        else if tagDict[tag] == "Chat List Request" {
            delegate?.chatSent("Chat List Request")
        }
        else if tagDict[tag] == "Add Chat Request" {
            delegate?.chatSent("Add Chat Request")
        }
    }
    
    // Called upon a successful partial write to the socket
    func socket(sock: GCDAsyncSocket!, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        DDLog.logInfo("We wrote \(partialLength) for \(tag)")
    }
    
    // Called upon a successful read from the socket
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        DDLog.logInfo("We received \(dataToString(data)) with tag \(tag)")
        
        if tagDict[tag] == "Login Request" {
            delegate?.loginResponse(dataToPortResponse(data))
        }
        else if tagDict[tag] == "Register Request" {
            delegate?.registerResponse(dataToPortResponse(data))
        }
        else if tagDict[tag] == "Chat List Request" {
            let response = dataToPortResponse(data)
            var chatInfo = [ChatInfo]()
            
            for chat in response.description["info"] as Array<NSDictionary> {
                let id = chat.objectForKey("_id") as String
                let creator = chat.objectForKey("creator") as String
                let name = chat.objectForKey("name") as String
                let members = chat.objectForKey("members") as [String]
                
                chatInfo.append(ChatInfo(id: id, name: name, creator: creator, members: members))
            }
            
            delegate?.listChatResponse(chatInfo)
        }
        else if tagDict[tag] == "Add Chat Request" {
            delegate?.addChatResponse(dataToPortResponse(data))
        }
        else if tagDict[tag] == "alert" {
            print("Holy shit it looks like it actually fucking worked jesus this was way easier than I thought it would be!")
        }
    }
    
    // Called upon a successful partial read to the socket
    func socket(sock: GCDAsyncSocket!, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        DDLog.logInfo("We read partial of \(partialLength) bytes for \(tag)")
    }
    
    // Called if our write operation has a timeout
    func socket(sock: GCDAsyncSocket!, shouldTimeoutWriteWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        DDLog.logInfo("Oh boy, we hit the write timeout of \(elapsed) for \(tag) with only \(length) bytes")
        
        // Timeout interval - can be higher if we wanna wait for more data or something
        return 0
    }
    
    // Called of our read operation has a timeout
    func socket(sock: GCDAsyncSocket!, shouldTimeoutReadWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
            DDLog.logInfo("Oh boy, we hit the read timeout of \(elapsed) for \(tag) with only \(length) bytes")
            
            // Timeout interval - can be higher if we wanna wait for more data or something
            return 0
    }
    
    // Called upon a disconnect
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLog.logError("Disconnected from \(host!):\(port!) with Error: \(err.localizedDescription)")
        
        delegate?.disconnectError("\(err.localizedDescription)")
    }
}