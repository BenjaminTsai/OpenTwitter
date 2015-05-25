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

    @IBOutlet weak var charLimitLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    weak var delegate: ComposeTweetViewControllerDelegate?

    private let maxTwitterLength = 140
    
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

        tweetTextView.delegate = self        
        if let replyToAccount = inReplyToTweet?.account {
            tweetTextView.text = "@" + replyToAccount.screenname! + " "
        } else {
            tweetTextView.text = ""
        }
        refreshCharLimitLabel()
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
    
    func refreshCharLimitLabel() {
        let remaining = maxTwitterLength - count(tweetTextView.text)
        charLimitLabel.text = "\(remaining)"
    }
}

extension ComposeTweetViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        refreshCharLimitLabel()
    }
}