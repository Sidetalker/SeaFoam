//
//  MainChatViewController.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/27/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

class MainChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
