//
//  searchCell.swift
//  Han
//
//  Created by Hanbin Park on 8/7/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class searchCell: UITableViewCell {

    
    @IBOutlet weak var postNum: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var keyWordsLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width
        
        
        
        avaImg.frame = CGRect(x: 10, y: 10, width: width/5.3, height: width/5.3)
        keyWordsLbl.frame = CGRect(x: avaImg.frame.size.width + 20, y: 30, width: width/3.2, height: 30)
        followBtn.frame = CGRect(x: width - width / 3.5 - 10 , y: 30, width: width / 3.5, height: 30)
        postNum.frame = CGRect(x: width - width / 3.5 - 20 , y: 30, width: width / 3.5, height: 30)
        postNum.textColor = UIColor.gray
        postNum.textAlignment = .center
        
        avaImg.layer.cornerRadius = avaImg.frame.size.width/2
        avaImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
