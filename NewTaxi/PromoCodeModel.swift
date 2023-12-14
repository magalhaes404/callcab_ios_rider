//
//  PromoCode.swift
// NewTaxi
//
//  Created by Seentechs Technologies on 24/11/17.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class PromoCodeModel : NSObject {

    var status_message : String = ""
    var status_code : String = ""
    var promo_amount_details : NSMutableArray = NSMutableArray()
    var id : String = ""
    var code : String = ""
    var amount : String = ""
    var expire_date : String = ""
    var arrTemp1 : NSMutableArray = NSMutableArray()
    var promo_details = PromoMode()


}
class RequestOptions: NSObject {
    let id : Int
    let name : String
    var isSelected : Bool = false
    override init(){
        id = 0
        name = ""
    }
    init(_ json : JSON){
        self.id = json.int("id")
        self.name = json.string("name")
        self.isSelected = json.bool("isSelected")
    }
    init(copy : RequestOptions){
        self.id = copy.id
        self.name = copy.name
        self.isSelected = copy.isSelected
    }
    func update(fromData data: RequestOptions){
        self.isSelected = data.isSelected
    }
}
class Support: NSObject {
    let id : Int
    let name : String
    var link : String
    var image : String
    override init(){
        id = 0
        name = ""
        link = ""
        image = ""
    }
    init(_ json : JSON){
        self.id = json.int("id")
        self.name = json.string("name")
        self.link = json.string("link")
        self.image = json.string("image")
    }
}
