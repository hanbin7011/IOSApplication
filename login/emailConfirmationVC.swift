//
//  emailConfirmationVC.swift
//  Han
//
//  Created by Hanbin Park on 6/25/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class emailConfirmationVC: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var sendEmailBtn: UIButton!
    @IBOutlet weak var confirmCodeTxt: UITextField!
    
    //Get data(token and email) from other VC(signUpVC, changeEmailVC)
    static var token:String = ""
    static var emailTxt:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show email to EmailLabel
        self.emailLabel.text = emailConfirmationVC.emailTxt
        self.emailLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        
    }
    
    //When dimiss other activity, always change emailLabel
    override func viewWillAppear(_ animated: Bool) {
        self.emailLabel.text = emailConfirmationVC.emailTxt
    }
    
    
    //Setup confirmation button
    @IBAction func confirmBtn_clicked(_ sender: Any) {
        //Check textField is empty
        if confirmCodeTxt.text!.isEmpty{
            confirmCodeTxt.attributedPlaceholder = NSAttributedString(string: "confirmation code", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            
            
        }else{
            //Check confimation code is correct
            if(emailConfirmationVC.token != confirmCodeTxt.text!){
                DispatchQueue.main.async {
                    let message = "Invalid Confirmation Code"
                    appDelegate.infoView(message: message, color: smoothRedColor)
                }
            
            //if it is correct delete token and dismiss current VC
            }else{
                deleteToken(checkLogin: true)
                self.parent?.dismiss(animated: false, completion: nil)
                self.dismiss(animated: false, completion: nil)
            }
            
        }
    }
    
    //Setup deleteToken function
    public func deleteToken(checkLogin: Bool){
        let url = NSURL(string: "http://localhost/Han/Han/deleteToken.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        //check delete with login or not
        var body = "token=\(emailConfirmationVC.token)&confirmationStatus=0"
        
        if(checkLogin){
            body = "token=\(emailConfirmationVC.token)&confirmationStatus=1"
        }
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler:{(data, reponse,error) in
            
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
                            //If deleteToken called from confirmation button login
                            if(checkLogin){
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                
                                UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                user = UserDefaults.standard.value(forKey: "parsJSON") as? NSDictionary
                                
                                DispatchQueue.main.async {
                                    appDelegate.login(tempUser: parseJSON)
                                }
                            }
                            
                        }else{
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothRedColor)
                            
                        }
                    }catch{
                        print(error)
                    }
                }
            }else{
                let message = error!.localizedDescription
                appDelegate.infoView(message: message, color: smoothRedColor)
            }
        });
        
        task.resume()
        
        
    }
    
    //Set up cancel Button, and delete token
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        deleteToken(checkLogin: false)
        let url = NSURL(string: "http://localhost/Han/Han/deleteUser.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        if(emailConfirmationVC.emailTxt != ""){
            let body = "email=\(emailConfirmationVC.emailTxt)"
            request.httpBody = body.data(using: String.Encoding.utf8)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler:{(data, reponse,error) in
                
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
                                let message = parseJSON["message"] as! String
                                print(message)
                                
                            }else{
                                let message = parseJSON["message"] as! String
                                print(message)
                                
                            }
                        }catch{
                            print(error)
                        }
                    }
                }else{
                    let message = error!.localizedDescription
                    appDelegate.infoView(message: message, color: smoothRedColor)
                }
            });
            
            task.resume()
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    //Set up send email button
    @IBAction func sendEamilBtn_clicked(_ sender: Any) {
        //Delete token without login
        deleteToken(checkLogin: false)
        
        let url = NSURL(string: "http://localhost/Han/Han/sendEmail.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        if(emailConfirmationVC.emailTxt != "" && emailConfirmationVC.token != ""){
            let body = "email=\(emailConfirmationVC.emailTxt)&token=\(emailConfirmationVC.token)"
            request.httpBody = body.data(using: String.Encoding.utf8)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler:{(data, reponse,error) in
                
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
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                
                                emailConfirmationVC.token = parseJSON["token"] as! String
                            }else{
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothRedColor)
                                
                            }
                        }catch{
                            print(error)
                        }
                    }
                }else{
                    let message = error!.localizedDescription
                    appDelegate.infoView(message: message, color: smoothRedColor)
                }
            });
            
            task.resume()
        }else{
            DispatchQueue.main.async {
                let message = "Email is not Set up"
                appDelegate.infoView(message: message, color: smoothRedColor)
            }
        }
        
    }
    
    
    // set up change email button, show new change Email VC with send data
    @IBAction func changeEmailBtn_clicked(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "changeEmailVC") as! changeEmailVC
        
        //Send data to emailConfirmationVC
        vc.token = emailConfirmationVC.token
        vc.emailTxt = emailConfirmationVC.emailTxt
        
        self.present(vc, animated: false, completion: nil)
    }
    
   
    

}
