//
//  PostVC.swift
//  Han
//
//  Created by Hanbin Park on 8/4/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import CoreLocation

class PostVC: UITableViewController {

    var books = [NSDictionary]()
    
    var from = 0
    var amount = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = self.view.frame.width + 185
        loadTable(from: from)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")  as! PostCell
            cell.mainImgs.frame.size.height = self.view.frame.width - 10
            cell.mainImgs.frame.size.width = self.view.frame.width - 10
            self.tableView.reloadData()
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")  as! PostCell
            cell.mainImgs.frame.size.height = self.view.frame.width - 10
            cell.mainImgs.frame.size.width = self.view.frame.width - 10
            self.tableView.reloadData()
        }
    }


    func loadTable(from : Int){
        
        let url = NSURL(string: "http://localhost/Han/Han/feed.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let body = "from=\(from)&amount=\(amount)&id=\(user!["id"] as! String)"
        
        
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
                            
                            if(self.books.count != 0){
                                for tmp in parseJSON["result"] as! [NSDictionary]{
                                    self.books.append(tmp as! NSDictionary)
                                }
                            }else{
                                self.books = parseJSON["result"] as! [NSDictionary]
                            }
                            
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
    
    @IBAction func shareBtn_click(_ sender: AnyObject) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let url = NSURL(string: "http://localhost/Han/Han/following.php")
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let cell = self.tableView.cellForRow(at: i as IndexPath) as! PostCell
        
        var type = "share"
        var uuid = books[i.row]["uuid"] as! String
        var style = books[i.row]["type"] as! String
        if(cell.shareBtn.titleLabel?.text == "Shared"){
            type = "unshare"
        }
        let body = "newsToID=\(books[i.row]["id"] as! Int)&newsByID=\(user!["id"] as! String)&newsByUsername=\(user!["username"] as! String)&type=\(type)&newsToUsername=\(uuid)&style=\(style)"
        
        
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
                            
                            
                            
                            if(parseJSON["news"] as! String != "news"){
                                cell.shareBtn.setTitle("Share", for: .normal)
                                cell.shareBtn.setTitleColor(.blue, for: .normal)
                            }else{
                                cell.shareBtn.setTitle("Shared", for: .normal)
                                cell.shareBtn.setTitleColor(.red, for: .normal)
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
    
    @IBAction func userBtn_click(_ sender: AnyObject) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let cell = self.tableView.cellForRow(at: i as IndexPath) as! PostCell
        
        if(user!["username"] as? String == cell.usernameBtn.titleLabel?.text){
            self.tabBarController?.selectedIndex = 2
        }else{
            
            
            let url = NSURL(string: "http://localhost/Han/Han/getUserInfo.php")
            
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "post"
            
            let body = "username=\(cell.usernameBtn.titleLabel?.text as! String)"
            
            
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
                                
                                let otherHomeVC = self.storyboard?.instantiateViewController(withIdentifier: "othersHomeVC") as! othersHomeVC
                                otherHomeVC.username = parseJSON["username"] as! String
                                otherHomeVC.email = parseJSON["email"] as! String
                                otherHomeVC.id = parseJSON["id"] as! String
                                otherHomeVC.ava = parseJSON["ava"] as! String
                                otherHomeVC.follow = true
                                self.navigationController?.pushViewController(otherHomeVC, animated: true)
                                
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
    
    
    @IBAction func commentBtn_click(_ sender: AnyObject) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        //call cell to call further cell data
        let cell = self.tableView.cellForRow(at: i as IndexPath) as! PostCell
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        comment.uuid = books[i.row]["uuid"] as! String
        comment.commentNum = books[i.row]["commentNum"] as! Int
        comment.type = books[i.row]["type"] as! String
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    
    @IBAction func sharingBtn_clicked(_ sender: AnyObject) {
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        let url = NSURL(string: "http://localhost/Han/Han/changeSold.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        
        let body = "type=\(books[i.row]["type"] as! String)&sold=\(books[i.row]["sold"] as! Int)&uuid=\(books[i.row]["uuid"] as! String)"
        
        
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
                            
                            let cell = self.tableView.cellForRow(at: i as IndexPath) as! PostCell
                            
                            if(parseJSON["sold"] as! Int == 1){
                                cell.sharingBtn.setTitle("Sold", for: .normal)
                                cell.sharingBtn.setTitleColor(.green, for: .normal)
                            }else{
                                cell.sharingBtn.setTitle("Sharing", for: .normal)
                                cell.sharingBtn.setTitleColor(.blue, for: .normal)
                            }
                            
                            
                            self.books[i.row].setValue(parseJSON["sold"] as! Int, forKey: "sold")
                            
                           
                            
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
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.frame.size.width = self.view.frame.width
        cell.frame.size.height = cell.contentLbl.frame.origin.y + cell.contentLbl.frame.height
        
        
        var book = books[indexPath.row] as! NSDictionary
        let username = user!["username"] as? String
        let email = user!["email"] as? String
        let ava = user!["ava"] as? String
        
        
        
        
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
        
        cell.avaImg.layer.cornerRadius = cell.avaImg.frame.width/2
        cell.avaImg.clipsToBounds = true
        
        cell.usernameBtn.setTitle(book["username"] as? String, for: .normal)
        
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
        cell.contentLbl.text = book["text"] as! String
        
        cell.images.removeAll()
        let pics = book["path"] as! [String]
        
        
        
        if(user!["latitude"] != nil && user!["longitude"] != nil && book["latitude"] != nil && book["longitude"] != nil){
            var userLocation = CLLocation(latitude: (user!["latitude"] as AnyObject).doubleValue, longitude:(user!["longitude"] as! AnyObject).doubleValue)
            var stuffLocation = CLLocation(latitude: (book["latitude"] as AnyObject).doubleValue, longitude:(book["longitude"] as! AnyObject).doubleValue)
            
            cell.distanceLbl.text = String(round(userLocation.distance(from: stuffLocation) / 1609.344 * 10) / 10) + " miles"
        
        }else{
            cell.distanceLbl.text = "?? miles"
        }
        
        
        if(book["sold"] as! Int == 1){
            cell.sharingBtn.setTitle("Sold", for: .normal)
            cell.sharingBtn.setTitleColor(.red, for: .normal)
        }else{
            cell.sharingBtn.setTitle("Sharing", for: .normal)
            cell.sharingBtn.setTitleColor(.green, for: .normal)
        }
        
        if (pics.count != 0){
            
            for i in 0 ..< pics.count{
                let path = pics[i] as? String
                if (!path!.isEmpty){
                    let imgUrl = NSURL(string: path!)
                    let imgData = NSData(contentsOf: imgUrl as! URL)
                    if imgData != nil{
                        let image = UIImage(data: imgData! as Data)
                        
                        cell.images.append(image!)
                        
                    }
                    
                    
                }
                
            }
            
        }
        var shares: [String] = book["shares"] as! [String]
        if(shares.contains(username!)){
            cell.shareBtn.setTitle("Shared", for: .normal)
            cell.shareBtn.setTitleColor(.red, for: .normal)
        }else{
            cell.shareBtn.setTitle("Share", for: .normal)
            cell.shareBtn.setTitleColor(.blue, for: .normal)
        }
        
        cell.mainImgs.frame.size.height = cell.mainImgs.frame.size.width
        cell.mainImgs.reloadData()
        //asign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.sharingBtn.layer.setValue(indexPath, forKey: "index")
        cell.shareBtn.layer.setValue(indexPath, forKey: "index")
        
        
        return cell
    }

    
    
}


