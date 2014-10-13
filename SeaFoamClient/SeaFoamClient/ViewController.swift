//
//  ViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/13/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GCDAsyncSocketDelegate {
    var socket: GCDAsyncSocket?
    var myFoam: SeaSocket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.logLevel = LogLevel.All
        DDLog.logInfo("Logger Initialized")
        
        myFoam = SeaSocket(host: "localhost", port: 5000)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

