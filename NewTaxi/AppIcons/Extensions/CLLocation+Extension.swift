//
//  CLLocation+Extension.swift
// NewTaxi
//
//  Created by Seentechs on 27/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D{
    var location : CLLocation{
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}
