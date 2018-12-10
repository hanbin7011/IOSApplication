//
//  SignUpVC.swift
//  Han
//
//  Created by Hanbin Park on 5/31/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import Photos

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //TextFields
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    
    //ScrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    //reset default size
    var scrollViewHeight : CGFloat = 0
    
    //keyboard frame size
    var keyboard = CGRect()
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set up layout
        scrollView.frame = CGRect(x:0,y:0, width:self.view.frame.width, height:self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        avaImg.frame = CGRect(x: self.view.frame.width/2 - 40, y: self.scrollView.frame.origin.y + 30, width: 80, height: 80)
        
        usernameTxt.frame = CGRect(x: 10, y: avaImg.frame.origin.y  + avaImg.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y  + usernameTxt.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        repeatPasswordTxt.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y  + passwordTxt.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: repeatPasswordTxt.frame.origin.y  + repeatPasswordTxt.frame.height + 10, width: self.view.frame.width - 20, height: 30)
        firstNameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y  + emailTxt.frame.height + 10, width: self.view.frame.width / 2 - 20, height: 30)
        lastNameTxt.frame = CGRect(x: firstNameTxt.frame.width + 20, y: emailTxt.frame.origin.y  + emailTxt.frame.height + 10, width: self.view.frame.width / 2 - 20, height: 30)
        
        signUpBtn.frame = CGRect(x: 10, y: firstNameTxt.frame.origin.y  + firstNameTxt.frame.height + 10, width: self.view.frame.width / 2 - 20, height: 30)
        cancelBtn.frame = CGRect(x: signUpBtn.frame.width + 20, y: firstNameTxt.frame.origin.y  + firstNameTxt.frame.height + 10, width: self.view.frame.width / 2 - 20, height: 30)
        
        //set up, Scrolling the View setting
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
       
        //Hide keyboard when tab outside of textField
        let hidetap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hidetap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
     
        
        //round ava
        avaImg.layer.cornerRadius = avaImg.frame.width/2
        avaImg.clipsToBounds = true
        
        //declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        avaTap.numberOfTapsRequired = 1
        avaImg.isUserInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        scrollView.addSubview(avaImg)
        scrollView.addSubview(usernameTxt)
        scrollView.addSubview(passwordTxt)
        scrollView.addSubview(repeatPasswordTxt)
        scrollView.addSubview(emailTxt)
        scrollView.addSubview(firstNameTxt)
        scrollView.addSubview(lastNameTxt)
        scrollView.addSubview(signUpBtn)
        scrollView.addSubview(cancelBtn)
        
        
        
    
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
    
    @objc func myTargetFunction(textField: UITextField) {
        print("myTargetFunction")
    }

    //Set up sign up button
    @IBAction func signUpBtn_click(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        //Check All TextFields are filled or not
        if(usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || firstNameTxt.text!.isEmpty || lastNameTxt.text!.isEmpty){
            
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            repeatPasswordTxt.attributedPlaceholder = NSAttributedString(string: "repeat password", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            firstNameTxt.attributedPlaceholder = NSAttributedString(string: "first name", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            lastNameTxt.attributedPlaceholder = NSAttributedString(string: "last name", attributes: [.foregroundColor : UIColor.red])
            
        }else{
        
            //Check the passwords are matching
            if passwordTxt.text != repeatPasswordTxt.text {
                
                //Slide down the information!!!

                    appDelegate.infoView(message: "Password do not Match", color: smoothRedColor)

                
            }else{
                
                //Check email format
                if !appDelegate.isValidEmail(testStr: emailTxt.text!){
                    DispatchQueue.main.async {
                        appDelegate.infoView(message: "Email format is not matched", color: smoothRedColor)
                        
                    }
                }else{
                    //Communicate with php code
                    let url = NSURL(string: "http://localhost/Han/Han/register.php")
                    let request = NSMutableURLRequest(url: url! as URL)
                    request.httpMethod = "post"
                    
                    let body = "username=\(usernameTxt.text!.lowercased())&password=\(passwordTxt.text!)&email=\(emailTxt.text!)&fullname=\(firstNameTxt.text!)%20\(lastNameTxt.text!)"
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
                                        
                                        
                                        
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "emailConfirmationVC") as! emailConfirmationVC
                                        
                                        //Send data(email, token) to EmailConfirmationVC
                                        emailConfirmationVC.token = parseJSON["token"] as! String
                                        emailConfirmationVC.emailTxt = self.emailTxt.text!
                                        
                                        self.present(vc, animated: false, completion: nil)
                                        
                                        //Store data to automatically login
//                                        UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
//                                        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
//
//                                        DispatchQueue.main.async {
//                                            appDelegate.login()
//                                        }
                                        
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
            }
        }
        
        
    }
    //Set up cancel button
    @IBAction func cancelBtn_click(_ sender: AnyObject) {
         self.dismiss(animated: false, completion: nil)
    }
    
}
