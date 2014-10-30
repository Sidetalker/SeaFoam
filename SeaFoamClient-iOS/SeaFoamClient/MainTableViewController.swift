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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if chatsTest != nil {
            return 1
        }
        
        return 0
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
    
    func chatSent() {
        DDLog.logInfo("Initiatied chat list request")
    }
    
    func chatResponse(chats: Array<String>) {
        DDLog.logInfo("Received chat list response: \(chats)")
        chatsTest = chats
        self.tableView.reloadData()
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
