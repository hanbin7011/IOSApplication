//
//  LocationManager.swift
//  Han
//
//  Created by Hanbin Park on 7/16/18.
//  Copyright © 2018 Hanbin Park. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationManager: NSObject,  CLLocationManagerDelegate{
    var coreLocationManager = CLLocationManager()
    
    class var SharedLocationManager:LocationManager{
        return GlobalVariableSharedInstance
    }
    
    
    func initLocationManager(){
        if (CLLocationManager.locationServicesEnabled()){
            coreLocationManager.delegate = self
            coreLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            coreLocationManager.startUpdatingLocation()
            coreLocationManager.startMonitoringSignificantLocationChanges()
        }
        else{
            let alert:UIAlertView = UIAlertView(title: "Message", message: "Location Services not Enabled. Please enable Location Services", delegate: nil, cancelButtonTitle: "ok")
            alert.show()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        if (locations.count > 0){
            var _:CLLocation = locations[0] as! CLLocation
            coreLocationManager.stopUpdatingLocation()
        }
        
    }
    
    
    
    func currentLocation() -> CLLocation {
        var location:CLLocation? = coreLocationManager.location
        if (location==nil) {
            location = CLLocation(latitude: 51.368123, longitude: -0.021973)
        }
        
        return location!
    }
    
    
}

let GlobalVariableSharedInstance = LocationManager()
