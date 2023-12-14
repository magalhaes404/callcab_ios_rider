/**
 * GoogleLocationModel.swift
 *
 * @package Makent
 * @subpackage Controller
 * @category Calendar
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */



import Foundation
import UIKit

class GoogleLocationModel : NSObject {
    
    //MARK Properties
    var success_message : NSString = ""
    var status_code : NSString = ""
    var street_address : String = ""
    var city_name : String = ""
    var premise_name : String = ""
    var state_name : String = ""
    var postal_code : String = ""
    var country_name : String = ""
    var dictTemp : NSMutableDictionary = NSMutableDictionary()
    
    //MARK: Inits
    func initiateLocationData(responseDict: NSDictionary) -> Any
    {
        let dictMainResult = responseDict.value(forKeyPath: "result.address_components") as? NSArray ?? NSArray()
        
        for i in 0 ..< dictMainResult.count
        {
            let dictOrgResult = dictMainResult[i] as! NSDictionary
            let arrResult = dictOrgResult["types"] as? NSArray ?? NSArray()
            let strType = arrResult[0] as? String ?? String()
            if strType == "street_number"
            {
                street_address = dictOrgResult["long_name"] as? String ?? String()
            }
            else if strType == "route"
            {
                if ((street_address as String).count > 0)
                {
                    street_address = String(format:"%@, %@",street_address,dictOrgResult["long_name"] as? String ?? String())
                }
                else
                {
                    street_address = String(format: "%@",dictOrgResult["long_name"] as? String ?? String())
                }
            }
            else if strType == "locality"
            {
                city_name = dictOrgResult["long_name"] as? String ?? String()
            }
            else if strType == "administrative_area_level_1"
            {
                state_name = dictOrgResult["long_name"] as? String ?? String()
            }
            else if strType == "country"
            {
                country_name = dictOrgResult["long_name"] as? String ?? String()
            }
            else if strType == "postal_code"
            {
                postal_code = dictOrgResult["long_name"] as? String ?? String()
            }
        }
        
        return self
    }
    
    
    
    static func generateModel(from json : JSON) -> GoogleLocationModel
    {
        let locModel = GoogleLocationModel()
        if ((json["status"] as? String ?? String())) as String == iApp.RESPONSE_STATUS_OK
        {
            locModel.dictTemp = NSMutableDictionary(dictionary:json)
            
            locModel.success_message = "Success"
            locModel.status_code = "1"
            let dictMainResult = json.json("result").array("address_components")
            //json.value(forKeyPath: "result.address_components") as? NSArray ?? NSArray()
            
            for i in 0 ..< dictMainResult.count
            {
                let dictOrgResult = dictMainResult[i] as NSDictionary
                let arrResult = dictOrgResult["types"] as? NSArray ?? NSArray()
                let strType = arrResult[0] as? String ?? String()
                
                if strType == "street_number"
                {
                    locModel.street_address = dictOrgResult["long_name"] as? String ?? String()
                }
                else if strType == "route"
                {
                    if ((locModel.street_address as String).count > 0)
                    {
                        locModel.street_address = String(format:"%@, %@",locModel.street_address,dictOrgResult["long_name"] as? String ?? String())
                    }
                    else
                    {
                        locModel.street_address = String(format: "%@",dictOrgResult["long_name"] as? String ?? String())
                    }
                }
                else if strType == "locality"
                {
                    locModel.city_name = dictOrgResult["long_name"] as? String ?? String()
                }
                else if strType == "premise"
                {
                    locModel.premise_name = dictOrgResult["long_name"] as? String ?? String()
                }
                else if strType == "administrative_area_level_1"
                {
                    locModel.state_name = dictOrgResult["long_name"] as? String ?? String()
                }
                else if strType == "country"
                {
                    locModel.country_name = dictOrgResult["long_name"] as? String ?? String()
                }
                else if strType == "postal_code"
                {
                    locModel.postal_code = dictOrgResult["long_name"] as? String ?? String()
                }
            }
        }
        else
        {
            locModel.success_message = "Failure"
            locModel.status_code = "0"
        }
        
        return locModel
    }
}
