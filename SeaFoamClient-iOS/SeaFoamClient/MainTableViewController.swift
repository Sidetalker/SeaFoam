//
//  MainTableViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/29/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

struct chatInfo {
    var id: String
    var name: String
    var creator: String
    var members: [String]
    var messages: [[String : String]]
}

class MainTableViewController: UITableViewController, SeaSocketDelegate {
    // TCP Connection variables (inherited from LoginViewController)
    var loginParent: LoginViewController?
    var myFoam: SeaSocket?
    var userID: String?
    
    var chats: [chatInfo]?
    var chatsTest: Array<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.toolbarHidden = false;

        myFoam?.delegate = self
        myFoam?.getChats(userID!)
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
                jiggle(messageTextField)
                self.presentViewController(messageDisplay, animated: true, completion: nil)
            }
        }))
        self.presentViewController(messageDisplay, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chatsTest != nil {
            return chatsTest!.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell") as UITableViewCell
        
        cell.textLabel.text = chatsTest![indexPath.row]

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    func listChatResponse(chats: Array<String>) {
        DDLog.logInfo("Received chat list response: \(chats)")
        
        var initialChatCount = 0
        
        if self.chatsTest != nil {
            initialChatCount = self.chatsTest!.count
        }
        
        self.tableView.beginUpdates()
        chatsTest = chats
        
        if chatsTest?.count == 0 {
            self.tableView.endUpdates()
            return
        }
        
        for index in initialChatCount...chatsTest!.count - 1 {
            let curIndex = NSIndexPath(forRow: initialChatCount, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([curIndex], withRowAnimation: UITableViewRowAnimation.Fade)
            initialChatCount++
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
    // These will be removed if Swift implements option protocol functions natively
    
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
