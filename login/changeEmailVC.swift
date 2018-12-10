//
//  changeEmailVC.swift
//  Han
//
//  Created by Hanbin Park on 6/27/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class changeEmailVC: UIViewController {

    @IBOutlet weak var newEmailTxt: UITextField!
    
    var emailTxt:String = ""
    var token:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //Setup change email button
    @IBAction func changeEmailBtn_clicked(_ sender: Any) {
        
        //Check TextField is empty
        if newEmailTxt.text!.isEmpty{
            newEmailTxt.attributedPlaceholder = NSAttributedString(string: "New Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            
            //Check input new email is same as email which is already get now, if yes resend email and dismiss VC
        }else if newEmailTxt.text! == emailTxt{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "emailConfirmationVC") as! emailConfirmationVC
            vc.sendEamilBtn_clicked(emailConfirmationVC())
            self.dismiss(animated: false, completion: nil)
            
            //Change email from user database and resend new token to new email
        }else{
            let url = NSURL(string: "http://localhost/Han/Han/changeEmail.php")
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "post"
            
            let body = "email=\(emailTxt)&token=\(token)&newEmail=\(newEmailTxt.text!)"
            
            
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
                                
                                //Change email success, send data(token,emil) to emailConfirmationVC and dismiss VC
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                
                                emailConfirmationVC.token = parseJSON["token"] as! String
                                emailConfirmationVC.emailTxt = parseJSON["email"] as! String
                                
                                
                                self.dismiss(animated: false, completion: nil)
                                
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
    }
    
    //Setup cancel button
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
