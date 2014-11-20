//
//  ChatViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/24/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController, JSQMessagesCollectionViewDataSource {
    var displayName: String?
    var id: String?
    var chatInfo: ChatInfo?
    var myFoam: SeaSocket?
    var messageData = ChatData()
    
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

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQTextMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messageData.sendMessage(message)
        myFoam!.sendMessage(senderId, chatID: chatInfo!.id, text: text)
        
        finishSendingMessage()
    }
    
    func senderDisplayName() -> String! {
        return self.displayName!
    }
    
    func senderId() -> String! {
        return self.id!
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageData.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messageData.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let curMessage = messageData.messages[indexPath.item]
        
        if curMessage.senderId == senderId() {
            return messageData.outgoingBubbleImage
        }
        else {
            return messageData.incomingBubbleImage
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
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
