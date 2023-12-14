//
//  RiderStatus.swift
// NewTaxi
//
//  Created by Seentechs on 24/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

enum UserStatus : Int{
    
    case online = 1
    case offline = 0
}
extension Bool : ExpressibleByIntegerLiteral{
    public init(integerLiteral value: Int) {
        self = value != 0
    }
}
