//
//  searchVC.swift
//  Han
//
//  Created by Hanbin Park on 8/7/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit
import CoreLocation

class searchVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate , UITabBarDelegate {

    @IBOutlet weak var searchTabBar: UITabBar!
    
    var searchingInfo = [NSDictionary]()
    
    var searchedInfo = [NSDictionary]()
    
    var followingUsername = [String]()
    
    var collectionView : UICollectionView!
    
    let locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var searchBar = UISearchBar()
    
    var distanceDiff = 0.5
    var bookDis = 0.5
    var othersDis = 0.5
    var bookFrom = 0
    var othersFrom = 0
    var amount = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        searchBar.showsCancelButton = false
        
        collectionViewLaunch()
        
        searchedInfo.removeAll()
        searchingInfo.removeAll()
        collectionView.reloadData()
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchedInfo.removeAll()
        self.collectionView.reloadData()
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
            
            currentLocation = locManager.location
            
        }
        
        if(currentLocation != nil){
            searchTabBar.selectedItem = searchTabBar.items![0] as UITabBarItem
            loadBookByDistance(currentLocation: currentLocation, from: bookFrom, amount: amount)
            bookFrom += amount
            searchTabBar.isHidden = false
        }
        
        getFollwingUsername()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if(searchTabBar.items?.index(of: item) as! Int == 0){
            searchedInfo.removeAll()
            othersFrom = 1
            loadBookByDistance(currentLocation: currentLocation, from: bookFrom, amount: amount)
            bookFrom += amount
            
        }else{
            searchedInfo.removeAll()
            bookFrom = 1
            loadOthersByDistance(currentLocation: currentLocation, from: othersFrom, amount: amount)
            othersFrom += amount
            
        }
    }
    //Get following User Name
    func getFollwingUsername(){
        let url = NSURL(string: "http://localhost/Han/Han/getFollowingUsername.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let id = user!["id"] as! String
        let body = "id=\(id)"
        
        
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
                            
                            self.followingUsername.removeAll()
                            
                            
                            self.followingUsername = parseJSON["result"] as! [String]
 
                            self.collectionView.reloadData()
                            
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
    
    //Get Post product depends on distance
    func loadBookByDistance(currentLocation : CLLocation, from : Int, amount: Int){
        let url = NSURL(string: "http://localhost/Han/Han/searchBookByDistance.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let latitudeFrom = currentLocation.coordinate.latitude - bookDis
        let latitudeTo = currentLocation.coordinate.latitude + bookDis
        
        let longitudeFrom = currentLocation.coordinate.longitude - bookDis
        let longitudeTo = currentLocation.coordinate.longitude + bookDis
        
        let body = "latitudeFrom=\(latitudeFrom)&latitudeTo=\(latitudeTo)&longitudeFrom=\(longitudeFrom)&longitudeTo=\(longitudeTo)&from=\(from)&amount=\(amount)"
        
        
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
                            
                            if(self.searchedInfo.count != 0){
                                for tmp in parseJSON["result"] as! [NSDictionary]{
                                    self.searchedInfo.append(tmp as! NSDictionary)
                                }
                            }else{
                                self.searchedInfo = parseJSON["result"] as! [NSDictionary]
                            }
                            

                            self.collectionView.reloadData()
                            
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
    
    func loadOthersByDistance(currentLocation : CLLocation, from : Int, amount: Int){
        let url = NSURL(string: "http://localhost/Han/Han/searchOthersByDistance.php")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        
        let latitudeFrom = currentLocation.coordinate.latitude - othersDis
        let latitudeTo = currentLocation.coordinate.latitude + othersDis
        
        let longitudeFrom = currentLocation.coordinate.longitude - othersDis
        let longitudeTo = currentLocation.coordinate.longitude + othersDis
        
        let body = "latitudeFrom=\(latitudeFrom)&latitudeTo=\(latitudeTo)&longitudeFrom=\(longitudeFrom)&longitudeTo=\(longitudeTo)&from=\(from)&amount=\(amount)"
        
        
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
                            
                            if(self.searchedInfo.count != 0){
                                for tmp in parseJSON["result"] as! [NSDictionary]{
                                    self.searchedInfo.append(tmp as! NSDictionary)
                                }
                            }else{
                                self.searchedInfo = parseJSON["result"] as! [NSDictionary]
                            }


                            self.collectionView.reloadData()
                            
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
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text != ""){
            collectionView.isHidden = true
            searchTabBar.isHidden = true
            let url = NSURL(string: "http://localhost/Han/Han/search.php")
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "post"
            let body = "search=\(searchBar.text?.lowercased() as! String)&id=\(user!["id"] as! String)"
            
            
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
                                
                                self.searchingInfo.removeAll()
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                
                                self.searchingInfo = parseJSON["match"] as! [NSDictionary]
                                
                                for tmp in parseJSON["result"] as! [NSDictionary]{
                                    self.searchingInfo.append(tmp as! NSDictionary)
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
        }else{
            searchingInfo.removeAll()
            tableView.reloadData()
            collectionView.isHidden = false
            searchTabBar.isHidden = false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        collectionView.isHidden = true
        searchTabBar.isHidden = true
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Dismiss keyborad
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        searchingInfo.removeAll()
        searchBar.showsCancelButton = false
        collectionView.isHidden = false
        searchTabBar.isHidden = false
        self.tableView.reloadData()
    }
    
    
    //
    //Tableview setup
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchingInfo.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! searchCell
        
        if(searchingInfo[indexPath.row]["username"] != nil){
            cell.keyWordsLbl.text = searchingInfo[indexPath.row]["username"] as! String
            
            cell.avaImg.isHidden = false
            cell.postNum.isHidden = true
            cell.followBtn.isHidden = false
            cell.keyWordsLbl.frame.origin.x = cell.avaImg.frame.size.width + 20
            if(followingUsername.contains(searchingInfo[indexPath.row]["username"] as! String)){
                cell.followBtn.setTitle("following", for: .normal)
                cell.followBtn.setTitleColor(.green, for: .normal)
            }
            cell.followBtn.tag = indexPath.row
            cell.followBtn.addTarget(self, action: #selector(registerFollowing(_:)), for: .touchUpInside)
            let path = searchingInfo[indexPath.row]["ava"] as! String
            if(path != ""){
                let imgUrl = NSURL(string: path)
                let imgData = NSData(contentsOf: imgUrl as! URL)
                
                if imgData != nil{
                    let image = UIImage(data: imgData! as Data)
                    cell.avaImg.image = image
                }
            }
        }else{
            cell.followBtn.isHidden = true
            cell.avaImg.isHidden = true
            cell.postNum.isHidden = false
            
            cell.keyWordsLbl.frame.origin.x = 20
            cell.keyWordsLbl.text = searchingInfo[indexPath.row]["word"] as! String
            cell.postNum.text = String(searchingInfo[indexPath.row]["postNum"] as! Int) + " public posts"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(searchingInfo[indexPath.row]["word"] != nil){
            searchedInfo.removeAll()
            self.collectionView.reloadData()
            
            let url = NSURL(string: "http://localhost/Han/Han/searchResult.php")
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "post"
            
            let body = "search=\(searchBar.text?.lowercased() as! String)&id=\(user!["id"] as! String)"
            
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
                                
                                //Change email success, send data(token,emil) to emailConfirmationVC and dismiss VC
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: smoothLightGreenColor)
                                
                                self.searchedInfo = parseJSON["result"] as! [NSDictionary]
                                
                                self.collectionView.reloadData()
                                
                                self.searchingInfo.removeAll()
                                self.tableView.reloadData()
                                
                                self.collectionView.isHidden = false
                                self.searchTabBar.isHidden = false
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
            if(searchingInfo[indexPath.row]["username"] != nil){
                if(user!["username"] as? String == searchingInfo[indexPath.row]["username"] as! String){
                    self.tabBarController?.selectedIndex = 2
                }else{
                    
                    
                    let url = NSURL(string: "http://localhost/Han/Han/getUserInfo.php")
                    
                    let request = NSMutableURLRequest(url: url! as URL)
                    request.httpMethod = "post"
                    
                    let body = "username=\(searchingInfo[indexPath.row]["username"] as! String)"
                    
                    
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
                                        if(self.followingUsername.contains(self.searchingInfo[indexPath.row]["username"] as! String)){
                                            otherHomeVC.follow = true
                                        }
                                        
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
        }
    }
    
    
    @objc func registerFollowing(_ button: UIButton) {
        var type = "follow"

        if(button.titleLabel?.text == "following"){
            type = "unfollow"
        }
        let url = NSURL(string: "http://localhost/Han/Han/following.php")
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "post"
        let body = "newsToID=\(searchingInfo[button.tag]["id"] as! Int)&newsByID=\(user!["id"] as! String)&newsByUsername=\(user!["username"] as! String)&newsToUsername=\(searchingInfo[button.tag]["username"] as! String)&type=\(type)"
        
        
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
                            
                            if(type == "unfollow"){
                                self.followingUsername = self.followingUsername.filter{$0 != self.searchingInfo[button.tag]["username"] as! String}
                            }else{
                                self.followingUsername.append(self.searchingInfo[button.tag]["username"] as! String)
                            }
                            let message = parseJSON["message"] as! String
                            appDelegate.infoView(message: message, color: smoothLightGreenColor)
                            
                            
                            
                            if(type == "follow"){
                                button.setTitle("following", for: .normal)
                                button.setTitleColor(.green, for: .normal)
                            }else{
                                button.setTitle("follow", for: .normal)
                                button.setTitleColor(.blue, for: .normal)
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
    
    //
    //CollectionView setup
    //
    func collectionViewLaunch(){
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        let frame = CGRect(x: 0, y: 5+self.searchTabBar.frame.height, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 40 - self.searchTabBar.frame.height)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        
        searchTabBar.delegate = self
        
        
        //color of tabbar items
        let color = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        
        //color of item in tabbar controller
        self.searchTabBar.tintColor = .white
        
        //color of background of tabbar controller
        self.searchTabBar.barTintColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        //disable translucent
        self.searchTabBar.isTranslucent = false
        
        //color of text under icon in tabbar controller
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : color], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: UIControlState.selected)
        
        searchTabBar.frame = CGRect(x: 0, y: self.searchTabBar.frame.height, width: self.view.frame.width, height: 30)
        
        searchTabBar.selectedItem = searchTabBar.items![0] as UITabBarItem
        
        self.view.addSubview(collectionView)
        
        //define cell for collectionView
        collectionView.register(searchCollecionCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedInfo.count
    }
    
    //cell config
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! searchCollecionCell
        
        cell.titleLbl.text = searchedInfo[indexPath.row]["title"] as! String
        
        let pathArray = searchedInfo[indexPath.row]["path"] as! [String]
        var path = ""
        if(pathArray.count >= 1){
            path = pathArray[0] as! String
        }
        
        if(path != ""){
            let imgUrl = NSURL(string: path)
            let imgData = NSData(contentsOf: imgUrl as! URL)
            
            if imgData != nil{
                let image = UIImage(data: imgData! as Data)
                cell.picImg.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: collectionView.frame.size.width/2 , height: collectionView.frame.size.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        post.books.removeAll()
        var stuff = searchedInfo[indexPath.row] as! NSDictionary
        post.books.append(stuff)
        
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    class searchCollecionCell: UICollectionViewCell {
        
        var picImg = UIImageView()
        var titleLbl = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.layer.borderWidth = 0.3
            
            picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height / 3 * 2))
            
            titleLbl = UILabel(frame: CGRect(x: 5, y: self.frame.size.height / 3 * 2, width: self.frame.size.width, height: self.frame.size.height / 3 ))
            
            titleLbl.font = titleLbl.font.withSize(15)
            
            self.addSubview(picImg)
            self.addSubview(titleLbl)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
    

}
