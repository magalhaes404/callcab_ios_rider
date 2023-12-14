//
//  InvoiceModel.swift
// NewTaxi
//
//  Created by Seentechs on 17/10/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class InvoiceModel: NSObject {
    
    var invoiceKey : String = ""
    var invoiceValue : String = ""
    var bar = 0
    var color = String()
    var comment : String?
    override init(){}
    init(_ json : JSON){
        self.invoiceKey = json.string("key")
        self.invoiceValue = json.string("value")
        self.bar = json.int("bar")
        self.color = json.string("colour")
        if !json.string("comment").isEmpty{
            comment = json.string("comment")
        }
    }
    func initInvoiceData(responseDict: NSDictionary) -> Any
    {
        guard let json = responseDict as? JSON else {return self}
        self.invoiceKey = json.string("key")
        self.invoiceValue = json.string("value")
        self.bar = json.int("bar")
        self.color = json.string("colour")
        if !json.string("comment").isEmpty{
            comment = json.string("comment")
        }
        return self
    }

}
