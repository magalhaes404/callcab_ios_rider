//
//  FIRRiderModel.swift
// NewTaxi
//
//  Created by Seentechs on 04/06/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

protocol FIRModel {
    var updateValue : [AnyHashable:Any]{get}

}

class FIRRiderModel : DriverDetailModel,FIRModel{
    
    var updateValue: [AnyHashable:Any]{
        return ["trip_id":self.getTripID]
    }
    
    override init(withJson json: JSON) {
        super.init(withJson: json)
    }
    
}

