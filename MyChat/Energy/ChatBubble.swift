//
//  ChatBubble.swift
//  Closio
//
//  Created by Rahul on 27/04/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit

class ChatBubble: UITableViewCell {

    @IBOutlet weak var lblTextMessage: UILabel!
    @IBOutlet weak var cellSafeView: UIView!
    @IBOutlet weak var cnstTrailing: NSLayoutConstraint!
    @IBOutlet weak var cnstLeading: NSLayoutConstraint!
    @IBOutlet weak var leftpicProfile: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
