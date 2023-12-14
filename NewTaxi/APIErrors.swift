//
//  APEErrors.swift
// NewTaxi
//
//  Created by Seentechs on 10/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

enum APIErrors : Error{
    case JSON_InCompatable
}
extension APIErrors : LocalizedError{
    var errorDescription: String?{
        return self.localizedDescription
    }
    var localizedDescription: String{
        let lang = Language.default.object
        switch self {
        case .JSON_InCompatable:
            return lang.jsonSerialaizationFailed
        default:
            return lang.no
        }
    }
}
