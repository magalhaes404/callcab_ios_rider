//
//  PromoMode.swift
// NewTaxi
//
//  Created by Seentechs on 25/11/17.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class PromoContainerModel : Codable{
    var promos : [PromoMode]
    
    enum CodingKeys : String, CodingKey{
        case promos = "promo_details"
    }
    required init(from decoder : Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
        self.promos = try container.decodeIfPresent([PromoMode].self, forKey: .promos) ?? [PromoMode]()

        Constants().STOREVALUE(value: self.promos.count.description, keyname: USER_PROMO_CODE)
    }
}

class PromoMode : Codable{
    var amount : String = ""
    var code : String = ""
    var expire_date : String = ""
    
    enum CodingKeys: String, CodingKey {
        case amount
        case code
        case expire_date
    }
    init() {}
    required init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount = container.safeDecodeValue(forKey: .amount)
        self.code = container.safeDecodeValue(forKey: .code)
        self.expire_date = container.safeDecodeValue(forKey: .expire_date)
    }
    //GET THE VALUE FOR JSON
    func initPromoData(responseDict: NSDictionary) -> Any
    {
        amount = responseDict["amount"] as? String ?? String()
        code = responseDict["code"] as? String ?? String()
        expire_date = responseDict["expire_date"] as? String ?? String()
        
        return self
    }

}

