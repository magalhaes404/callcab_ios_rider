/**
* CurrencyModel.swift
 // NewTaxi
 //
 //  Created by Seentechs on 16/05/18.
 //  Copyright © 2021 Seen Technologies. All rights reserved.
 //
* @link http://seentechs.com
*/


import Foundation
import UIKit

class CurrencyModel : NSObject {
    
    //MARK Properties
    var success_message : String = ""
    var status_code : String = ""
    var currency_code : String = ""
    var currency_symbol : String = ""
    override init() {
        super.init()
    }
    convenience init(from json : JSON) {
        self.init()
        self.currency_code = json.string("code")
        self.currency_symbol = json.string("symbol")
    }
   // MARK: Inits
    func initiateCurrencyData(responseDict: NSDictionary) -> Any
    {
//        currency_code = self.checkParamTypes(params: responseDict, keys:"code")
//        currency_symbol = self.checkParamTypes(params: responseDict, keys:"symbol")
        return self
    }
    
    
    //MARK: Check Param Type
    func checkParamTypes(params:NSDictionary, keys:NSString) -> NSString
    {
        if let latestValue = params[keys] as? NSString {
            return latestValue as NSString
        }
        else if let latestValue = params[keys] as? String {
            return latestValue as NSString
        }
        else if let latestValue = params[keys] as? Int {
            return String(format:"%d",latestValue) as NSString
        }
        else if (params[keys] as? NSNull) != nil {
            return ""
        }
        else
        {
            return ""
        }
    }

}
