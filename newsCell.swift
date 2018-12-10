//
//  newsCell.swift
//  Han
//
//  Created by Hanbin Park on 8/16/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        let width = UIScreen.main.bounds.width
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
