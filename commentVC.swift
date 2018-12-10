//
//  commnetVC.swift
//  Han
//
//  Created by Hanbin Park on 9/4/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class commentVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var commentsArray = [NSDictionary]()
    var uuid = ""
    var commentNum = 0
    var type = ""
    
    var keyboard = CGRect()
    
    var tableViewHeight : CGFloat = 0
    var commentHeight : CGFloat = 0
    var commentY : CGFloat = 0
    
    var from = 0
    var amount = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .red

        let width = self.view.frame.size.width
        let height = self.view.frame.size.width
        
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height  - 57)
        commentTxt.frame = CGRect(x: 10, y: tableView.frame.size.height + 7 , width: width / 4 * 3, height: 43)
        sendBtn.frame = CGRect(x: commentTxt.frame.origin.x + commentTxt.frame.size.width + 5, y: commentTxt.frame.origin.y, width: width - (commentTxt.frame.origin.x + commentTxt.frame.size.width + 10), height: commentTxt.frame.size.height)
        
        //set up, Scrolling the View setting
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //Hide keyboard when tab outside of textField
        let hidetap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        hidetap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hidetap)
        
        tableView.delegate = self
        tableView.dataSource = self
        commentTxt.delegate = self
        
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTxt.frame.size.height
        commentY = commentTxt.frame.origin.y
        
        if(self.commentNum > 0 && self.commentNum < amount){
            loadComments(from: self.from, amount : self.commentNum,uuid: uuid)
        }else if(self.commentNum > 0){
            loadComments(from: self.from, amount : self.amount,uuid: uuid)
        }
        
    
    }
    @IBAction func sendBtn_click(_ sender: Any) {
        var comment = commentTxt.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        let url = NSURL(string: "http://localhost/Han/Han/addComments.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let body = "uuid=\(uuid)&username=\(user!["username"] as! String)&comment=\(comment)&commentNum=\(commentNum+1)&type=\(self.type)"
        
        
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
                           
                            self.commentNum = self.commentNum+1
                            
                            self.loadComments(from: self.from, amount : 1 ,uuid: self.uuid)
                            self.tableView.reloadData()
                            
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
    
    func loadComments(from : Int, amount : Int, uuid : String){
        
        let url = NSURL(string: "http://localhost/Han/Han/loadComments.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let body = "from=\(from)&amount=\(amount)&uuid=\(uuid)"
        
        
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
                            
                            if(self.commentsArray.count != 0){
                                for tmp in parseJSON["result"] as! [NSDictionary]{
                                    self.commentsArray.append(tmp as! NSDictionary)
                                }
                            }else{
                                self.commentsArray = parseJSON["result"] as! [NSDictionary]
                            }
                            
                            self.from = self.from + self.commentsArray.count
                            
                            self.tableView.reloadData()
                            
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
    
    override func viewWillAppear(_ animated: Bool) {
        //hide bottom bar
        self.tabBarController?.tabBar.isHidden = true
        
        //call keyboard
        commentTxt.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Set up Scrolling View due to keyboard pop up
    @objc func adjustForKeyboard(notification: Notification) {
        
        let height = self.view.frame.size.height
        
        let userInfo = notification.userInfo!
        
        keyboard = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboard, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.frame.size.height = height - 57
            commentTxt.frame.origin.y = tableView.frame.height + 7
            sendBtn.frame.origin.y = commentTxt.frame.origin.y
        } else {
            commentTxt.frame.origin.y = keyboardViewEndFrame.origin.y - 57
            tableView.frame.size.height = height - commentTxt.frame.origin.y - 7
            sendBtn.frame.origin.y = commentTxt.frame.origin.y
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //cell config
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //declare cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! commentCell
        
        var commentInfo = commentsArray[indexPath.row] as! NSDictionary
        
        cell.usernameBtn.setTitle(commentInfo["username"] as! String, for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.commentLbl.text = commentInfo["comment"] as! String
        
        var ava = commentInfo["ava"] as? String
        
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
                        cell.avaImg.image = UIImage(data: imageData! as Data)
                    }
                }
            }
        }
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let from = dateFormat.date(from: commentInfo["date"] as! String)
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
        
        return cell
    }
    
    //while writing something
    func textViewDidChange(_ textView: UITextView) {
        
        //disable button if entered no text
        let spacing = NSCharacterSet.whitespacesAndNewlines
        if !commentTxt.text.trimmingCharacters(in: spacing).isEmpty{
            sendBtn.isEnabled = true
        }else{
            sendBtn.isEnabled = false
        }
        
        //+ paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            //redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            //move up tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
        //-  paragraph
        else if textView.contentSize.height < textView.frame.size.height{
             // find difference to deduct
            let difference  = textView.frame.size.height - textView.contentSize.height
            
            //redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            //move down tableView
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height{
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }

}
