//
//  MenuProfileCell.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/31/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class MenuProfileCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Utils.sharedInstance.loadImage(fromString: Account.currentAccount!.profileImageUrl!, forImage: profileImageView)
        nameLabel.text = Account.currentAccount!.name!
        screennameLabel.text = "@" + Account.currentAccount!.screenname!
    }

}
