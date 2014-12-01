//
//  ChatViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/24/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController, JSQMessagesCollectionViewDataSource, SeaSocketDelegate {
    var displayName: String?
    var id: String?
    var chatInfo: ChatInfo?
    var myFoam: SeaSocket?
    var messageData = ChatData()
    
    @IBOutlet var btnAddUser: UIBarButtonItem!
    @IBOutlet var navTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = false
        
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        myFoam?.delegate = self
        myFoam?.getChatContents(id!, chatID: chatInfo!.id)
    }
    
    @IBAction func btnCommand(sender: AnyObject) {
        if btnAddUser.title == "Leave Chat" {
            myFoam!.removeChat(chatInfo!.id, userID: id!)
            self.navigationController?.popViewControllerAnimated(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else if btnAddUser.title == "Add User" {
            let messageDisplay = UIAlertController(title: "Add User", message: "Enter the new user's name", preferredStyle: UIAlertControllerStyle.Alert)
            
            messageDisplay.addTextFieldWithConfigurationHandler { textField in }
            let messageTextField = messageDisplay.textFields![0] as UITextField
            messageTextField.placeholder = "User's Name"
            
            messageDisplay.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) in
                if messageTextField.text != "" {
                    self.myFoam!.addChatUser(self.chatInfo!.id, userID: messageTextField.text)
                    
                    let messageDisplay = UIAlertController(title: "Success!", message: "Added \(messageTextField.text) to the chatroom", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    messageDisplay.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                        (alert: UIAlertAction!) in
                    }))
                    self.presentViewController(messageDisplay, animated: true, completion: nil)
                }
                else {
                    messageDisplay.message = "You must enter a name"
                    self.presentViewController(messageDisplay, animated: true, completion: nil)
                }
            }))
            
            messageDisplay.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (alert: UIAlertAction!) in
            }))
            
            self.presentViewController(messageDisplay, animated: true, completion: nil)
        }
        else {
            print("This is a mighty weird bigish smally problem!\n")
        }
    }
    
    func chatContentResponse(message: portResponse) {
        for mes in message.description["info"] as Array<NSDictionary> {
            let senderId = mes["userID"] as String
            let senderDisplayName = mes["username"] as String
            let date = NSDate()
            let text = mes["text"] as String
            
            let message = JSQTextMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
            messageData.sendMessage(message)
        }
        
        finishReceivingMessage()
    }
    
    func updatedChat(message: portResponse) {
        myFoam?.getChatContents(id!, chatID: chatInfo!.id)
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQTextMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messageData.sendMessage(message)
        myFoam!.sendMessage(senderId, chatID: chatInfo!.id, text: text, username: displayName!)
        
        finishSendingMessage()
    }
    
    func senderDisplayName() -> String! {
        return self.displayName!
    }
    
    func senderId() -> String! {
        return self.id!
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        print("We're prepping to leave ChatViewControllerA\n")
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionViewA\n")
        return messageData.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messageData.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        print("collectionViewC\n")
        let curMessage = messageData.messages[indexPath.item]
        
        if curMessage.senderId == senderId() {
            return messageData.outgoingBubbleImage
        }
        else {
            return messageData.incomingBubbleImage
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource {
        let initials = Array(messageData.messages[indexPath.item].senderDisplayName)[0]
        
        let avatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(String(initials), backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.darkTextColor(), font: UIFont.systemFontOfSize(9), diameter: 15)
        
        return avatar
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        print("collectionViewE\n")
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        print("collectionViewF\n")
        return nil
    }
    
    func connectedToSocket(message: String) {
        return
    }
    func loginSent() {
        return
    }
    func registerSent() {
        return
    }
    func chatSent(type: String) {
        return
    }
    func loginResponse(message: portResponse) {
        return
    }
    func registerResponse(message: portResponse) {
        return
    }
    func listChatResponse(chats: [ChatInfo]) {
        return
    }
    func addChatResponse(message: portResponse) {
        return
    }
    func disconnectError(message: String) {
        return
    }
}

class ChatData: NSObject {
    var outgoingBubbleImage: JSQMessagesBubbleImage?
    var incomingBubbleImage: JSQMessagesBubbleImage?
    var messages = [JSQTextMessage]()
    
    override init() {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        // Here is where we would get all the existing messages for the chat
    }
    
    func sendMessage(message: JSQTextMessage) {
        messages.append(message)
    }
}
