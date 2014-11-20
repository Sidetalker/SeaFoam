//
//  ViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/13/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SeaSocketDelegate, UITextFieldDelegate {
    // TCP connection variables
    var myFoam: SeaSocket?
    var userID: String?
    
    // View outlets
    @IBOutlet var imageBG: UIImageView!
    
    // Dynamically created UI elements
    var blurView: UIVisualEffectView?
    var titleLabel: UILabel?
    var usernameField: UITextField?
    var passwordField: UITextField?
    var passwordConfirmField: UITextField?
    var emailField: UITextField?
    var loginButton: UIButton?
    var loginSpinner: UIActivityIndicatorView?
    
    // State flag (0: Login, 1: Register)
    var state = -1
    
    // Custom transition manager
    let transitionManager = TransitionManager()
    
    // MARK: - UIViewController overrides
    
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
//        myFoam = SeaSocket(host: "50.63.60.10", port: 534)
        myFoam = SeaSocket(host: "127.0.0.1", port: 534)
        myFoam!.delegate = self
        
        // Connect and check for errors
        if let error = myFoam?.connect() {
            DDLog.logError("Unable to connect - Error: \(error.localizedDescription)")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Don't reanimate everything if this isn't our first time here
        if state == -1 {
            state = 0
        }
        else {
            return
        }
        
        // Add all of the custom UI elements
        addBlur()
        addTitle()
        addFields()
        addButton()
        addSpinner()
        
        // Smoothly animate our UI elements
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.blurView!.alpha = 0.9
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.titleLabel!.alpha = 0.8
            self.passwordField!.alpha = 0.8
            self.usernameField!.alpha = 0.8
            self.loginButton!.alpha = 0.8
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

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
        
        usernameField?.returnKeyType = UIReturnKeyType.Next
        passwordField?.returnKeyType = UIReturnKeyType.Done
        usernameField?.alpha = 0.0
        passwordField?.alpha = 0.0
        passwordField?.secureTextEntry = true
        
        self.view.addSubview(usernameField!)
        self.view.addSubview(passwordField!)
    }
    
    // Create the login button
    func addButton() {
        loginButton = UIButton(frame: CGRect(x: 50, y: 224, width: self.view.frame.width - 100, height: 50))
        loginButton?.setAttributedTitle(NSAttributedString(string: "Float On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
        loginButton?.setAttributedTitle(NSAttributedString(string: "Float On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.lightGrayColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Highlighted)
        loginButton?.alpha = 0.0
        loginButton?.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton?.addTarget(self, action: "smoothAnim", forControlEvents: UIControlEvents.TouchDown)
        loginButton?.addTarget(self, action: "smoothAnimUndo", forControlEvents: UIControlEvents.TouchUpOutside)
        
        self.view.addSubview(loginButton!)
    }
    
    // These two functions take care of a tiny graphical inconsistency while fading out the Float On text
    func smoothAnim() {
        loginButton?.setAttributedTitle(NSAttributedString(string: loginButton!.titleLabel!.text!, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.lightGrayColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
    }
    
    func smoothAnimUndo() {
        loginButton?.setAttributedTitle(NSAttributedString(string: loginButton!.titleLabel!.text!, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
    }
    
    // Add the loading spinner
    func addSpinner() {
        loginSpinner = UIActivityIndicatorView(frame: CGRect(x: 50, y: 224, width: self.view.frame.width - 100, height: 50))
        loginSpinner?.alpha = 0.0
        
        self.view.addSubview(loginSpinner!)
    }
    
    // Get pretty transparent text fields provided frame and placeholder
    func getField(frame: CGRect, placeholder: String) -> UITextField {
        let textField = UITextField(frame: frame)
        let placeholderString = NSAttributedString(string: placeholder, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!)))
        
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
        textField.delegate = self
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.autocorrectionType = UITextAutocorrectionType.No
        
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
    
    // MARK: - Login functions
    
    // Initiate login
    func login() {
        // Make sure username and password are filled in
        var filled = true
        
        if usernameField?.text == "" {
            filled = false
            jiggle(usernameField!, 5, 10)
        }
        
        if passwordField?.text == "" {
            filled = false
            jiggle(passwordField!, 5, 10)
        }
        
        // Check additional conditions for registration
        if state == 1 {
            if passwordConfirmField?.text == "" {
                filled = false
                jiggle(passwordConfirmField!, 5, 10)
            }
            
            if emailField?.text == "" {
                filled = false
                jiggle(emailField!, 5, 10)
            }
            
            if passwordConfirmField?.text != passwordField?.text && filled {
                let messageDisplay = UIAlertController(title: "Registration Failed", message: "Passwords did not match", preferredStyle: UIAlertControllerStyle.Alert)
                messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
                    (alert: UIAlertAction!) in
                    jiggle(self.passwordField!, 5, 10)
                    jiggle(self.passwordConfirmField!, 5, 10)
                    self.passwordConfirmField?.text = ""
                    self.passwordField?.text = ""
                    self.passwordField?.becomeFirstResponder()
                }))
                presentViewController(messageDisplay, animated: true, completion: nil)
                
                filled = false
            }
            
            // Check for valid email
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            if emailTest!.evaluateWithObject(emailField!.text) == false {
                let messageDisplay = UIAlertController(title: "Registration Failed", message: "Invalid Email", preferredStyle: UIAlertControllerStyle.Alert)
                messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
                    (alert: UIAlertAction!) in
                    jiggle(self.emailField!, 5, 10)
                    self.emailField?.text = ""
                    self.emailField?.becomeFirstResponder()
                }))
                presentViewController(messageDisplay, animated: true, completion: nil)
                
                filled = false
            }
        }
        
        // Undo the smooth animation fix
        if !filled {
            loginButton?.setAttributedTitle(NSAttributedString(string: loginButton!.titleLabel!.text!, attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
            
            return
        }
        
        // Hide the keyboard
        dismissKeyboard()
        
        // Lock the textfields
        usernameField?.enabled = false
        passwordField?.enabled = false
        
        // Check additional conditions for registration
        if state == 1 {
            passwordConfirmField?.enabled = false
            emailField?.enabled = false
        }
        
        // Fade out the button and bring in the spinner
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loginButton!.alpha = 0.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loginSpinner?.startAnimating()
            self.loginSpinner!.alpha = 0.8
            }, completion: nil)
        
        if state == 0 {
            myFoam?.sendLogin(usernameField!.text, password: passwordField!.text)
        }
        else if state == 1 {
            myFoam?.sendRegister(usernameField!.text, password: passwordField!.text, email: emailField!.text)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField?.becomeFirstResponder()
            return false
        }
        else if textField == passwordField {
            if state == 0 {
                passwordField?.resignFirstResponder()
                login()
            }
            else if state == 1 {
                passwordConfirmField?.becomeFirstResponder()
            }
            return false
        }
        else if textField == passwordConfirmField {
            emailField?.becomeFirstResponder()
        }
        else if textField == emailField {
            emailField?.resignFirstResponder()
            login()
        }
        
        return true
    }
    
    // Transition to the login state
    func transitionToLogin() {
        // Change state
        state = 0
        
        passwordField?.returnKeyType = UIReturnKeyType.Done
        
        // Animate the elements back to their proper location
        UIView.animateWithDuration(0.8, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.passwordConfirmField!.frame = CGRect(x: 50, y: 182, width: self.view.frame.width - 100, height: 30)
            self.emailField!.frame = CGRect(x: 50, y: 182, width: self.view.frame.width - 100, height: 30)
            self.loginButton!.frame = CGRect(x: 50, y: 224, width: self.view.frame.width - 100, height: 30)
            self.loginSpinner!.frame = CGRect(x: 50, y: 224, width: self.view.frame.width - 100, height: 30)
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loginButton!.alpha = 0.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loginButton!.setAttributedTitle(NSAttributedString(string: "Float On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
            self.loginButton!.setAttributedTitle(NSAttributedString(string: "Float On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.lightGrayColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Highlighted)
            self.loginButton!.alpha = 0.8
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.passwordConfirmField!.alpha = 0.0
            self.emailField!.alpha = 0.0
            }, completion: nil)
    }
    
    // Transition to the register state
    func transitionToRegister() {
        // Change state
        state = 1
        
        // Add the two extra fields
        if passwordConfirmField == nil {
            passwordConfirmField = getField(CGRect(x: 50, y: 182, width: self.view.frame.width - 100, height: 30), placeholder: "Confirm Password")
            passwordField?.returnKeyType = UIReturnKeyType.Next
            passwordConfirmField?.returnKeyType = UIReturnKeyType.Next
            passwordConfirmField?.secureTextEntry = true
        }
        if emailField == nil {
            emailField = getField(CGRect(x: 50, y: 182, width: self.view.frame.width - 100, height: 30), placeholder: "Email")
            emailField?.returnKeyType = UIReturnKeyType.Done
            emailField?.keyboardType = UIKeyboardType.EmailAddress
        }
        
        passwordConfirmField?.alpha = 0.0
        emailField?.alpha = 0.0
        
        self.view.addSubview(passwordConfirmField!)
        self.view.addSubview(emailField!)
        
        // Animate the new elements
        UIView.animateWithDuration(0.8, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.passwordConfirmField!.frame = CGRect(x: 50, y: 224, width: self.view.frame.width - 100, height: 30)
            self.emailField!.frame = CGRect(x: 50, y: 266, width: self.view.frame.width - 100, height: 30)
            self.loginButton!.frame = CGRect(x: 50, y: 308, width: self.view.frame.width - 100, height: 30)
            self.loginSpinner!.frame = CGRect(x: 50, y: 308, width: self.view.frame.width - 100, height: 30)
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loginButton!.alpha = 0.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.4, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loginButton!.setAttributedTitle(NSAttributedString(string: "Ride the Waves", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
            self.loginButton!.setAttributedTitle(NSAttributedString(string: "Ride the Waves", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.lightGrayColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Highlighted)
            self.loginButton!.alpha = 0.8
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.passwordConfirmField!.alpha = 0.8
            self.emailField!.alpha = 0.8
            }, completion: nil)
    }
    
    // Use our custom transition manager
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatSegue" {
            // Get handles on the navigation controller and embedded chat list controller
            let navVC = segue.destinationViewController as UINavigationController
            let chatVC = navVC.viewControllers[0] as MainTableViewController
            
            // Pass the userID and the SeaSocket object down to the chat list controller
            chatVC.userID = userID
            chatVC.userName = usernameField?.text
            chatVC.myFoam = myFoam
            chatVC.loginParent = self
            
            // Set up custom segue animations
            navVC.transitioningDelegate = transitionManager
        }
    }
    
    // MARK: - SeaSocket Delegates
    
    func connectedToSocket(message: String) {
        DDLog.logInfo(message)
    }
    
    func loginSent() {
        DDLog.logInfo("Successfully sent login request")
    }
    
    func registerSent() {
        DDLog.logInfo("Successfully sent register request")
    }
    
    func registerResponse(message: portResponse) {
        DDLog.logInfo("Received register response: \(message)")
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loginSpinner?.stopAnimating()
            self.loginSpinner!.alpha = 0.0
            }, completion: nil)
        
        let messageDisplay = UIAlertController(title: "Registration Successful", message: "Created new user: \(self.usernameField!.text)", preferredStyle: UIAlertControllerStyle.Alert)
        messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) in
            self.transitionToLogin()
        }))
        presentViewController(messageDisplay, animated: true, completion: nil)
    }
    
    func loginResponse(message: portResponse) {
        DDLog.logInfo("Received login response: \(message)")
        
        // Bring the button back!
        loginButton?.setAttributedTitle(NSAttributedString(string: "Float On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
        
        // Enable the text fields
        usernameField?.enabled = true
        passwordField?.enabled = true
        passwordConfirmField?.enabled = true
        emailField?.enabled = true
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loginSpinner?.stopAnimating()
            self.loginSpinner!.alpha = 0.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loginButton!.alpha = 0.8
            }, completion: nil)
        
        if message.result == "SUCCESS" {
            self.userID = message.userID
            performSegueWithIdentifier("chatSegue", sender: self)
            
            return
        }
        else if message.result == "FAILURE-PW" {
            let messageDisplay = UIAlertController(title: "Login Failed", message: "Incorrect Password", preferredStyle: UIAlertControllerStyle.Alert)
            messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
                (alert: UIAlertAction!) in
                self.passwordField?.text = ""
                self.passwordField?.becomeFirstResponder()
                jiggle(self.passwordField!, 5, 10)
            }))
            presentViewController(messageDisplay, animated: true, completion: nil)
        }
        else if message.result == "FAILURE-UN" {
            let messageDisplay = UIAlertController(title: "Login Failed", message: "Incorrect Username", preferredStyle: UIAlertControllerStyle.Alert)
            messageDisplay.addAction(UIAlertAction(title: "Create User", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) in
                self.transitionToRegister()
            }))
            messageDisplay.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(messageDisplay, animated: true, completion: nil)
        }
        else {
            let messageDisplay = UIAlertController(title: "Login Response", message: "\(message.description)", preferredStyle: UIAlertControllerStyle.Alert)
            messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(messageDisplay, animated: true, completion: nil)
        }
    }
    
    func disconnectError(message: String) {
        // Bring the button back!
        loginButton?.setAttributedTitle(NSAttributedString(string: "Float On", attributes: Dictionary(dictionaryLiteral: (NSForegroundColorAttributeName, UIColor.whiteColor().colorWithAlphaComponent(0.8)), (NSFontAttributeName, UIFont(name: "HelveticaNeue-UltraLight", size: 23)!))), forState: UIControlState.Normal)
        
        // Enable the text fields
        usernameField?.enabled = true
        passwordField?.enabled = true
        passwordConfirmField?.enabled = true
        emailField?.enabled = true
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.loginSpinner?.stopAnimating()
            self.loginSpinner!.alpha = 0.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.7, delay: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.loginButton!.alpha = 0.8
            }, completion: nil)
        
        let messageDisplay = UIAlertController(title: "Disconnect Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        messageDisplay.addAction(UIAlertAction(title: "Ok :(", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(messageDisplay, animated: true, completion: nil)
    }
    
    // MARK: - Unused SeaSocket Delegates
    // These will be removed if Swift implements option protocol functions natively
    
    func chatSent(type: String) {
        return
    }
    
    func listChatResponse(chats: [ChatInfo]) {
        return
    }
    
    func addChatResponse(message: portResponse) {
        return
    }
}

