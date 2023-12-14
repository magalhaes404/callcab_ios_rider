//
//  APIProtocols.swift
// NewTaxi
//
//  Created by Seentechs on 23/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Alamofire


//MARK:- protocol APILoadersProtocol
/**
 api progress loading handler
 - Author: Abishek Robin
 */
protocol APILoadersProtocol{
    func shouldLoad(_ shouldLoad: Bool,function : String)
}
extension APILoadersProtocol{
    
    func shouldLoad(_ shouldLoad: Bool,function : String = #function){
        self.shouldLoad(shouldLoad, function: function)
    }
}

