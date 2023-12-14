//
//  PaymentOptionModel.swift
// NewTaxi
//
//  Created by Seentechs on 03/02/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation



class PaymentOptionModel : Codable{
    var key : String
    var value : String
    var icon : String
    var isDefault : Bool
    enum CodingKeys: String,CodingKey{
        case key,value,icon,isDefault = "is_default"
    }
    
    lazy var option : PaymentOptions = {
        return PaymentOptions(key: self.key)
    }()
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.key = container.safeDecodeValue(forKey: .key)
        self.value = container.safeDecodeValue(forKey: .value)
        self.icon = container.safeDecodeValue(forKey: .icon)
        self.isDefault = container.safeDecodeValue(forKey: .isDefault)
        
        if key.lowercased() == "stripe"{
            let last = String(value.suffix(4))
            guard !last.lowercased().contains("x") else{return}
            UserDefaults.set(last, for: .card_last_4)
            
        }else if key.lowercased() == "braintree"{
            UserDefaults.set(value, for: .brain_tree_display_name)
        }
    }
}
