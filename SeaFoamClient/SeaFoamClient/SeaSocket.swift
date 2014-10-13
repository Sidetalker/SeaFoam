//
//  SeaSocket.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/13/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation

class SeaSocket {
    var address = "localhost"
    var port = 5000
    var host: inputStream: nsin
}






var inputStream : NSInputStream?
var outputStream : NSOutputStream?

func connect() {
    var readStream : Unmanaged<CFReadStream>?
    var writeStream : Unmanaged<CFWriteStream>?
    let host : CFString = NSString(string: self.host)
    let port : UInt32 = UInt32(self.port)
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
    
    inputStream = readStream!.takeUnretainedValue()
    outputStream = writeStream!.takeUnretainedValue()
    
    inputStream!.delegate = self
    outputStream!.delegate = self
    
    inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    
    inputStream!.open()
    outputStream!.open()
}