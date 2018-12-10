//
//  EditVC.swift
//  Han
//
//  Created by Hanbin Park on 8/11/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import Photos

class EditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var avaImg: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var repassTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var firstnameTxt: UITextField!
    @IBOutlet weak var lastnameTxt: UITextField!
    
    @IBOutlet weak var editAddressBtn: UIButton!
    
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var ava = ""
    var username = ""
    var email = ""
    var fullname = ""
    var firstname = ""
    var lastname = ""
    var passWord = ""
    var checkSameUsernameEmail = "0"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        
        //set up layout
        scrollView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        avaImg.frame = CGRect(x: viewWidth/2 - 40 , y: 40, width: 80, height: 80)
        usernameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y + avaImg.frame.height + 30, width: viewWidth - 20, height: 30)
        passTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + usernameTxt.frame.height + 20, width: viewWidth - 20, height: 30)
        repassTxt.frame = CGRect(x: 10, y: passTxt.frame.origin.y + passTxt.frame.height + 20, width: viewWidth - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: repassTxt.frame.origin.y + repassTxt.frame.height + 20, width: viewWidth - 20, height: 30)
        firstnameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + emailTxt.frame.height + 20, width: viewWidth/2 - 15, height: 30)
        lastnameTxt.frame = CGRect(x: viewWidth/2 + 5, y: emailTxt.frame.origin.y + emailTxt.frame.height + 20, width: viewWidth/2 - 15, height: 30)
        
        editAddressBtn.frame = CGRect(x: 10, y: firstnameTxt.frame.origin.y + firstnameTxt.frame.height + 20, width: viewWidth - 20, height: 35)
        changeBtn.frame = CGRect(x: 10, y: editAddressBtn.frame.origin.y + editAddressBtn.frame.height + 20, width: viewWidth/2 - 15, height: 30)
        cancelBtn.frame = CGRect(x: viewWidth/2 + 5, y: editAddressBtn.frame.origin.y + editAddressBtn.frame.height + 20, width: viewWidth/2 - 15, height: 30)
        
        ava = user!["ava"] as! String
        username = user!["username"] as! String
        email = user!["email"] as! String
        fullname = user!["fullname"] as! String
        
        usernameTxt.placeholder = user!["username"] as! String
        emailTxt.placeholder = email
        passWord = "****"
        
        if fullname != ""{
            if fullname.lowercased().range(of:" ") != nil {
                firstname = fullname.components(separatedBy: " ")[0]
                firstnameTxt.placeholder = fullname.components(separatedBy: " ")[0]
                lastname = fullname.components(separatedBy: " ")[1]
                lastnameTxt.placeholder = fullname.components(separatedBy: " ")[1]
            }
        }
        
        passTxt.placeholder = "****"
        repassTxt.placeholder = "****"
        
        
        
        //get user profile picture
        if ava != ""{
            //url path to image
            let imageURL = NSURL(string: ava)!
            
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
        
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        
        //set up, Scrolling the View setting
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //Hide keyboard when tab outside of textField
        let hidetap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hidetap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
        
        
        
        //declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)

    }
    
    //call picker to select image
    @objc func loadImg(recognizer: UITapGestureRecognizer){
        checkPermission()
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
        }
        
        dismiss(animated: false, completion: nil)
        
        //upload image
        uploadAva()
        
    }
    
    
    //upload image to server
    func uploadAva(){
        let id = user!["id"] as! String
        
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

    //Set up permission for photo library
    @objc func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Set up Scrolling View due to keyboard pop up
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        if notification.name != Notification.Name.UIKeyboardWillHide {
            scrollView.setContentOffset(CGPoint(x:0,y:80), animated: true)
        }
        
    }
    
    @IBAction func changeBtn_clicked(_ sender: Any) {
        var check = true
        //Check All TextFields are filled or not
        if(!usernameTxt.text!.isEmpty || !passTxt.text!.isEmpty || !repassTxt.text!.isEmpty || !emailTxt.text!.isEmpty || !firstnameTxt.text!.isEmpty || !lastnameTxt.text!.isEmpty){
            
            if( !passTxt.text!.isEmpty || !repassTxt.text!.isEmpty){
                if(passTxt.text!.isEmpty || repassTxt.text!.isEmpty){
                    passTxt.attributedPlaceholder = NSAttributedString(string: "****", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
                    repassTxt.attributedPlaceholder = NSAttributedString(string: "****", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
                    
                    check = false
                }else{
                    if passTxt.text != repassTxt.text{
                        //Slide down the information!!!
                        appDelegate.infoView(message: "Password do not Match", color: smoothRedColor)
                        check = false
                        
                    }else{
                        
                        passWord = passTxt.text as! String
                        
                    }
                }
            }
            
            if(usernameTxt.text != ""){
                
                
                if(usernameTxt.text! as! String == username){
                    appDelegate.infoView(message: "Same as your Username", color: smoothRedColor)
                    check = false
                }else{
                    username = usernameTxt.text! as! String
                }
            }else{
                //put "username" to checkSameUsernameEmail if username is not type
                checkSameUsernameEmail = checkSameUsernameEmail + "username"
            }
            
            if(emailTxt.text != ""){
                
                if(emailTxt.text! as! String == email){
                    appDelegate.infoView(message: "Same as your email", color: smoothRedColor)
                    username = user!["username"] as! String
                    check = false
                }//Check email format
                else if !appDelegate.isValidEmail(testStr: emailTxt.text!){
                    appDelegate.infoView(message: "Email format is not matched", color: smoothRedColor)
                    username = user!["username"] as! String
                    check = false
                }else{
                    email = emailTxt.text! as! String
                }
            }else{
                //put "email" to checkSameUsernameEmail if email is not type
                checkSameUsernameEmail = checkSameUsernameEmail + "email"
            }
            
            if(firstnameTxt.text != ""){
                firstname = firstnameTxt.text! as! String
            }
            
            if(lastnameTxt.text != ""){
                lastname = lastnameTxt.text! as! String
            }
            
            if(check){
                //Communicate with php code
                let url = NSURL(string: "http://localhost/Han/Han/changeUserInfo.php")
                let request = NSMutableURLRequest(url: url! as URL)
                request.httpMethod = "post"
                
                let body = "username=\(username)&password=\(passWord)&email=\(email)&fullname=\(firstname)%20\(lastname)&id=\(user!["id"] as! String)&checkSameUsernameEmail=\(checkSameUsernameEmail)"
                request.httpBody = body.data(using: String.Encoding.utf8)
                
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                    
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
                                    //pop up the error message
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                    
                                    
                                    //Store data to automatically login
                                    UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                    user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                    self.checkSameUsernameEmail="0"
                                    
                                    self.navigationController?.popToRootViewController(animated: true)
                                    
                                    
                                }else{
                                    //pop up the error message
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: smoothRedColor)
                                    
                                    self.username = user!["username"] as! String
                                    self.email = user!["email"] as! String
                                    self.fullname = user!["fullname"] as! String
                                    self.checkSameUsernameEmail = "0"
                                    
                                    
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
            
            
        }
    }
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
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
    

}
