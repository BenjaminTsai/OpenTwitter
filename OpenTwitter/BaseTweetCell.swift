//
//  BaseTweetCell.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/24/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class BaseTweetCell: UITableViewCell {

    var tweet: Tweet!
    
    func onRetweet(sender: AnyObject) {
        NSLog("retweet")
        TwitterClient.sharedInstance.retweet(tweet, completion: { (tweet, error) -> () in
            if let error = error {
                NSLog("Error: %@", error)
            } else if let tweet = tweet {
                NSLog("success")
                self.tweet = tweet
                self.delegate?.tweetDetailCell(self, didUpdateTweet: tweet)
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
                    self.delegate?.tweetDetailCell(self, didUpdateTweet: tweet)
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
                    self.delegate?.tweetDetailCell(self, didUpdateTweet: tweet)
                } else {
                    NSLog("Received empty result on create favorite")
                }
            })
        }
    }
    
    
}
