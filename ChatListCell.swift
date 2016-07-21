//
//  ChatListCell.swift
//  ChatMessenger
//
//  Created by raghav vij on 7/21/16.
//  Copyright © 2016 raghav vij. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {

    @IBOutlet weak var buddyNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(buddyName:String?) {
        buddyNameLabel.text = buddyName
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
