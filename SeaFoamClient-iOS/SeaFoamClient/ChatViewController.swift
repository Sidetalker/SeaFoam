//
//  ChatViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/24/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

//class ChatViewController: JSQMessagesViewController, JSQMessagesCollectionViewDataSource {
//    var chatInfo: ChatInfo?
//    
//    @IBOutlet var navTitle: UINavigationItem!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.navigationController?.toolbarHidden = true
//        self.navigationController?.navigationBarHidden = false
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
//
//    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        let message = JSQTextMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
//        
//        finishSendingMessage()
//    }
//}

class ChatData: NSObject {
    var outgoingBubbleImage: JSQMessagesBubbleImage?
    var incomingBubbleImage: JSQMessagesBubbleImage?
//    var messages = 
    
    override init() {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
}
