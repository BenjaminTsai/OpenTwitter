//
//  ComposeTweetViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/22/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

// why is :class needed for weak reference?
protocol ComposeTweetViewControllerDelegate: class {
    func composeTweetViewController(composeTweetViewController: ComposeTweetViewController, didPublishTweet: Bool)
}

class ComposeTweetViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    weak var delegate: ComposeTweetViewControllerDelegate?

    var inReplyToTweet: Tweet? {
        set(newValue) {
            _inReplyToTweet = newValue
        }
        get {
            return _inReplyToTweet?.retweetedStatus ?? _inReplyToTweet
        }
    }
    private var _inReplyToTweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = Account.currentAccount?.name
        
        if let replyToAccount = inReplyToTweet?.account {
            tweetTextView.text = "@" + replyToAccount.screenname! + " "
        } else {
            tweetTextView.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        let status = tweetTextView.text
        TwitterClient.sharedInstance.updateStatus(status, inReplyToId: inReplyToTweet?.id) { (tweet: Tweet?, error: NSError?) in
            if let error = error {
                NSLog("Error tweeting: %@", error)
            }
            self.delegate?.composeTweetViewController(self, didPublishTweet: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
