//
//  commentCell.swift
//  Han
//
//  Created by Hanbin Park on 9/4/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        commentLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[username]-(-2)-[comment]-5-|", options: [], metrics: nil, views: ["username":usernameBtn, "comment": commentLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[date]", options: [], metrics: nil, views: ["date":dateLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[ava(40)]", options: [], metrics: nil, views: ["ava":avaImg]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ava(40)]-13-[comment]-20-|", options: [], metrics: nil, views: ["ava":avaImg, "comment" : commentLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[ava]-13-[username]", options: [], metrics: nil, views: ["ava":avaImg, "username" : usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[date]-10-|", options: [], metrics: nil, views: ["date":dateLbl]))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
