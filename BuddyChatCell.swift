//
//  BuddyChatCell.swift
//  ChatMessenger
//
//  Created by raghav vij on 7/20/16.
//  Copyright © 2016 raghav vij. All rights reserved.
//

import UIKit

class BuddyChatCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(message:String?,sender:String?)  {
        senderLabel.text = sender
        messageLabel.text = message
        self.userInteractionEnabled = false
        if sender == "you" {
            messageLabel.textColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.blackColor()
        }
        else {
            self.backgroundColor = UIColor.whiteColor()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
