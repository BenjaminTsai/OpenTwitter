//
//  TwitterClient.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/19/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import OAuthSwift

let currentTokenKey = "kCurrentTokenKey"
let currentTokenSecretKey = "kCurrentTokenSecretKey"

class TwitterClient {

    let consumerKey: String!
    let consumerSecret: String!
    
    var loginCompletion: ((account: Account?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient()
        }
        return Static.instance
    }
    
    let oauth: OAuth1Swift
    var client: OAuthSwiftClient?
    
    init() {
        let secrets = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("secrets", ofType: "plist")!)!
        consumerKey = secrets["consumer_key"] as! String
        consumerSecret = secrets["consumer_secret"] as! String
        
        oauth = OAuth1Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        
        let token = NSUserDefaults.standardUserDefaults().valueForKey(currentTokenKey) as? String
        let tokenSecret = NSUserDefaults.standardUserDefaults().valueForKey(currentTokenSecretKey) as? String
        
        if token != nil && tokenSecret != nil {
            oauth.client = OAuthSwiftClient(
                consumerKey: consumerKey,
                consumerSecret: consumerSecret,
                accessToken: token!,
                accessTokenSecret: tokenSecret!
            )
        }
    }
    
    func clearTokens() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(currentTokenKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(currentTokenSecretKey)
    }
    
    func loginWithCompletion(completion: (account: Account?, error: NSError?) -> ()) {
        oauth.authorizeWithCallbackURL(NSURL(string: "opentwitter://oauth-callback/twitter")!,
            success: { (credential: OAuthSwiftCredential, response: NSURLResponse) in
                NSUserDefaults.standardUserDefaults().setObject(credential.oauth_token, forKey: currentTokenKey)
                NSUserDefaults.standardUserDefaults().setObject(credential.oauth_token_secret, forKey: currentTokenSecretKey)

                
                var parameters = Dictionary<String, AnyObject>()
                self.oauth.client.get("https://api.twitter.com/1.1/account/verify_credentials.json",
                    parameters: parameters,
                    success: { (data: NSData, response: NSHTTPURLResponse) -> Void in
                        var error: NSError?
                        let dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data,
                            options: NSJSONReadingOptions.allZeros,
                            error: &error) as! NSDictionary

                        if let error = error {
                            completion(account: nil, error: error)
                        } else {
                            var account = Account(dictionary: dict)
                            completion(account: account, error: nil)
                        }
                    },
                    failure: { (error: NSError!) -> Void in
                        completion(account: nil, error: error)
                    }
                )
            },
            failure: { (error: NSError) in
                completion(account: nil, error: error)
            }
        )
    }

    func homeTimelineWithParams(params: Dictionary<String, AnyObject>?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        getRequestReturnsTweetArray("https://api.twitter.com/1.1/statuses/home_timeline.json",
            parameters: params ?? Dictionary<String, AnyObject>(),
            completion: completion
        )
    }

    func mentionsTimelineWithParams(params: Dictionary<String, AnyObject>?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        getRequestReturnsTweetArray("https://api.twitter.com/1.1/statuses/mentions_timeline.json",
            parameters: params ?? Dictionary<String, AnyObject>(),
            completion: completion
        )
    }
    
    func getStatus(id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = Dictionary<String, AnyObject>()
        params["include_my_retweet"] = 1
        getRequestReturnsTweet("https://api.twitter.com/1.1/statuses/show/" + id + ".json",
            parameters: params,
            completion: completion
        )
    }
    
    func updateStatus(status: String, inReplyToId: String?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = Dictionary<String, AnyObject>()
        params["status"] = status

        if let inReplyToId = inReplyToId {
            params["in_reply_to_status_id"] = inReplyToId
        }
        
        oauth.client.post("https://api.twitter.com/1.1/statuses/update.json",
            parameters: params,
            success: { (data: NSData, response: NSHTTPURLResponse) -> Void in
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                
                if let error = error {
                    completion(tweet: nil, error: error)
                } else {
                    completion(tweet: Tweet(dictionary: jsonDict), error: nil)
                }
            },
            failure: { (error: NSError!) -> Void in
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func destroyStatus(id: String, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        postRequestReturnsTweet("https://api.twitter.com/1.1/statuses/destroy/" + id + ".json", parameters: nil, completion: completion)
    }
    
    func retweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = Dictionary<String, AnyObject>()
        postRequestReturnsTweet("https://api.twitter.com/1.1/statuses/retweet/" + tweet.id! + ".json", parameters: params, completion: completion)
    }
    
    func destroyRetweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let tweetId = tweet.retweetedStatus?.id ?? tweet.id
        
        getStatus(tweetId!, completion: { (tweet, error) -> () in
            if let currentUserRetweetId = tweet?.currentUserRetweetId {
                self.destroyStatus(currentUserRetweetId, completion: completion)
            } else {
                completion(tweet: nil, error: nil)
            }
        })
    }
    
    func createFavorite(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = Dictionary<String, AnyObject>()

        // assumes we're on 64 bit platform
        params["id"] = tweet.id!.toInt()
        
        postRequestReturnsTweet("https://api.twitter.com/1.1/favorites/create.json", parameters: params, completion: completion)
    }
    
    func destroyFavorite(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params = Dictionary<String, AnyObject>()
        
        // assumes we're on 64 bit platform
        params["id"] = tweet.id!.toInt()
        
        postRequestReturnsTweet("https://api.twitter.com/1.1/favorites/destroy.json", parameters: params, completion: completion)
    }
    
    private func getRequestReturnsTweetArray(url: String, parameters: Dictionary<String, AnyObject>, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        oauth.client.get(url,
            parameters: parameters,
            success: { (data: NSData, response: NSHTTPURLResponse) -> Void in
                var error: NSError?
                let jsonArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSArray
                
                if let error = error {
                    completion(tweets: nil, error: error)
                } else {
                    var tweets = [Tweet]()
                    for entry in jsonArray as! [NSDictionary] {
                        tweets.append(Tweet(dictionary: entry))
                    }
                    completion(tweets: tweets, error: nil)
                }
            },
            failure: { (error: NSError!) -> Void in
                completion(tweets: nil, error: error)
            }
        )
    }
    
    private func getRequestReturnsTweet(url: String, parameters: Dictionary<String, AnyObject>, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        oauth.client.get(url,
            parameters: parameters,
            success: { (data: NSData, response: NSHTTPURLResponse) -> Void in
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                
                if let error = error {
                    completion(tweet: nil, error: error)
                } else {
                    completion(tweet: Tweet(dictionary: jsonDict), error: nil)
                }
            },
            failure: { (error: NSError!) -> Void in
                completion(tweet: nil, error: error)
            }
        )
    }
    
    private func postRequestReturnsTweet(url: String, parameters: Dictionary<String, AnyObject>?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        oauth.client.post(url,
            parameters: parameters ?? Dictionary<String, AnyObject>(),
            success: { (data: NSData, response: NSHTTPURLResponse) -> Void in
                var error: NSError?
                let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                
                if let error = error {
                    completion(tweet: nil, error: error)
                } else {
                    completion(tweet: Tweet(dictionary: jsonDict), error: nil)
                }
            },
            failure: { (error: NSError!) -> Void in
                completion(tweet: nil, error: error)
            }
        )
    }
    
    func openURL(url: NSURL) {
        OAuth1Swift.handleOpenURL(url)
    }
}
