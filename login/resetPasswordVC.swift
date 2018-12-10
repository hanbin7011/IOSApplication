//
//  resetPasswordVC.swift
//  Han
//
//  Created by Hanbin Park on 5/31/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class resetPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide keyboard when tab outside of textField
        let hidetap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hidetap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
        
    }
    
    //Hide keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    //Set up reset password button
    @IBAction func resetBtn_clicked(_ sender: Any) {
        
        //Check textfield is empty or not
        if emailTxt.text!.isEmpty {
            emailTxt.attributedPlaceholder = NSAttributedString(string:"email", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
        }else{
            //Check email format
            if !appDelegate.isValidEmail(testStr: emailTxt.text!){
                DispatchQueue.main.async {
                    appDelegate.infoView(message: "Email format is not matched", color: smoothRedColor)
                    
                }
            }else{
                //communicate with php code by http post method
                let url = NSURL(string: "http://localhost/Han/Han/resetPassword.php")
                let request = NSMutableURLRequest(url: url! as URL)
                request.httpMethod = "post"
                
                let body = "email=\(emailTxt.text!)"
                request.httpBody = body.data(using:String.Encoding.utf8)
                
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                
                let task = session.dataTask(with: request as URLRequest, completionHandler:{(data,response,error) in if error == nil{
                    DispatchQueue.main.async {
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                            
                            guard let parseJSON = json else{
                                print("Error while Parsing")
                                return
                            }
                            
                            let email = parseJSON["email"]
                            
                            //Check success or not by checking status
                            if email != nil{
                                
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                
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
                    print("Error: \(String(describing: error)) ")
                    DispatchQueue.main.sync {
                        //pop up the error message
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: smoothRedColor)
                    }
                    }
                });
                
                task.resume()
            }
        }
    }
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
}
