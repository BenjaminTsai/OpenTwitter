//
//  Tweet.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/19/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class Tweet: NSObject {
 
    var id: String?
    var id_int: Int?
    var account: Account?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    
    var favorited: Bool?
    var retweeted: Bool?
    var favoriteCount: Int?
    var retweetCount: Int?

    var currentUserRetweetId: String?
    var retweetedStatus: Tweet?
    
    init(dictionary: NSDictionary) {
        id = dictionary["id_str"] as? String
        id_int = id?.toInt() // assumes 64 bit system
        account = Account(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        
        favorited = dictionary["favorited"] as? Bool
        retweeted = dictionary["retweeted"] as? Bool
        
        favoriteCount = dictionary["favorite_count"] as? Int
        retweetCount = dictionary["retweet_count"] as? Int
        
        if let currentUserRetweetJson = dictionary["current_user_retweet"] as? NSDictionary {
            currentUserRetweetId = currentUserRetweetJson["id_str"] as? String
        }
        
        if let retweetedJson = dictionary["retweeted_status"] as? NSDictionary {
            retweetedStatus = Tweet(dictionary: retweetedJson)
        }
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
    
    func retweet(completion: (sender: Tweet, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.retweet(self, completion: { (retweet, error) -> () in
            if let error = error {
                completion(sender: self, error: error)
            } else if let retweet = retweet {
                self.retweeted = true
                self.currentUserRetweetId = retweet.id
                completion(sender: self, error: nil)
            } else {
                NSLog("Received empty result on retweet")
            }
        })
    }
}
