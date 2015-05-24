//
//  Utils.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/23/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit
import Alamofire

class Utils {
    
    let shortDateFormatter: NSDateFormatter

    init() {
        shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    }
    
    func loadImage(fromString url: String, forImage image: UIImageView) {
        Alamofire.request(.GET, url, parameters: nil).response { (request, response, data, error) in
            image.image = UIImage(data: data! as! NSData)
        }
    }
    
    func formatDate(date: NSDate) -> String {
        return shortDateFormatter.stringFromDate(date)
    }
    
    // Singleton
    class var sharedInstance: Utils {
        struct Static {
            static let instance = Utils()
        }
        return Static.instance
    }
}