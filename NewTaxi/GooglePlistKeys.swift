//
//  GooglePlistKeys.swift
// NewTaxi
//
//  Created by Seentechs on 15/05/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

enum GooglePlistKeys : String{
    case clientId = "CLIENT_ID"
    case apiKey = "API_KEY"
}
extension GooglePlistKeys : PlistKeys{
    var key: String{
        return self.rawValue
    }
    
    static var fileName: String {
        return "GoogleService-Info"
    }
    
    
}

