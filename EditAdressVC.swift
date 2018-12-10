//
//  EditAdressVC.swift
//  Han
//
//  Created by Hanbin Park on 8/11/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import CoreLocation

class EditAdressVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var countryTxt: UITextField!
    var dropDown: UIPickerView!
    
    @IBOutlet weak var streetLbl: UILabel!
    @IBOutlet weak var streetTxt: UITextField!
    @IBOutlet weak var streetDetailTxt: UITextField!
    
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var cityTxt: UITextField!
    
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var stateTxt: UITextField!
    
    @IBOutlet weak var zipCodeLbl: UILabel!
    @IBOutlet weak var zipCodeTxt: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var fromHome = false
    
    var listOfCountry = ["Counrty/Region"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown = UIPickerView()
        
        dropDown.delegate = self
        dropDown.dataSource = self
        
        countryTxt.inputView = dropDown
        countryTxt.text = listOfCountry[0]
        
        
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            listOfCountry.append(name)
        }
        
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        
        //set up layout
        scrollView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        countryLbl.frame = CGRect(x: 10 , y: 10, width: viewWidth - 20, height: 35)
        countryTxt.frame = CGRect(x: 10, y: countryLbl.frame.origin.y + countryLbl.frame.height + 5 , width: viewWidth - 20, height: 30)
        streetLbl.frame = CGRect(x: 10, y: countryTxt.frame.origin.y + countryTxt.frame.height + 20, width: viewWidth - 20, height: 35)
        streetTxt.frame = CGRect(x: 10, y: streetLbl.frame.origin.y + streetLbl.frame.height + 5, width: viewWidth - 20, height: 30)
        streetDetailTxt.frame = CGRect(x: 10, y: streetTxt.frame.origin.y + streetTxt.frame.height + 5, width: viewWidth - 20, height: 30)
        cityLbl.frame = CGRect(x: 10, y: streetDetailTxt.frame.origin.y + streetDetailTxt.frame.height + 20, width: viewWidth - 20, height: 35)
        cityTxt.frame = CGRect(x: 10, y: cityLbl.frame.origin.y + cityLbl.frame.height + 5, width: viewWidth - 20, height: 30)
        stateLbl.frame = CGRect(x: 10, y: cityTxt.frame.origin.y + cityTxt.frame.height + 20, width: viewWidth - 20, height: 35)
        stateTxt.frame = CGRect(x: 10, y: stateLbl.frame.origin.y + stateLbl.frame.height + 5, width: viewWidth - 20, height: 30)
        zipCodeLbl.frame = CGRect(x: 10, y: stateTxt.frame.origin.y + stateTxt.frame.height + 20, width: viewWidth - 20, height: 35)
        zipCodeTxt.frame = CGRect(x: 10, y: zipCodeLbl.frame.origin.y + zipCodeLbl.frame.height + 5, width: viewWidth - 20, height: 30)
        
        saveBtn.frame = CGRect(x: 10, y: zipCodeTxt.frame.origin.y + zipCodeTxt.frame.height + 20, width: viewWidth/2 - 15, height: 30)
        cancelBtn.frame = CGRect(x: viewWidth/2 + 5, y: zipCodeTxt.frame.origin.y + zipCodeTxt.frame.height + 20, width: viewWidth/2 - 15, height: 30)
        
        //set up, Scrolling the View setting
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //Hide keyboard when tab outside of textField
        let hidetap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hidetap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
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
    
    @objc func dismissDropDown() {
        view.endEditing(true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listOfCountry.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listOfCountry[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryTxt.text = self.listOfCountry[row]
    }
    
    @IBAction func countryTxt_clicked(_ sender: Any) {
    }
    
    
    @IBAction func saveBtn_clicked(_ sender: Any) {
        if(countryTxt.text! == "Counrty/Region" || streetTxt.text!.isEmpty || cityTxt.text!.isEmpty || stateTxt.text!.isEmpty || zipCodeTxt.text!.isEmpty){
            
            if streetDetailTxt.text!.isEmpty{
                streetTxt.attributedPlaceholder = NSAttributedString(string: "Apartment, suite, unit, building, floor, etc.", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            }
            countryTxt.attributedPlaceholder = NSAttributedString(string: "Counrty/Region", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            streetTxt.attributedPlaceholder = NSAttributedString(string: "Street and number, P.O. box, c/o.", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
            cityTxt.attributedPlaceholder = NSAttributedString(string: "city", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            stateTxt.attributedPlaceholder = NSAttributedString(string: "state/ province /region", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            zipCodeTxt.attributedPlaceholder = NSAttributedString(string: "zip code", attributes: [NSAttributedStringKey.foregroundColor : UIColor.red])
            
        }else{
            var address : String
            if(streetDetailTxt.text!.isEmpty){
                address = streetTxt.text! + ", " + cityTxt.text! + ", " + stateTxt.text! + " " + zipCodeTxt.text! + ", " + countryTxt.text!
            }else{
                address = streetTxt.text! + streetDetailTxt.text!+", " + cityTxt.text! + stateTxt.text! + ", " +  " " + zipCodeTxt.text! + ", " + countryTxt.text!
            }
            
            if (!address.isEmpty){
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard let placemarks = placemarks, let location = placemarks.first?.location else{
                        return
                    }
                    
                    if(location.coordinate.latitude != nil && location.coordinate.longitude != nil ){
                        let url = NSURL(string: "http://localhost/Han/Han/setCoordinate.php")
                        let request = NSMutableURLRequest(url: url! as URL)
                        request.httpMethod = "post"
                        
                        let body = "id=\(user!["id"] as! String)&latitude=\(location.coordinate.latitude as! Double)&longitude=\(location.coordinate.longitude as! Double)"
                        
                        
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
                                        
                                        let status = parseJSON["status"] as! String
                                        
                                        if status == "200"{
                                            
                                            let message = parseJSON["message"] as! String
                                            appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                            
                                            UserDefaults.standard.set(parseJSON, forKey: "parseJSON")
                                            user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                            
                                            if(self.fromHome){
                                                
                                                self.dismiss(animated: true, completion: {
                                                    let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostTabBarVC") as! PostTabBarVC
                                                    self.present(newViewController, animated: true, completion: nil)
                                                    
                                                })
                                            }else{
                                                _ = self.navigationController?.popViewController(animated: true)
                                                
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
                    
                }
                
            }
        }
    }
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        if(fromHome){
            self.dismiss(animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    

}
