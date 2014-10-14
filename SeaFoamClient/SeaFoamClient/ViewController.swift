//
//  ViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/13/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SeaSocketDelegate {
    var socket: GCDAsyncSocket?
    var myFoam: SeaSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.logLevel = LogLevel.All
        DDLog.logInfo("Logger Initialized")
        
        // This should be defined somewhere locally that can be accessed without a connection
        myFoam = SeaSocket(host: "localhost", port: 5000)
        
        // Connect and check for errors
        if let error = myFoam?.connect() {
            DDLog.logError("Unable to connect - Error: \(error.localizedDescription)")
        }
        
        // Send a test message (no delegates set up yet for checking completion)
        myFoam?.sendString("Hello Worlds!", descriptor: "Simple hello world test message")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SeaSocket Delegates
    
    func connectedToSocket(message: String) {
        DDLog.logInfo(message)
    }
}

