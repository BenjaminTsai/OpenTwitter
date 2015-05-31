//
//  MenuCell.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/31/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var menuLabel: UILabel!
    
    var menu: MenuEnum! {
        didSet {
            switch menu! {
            case .Home:
                menuLabel.text = "Home Timeline"
            case .Mention:
                menuLabel.text = "Mentions"
            default:
                NSLog("Unexpected enum")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
