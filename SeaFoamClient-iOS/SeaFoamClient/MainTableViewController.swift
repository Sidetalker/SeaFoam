//
//  MainTableViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/29/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

struct ChatInfo {
    var id: String
    var name: String
    var creator: String
    var members: [String]
}

class MainTableViewController: UITableViewController, SeaSocketDelegate {
    // TCP Connection variables (inherited from LoginViewController)
    var loginParent: LoginViewController?
    var myFoam: SeaSocket?
    var userID: String?
    var userName: String?
    
    // Chatroom information
    var myChats = [ChatInfo]()
    var otherChats = [ChatInfo]()
    var curChat: ChatInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        myFoam?.delegate = self
        myFoam?.getChats(userID!)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Buttons
    
    @IBAction func logoutTap(sender: AnyObject) {
        self.loginParent?.myFoam?.delegate = loginParent
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newChatTap(sender: AnyObject) {
        let messageDisplay = UIAlertController(title: "Create Chatroom", message: "Enter the name of your new chatroom", preferredStyle: UIAlertControllerStyle.Alert)
        
        messageDisplay.addTextFieldWithConfigurationHandler { textField in }
        let messageTextField = messageDisplay.textFields![0] as UITextField
        messageTextField.placeholder = "Chatroom Name"
        
        messageDisplay.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) in
            if messageTextField.text != "" {
                self.myFoam?.createChat(messageTextField.text, userID: self.userID!)
            }
            else {
                messageDisplay.message = "You must enter a name for your chatroom"
                self.presentViewController(messageDisplay, animated: true, completion: nil)
            }
        }))
        
        messageDisplay.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) in
        }))
        
        self.presentViewController(messageDisplay, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return myChats.count
        case 1:
            return otherChats.count
        default: ()
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Owned Chatrooms"
        case 1:
            return "Joined Chatrooms"
        default: ()
        }
        
        return "You like this shit? I bet you love it you dirty little fiend"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell") as UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell.textLabel.text = myChats[indexPath.row].name
        case 1:
            cell.textLabel.text = otherChats[indexPath.row].name
        default: ()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Did select row at index path \(indexPath)\n")
        
        if indexPath.section == 0 {
            curChat = myChats[indexPath.row]
        }
        else if indexPath.section == 1 {
            curChat = otherChats[indexPath.row]
        }
        
        performSegueWithIdentifier("chatDetailSegue", sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            return
        }
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            myFoam?.removeChat(myChats[indexPath.row].id, userID: userID!)
            
            self.tableView.beginUpdates()
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            myChats.removeAtIndex(indexPath.row)
            
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatDetailSegue" {
            let chatDetailVC = segue.destinationViewController as ChatViewController
            
            chatDetailVC.myFoam = myFoam!
            chatDetailVC.id = userID
            chatDetailVC.displayName = userName
            chatDetailVC.chatInfo = curChat!
            chatDetailVC.navTitle.title = curChat!.name
        }
    }
    
    // MARK: - SeaSocket Delegates
    
    func connectedToSocket(message: String) {
        DDLog.logInfo(message)
    }
    
    func disconnectError(message: String) {
        DDLog.logInfo(message)
    }
    
    func chatSent(type: String) {
        DDLog.logInfo("Initiatied chat request of type: \(type)")
    }
    
    func listChatResponse(chats: [ChatInfo]) {
        DDLog.logInfo("Received chat list response")
        
        let initialMyChatCount = myChats.count
        let initialOtherChatCount = otherChats.count
        
        self.tableView.beginUpdates()
        
        myChats.removeAll(keepCapacity: false)
        otherChats.removeAll(keepCapacity: false)
        
        for chat in chats {
            if chat.creator == userID {
                myChats.append(chat)
            }
            else {
                otherChats.append(chat)
            }
        }
        
        if (myChats.count + otherChats.count) == 0 {
            self.tableView.endUpdates()
            return
        }
        
        if myChats.count != 0 {
            for index in initialMyChatCount...myChats.count - 1 {
                let curIndex = NSIndexPath(forRow: index, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([curIndex], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
        if otherChats.count != 0 {
            for index in initialOtherChatCount...otherChats.count - 1 {
                let curIndex = NSIndexPath(forRow: index, inSection: 1)
                self.tableView.insertRowsAtIndexPaths([curIndex], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        
        self.tableView.endUpdates()
    }
    
    func addChatResponse(message: portResponse) {
        DDLog.logInfo("Received add chat response: \(message)")
        
        if message.result == "FAILURE" {
            let messageDisplay = UIAlertController(title: "Failure", message: "Unable to create chatroom", preferredStyle: UIAlertControllerStyle.Alert)
            
            messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) in
            }))
            self.presentViewController(messageDisplay, animated: true, completion: nil)
        }
        
        myFoam?.getChats(userID!)
    }
    
    // MARK: - Unused SeaSocket Delegates
    // These will be removed if Swift implements optional protocol functions
    
    func loginSent() {
        return
    }
    
    func registerSent() {
        return
    }
    
    func registerResponse(message: portResponse) {
        return
    }
    
    func loginResponse(message: portResponse) {
        return
    }
}
