import Foundation

protocol SeaSocketDelegate {
    func connectedToSocket(message: String)
    func loginSent()
    func loginResponse(message: String)
    func disconnectError(message: String)
}

class SeaSocket: GCDAsyncSocketDelegate {
    // Connection variables
    var socket: GCDAsyncSocket = GCDAsyncSocket()
    var host: NSString?
    var port: UInt16?
    var timeout: NSTimeInterval = 2
    
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
        if socket.connectToHost(host, onPort: port!, error: &connectionError) == false {
            DDLog.logError("Unable to connect to host \(host):\(port) - Error: \(connectionError.debugDescription)")
            return connectionError
        }
        
        return nil
    }

    // Send a message to the server
    func sendString(message: String, descriptor: String) -> Bool {
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
        socket.readDataWithTimeout(timeout, tag: curTag)
        
        curTag++
        
        return true
    }
    
    func sendLogin(username: String, password: String) {
        let request = "LOGIN - \(username):\(password)"
        
        sendString(request, descriptor: "Login Request")
    }
    
    // MARK: - Helper Functions
    
    // Converts a string into NSData
    func stringToData(input: String) -> NSData? {
        return input.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    }
    
    // Converst NSData to a string 
    func dataToString(input: NSData) -> String? {
        return NSString(data: input, encoding: NSUTF8StringEncoding)
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
    }
    
    // Called upon a successful partial write to the socket
    func socket(sock: GCDAsyncSocket!, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        DDLog.logInfo("We wrote \(partialLength) for \(tag)")
    }
    
    // Called upon a successful read from the socket
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        DDLog.logInfo("We received \(dataToString(data)) with tag \(tag)")
        
        if tagDict[tag] == "Login Request" {
            delegate?.loginResponse("\(dataToString(data)!)")
        }
    }
    
    // Called upon a successful partial read to the socket
    func socket(sock: GCDAsyncSocket!, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        DDLog.logInfo("We wrote \(partialLength) for \(tag)")
    }
    
    // Called if our write operation has a timeout
    func socket(sock: GCDAsyncSocket!, shouldTimeoutWriteWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        DDLog.logInfo("Oh boy, we hit the timeout of \(elapsed) for \(tag) with only \(length) bytes")
        
        // Timeout interval - can be higher if we wanna wait for more data or something
        return 0
    }
    
    // Called upon a disconnect
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLog.logError("Disconnected from \(host!):\(port!) with Error: \(err.localizedDescription)")
        
        delegate?.disconnectError("\(err.localizedDescription)")
    }
}