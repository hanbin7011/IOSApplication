 //
//  AppDelegate.swift
//  Han
//
//  Created by Hanbin Park on 5/31/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate

let smoothRedColor = UIColor(red: 255/255, green: 50/255, blue: 75/255, alpha: 1)
let smoothLightGreenColor = UIColor(red: 30/255, green: 244/255, blue: 125/255, alpha: 1)
let brandColor = UIColor(red: 45/355, green: 213/255, blue: 255/255, alpha: 1)

let fontSize12 = UIScreen.main.bounds.width / 28
var user : NSDictionary?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var infoViewShowing = false
    
    
    //Login and go to main tabBar
    func login(tempUser : NSDictionary){
        
        UserDefaults.standard.set(tempUser, forKey: "parseJSON")
        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
        
        let storyboaerd = UIStoryboard(name: "Main", bundle: nil)
        
        let tabBar = storyboaerd.instantiateViewController(withIdentifier: "tabBar")
        
        window?.rootViewController = tabBar
    }
    
    //Check Email Validation
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
        
        //Check user already login or not
        if user != nil{
            
            let id = user!["id"] as? String
            print(user)
            
            if id != nil{
                login(tempUser: user!)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func infoView(message:String,color:UIColor) {
        if infoViewShowing == false{
            infoViewShowing = true
            let infoView_Height = self.window!.bounds.height / 10
            let infoView_Y = infoView_Height
            
            
            let infoView = UIView(frame: CGRect(x: 0, y: -infoView_Y, width: self.window!.bounds.width, height: infoView_Height))
            infoView.backgroundColor = color
            self.window!.addSubview(infoView)
            
            let infoLabel_width = infoView.bounds.width
            let infoLabel_height = infoView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
            
            let infoLabel = UILabel()
            infoLabel.frame.size.width = infoLabel_width
            infoLabel.frame.size.height = infoLabel_height
            infoLabel.numberOfLines = 0
            
            infoLabel.text = message
            infoLabel.font = UIFont(name: "HelveticaNeue", size: fontSize12)
            infoLabel.textColor = .white
            infoLabel.textAlignment = .center
            
            infoView.addSubview(infoLabel)
            
            UIView.animate(withDuration: 0.9, animations: {
                infoView.frame.origin.y = 0
    
            }, completion: {(finished:Bool) in
                if finished{
                    UIView.animate(withDuration: 0.9, animations: {
                        infoView.frame.origin.y = -infoView_Y
                        
                    }, completion: {(finished:Bool) in
                        if finished{
                            
                            infoView.removeFromSuperview()
                            infoLabel.removeFromSuperview()
                            self.infoViewShowing = false
                        }
                    })
                }
            })
        }
    }


}

