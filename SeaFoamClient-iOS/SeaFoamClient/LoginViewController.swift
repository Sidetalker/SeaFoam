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
    @IBOutlet var imageBG: UIImageView!
    
    // Dynamically created UI elements
    var blurView: UIVisualEffectView?
    var titleLabel: UILabel?
    var usernameField: UITextField?
    var passwordField: UITextField?
    var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize our logger
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDLog.logLevel = LogLevel.All
        DDLog.logInfo("Logger Initialized")
        
        // Add a tap recognizer to hide the keyboard as expected
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        // Initialize our connection manager (SeaSocket represent)
        myFoam = SeaSocket(host: "localhost", port: 5015)
        
        // Connect and check for errors
        if let error = myFoam?.connect() {
            DDLog.logError("Unable to connect - Error: \(error.localizedDescription)")
        }
        
        loginTests()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Add all of the custom UI elements
        addBlur()
        addTitle()
        addFields()
        addButton()
        
        // Smoothly animate our UI elements
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.blurView!.alpha = 0.9
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.titleLabel!.alpha = 0.8
            self.passwordField!.alpha = 0.8
            self.usernameField!.alpha = 0.8
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // NOTE: This currently makes a discrepancy between the launch image and home screen image
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - UI Element Generation

    // Generate the view controlling the background blur effect
    func addBlur() {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurView = UIVisualEffectView(effect: blur)
        
        blurView!.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        blurView!.alpha = 0.0
        
        self.view.addSubview(blurView!)
    }
    
    // Create the title text label
    func addTitle() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 130))
        
        titleLabel!.text = "SeaFoam"
        titleLabel!.font = UIFont(name: "HelveticaNeue-UltraLight", size: 60)
        titleLabel!.textColor = UIColor.whiteColor()
        titleLabel!.textAlignment = NSTextAlignment.Center
        titleLabel!.alpha = 0.0
        
        self.view.addSubview(titleLabel!)
    }
    
    // Create the username and password fields
    func addFields() {
        usernameField = getField(CGRect(x: 50, y: 140, width: self.view.frame.width - 100, height: 30), placeholder: "Username")
        passwordField = getField(CGRect(x: 50, y: 182, width: self.view.frame.width - 100, height: 30), placeholder: "Password")
        usernameField?.alpha = 0.0
        passwordField?.alpha = 0.0
        passwordField?.secureTextEntry = true
        
        self.view.addSubview(usernameField!)
        self.view.addSubview(passwordField!)
    }
    
    // Create the login button
    func addButton() {
        
    }
    
    // Get username and password fields provided frame
    func getField(frame: CGRect, placeholder: String) -> UITextField {
        let textField = UITextField(frame: frame)
        let placeholderString = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.7), NSFontAttributeName : UIFont(name: "HelveticaNeue-UltraLight", size: 14)])
        
        textField.attributedPlaceholder = placeholderString
        textField.font = UIFont(name: "HelveticaNeue", size: 14)
        textField.tintColor = UIColor.whiteColor()
        textField.textColor = UIColor.whiteColor()
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        textField.layer.borderWidth = 0.6
        textField.layer.cornerRadius = 7
        textField.clipsToBounds = true
        textField.alpha = 0.8
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = UITextFieldViewMode.Always
        
        let clearButton: UIButton = textField.valueForKey("_clearButton") as UIButton
        clearButton.setImage(UIImage(named: "ClearWhite.png"), forState: UIControlState.Normal)
        clearButton.setImage(UIImage(named: "ClearWhitePressed.png"), forState: UIControlState.Highlighted)
        
        return textField
    }
    
    func dismissKeyboard() {
        usernameField?.resignFirstResponder()
        passwordField?.resignFirstResponder()
    }
    
    // MARK: - Tests
    
    func loginTests() {
        // Send a test message (no delegates set up yet for checking completion)
        myFoam?.sendString("LOGIN - Kevin:test", descriptor: "Successful Login")
    }
    
    // MARK: - SeaSocket Delegates
    
    func connectedToSocket(message: String) {
        DDLog.logInfo(message)
    }
}

