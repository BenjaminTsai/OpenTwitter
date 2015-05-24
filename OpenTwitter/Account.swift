//
//  Account.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/19/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

var _currentAccount: Account?
let currentAccountKey = "kCurrentAccountKey"
let accountDidLoginNotification = "accountDidLoginNotification"
let accountDidLogoutNotification = "accountDidLogoutNotification"

class Account: NSObject {

    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var profileImageBiggerUrl: String?
    var tagline: String?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String

        profileImageUrl = dictionary["profile_image_url"] as? String
        if let url = profileImageUrl {
            var range = url.rangeOfString("_normal\\.", options: .RegularExpressionSearch)
            if let range = range {
                profileImageBiggerUrl = url.stringByReplacingCharactersInRange(range, withString: "_bigger.")
            }
        }
    }
 
    func logout() {
        Account.currentAccount = nil
        TwitterClient.sharedInstance.clearTokens()
        
        NSNotificationCenter.defaultCenter().postNotificationName(accountDidLogoutNotification, object: nil)
    }
    
    class var currentAccount: Account? {
        get {
            if _currentAccount == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentAccountKey) as? NSData
                if data != nil {
                    var dictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
                    _currentAccount = Account(dictionary: dictionary)
                }
            }
            return _currentAccount
        }
        set(account) {
            _currentAccount = account
            
            if _currentAccount != nil {
                var data = NSJSONSerialization.dataWithJSONObject(account!.dictionary, options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentAccountKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentAccountKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}
