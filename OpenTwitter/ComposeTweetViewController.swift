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

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!

    @IBOutlet weak var charLimitLabel: UILabel!

    @IBOutlet weak var textViewToBottomConstraint: NSLayoutConstraint!
    
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
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification,
            object: nil,
            queue: nil,
            usingBlock: { (notification: NSNotification!) in
                if let info = notification.userInfo {
                    var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
                    self.textViewToBottomConstraint.constant = keyboardFrame.height
                    self.view.layoutIfNeeded()
                }
            }
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Utils.sharedInstance.loadImage(fromString: Account.currentAccount!.profileImageUrl!, forImage: profileImageView)
        nameLabel.text = Account.currentAccount?.name
        screennameLabel.text = "@" + (Account.currentAccount?.screenname ?? "")

        // this should not be needed, it's still messing up the scrollbar display
        tweetTextView.contentInset.top = -65
        
        tweetTextView.delegate = self        
        if let replyToAccount = inReplyToTweet?.account {
            tweetTextView.text = "@" + replyToAccount.screenname! + " "
        } else {
            tweetTextView.text = ""
        }
        refreshCharLimitLabel()
        
        // show keyboard
        tweetTextView.becomeFirstResponder()
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
    
    private func refreshCharLimitLabel() {
        let remaining = maxTwitterLength - count(tweetTextView.text)
        charLimitLabel.text = "\(remaining)"
    }
}

extension ComposeTweetViewController: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        refreshCharLimitLabel()
    }
}