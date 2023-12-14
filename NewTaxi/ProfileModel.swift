/**
* ProfileModel.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/


import Foundation
import UIKit

class ProfileModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var user_name : String = ""
    var first_name : String = ""
    var last_name : String = ""
    var user_thumb_image : String = ""
    var user_normal_image_url : String = ""
    var user_large_image_url : String = ""
    var user_small_image_url : String = ""
    var dob : String = ""
    var email_id : String = ""
    var user_location : String = ""
    var member_from : String = ""
    var about_me : String = ""
    var school : String = ""
    var gender : String = ""
    var phone : String = ""
    var work : String = ""
    var is_email_connect : String = ""
    var is_facebook_connect : String = ""
    var is_google_connect : String = ""
    var is_linkedin_connect : String = ""
    var user_id : String = ""
    
    //MARK: Inits
    func initiateProfileData(responseDict: NSDictionary) -> Any
    {
        user_name =  responseDict["user_name"] as? String ?? String()
        first_name = responseDict["first_name"] as? String ?? String()
        last_name = responseDict["last_name"] as? String ?? String()
        user_thumb_image = responseDict["small_image_url"] as? String ?? String()
        user_normal_image_url = responseDict["normal_image_url"] as? String ?? String()
        user_large_image_url = responseDict["large_image_url"] as? String ?? String()
        user_small_image_url = responseDict["small_image_url"] as? String ?? String()
        email_id =  UberSupport().checkParamTypes(params: responseDict, keys:"email") as String
        phone = UberSupport().checkParamTypes(params: responseDict, keys:"phone") as String
        return self
    }
    
    //MARK: Inits
    func initiateOtherProfileData(responseDict: NSDictionary) -> Any
    {
        user_name =  String(format:"%@ %@",responseDict["first_name"] as? String ?? String(),responseDict["last_name"] as? String ?? String()) as String
        first_name = responseDict["first_name"] as? String ?? String()
        last_name = responseDict["last_name"] as? String ?? String()
        user_thumb_image = responseDict["large_image"] as? String ?? String()
        user_normal_image_url = responseDict["large_image"] as? String ?? String()
        user_large_image_url = responseDict["large_image"] as? String ?? String()
        user_small_image_url = responseDict["large_image"] as? String ?? String()
        user_location = responseDict["user_location"] as? String ?? String()
        member_from = UberSupport().checkParamTypes(params: responseDict, keys:"member_from") as String
        about_me = UberSupport().checkParamTypes(params: responseDict, keys:"about_me") as String
        return self
    }

    
}
