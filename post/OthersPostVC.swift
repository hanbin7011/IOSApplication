//
//  OthersPostVC.swift
//  Han
//
//  Created by Hanbin Park on 7/9/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import Photos

class OthersPostVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UITextViewDelegate{
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imgBtn: UIButton!
    
    static var picColletionView: UICollectionView!
    
    static var imgArray = [UIImage]()
    
    //CheckTabBar changed
    static var checkTabBarChanged = false
    
    var keyBoardSatartHeight : CGFloat = 0
    
    var viewHeight : CGFloat = 0
    var viewWidth : CGFloat = 0
    
    //keyboard frame size
    var keyboard = CGRect()
    
    var uuid = String()
    
    var countLbl : UILabel!
    
    var shareButton : UIBarButtonItem!
    
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewHeight = self.view.frame.size.height
        viewWidth = self.view.frame.size.width
        
        shareButton = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AlbumVC.share(sender:)))
        self.navigationItem.rightBarButtonItem = shareButton
        countLbl = UILabel(frame: CGRect(x: viewWidth - 200, y: viewHeight - 150, width: 50, height: 40))
        countLbl.text = String(500)
        countLbl.textColor = UIColor.lightGray
        
        self.view.addSubview(countLbl)
        
        
        //set up, Change textView and collectionView when keyboard pop up.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboardOthers), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboardOthers), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
        //Set up textview when first pop up
        textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight - 100)
        textViewDidBeginEditing(textView)
        textViewDidEndEditing(textView)
        textView.text = "@Title of Stuff#comment#comment..."
        textView.textColor = UIColor.lightGray
        textView.delegate = self
        
        
        
       
        //Add image button when first pop up
        imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 150, width: 100, height: 40)
        
        //add image button to view
        self.view.addSubview(imgBtn)
        
        // Set up Back and share button in navigation bar
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AlbumVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        
        
    }
    
   
    //Always check the setting when page open again
    override func viewWillAppear(_ animated: Bool) {
        
        //Set up views depend on keyboard show or not
        if(OthersPostVC.checkTabBarChanged){
            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: keyBoardSatartHeight)
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: keyBoardSatartHeight + 111, width: viewWidth, height: 40)
        }else{
            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            countLbl.frame = CGRect(x: viewWidth - 200, y: viewHeight - 150, width: 50, height: 40)
            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 150, width: 100, height: 40)
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight-40, width: viewWidth, height: 40)
        }
//        if (!OthersPostVC.checkTabBarChanged && BookPostVC.checkTabBarChanged){
//            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 60, width: 100, height: 40)
//            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight + 40, width: viewWidth, height: 40)
//        }else if(OthersPostVC.checkTabBarChanged){
//            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: keyBoardSatartHeight + 111, width: viewWidth, height: 40)
//        }else{
//            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//        }
        
        //If image is sent, show the image
        if(OthersPostVC.imgArray.count > 0){
            if( OthersPostVC.picColletionView == nil){
                let layout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                layout.minimumInteritemSpacing=0
                layout.minimumLineSpacing=0
                layout.scrollDirection = .horizontal
                
                
                var collectionViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewHeight / 3)
                
                
                
                if(OthersPostVC.imgArray.count == 1){
                    
                    collectionViewFrame = CGRect(x: viewWidth / 4, y: 2, width: self.view.frame.size.width, height: viewHeight / 3)
                    
                }
                
                //set up the collection view
                OthersPostVC.picColletionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
                OthersPostVC.picColletionView.delegate=self
                OthersPostVC.picColletionView.dataSource=self
                OthersPostVC.picColletionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
                OthersPostVC.picColletionView.isPagingEnabled = true
                OthersPostVC.picColletionView.backgroundColor = UIColor.white
                
                
                //Put textview bottom of collection view
                textView.frame = CGRect(x: 0, y: viewHeight / 3, width: self.view.frame.size.width, height: 100)
                
                let button = UIButton(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
                button.backgroundColor = .black
                button.setTitle("X", for: .normal)
                button.addTarget(self, action: #selector(removeImgAction), for: .touchUpInside)
                OthersPostVC.picColletionView.addSubview(button)
                
                OthersPostVC.picColletionView.addSubview(button)
                self.view.addSubview(OthersPostVC.picColletionView)
                
                
                OthersPostVC.picColletionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
            }else{
                OthersPostVC.picColletionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewHeight / 3)
                
                if(OthersPostVC.imgArray.count == 1){
                    
                    OthersPostVC.picColletionView.frame = CGRect(x: viewWidth / 4, y: 2, width: self.view.frame.size.width, height: viewHeight / 3)
                    
                }
                
                //Put textview bottom of collection view
                textView.frame = CGRect(x: 0, y: viewHeight / 3, width: self.view.frame.size.width, height: 100)
                
                
                self.view.addSubview(OthersPostVC.picColletionView)
                
                OthersPostVC.picColletionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
            }
            
            // Reset the setting for first set up
        }
    }
    
    @objc func removeImgAction(sender: UIButton!) {
        OthersPostVC.imgArray.removeAll()
        OthersPostVC.picColletionView.reloadData()
        OthersPostVC.picColletionView.removeFromSuperview()
        self.viewWillAppear(false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //numb of characters in textview
        
        let chars = String(textView.text).count
        
        let spacing = NSCharacterSet.whitespacesAndNewlines
        
        countLbl.text = String(500 - chars)
        
        if chars > 500 {
            countLbl.textColor = smoothRedColor
            shareButton.isEnabled = false
            shareButton.tintColor = UIColor.white.withAlphaComponent(0.4)
        }else if textView.text.trimmingCharacters(in: spacing).uppercased().isEmpty{
            shareButton.isEnabled = false
            shareButton.tintColor = UIColor.white.withAlphaComponent(0.4)
        }else{
            countLbl.textColor = UIColor.lightGray
            shareButton.isEnabled = true
            shareButton.tintColor = UIColor.white.withAlphaComponent(1)
        }
    }
    
    //Clear the hint text for textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = "@"
            textView.textColor = UIColor.black
            
            //CheckTabBar moved
            OthersPostVC.checkTabBarChanged = true
        }
    }
    
    //re-set up  hint text
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "@" {
            textView.text = "@Title of stuff#comment#comment..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    //Set up View due to keyboard pop up
    @objc func adjustForKeyboardOthers(notification: Notification) {
        let viewWidth = self.view.frame.size.width
        let viewHeight = self.view.frame.size.height
        
        
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            countLbl.frame = CGRect(x: viewWidth - 200, y: viewHeight - 70, width: 50, height: 40)
            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 70, width: 100, height: 40)
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight + 40, width: viewWidth, height: 40)
        } else {
            self.keyBoardSatartHeight = keyboardViewEndFrame.height
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: keyboardViewEndFrame.height + 111, width: viewWidth, height: 40)
            
            
            
            //check image showing or not
            if(textView.frame.minY != 0){
                //check how many image and set up depend on that
                textView.frame = CGRect(x: 0, y: viewHeight / 3, width: viewWidth, height: keyboardViewEndFrame.height + 50 - viewHeight / 3)
                
                if(OthersPostVC.imgArray.count == 1){
                    textView.frame = CGRect(x: 0, y: viewHeight / 3, width: viewWidth, height: keyboardViewEndFrame.height + 50 - viewHeight / 3)
                    OthersPostVC.picColletionView.frame = CGRect(x: viewWidth / 4, y: 2, width: viewWidth, height: viewHeight / 3)
                    self.view.addSubview( OthersPostVC.picColletionView)
                }else{
                    textView.frame = CGRect(x: 0, y: viewHeight / 3, width: viewWidth, height: keyboardViewEndFrame.height + 50 - viewHeight / 3)
                    OthersPostVC.picColletionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewHeight / 3)
                    self.view.addSubview(OthersPostVC.picColletionView)
                }
                
            }else{
                textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: keyboardViewEndFrame.height + 50)
            }
            countLbl.frame = CGRect(x: viewWidth - 200, y: keyboardViewEndFrame.height + 10, width: 50, height: 40)
            //add image button
            imgBtn.frame = CGRect(x: self.view.frame.size.width - 100, y: keyboardViewEndFrame.height + 10, width: 100, height: 40)
        }
        
        
    }
    
    //Back button action handledr, clear the data when back button clicked
    @objc func back(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
        OthersPostVC.imgArray.removeAll()
        self.textView.text = nil
        
        BookPostVC.checkTabBarChanged = false
        OthersPostVC.checkTabBarChanged = false
        
        BookPostVC.imgArray.removeAll()
        
    }
    
    //Share button handler
    @objc func share(sender: UIBarButtonItem) {
        //Work later for share and pop up the story
        print("share")
        uploadPost()
    }
    
    @IBAction func imgBtn_clicked(_ sender: Any) {
        AlbumVC.check = 2
    }
    
    
    //
    //collection view set up
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OthersPostVC.imgArray.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        //        if UIDevice.current.orientation.isPortrait {
        //            return CGSize(width: width/4 - 1, height: width/4 - 1)
        //        } else {
        //            return CGSize(width: width/6 - 1, height: width/6 - 1)
        //        }
        
        if OthersPostVC.imgArray.count == 1{
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        }else if OthersPostVC.imgArray.count == 2{
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        }else if OthersPostVC.imgArray.count == 3{
            return CGSize(width: width/3 - 1, height: width/3 - 1)
        }else if OthersPostVC.imgArray.count == 4{
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        }else{
            return CGSize(width: width/5 - 1, height: width/5 - 1)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewFullViewCell
        cell.img.image=OthersPostVC.imgArray[indexPath.row]
        return cell
    }
    //upload image to server
    func uploadPost(){
        let id = user!["id"] as! String
        let uuid = NSUUID().uuidString
        let text = textView.text as String
        let count = String(OthersPostVC.imgArray.count)
        let type = "Others"
        var title = ""
        var posOfNewline = Int.max
        var posOfHash = Int.max
        var posOfAt = Int.max
        
        if let indexOfNewline = text.index(of: "\n") {
            posOfNewline = text.distance(from: text.startIndex, to: indexOfNewline)
        }
        if let indexOfHash = text.index(of: "#") {
            posOfHash = text.distance(from: text.startIndex, to: indexOfHash)
        }
        if let indexOfAt = text.index(of: "@") {
            posOfAt = text.distance(from: text.startIndex, to: indexOfAt) + 1
        }
        
        if(posOfAt < posOfNewline || posOfAt < posOfHash){
            if(posOfNewline < posOfHash){
                title = String(text[posOfAt..<posOfNewline])
            }else if(posOfNewline == posOfHash){
                title = String(text[posOfAt..<text.count])
            }else{
                title = String(text[posOfAt..<posOfHash])
            }
        }
        
        let url = NSURL(string: "http://localhost/Han/Han/posts.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let param = [
            "id" : id,
            "uuid" : uuid,
            "title" : title,
            "text" : text,
            "count" : count,
            "type" : type
        ]
        let boundary = "Boundary-\(NSUUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParams(parameters: param, filePathKey: "file",uuid: uuid, images: OthersPostVC.imgArray, boundary: boundary) as Data
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler : {(data, response, error) in
            
            if error == nil{
                DispatchQueue.main.async {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        guard let parseJSON = json else{
                            print("Error while Parsing")
                            return
                        }
                        
                        let id = parseJSON["id"]
                        
                        if id != nil{
                            if(OthersPostVC.imgArray.count != 0){
                                OthersPostVC.imgArray.removeAll()
                                OthersPostVC.picColletionView.reloadData()
                                OthersPostVC.picColletionView.removeFromSuperview()
                            }
                            
                            self.textView.text = nil
                            
                            BookPostVC.checkTabBarChanged = false
                            OthersPostVC.checkTabBarChanged = false
                            
                            self.viewWillAppear(false)
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothLightGreenColor)
                        }else{
                            //pop up the error message
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothRedColor)
                            
                        }
                    }catch{
                        //pop up the error message
                        let message = error.localizedDescription
                        appDelegate.infoView(message: message, color: smoothRedColor)
                        
                    }
                    
                }
                
            }else{
                DispatchQueue.main.sync {
                    //pop up the error message
                    let message = error!.localizedDescription
                    appDelegate.infoView(message: message, color: smoothRedColor)
                }
            }
            
        });
        
        // do whatever you need with the task e.g. run
        task.resume()
    }
    
    //custom body of HTTP request to upload image file
    func createBodyWithParams(parameters: [String: String]?, filePathKey: String?,uuid : String?, images : [UIImage], boundary : String)-> NSData{
        let body = NSMutableData();
        
        for (key, value) in parameters! {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        var defFileName = ""
        
        if images.count == 0{
            body.appendString(string: "--\(boundary)\r\n")
            
            let mimetype = "image/jpg"
            
            defFileName = ""
            
            
            body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(defFileName)\"\r\n")
            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
            body.appendString(string: "\r\n")
            
        }else{
            for i in 0..<images.count{
                body.appendString(string: "--\(boundary)\r\n")
                
                let mimetype = "image/jpg"
                
                let filePath = "file\(i)"
                
                defFileName = uuid! + "post-\(i).jpg"
                
                
                let imageData = UIImageJPEGRepresentation(images[i], 0.5)
                
                print("=---------------")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(filePath)\"; filename=\"\(defFileName)\"\r\n")
                body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
                body.append(imageData!)
                body.appendString(string: "\r\n")
                
            }
        }
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        
        return body
    }

    
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

