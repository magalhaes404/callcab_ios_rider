/**
* ReviewsModel.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/


import Foundation
import UIKit

class ReviewsModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var accuracy_value : String = ""
    var check_in_value : String = ""
    var cleanliness_value : String = ""
    var communication_value : String = ""
    var location_value : String = ""
    var total_review : String = ""
    var reivew_value : String = ""
    var review_user_name : String = ""
    var review_user_image : String = ""
    var review_date : String = ""
    var review_message : String = ""
    var value : String = ""

    var arrReviewData : NSMutableArray = NSMutableArray()
    
   // MARK: Inits
    func initiateReviewData(responseDict: NSDictionary) -> Any
    {
        reivew_value =  self.checkParamTypes(params: responseDict, keys:"reivew_value")
        review_user_name = self.checkParamTypes(params: responseDict, keys:"review_user_name")
        review_user_image = self.checkParamTypes(params: responseDict, keys:"review_user_image")
        review_date = self.checkParamTypes(params: responseDict, keys:"review_date")
        review_message =  self.checkParamTypes(params: responseDict, keys:"review_message")
        
        return self
    }
    
    //MARK: Check Param Type
    func checkParamTypes(params:NSDictionary, keys:String) -> String
    {
        if let latestValue = params[keys] as? String {
            return latestValue as String
        }
        else if let latestValue = params[keys] as? String {
            return latestValue as String
        }
        else if let latestValue = params[keys] as? Int {
            return String(format:"%d",latestValue) as String
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
