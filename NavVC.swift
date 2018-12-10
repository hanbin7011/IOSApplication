//
//  NavVC.swift
//  Han
//
//  Created by Hanbin Park on 7/2/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //color of title at the top of nav controller
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        //color of buttons in nav controller
        self.navigationBar.tintColor = .white
        
        //color of background of nav controller /nav bar
        self.navigationBar.barTintColor = brandColor
        
        //disable translucent
        self.navigationBar.isTranslucent = false
    }
    
    //white status bar
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }


}
