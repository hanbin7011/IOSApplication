//
//  PostTabBarVC.swift
//  Han
//
//  Created by Hanbin Park on 7/3/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class PostTabBarVC: UITabBarController, UITabBarControllerDelegate {

    @IBOutlet weak var postTabBar: UITabBar!
    
    var clickedFromBook = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self as UITabBarControllerDelegate
        
        //color of tabbar items
        let color = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        
        //color of item in tabbar controller
        self.tabBar.tintColor = .white
        
        //color of background of tabbar controller
        self.tabBar.barTintColor = brandColor
        
        //disable translucent
        self.tabBar.isTranslucent = false
        
        //color of text under icon in tabbar controller
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : color], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white], for: UIControlState.selected)
    
        
        
    }
    
    
    
}


