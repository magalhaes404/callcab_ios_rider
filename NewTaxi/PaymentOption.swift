//
//  PaymentOption.swift
// NewTaxi
//
//  Created by Seentechs on 29/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
enum PaymentOptions : String{
    case tips = "T"
    
    case brainTree = "B"
    case cash = "C"
    case paypal = "P"
    case stripe = "S"
    case onlinepayment = "O"
    static var `default` : PaymentOptions?{
        guard let string : String = UserDefaults.value(for: .payment_method) else{return nil}
        //        let char = string?.first?.uppercased()
        return PaymentOptions(rawValue: string.uppercased())
    }

    func with(wallet : Bool,promo : Bool) -> String{
        var value = self.rawValue
        if wallet{
            value.append("W")
        }
        if promo{
            value.append("P")
        }
        return value
    }
    
    func setAsDefault(){
        UserDefaults.set(self.rawValue, for: .payment_method)
     
    }
    var paramValue : String{
        switch self {
        case .brainTree:
            return "Braintree"
        case .paypal:
            return "Paypal"
        case .stripe:
            return "Stripe"
        case .cash:
            return "Cash"
        case .onlinepayment:
            return "onlinepayment"
        default:
            return "Cash"
        }
    }
    
    init(key : String) {
        switch key.lowercased() {
        case "stripe":
            self = .stripe
        case "cash":
            self = .cash
        case "paypal":
            self = .paypal
        case "braintree":
            self = .brainTree
        case "stripe_card":
            self = .stripe
        case "onlinepayment":
            self = .onlinepayment
        default:
            self = .cash
        }
    }
}
extension PaymentOptions : Codable{
    
}
