//
//  MobileNumber.swift
// NewTaxi
//
//  Created by Seentechs on 11/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
/**
 Model for mobile number
 - Author: Abishek Robin
 - Note: class has Mobile number and flag(CountryCode,FlagImage,DialCode)
 */
struct MobileNumber {
    let number : String
    let flag : CountryModel
}
