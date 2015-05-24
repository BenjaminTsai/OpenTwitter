//
//  ViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/19/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion( { (account: Account?, error: NSError?) in
            if let account = account {
                NSLog("login success")
                Account.currentAccount = account
                self.performSegueWithIdentifier("loginToTweetsSegue", sender: self)
            } else if let error = error {
                NSLog("%@", error)
            } else {
                NSLog("loginWithCompletion all nil")
            }
        })
    }

}

