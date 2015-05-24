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
    
    let detailDateFormatter: NSDateFormatter = NSDateFormatter()
    let shortDateFormatter: NSDateFormatter = NSDateFormatter()

    init() {
        detailDateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
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
    
    func formatDetailDate(date: NSDate) -> String {
        return detailDateFormatter.stringFromDate(date)
    }
    
    // Singleton
    class var sharedInstance: Utils {
        struct Static {
            static let instance = Utils()
        }
        return Static.instance
    }
}