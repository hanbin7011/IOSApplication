//
//  PostCell.swift
//  Han
//
//  Created by Hanbin Park on 8/4/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var mainImgs: UICollectionView!
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var sharingBtn: UIButton!
    
    @IBOutlet weak var contentLbl: UILabel!
    
    
    var images = [UIImage]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let width = UIScreen.main.bounds.width
        
        distanceLbl.translatesAutoresizingMaskIntoConstraints = false
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        mainImgs.translatesAutoresizingMaskIntoConstraints = false
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        sharingBtn.translatesAutoresizingMaskIntoConstraints = false
        contentLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[distance(30)]-5-[ava(40)]-5-[mainImgs]-5-[share(30)]-5-[content]", options: [], metrics: nil, views: ["distance" : distanceLbl, "ava" : avaImg, "mainImgs" : mainImgs, "share": shareBtn, "content": contentLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[sharing(30)]-5-[date(40)]-5-[mainImgs(\(width - 10))]-5-[comment(30)]", options: [], metrics: nil, views: ["sharing" : sharingBtn, "date" : dateLbl, "mainImgs" : mainImgs, "comment": commentBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sharing(30)]-5-[username(40)]", options: [], metrics: nil, views: ["sharing" : sharingBtn, "username" : usernameBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[distance(80)]", options: [], metrics: nil, views: ["distance" : distanceLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[sharing(80)]-5-|", options: [], metrics: nil, views: ["sharing" : sharingBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[ava(40)]-5-[username]-5-[date]-5-|", options: [], metrics: nil, views: ["ava" : avaImg, "username" : usernameBtn, "date" : dateLbl]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[mainimgs(\(width - 10))]-5-|", options: [], metrics: nil, views: ["mainimgs" : mainImgs]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[share]", options: [], metrics: nil, views: ["share" : shareBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[comment]-5-|", options: [], metrics: nil, views: ["comment" : commentBtn]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[content]-5-|", options: [], metrics: nil, views: ["content" : contentLbl]))
        
        self.mainImgs.frame.size.width = width - 10
        self.mainImgs.frame.size.height = width - 10
//        avaImg.frame = CGRect(x: 5, y: 5 , width: 30, height: 30)
//        let usernameBtnX = avaImg.frame.origin.x + avaImg.frame.width
//        usernameBtn.frame = CGRect(x: usernameBtnX, y: 5, width: width - usernameBtnX - 115 , height: 30)
//        distanceLbl.frame = CGRect(x: usernameBtn.frame.origin.x + usernameBtn.frame.width, y: 5, width: 60, height: 30)
//        dateLbl.frame = CGRect(x: distanceLbl.frame.origin.x + distanceLbl.frame.width, y: 5, width: 50, height: 30)
//        
//        mainImgs.frame = CGRect(x: 5, y: avaImg.frame.origin.y + avaImg.frame.height + 5, width: width - 10, height: width - 10)
//        
//        shareBtn.frame = CGRect(x: 5, y: mainImgs.frame.origin.y + mainImgs.frame.height + 5, width: width/2 - 5, height: 30)
//        commentBtn.frame = CGRect(x: shareBtn.frame.origin.x + shareBtn.frame.width, y: mainImgs.frame.origin.y + mainImgs.frame.height + 5, width: width/2 - 5, height: 30)
//        
//        contentLbl.frame = CGRect(x: 10, y: shareBtn.frame.origin.y + shareBtn.frame.height + 5, width: width - 20, height: 120)
        
        
        
        
        //set up the collection view
        mainImgs.delegate=self
        mainImgs.dataSource=self
        mainImgs.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "Cell")
        mainImgs.isPagingEnabled = true
        mainImgs.backgroundColor = UIColor.white
       
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //
    //collection view set up
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = mainImgs.frame.width
        
        //        if UIDevice.current.orientation.isPortrait {
        //            return CGSize(width: width/4 - 1, height: width/4 - 1)
        //        } else {
        //            return CGSize(width: width/6 - 1, height: width/6 - 1)
        //        }
        
        if images.count == 1{
            return CGSize(width: width - 1, height: width - 1)
        }else if images.count == 2{
            return CGSize(width: width/2 - 1, height: width - 1)
        }else if images.count == 3{
            switch indexPath.item {
            case 0:
                return CGSize(width: width - 1, height: width/2 - 1)
            default:
                return CGSize(width: width/2 - 1, height: width/2 - 1)
            }
        }else if images.count == 4{
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        }else{
            switch indexPath.item {
            case 0,1:
                return CGSize(width: (UIScreen.main.bounds.width - 16) / 2, height: (UIScreen.main.bounds.width - 16) / 2)
            default:
                return CGSize(width: (UIScreen.main.bounds.width - 32) / 3, height:  (UIScreen.main.bounds.width) / 3)
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainImgs.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewCell
        cell.img.image=images[indexPath.row]
        return cell
    }

}

//Cell class
class ImagePreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var img = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
