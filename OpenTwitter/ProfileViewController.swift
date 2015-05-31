//
//  ProfileViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/30/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    var account: Account!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Utils.sharedInstance.loadImage(fromString: account.profileImageBiggerUrl!, forImage: profileImageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
