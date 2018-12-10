//
//  signInVC.swift
//  Han
//
//  Created by Hanbin Park on 5/31/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class signInVC: UIViewController {

    //TextFields
    @IBOutlet weak var appNameLb: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    //Buttons
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        //Alignment
        appNameLb.frame = CGRect(x:10, y:80, width:self.view.frame.size.width-20,height: 50)
        emailTxt.frame = CGRect(x: 10, y: appNameLb.frame.origin.y + 70, width: self.view.frame.size.width-20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 30, width: self.view.frame.size.width - 20, height: 30)
        forgotBtn.frame = CGRect(x: 15, y: passwordTxt.frame.origin.y + 15 , width: self.view.frame.size.width - 20, height: 30)
        logInBtn.frame = CGRect(x: 10, y: forgotBtn.frame.origin.y + 30, width: self.view.frame.size.width/4, height: 30)
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width/4 - 10, y: logInBtn.frame.origin.y, width: self.view.frame.size.width/4, height: 30)
        
        //Set up hide keyboard when tab outside of TextField
        let hidetap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hidetap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
        
        
    }
    //Hide keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    //Clicked Log In Button
    @IBAction func logInBtn_click(_ sender: AnyObject) {
        self.dismissKeyboard()
        //Check All textFields are empty or not
        if emailTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
            emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "passwoard", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
        }else{
            //Check email format
            if !appDelegate.isValidEmail(testStr: emailTxt.text!){
                DispatchQueue.main.async {
                    appDelegate.infoView(message: "Email format is not matched", color: smoothRedColor)
                    
                }
            }else{
                let email = emailTxt.text!
                let password = passwordTxt.text!
                
                let url = NSURL(string:"http://localhost/Han/Han/login.php")
                
                let request = NSMutableURLRequest(url: url! as URL)
                request.httpMethod = "post"
                
                let body = "email=\(email)&password=\(password)"
                
                request.httpBody = body.data(using: String.Encoding.utf8)
                
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration:config)
          
                
                let task = session.dataTask(with: request as URLRequest, completionHandler : {(data, reponse, error) in
                    
                    if error == nil{
                        DispatchQueue.main.async {
                            do{
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                guard let parseJSON = json else{
                                    print("Error while Parsing")
                                    return
                                }
                                
                                
                                let id = parseJSON["id"]
                                //Check email exist or not
                                if id != nil{
                                    
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                    
                                    UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                    user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                    print(user)
                                    
                                    DispatchQueue.main.async {
                                        appDelegate.login(tempUser: parseJSON)
                                    }
                                    
                                    
                                }else{
                                    
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: smoothRedColor)
                                        
                                    
                                }
                            }catch{
                                let message = error as! String
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
    }
    
    

}
