/**
* ProfileImageModel.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/


import Foundation
import UIKit

class ProfileImageModel : NSObject {
    
    //MARK Properties
    var large_image_url : String = ""
    var normal_image_url : String = ""
    var small_image_url : String = ""

    //MARK: Inits
    func initiateProfileImageData(responseDict: NSDictionary) -> Any
    {
        large_image_url = UberSupport().checkParamTypes(params: responseDict, keys:"image_url") as String
        normal_image_url = UberSupport().checkParamTypes(params: responseDict, keys:"image_url") as String
        small_image_url = UberSupport().checkParamTypes(params: responseDict, keys:"image_url") as String
        return self
    }
    
    
}
