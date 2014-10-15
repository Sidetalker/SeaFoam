//
//  ViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/13/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SeaSocketDelegate {
    // TCP connection variables
    var socket: GCDAsyncSocket?
    var myFoam: SeaSocket?
    
    // View outlets
    @IBOutlet var imageLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize our logger
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.logLevel = LogLevel.All
        DDLog.logInfo("Logger Initialized")
        
        // Initialize our connection manager (SeaSocket represent)
        myFoam = SeaSocket(host: "localhost", port: 5014)
        
        // Connect and check for errors
        if let error = myFoam?.connect() {
            DDLog.logError("Unable to connect - Error: \(error.localizedDescription)")
        }
        
        // Send a test message (no delegates set up yet for checking completion)
        myFoam?.sendString("Hello Worlds!", descriptor: "Simple hello world test message")
    }
    
    override func viewDidAppear(animated: Bool) {
                animateLogo()
//        self.imageLogo.image = UIImage(contentsOfFile: "SFLogo.png")
//        DDLog.logDebug("SDAF")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func animateLogo() {
        
        UIView.transitionWithView(self.imageLogo, duration: 3, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
            self.imageLogo.image = UIImage(contentsOfFile: "SFLogo.png")
            }, completion: {
                (value: Bool) in
        })
    }
    
    // MARK: - Tests
    
    
    
    // MARK: - SeaSocket Delegates
    
    func connectedToSocket(message: String) {
        DDLog.logInfo(message)
    }
}

