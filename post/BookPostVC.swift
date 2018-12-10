//
//  BookPostVC.swift
//  Han
//
//  Created by Hanbin Park on 7/3/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

import Photos


class BookPostVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UITextViewDelegate{

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var imgBtn: UIButton!
    
    static var picColletionView: UICollectionView!
    var countLbl : UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    static var imgArray = [UIImage]()
    
    static var checkTabBarChanged = false
    var keyBoardSatartHeight : CGFloat = 0
    
    var uuid = String()
    
    var viewHeight : CGFloat = 0
    var viewWidth : CGFloat = 0
    
    var shareButton : UIBarButtonItem!
    
    //keyboard frame size
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let screenSize = UIScreen.main.bounds
        viewWidth = screenSize.width
        viewHeight = screenSize.height
        countLbl = UILabel(frame: CGRect(x: viewWidth - 200, y: viewHeight - 150, width: 50, height: 40))
        countLbl.text = String(500)
        countLbl.textColor = UIColor.lightGray
        
        shareButton = UIBarButtonItem(title: "Share", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AlbumVC.share(sender:)))
        self.navigationItem.rightBarButtonItem = shareButton
        
        
        //set up, Change textView and collectionView when keyboard pop up.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboardBook), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.adjustForKeyboardBook), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //Set up textview when first pop up
        textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight - 100)
        textViewDidBeginEditing(textView)
        textViewDidEndEditing(textView)
        textView.text = "@Title#comment#comment..."
        textView.textColor = UIColor.lightGray
        textView.delegate = self
       
        //Add image button when first pop up
        imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 150, width: 100, height: 40)
        
        
        //add image button to view
        self.view.addSubview(countLbl)
        self.view.addSubview(imgBtn)
        
        // Set up Back and share button in navigation bar
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AlbumVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        
        
    }
    
    
    //Always check the setting when page open again
    override func viewWillAppear(_ animated: Bool) {
        
        
        if(BookPostVC.checkTabBarChanged){
            print("1")
            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: keyBoardSatartHeight)
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: keyBoardSatartHeight + 111, width: viewWidth, height: 40)
        }else{
            print("2")
            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            countLbl.frame = CGRect(x: viewWidth - 200, y: viewHeight - 150, width: 50, height: 40)
            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 150, width: 100, height: 40)
            
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight-40, width: viewWidth, height: 40)
        }
       
//        if (OthersPostVC.checkTabBarChanged && !BookPostVC.checkTabBarChanged){
//            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 60, width: 100, height: 40)
//            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight + 40, width: viewWidth, height: 40)
//        }else if(BookPostVC.checkTabBarChanged){
//
//            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: keyBoardSatartHeight + 111, width: viewWidth, height: 40)
//        }else{
//            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 150, width: 100, height: 40)
//            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight - 40, width: viewWidth, height: 40)
//            textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//        }
        
        //If image is sent, show the image
        if(BookPostVC.imgArray.count > 0){
            
            if ( BookPostVC.picColletionView == nil){
                let layout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                layout.minimumInteritemSpacing=0
                layout.minimumLineSpacing=0
                layout.scrollDirection = .horizontal
                
                var collectionViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewHeight / 3)
                
                
                if(BookPostVC.imgArray.count == 1){
                    
                    collectionViewFrame = CGRect(x: viewWidth / 4, y: 2, width: self.view.frame.size.width, height: viewHeight / 3)
                    
                }
                
                
                //set up the collection view
                BookPostVC.picColletionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
                BookPostVC.picColletionView.delegate=self
                BookPostVC.picColletionView.dataSource=self
                BookPostVC.picColletionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
                BookPostVC.picColletionView.isPagingEnabled = true
                BookPostVC.picColletionView.backgroundColor = UIColor.white
                
                //Put textview bottom of collection view
                textView.frame = CGRect(x: 0, y: viewHeight / 3, width: self.view.frame.size.width, height: 100)
                
                let button = UIButton(frame: CGRect(x: 5, y: 5, width: 25, height: 25))
                button.backgroundColor = .black
                button.setTitle("X", for: .normal)
                button.addTarget(self, action: #selector(removeImgAction), for: .touchUpInside)
                BookPostVC.picColletionView.addSubview(button)
                self.view.addSubview(BookPostVC.picColletionView)
                
                BookPostVC.picColletionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
            }else{
                BookPostVC.picColletionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewHeight / 3)
                
                if(BookPostVC.imgArray.count == 1){
                    
                    BookPostVC.picColletionView.frame = CGRect(x: viewWidth / 4, y: 2, width: self.view.frame.size.width, height: viewHeight / 3)
                    
                }

                //Put textview bottom of collection view
                textView.frame = CGRect(x: 0, y: viewHeight / 3, width: self.view.frame.size.width, height: 100)
                
                
                self.view.addSubview(BookPostVC.picColletionView)
                
                BookPostVC.picColletionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
            }
            
            
        }
    }
    
    @objc func removeImgAction(sender: UIButton!) {
        BookPostVC.imgArray.removeAll()
        BookPostVC.picColletionView.reloadData()
        BookPostVC.picColletionView.removeFromSuperview()
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
            BookPostVC.checkTabBarChanged = true
        }
        
        
    }
    
    //re-set up  hint text
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "@"{
            textView.text = "@Title#comments#comments..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    //Set up View due to keyboard pop up
    @objc func adjustForKeyboardBook(notification: Notification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            print("3")
            countLbl.frame = CGRect(x: viewWidth - 200, y: viewHeight - 170, width: 50, height: 40)
            imgBtn.frame = CGRect(x: viewWidth - 100, y: viewHeight - 170, width: 100, height: 40)
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: viewHeight + 40, width: viewWidth, height: 40)
        } else {
            print("4")
            self.keyBoardSatartHeight = keyboardViewEndFrame.height
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: keyboardViewEndFrame.height + 111, width: viewWidth, height: 40)
            
            
            //check image showing or not
            if(textView.frame.minY != 0){
                //check how many image and set up depend on that
                if(BookPostVC.imgArray.count == 1){
                    textView.frame = CGRect(x: 0, y: viewHeight / 3, width: viewWidth, height: keyboardViewEndFrame.height + 50 - viewHeight / 3)
                    BookPostVC.picColletionView.frame = CGRect(x: viewWidth / 4, y: 2, width: viewWidth, height: viewHeight / 3)
                    self.view.addSubview(BookPostVC.picColletionView)
                }else{
                    textView.frame = CGRect(x: 0, y: viewHeight / 3, width: viewWidth, height: keyboardViewEndFrame.height + 50 - viewHeight / 3)
                    BookPostVC.picColletionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: viewHeight / 3)
                    self.view.addSubview(BookPostVC.picColletionView)
                }
                
            }else{
                textView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: keyboardViewEndFrame.height + 50)
            }
            
            //add image button
            countLbl.frame = CGRect(x: viewWidth - 200, y: keyboardViewEndFrame.height + 10, width: 50, height: 40)
            imgBtn.frame = CGRect(x: self.view.frame.size.width - 100, y: keyboardViewEndFrame.height + 10, width: 100, height: 40)
        }
        
        
    }
    
    //Back button action handledr, clear the data when back button clicked
    @objc func back(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
        BookPostVC.imgArray.removeAll()
        self.textView.text = nil
        
        BookPostVC.checkTabBarChanged = false
        OthersPostVC.checkTabBarChanged = false
        
        OthersPostVC.imgArray.removeAll()
        
        
    }
    
    //Share button handler
    @objc func share(sender: UIBarButtonItem) {
        //Work later for share and pop up the story
        print("share")
        uploadPost()
    }
    
    @IBAction func imgBtn_clicked(_ sender: Any) {
        AlbumVC.check = 1
    }
    
    
    //
    //collection view set up
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BookPostVC.imgArray.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        //        if UIDevice.current.orientation.isPortrait {
        //            return CGSize(width: width/4 - 1, height: width/4 - 1)
        //        } else {
        //            return CGSize(width: width/6 - 1, height: width/6 - 1)
        //        }
        
        if BookPostVC.imgArray.count == 1{
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        }else if BookPostVC.imgArray.count == 2{
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        }else if BookPostVC.imgArray.count == 3{
            return CGSize(width: width/3 - 1, height: width/3 - 1)
        }else if BookPostVC.imgArray.count == 4{
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
        cell.img.image=BookPostVC.imgArray[indexPath.row]
        return cell
    }
    
    //upload image to server
    func uploadPost(){
        let id = user!["id"] as! String
        let uuid = NSUUID().uuidString
        let text = textView.text as String
        var title = ""
        var posOfNewline = Int.max
        var posOfSpace = Int.max
        var posOfHash = Int.max
        var posOfAt = Int.max
        
        if let indexOfNewline = text.index(of: "\n") {
            posOfNewline = text.distance(from: text.startIndex, to: indexOfNewline)
        }
        
        //
        //
        //    Should I have to put space for writing title?
        //
        //
        if let indexOfSpace = text.index(of: " ") {
            posOfSpace = text.distance(from: text.startIndex, to: indexOfSpace)
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
        print("----------------------------------------------------------")
        print(title)
        
        let count = String(BookPostVC.imgArray.count)
        let type = "Book"
        
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
        
        request.httpBody = createBodyWithParams(parameters: param, filePathKey: "file", uuid: uuid, images: BookPostVC.imgArray, boundary: boundary) as Data
        
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
                            if(BookPostVC.imgArray.count != 0){
                                BookPostVC.imgArray.removeAll()
                                BookPostVC.picColletionView.reloadData()
                                BookPostVC.picColletionView.removeFromSuperview()
                            }
                            
                            
                            self.textView.text = nil
                            
                            BookPostVC.checkTabBarChanged = false
                            OthersPostVC.checkTabBarChanged = false
                            
                            self.dismiss(animated: true, completion: nil)
                            
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothLightGreenColor)
                        }else{
                            //pop up the error message
                            print("1")
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothRedColor)
                            
                        }
                    }catch{
                        //pop up the error message
                        print("2")
                        let message = error.localizedDescription
                        appDelegate.infoView(message: message, color: smoothRedColor)
                        
                    }
                    
                }
                
            }else{
                DispatchQueue.main.sync {
                    //pop up the error message
                    print("3")
                    let message = error!.localizedDescription
                    appDelegate.infoView(message: message, color: smoothRedColor)
                }
            }
            
        });
        
        // do whatever you need with the task e.g. run
        task.resume()
    }
    
    //custom body of HTTP request to upload image file
    func createBodyWithParams(parameters: [String: String]?, filePathKey: String?, uuid: String? , images : [UIImage], boundary : String)-> NSData{
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





//Cell class
class ImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
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


