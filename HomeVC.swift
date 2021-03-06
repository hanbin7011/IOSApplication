//
//  HomeVC.swift
//  Han
//
//  Created by Hanbin Park on 7/2/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var homeTabBar: UITabBar!
    
    var books = [NSDictionary]()
    

    var tmp = [Any]()
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    var images = [[UIImage]]()
    
    let username = user!["username"] as? String
    let email = user!["email"] as? String
    let ava = user!["ava"] as? String
    let id = user!["id"] as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTabBar.delegate = self
        
        
        //color of tabbar items
        let color = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        
        //color of item in tabbar controller
        self.homeTabBar.tintColor = .white
        
        //color of background of tabbar controller
        self.homeTabBar.barTintColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        //disable translucent
        self.homeTabBar.isTranslucent = false
        
        //color of text under icon in tabbar controller
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : color], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: UIControlState.selected)
        
        homeTabBar.selectedItem = homeTabBar.items![1] as UITabBarItem
        
        
        
        
        let viewHeight = self.view.frame.height
        let viewWidth = self.view.frame.width
        
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        
        
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        
        //set up layout
        avaImg.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        let xposition = avaImg.frame.origin.x + avaImg.frame.width + 10
        usernameLbl.frame = CGRect(x: xposition, y: 10, width: viewWidth - xposition - 10, height: 30)
        usernameLbl.textAlignment = .center
        emailLbl.frame = CGRect(x: xposition, y: usernameLbl.frame.origin.y + usernameLbl.frame.height, width: viewWidth - xposition - 10, height: 30)
        emailLbl.textAlignment = .center
        editBtn.frame = CGRect(x: xposition, y: emailLbl.frame.origin.y + emailLbl.frame.height, width: viewWidth - xposition - 10, height: 30)
        homeTabBar.frame = CGRect(x: 0, y: editBtn.frame.origin.y + editBtn.frame.height, width: viewWidth, height: 40)
        self.tableView.frame = CGRect(x: 0, y: homeTabBar.frame.origin.y + homeTabBar.frame.height + 10, width: viewWidth, height: viewHeight-(homeTabBar.frame.origin.y + homeTabBar.frame.height))
        
        postBtn.frame = CGRect(x: viewWidth - 85, y: (self.tabBarController?.tabBar.frame.origin.y)! - 160, width: 75, height: 75)
        
        self.tableView.rowHeight = 130
        self.view.addSubview(postBtn)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeTabBar.selectedItem = homeTabBar.items![0] as UITabBarItem
        
        loadPosts(showBooks: true)
        
        
        
        
        //get user profile picture
        if ava != ""{
            //url path to image
            let imageURL = NSURL(string: ava!)!
            
            //communivate back user as main queue
            DispatchQueue.main.async {
                //get data from image url
                let imageData = NSData(contentsOf: imageURL as URL)
                
                //if data is not nil assign it to ava.Img
                if imageData != nil{
                    DispatchQueue.main.async {
                        self.avaImg.image = UIImage(data: imageData! as Data)
                    }
                }
            }
        }
        
        
        usernameLbl.text = username?.uppercased()
        emailLbl.text = email
        self.navigationItem.title = username
        
        tableView.reloadData()
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(homeTabBar.items?.index(of: item) as! Int == 0){
            loadPosts(showBooks : true)
            
        }else{
            loadPosts(showBooks : false)
        }
    }
    
    
    //call picker to select image
    @objc func loadImg(recognizer: UITapGestureRecognizer){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avaImg.contentMode = .scaleAspectFit
            avaImg.image = pickedImage
            let imageData:Data = UIImagePNGRepresentation(pickedImage)!
        }
        
        
        self.dismiss(animated: false, completion: nil)
        
        
        //upload image
        uploadAva()
        
    }
    
    
    //upload image to server
    func uploadAva(){
        
        
        let url = NSURL(string: "http://localhost/Han/Han/uploadAva.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let param = ["id" : id]
        let boundary = "Boundary-\(NSUUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        
        if imageData == nil{
            return
        }
        
        request.httpBody = createBodyWithParams(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
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
                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                            user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary

                        }else{
                            //pop up the error message
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothRedColor)

                        }
                    }catch{
                        //pop up the error message
                        let message = error as! String
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
    func createBodyWithParams(parameters: [String: String]?, filePathKey: String?, imageDataKey : NSData, boundary : String)-> NSData{
        let body = NSMutableData();
        
        for (key, value) in parameters! {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        body.appendString(string: "--\(boundary)\r\n")
        
        let mimetype = "image/jpg"
        
        let defFileName = "ava.jpg"
        
        
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(defFileName)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    @IBAction func edit_clicked(_ sender: Any) {
        
    }
    
    @IBAction func logout_clicked(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "signInVC") as! signInVC
        self.present(signInVC, animated : true, completion: nil)
    }
    
    
    @IBAction func postBtn_cilcked(_ sender: Any) {
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostTabBarVC") as! PostTabBarVC
        if(tabBarItem == homeTabBar.items![0] as UITabBarItem){
            newViewController.clickedFromBook = true
        }else{
            newViewController.clickedFromBook = false
        }
        
        if(user!["latitude"] as! String == "0" && user!["longitude"] as! String == "0"){
            let alert = UIAlertController(title: "Alert", message: "In order to post, please update address", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
                
                let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditAdressVC") as! EditAdressVC
                editVC.fromHome = true
                self.navigationController?.present(editVC, animated: true, completion: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.present(newViewController, animated: true, completion: nil)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    //When Click the img, go to postVC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        
        post.books.append(books[indexPath.row] as! NSDictionary)
        
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! homePostCell
        var book = books[indexPath.row] as! NSDictionary
        
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormat.date(from: book["date"] as! String)
        
        let from = newDate
        let now = NSDate()
        let components : Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
        let differece = NSCalendar.current.dateComponents(components, from: from as! Date, to: now as! Date)
        
        if differece.second! <= 0 {
            cell.dateLbl.text = "now"
        }
        if differece.second! > 0 && differece.minute! == 0 {
            cell.dateLbl.text = "\(differece.second as! Int)sec"
        }
        if differece.minute! > 0 && differece.hour! == 0 {
            cell.dateLbl.text = "\(differece.minute as! Int)min"
        }
        if differece.hour! > 0 && differece.day! == 0 {
            cell.dateLbl.text = "\(differece.hour as! Int)hours"
        }
        if differece.day! > 0 && differece.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(differece.day as! Int)days"
        }
        if differece.weekOfMonth! > 0 {
            cell.dateLbl.text = "\(differece.weekOfMonth as! Int)month"
        }
        
        cell.titleLbl.text = book["title"] as! String

        if(images[indexPath.row].count != 0){
            cell.mainImg.image = images[indexPath.row][0]
        }else{
            cell.mainImg.image = UIImage()
        }
        
        return cell
    }
    
    func loadPosts(showBooks : Bool){
        let url = NSURL(string:"http://localhost/Han/Han/posts.php")
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        var body = "email=\(user!["email"] as! String)&type=Book"
        
        if(!showBooks){
            body = "email=\(user!["email"] as! String)&type=Others"
        }
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration:config)
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler : {(data, reponse, error) in
            
            if error == nil{
                DispatchQueue.main.async {
                    do{
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        as? NSDictionary
                        
                        guard let parseJSON = json else{
                            print("Error while Parsing")
                            return
                        }
                        
                        guard let posts = parseJSON["posts"] as? [NSDictionary] else{
                            print("Error while Parsing")
                            return
                        }
                        
                        self.books = posts
                        self.images.removeAll()
                        for i in 0 ..< self.books.count{
                            let pics = self.books[i]["path"] as! [String]
                            if(pics.count == 0){
                                self.images.append([])
                            }
                            for j in 0 ..< pics.count{
                                let path = pics[j] as? String
                                if !path!.isEmpty{
                                    let imgUrl = NSURL(string: path!)
                                    let imgData = NSData(contentsOf: imgUrl as! URL)
                                    if imgData != nil{
                                        let image = UIImage(data: imgData! as Data)
                                        if j == 0{
                                            self.images.append([image!])
                                        }else{
                                            self.images[i].append(image!)
                                        }
                                            
                                    }
                                }
                            }

                        }
                        
                        
                        self.tableView.reloadData()
                        
                    }catch{
                        let message = error.localizedDescription
                        print(message)
                        appDelegate.infoView(message: message, color: smoothRedColor)
                    }
                    
                }
            }else{
                DispatchQueue.main.sync {
                    let message = error!.localizedDescription
                    appDelegate.infoView(message: message, color: smoothRedColor)
                }
            }
        });
        
        task.resume()
    
    }
    
 
    
}

//Creating protocol of appending string to var data
extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


