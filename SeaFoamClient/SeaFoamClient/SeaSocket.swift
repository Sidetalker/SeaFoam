//
//  SeaSocket.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/13/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation

class SeaSocket: GCDAsyncSocketDelegate {
    var socket: GCDAsyncSocket = GCDAsyncSocket()
    let host: NSString?
    let port: UInt16?
    
    init(host: NSString, port: UInt16) {
        // Store the initializer values
        self.host = host
        self.port = port
        
        // Initalize our asynchronous socket
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        DDLog.logInfo("GCDAsyncSocket created with delegate: \(self)")
        
        var connectionError: NSError?
        
        // Attempt to connect to the specified host/port
        if socket.connectToHost(host, onPort: port, error: &connectionError) == false {
            DDLog.logError("Unable to connect to host \(host):\(port) - Error: \(connectionError.debugDescription)")
            return
        }
        
        // Write something simple to the socket
        let message = "Hello iOS World!"
        let messageData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        socket.writeData(messageData, withTimeout: 2, tag: 0)
        
        DDLog.logInfo("Sending data to \(host):\(port)")
    }
    
    // Called upon successful socket connection
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
         DDLog.logInfo("Socket is connected to \(socket.connectedHost()):\(socket.connectedPort())")
    }
    
    // Called upon a successful write to the socket
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        DDLog.logInfo("Successfully wrote data with tag: \(tag)")
    }
    
    // Called upon a successful partial write to the socket
    func socket(sock: GCDAsyncSocket!, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        DDLog.logInfo("We wrote \(partialLength) for \(tag)")
    }
    
    // Called if our write operation has a timeout
    func socket(sock: GCDAsyncSocket!, shouldTimeoutWriteWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        DDLog.logInfo("Oh boy, we hit the timeout of \(elapsed) for \(tag) with only \(length) bytes")
        return 0
    }
    
    // Called upon a disconnect
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        DDLog.logError("Disconnected from \(host):\(port) with Error: \(err.localizedDescription)")
    }
}