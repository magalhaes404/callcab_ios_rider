//
//  iTunesConfig.swift
// NewTaxi
//
//  Created by Seentechs on 25/09/21.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

protocol iTunesData {
    var appName : String{get}
    var appStoreDisplayName : String{get}
    var appID : String{get}
    var appStoreLink : URL?{get}
}
extension iTunesData{
    var appStoreLink : URL?{
        return URL(string: "https://itunes.apple.com/us/app/\(appStoreDisplayName)/\(appID)?mt=8")
        
    }
}
