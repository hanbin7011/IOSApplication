//
//  homePostCell.swift
//  Han
//
//  Created by Hanbin Park on 7/13/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class homePostCell: UITableViewCell {

    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let width = UIScreen.main.bounds.width
        mainImg.frame = CGRect(x: 10, y: 25, width: 80, height: 80)
        titleLbl.frame = CGRect(x: mainImg.frame.origin.x + mainImg.frame.width + 10, y: 25, width: width - (mainImg.frame.origin.x + mainImg.frame.width + 20), height: 80)
        dateLbl.frame = CGRect(x: width - 70, y: 5, width: 60, height: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
