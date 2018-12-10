//
//  newsVC.swift
//  Han
//
//  Created by Hanbin Park on 8/16/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class newsVC: UITableViewController {

    var from = 0
    var amount = 10
    
    var news = [NSDictionary]()
    override func viewDidLoad() {
        super.viewDidLoad()

        loadNews(from: from, amount: amount)
    }


    func loadNews(from : Int, amount : Int){
        let url = NSURL(string: "http://localhost/Han/Han/getNews.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let body = "username=\(user!["username"] as! String)&from=\(from)&amount=\(amount)"
        
        
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
                            
                            if(self.news.count != 0){
                                for tmp in parseJSON["result"] as! [NSDictionary]{
                                    self.news.append(tmp as! NSDictionary)
                                }
                            }else{
                                self.news = parseJSON["result"] as! [NSDictionary]
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! newsCell
        
        cell.usernameBtn.setTitle(news[indexPath.row]["newsBy"] as! String, for: .normal)
        cell.usernameBtn.sizeToFit()
        cell.infoLbl.text = news[indexPath.row]["type"] as! String
        
        let path = news[indexPath.row]["ava"] as! String
        
        if(path != ""){
            let imgUrl = NSURL(string: path)
            let imgData = NSData(contentsOf: imgUrl as! URL)
            
            if(imgData != nil){
                let image = UIImage(data: imgData as! Data)
                cell.avaImg.image = image
            }
        }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormat.date(from: news[indexPath.row]["date"] as! String)
        
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
        
        return cell
    }

    
}
