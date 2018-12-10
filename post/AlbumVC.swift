//
//  AlbumVC.swift
//  Han
//
//  Created by Hanbin Park on 7/6/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import Photos

class AlbumVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    var selectedImageArray=[UIImage]()
    
    //Check the VC calling from OthersPostVC(2) or BookPostVC(1) default is 3
    static var check = 3
    var limitPhoto = 12
    var from = 0
    var to = 12
    
//    var refresher : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(AlbumVC.check)
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Photos"
        
        let layout = UICollectionViewFlowLayout()
        
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        myCollectionView.allowsMultipleSelection = true
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AlbumVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let shareButton = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AlbumVC.share(sender:)))
        self.navigationItem.rightBarButtonItem = shareButton
        
//        refresher = UIRefreshControl()
//        refresher.addTarget(self, action: Selector("refresh"), for: .valueChanged)
//        myCollectionView.addSubview(refresher)
        
        
        
        
        self.view.addSubview(myCollectionView)
        
        myCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
        grabPhotos(from: from, to: to)
        from = to
        to = to + limitPhoto
    }
    
    @objc func share(sender: UIBarButtonItem) {
        if AlbumVC.check == 1{
            if (BookPostVC.imgArray.count != 0){
                BookPostVC.imgArray.removeAll()
                BookPostVC.picColletionView.reloadData()
            }
            BookPostVC.imgArray = self.selectedImageArray
        }else if AlbumVC.check == 2{
            if (OthersPostVC.imgArray.count != 0){
                OthersPostVC.imgArray.removeAll()
                OthersPostVC.picColletionView.reloadData()
            }
            OthersPostVC.imgArray = self.selectedImageArray
        }
        
        self.tabBarController?.tabBar.isHidden = false
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        self.tabBarController?.tabBar.isHidden = false
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews(){
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
//    func refresh(){
//        myCollectionView.reloadData()
//        refresher.endRefreshing()
//    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    
    
    //set image to cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //in order to check load photo amount
        let fetchOptions=PHFetchOptions()
        fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        if indexPath.row < imageArray.count{
            cell.img.image=imageArray[indexPath.item]
        }
        
        let currentOffset = collectionView.contentOffset.y
        let maximumOffset = collectionView.contentSize.height - collectionView.frame.size.height
        
        // If scroll to bottom reload more photos
        if maximumOffset - currentOffset <= 10.0  {
            if fetchResult.count > to{
                grabPhotos(from: from, to: to)
                from = to
                to = to + limitPhoto
            }else if to == from{
                
            //if almost all photos reload change from to value
            }else{
                grabPhotos(from: from, to: fetchResult.count)
                from = fetchResult.count
                to = fetchResult.count
            }
            
        }
        
        return cell
    }
    
    
    //limitation for selection amount
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if selectedImageArray.count >= 3{
            DispatchQueue.main.async {
                let message = "Can't pick more than 3 picture"
                appDelegate.infoView(message: message, color: smoothRedColor)
            }
        }
        return selectedImageArray.count < 3
    }
    
    //when select add to selectedImageArray
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoItemCell
        cell.toggleSelected(num : String(selectedImageArray.count+1))
        selectedImageArray.append(imageArray[indexPath.item])
        
        
    }
    //when deselected remove from selectedImageArray
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! PhotoItemCell
        cell.toggleSelected(num : String(selectedImageArray.count+1))
        let index = selectedImageArray.index(of: imageArray[indexPath.item])
        selectedImageArray.remove(at: index!)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        //        if UIDevice.current.orientation.isPortrait {
        //            return CGSize(width: width/4 - 1, height: width/4 - 1)
        //        } else {
        //            return CGSize(width: width/6 - 1, height: width/6 - 1)
        //        }
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/3 - 1, height: width/3 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK: grab photos
    func grabPhotos(from: Int, to: Int){
        
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            let imgManager=PHImageManager.default()
            
            let requestOptions=PHImageRequestOptions()
            requestOptions.isSynchronous=true
            requestOptions.deliveryMode = .fastFormat
            
            let fetchOptions=PHFetchOptions()
            fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            print(fetchResult)
            print(fetchResult.count)
            if(fetchResult.count > to){
                if fetchResult.count > 0 {
                    for i in from..<to{
                        imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:150, height: 150),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                            self.imageArray.append(image!)
                            
                        })
                    }
                }
            }else{
                if fetchResult.count > from {
                    for i in from..<fetchResult.count{
                        imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:150, height: 150),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                            self.imageArray.append(image!)
                            
                        })
                    }
                } else {
                    print("You got no photos.")
                }
            }
            
            print("imageArray count: \(self.imageArray.count)")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.myCollectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


class PhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    var label = UILabel()
    
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
    
    func toggleSelected (num : String)
    {
        if (isSelected){
            if(num == "1"){
                label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                label.textAlignment = NSTextAlignment.center
                label.text = "Main Picture"
                label.backgroundColor = brandColor
                label.textColor = UIColor.white
                label.font = UIFont.boldSystemFont(ofSize: 16.0)
            }else{
                label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                label.textAlignment = NSTextAlignment.center
                label.text = num
                label.backgroundColor = brandColor
                label.textColor = UIColor.white
                label.font = UIFont.boldSystemFont(ofSize: 16.0)
            }
            
            alpha = 0.8
            
            self.addSubview(label)
        }else {
            label.removeFromSuperview()
            alpha = 1
        }
    }
}

struct DeviceInfo {
    struct Orientation {
        // indicate current device is in the LandScape orientation
        static var isLandscape: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isLandscape
                    : UIApplication.shared.statusBarOrientation.isLandscape
            }
        }
        // indicate current device is in the Portrait orientation
        static var isPortrait: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isPortrait
                    : UIApplication.shared.statusBarOrientation.isPortrait
            }
        }
    }
}
