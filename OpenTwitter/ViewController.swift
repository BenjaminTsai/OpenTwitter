//
//  ViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/19/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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