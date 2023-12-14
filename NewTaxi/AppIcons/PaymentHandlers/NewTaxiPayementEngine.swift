//
// NewTaxiPayementEngine.swift
// NewTaxi
//
//  Created by Seentechs on 18/06/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
protocol PaymentType {
    var name : String { get }
    var logo : UIImage?{ get }
    
    func setUP() throws
    
    
}
