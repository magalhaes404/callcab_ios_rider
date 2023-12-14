//
//  Flag.swift
// NewTaxi
//
//  Created by Seentechs on 19/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import UIKit

class CountryModel{
    var country_code : String
    var dial_code : String
    var flag : UIImage
    var name : String
    
    private let plist = Bundle.contentsOfFileArray(plistName: "CallingCodes.plist")
    private var is_accurate = false
    var isAccurate : Bool{
        return self.is_accurate
    }
    static var `default` : CountryModel{
        return CountryModel()
    }
    init(_ json : JSON){
        self.name = json.string("name")
        self.dial_code = json.string("dial_code")
        self.country_code = json.string("code")
        self.flag = UIImage(named: "\(self.country_code.lowercased())") ?? UIImage(named: "us.png")!
        
        //          if let bundlePath = Bundle.main.path(forResource: "assets", ofType: "bundle"),
        //              let bundle = Bundle(path: bundlePath){
        //              !
        //          }else{
        //              self.flag = UIImage(named: "us.png")!
        //          }
    }
    init(forDialCode d_code : String? = nil,withCountry c_code : String? =  nil){
        let code_matching_countries = self.plist.filter { (country) -> Bool in
            let dial = country["dial_code"] as? String ?? String()
            return  dial.replacingOccurrences(of: "+", with: "") == d_code?.replacingOccurrences(of: "+", with: "")
        }
        switch code_matching_countries.count {
        case 1:
            self.country_code = code_matching_countries.first?["code"] as? String ?? String()
            self.dial_code = code_matching_countries.first?["dial_code"] as? String ?? String()
            self.name = code_matching_countries.first?["name"] as? String ?? String()
            self.is_accurate = true
        case let x where x > 1 ://got more possibility
            self.is_accurate = false
            if let _cCode = c_code,
                let country = code_matching_countries
                    .filter({_cCode == ($0["code"] as? String)})
                    .first{
                
                self.country_code = country["code"] as? String ?? String()
                self.dial_code = country["dial_code"] as? String ?? String()
                self.name = country["name"] as? String ?? String()
                self.is_accurate = true
            }else{
                fallthrough
            }
        case 0:
            self.is_accurate = false
            if let _cCode = c_code,
                let country = self.plist
                    .filter({_cCode == ($0["code"] as? String)})
                    .first{
                
                self.country_code = country["code"] as? String ?? String()
                self.dial_code = country["dial_code"] as? String ?? String()
                self.name = country["name"] as? String ?? String()
                self.is_accurate = true
            }else{
                fallthrough
            }
        default:
            self.country_code = "US"
            self.dial_code = "+1"
            self.name = "United States"
            self.is_accurate = false
        }
        self.flag = UIImage(named: "\(self.country_code.lowercased())") ?? UIImage(named: "us")!

//        if let bundlePath = Bundle.main.path(forResource: "assets", ofType: "bundle"),
//            let bundle = Bundle(path: bundlePath){
//            self.flag = UIImage(named: "\(self.country_code.lowercased()).png", in: bundle, compatibleWith: nil)!
//        }else{
//            self.flag = UIImage(named: "us.png")!
//        }
    }
    func store(){
        let preference = UserDefaults.standard
        preference.set(self.dial_code, forKey: USER_DIAL_CODE)
        preference.set(self.country_code,forKey : USER_COUNTRY_CODE)
    }
}
extension CountryModel : Equatable{
    static func == (lhs: CountryModel, rhs: CountryModel) -> Bool {
        return lhs.country_code == rhs.country_code
    }
    
    
}
