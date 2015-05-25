//
//  TweetCell.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/21/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

let favoriteOnImageName = "favorite_on"
let favoriteImageName = "favorite"
let retweetImageName = "retweet"
let retweetOnImageName = "retweet_on"

enum TweetCellMode {
    case Compact, Detail
}

protocol TweetCellProtocol: class {
    func tweetCell(tweetCell: TweetCell, didUpdateTweet: Tweet)
    func tweetCell(tweetCell: TweetCell, replyToTweet: Tweet)
}

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var retweeterIconImageView: UIImageView!
    @IBOutlet weak var retweeterLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel?
    @IBOutlet weak var favoriteCountLabel: UILabel?
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var profileImageTopConstraint: NSLayoutConstraint?

    weak var delegate: TweetCellProtocol?
    
    var mode: TweetCellMode = .Compact    
    var tweet: Tweet! {
        didSet {
            let tweetForDisplay: Tweet
            if let retweetedStatus = tweet.retweetedStatus {
                tweetForDisplay = retweetedStatus
                retweeterLabel.text = "\(tweet.account!.name!) retweeted"

                retweeterIconImageView.hidden = false
                retweeterLabel.hidden = false
                profileImageTopConstraint?.constant = 200
            } else {
                tweetForDisplay = tweet

                retweeterIconImageView.hidden = true
                retweeterLabel.hidden = true
                profileImageTopConstraint?.constant = 8
            }
            
            switch mode {
            case .Compact:
                Utils.sharedInstance.loadImage(fromString: tweetForDisplay.account!.profileImageUrl!, forImage: profileImageView)
            case .Detail:
                Utils.sharedInstance.loadImage(fromString: tweetForDisplay.account!.profileImageBiggerUrl!, forImage: profileImageView)
            }
            
            bodyLabel.text = tweetForDisplay.text
            nameLabel.text = tweetForDisplay.account?.name
            screennameLabel.text = "@" + (tweetForDisplay.account?.screenname ?? "")
            
            retweetCountLabel?.text = "\(tweetForDisplay.retweetCount ?? 0)"
            favoriteCountLabel?.text = "\(tweetForDisplay.favoriteCount ?? 0)"
            
            if tweet.retweeted ?? false {
                retweetButton.setImage(UIImage(named: retweetOnImageName), forState: UIControlState.Normal)
            }
            
            if tweet.favorited ?? false {
                favoriteButton.setImage(UIImage(named: favoriteOnImageName), forState: UIControlState.Normal)
            }
            
            if let createdAt = tweet.createdAt {
                switch mode {
                case .Compact:
                    // seconds
                    let secondsSinceCreated = createdAt.timeIntervalSinceNow.distanceTo(0)
                    let minutesSinceCreated = Int(secondsSinceCreated / 60)
                    let hoursSinceCreated = Int(secondsSinceCreated / (60 * 60))
                    
                    if minutesSinceCreated < 60 {
                        createdAtLabel.text = "\(minutesSinceCreated)m"
                    } else if hoursSinceCreated < 23 {
                        createdAtLabel.text = "\(hoursSinceCreated)h"
                    } else {
                        createdAtLabel.text = Utils.sharedInstance.formatDate(createdAt)
                    }
                case .Detail:
                    createdAtLabel.text = Utils.sharedInstance.formatDetailDate(createdAt)
                }
                
            }
            self.layoutIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
    }
    
    @IBAction func onReply(sender: AnyObject) {
        self.delegate?.tweetCell(self, replyToTweet: tweet)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweet(tweet, completion: { (tweet, error) -> () in
            if let error = error {
                NSLog("Error: %@", error)
            } else if let tweet = tweet {
                self.tweet = tweet
                self.delegate?.tweetCell(self, didUpdateTweet: tweet)
            } else {
                NSLog("Received empty result on destroy favorite")
            }
        })
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if tweet.favorited ?? false {
            favoriteButton.setImage(UIImage(named: favoriteImageName), forState: UIControlState.Normal)
            TwitterClient.sharedInstance.destroyFavorite(tweet, completion: { (tweet, error) -> () in
                if let error = error {
                    NSLog("Error: %@", error)
                } else if let tweet = tweet {
                    self.tweet = tweet
                    self.delegate?.tweetCell(self, didUpdateTweet: tweet)
                } else {
                    NSLog("Received empty result on destroy favorite")
                }
            })
        } else {
            favoriteButton.setImage(UIImage(named: favoriteOnImageName), forState: UIControlState.Normal)
            TwitterClient.sharedInstance.createFavorite(tweet, completion: { (tweet, error) -> () in
                if let error = error {
                    NSLog("Error: %@", error)
                } else if let tweet = tweet {
                    self.tweet = tweet
                    self.delegate?.tweetCell(self, didUpdateTweet: tweet)
                } else {
                    NSLog("Received empty result on create favorite")
                }
            })
        }
    }
    
}
