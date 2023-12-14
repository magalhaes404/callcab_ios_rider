//
//  LocationManager.swift
// NewTaxi
//
//  Created by Seentechs on 22/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

class LocationManager : CLLocationManager{
    override init() {
        super.init()
    }
    static let instance = LocationManager()
    
    var isAuthorized : Bool{
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
}
