/**
 * LoginModel.swift
 *
 * @package NewTaxi
 * @subpackage Controller
 * @category Calendar
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */



import Foundation
import UIKit

class RiderDataModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var access_token : String = ""
    var first_name : String = ""
    var last_name : String = ""
    var mobile_number : String = ""
    var country_code : String = ""
    var email_id : String = ""
    var home_location_name : String = ""
    var work_location_name : String = ""    
    var home_location_latitude : String = ""
    var home_location_longitude : String = ""
    var work_location_latitude : String = ""
    var work_location_longitude : String = ""
    var wallet_amount :String = ""
//    var paypal_app_id :String = ""
//    var paypal_mode :String = ""
    var expire_date :String  = ""
    var currency_symbol : String = ""
    var currencyCode = ""
    var paypal_email_id : String = ""
    var user_status : String = ""
    var user_thumb_image : String = ""
    var user_id : String = ""
    var user_name : String = ""
    var arraycount : String = ""
    var amount :String = ""
    var code :String = ""
    var arrTemp1 : NSMutableArray = NSMutableArray()
    var promo_details = PromoCodeModel()
    var gender : String = ""
    var requestOptions = [RequestOptions]()
    override init(){}
    init(_ json : JSON){
        
        super.init()
        self.status_message = json.string("status_message")
        self.status_code = json.string("status_code")
        guard json.isSuccess else{return}
        self.access_token = json.string("access_token")
        self.first_name = json.string("first_name")
        self.last_name = json.string("last_name")
        self.mobile_number = json.string("mobile_number")
        self.email_id = json.string("email_id")
        self.user_status = json.string("user_status")
        self.paypal_email_id = json.string("paypal_email_id")
        self.user_name = String(format:"%@ %@",self.first_name, self.last_name)
        self.user_thumb_image = json.string("user_thumb_image")
        if !json.string("profile_image").isEmpty{
            self.user_thumb_image = json.string("profile_image")
        }
        self.email_id = json.string("email_id")
        self.user_id = json.string("user_id")
        self.country_code = json.string("country_code")
        self.home_location_name = json.string("home")
        self.work_location_name = json.string("work")
        self.home_location_latitude = json.string("home_latitude")
        self.home_location_longitude = json.string("home_longitude")
        self.work_location_latitude = json.string("work_latitude")
        self.work_location_longitude = json.string("work_longitude")
        self.wallet_amount = json.string("wallet_amount")
//        self.paypal_app_id = json.string("paypal_app_id")
//        self.paypal_mode = json.string("paypal_mode")
        self.arrTemp1 = NSMutableArray()
        if json["promo_details"] != nil
        {
            let arrData = json["promo_details"] as? NSArray ?? NSArray()
            let arraycount = arrData.count
            self.arraycount = "\(arraycount)"
           
        }
        let currencySymbol = (json.string("currency_symbol") ).stringByDecodingHTMLEntities
        Constants().STOREVALUE(value: currencySymbol, keyname: USER_CURRENCY_SYMBOL_ORG)
        self.currency_symbol = currencySymbol
        
        let currencyCode = json.string("currency_code")
        Constants().STOREVALUE(value: currencyCode , keyname: USER_CURRENCY_ORG)
        self.currencyCode = currencyCode
        self.gender = json.string("gender")
        let requestOption = json.array("request_options")
        self.requestOptions = requestOption.compactMap({RequestOptions.init($0)})
    }
    init(copy: RiderDataModel){
        self.status_message = copy.status_message
        self.status_code = copy.status_code
        self.access_token = copy.access_token
        self.first_name = copy.first_name
        self.last_name = copy.last_name
        self.mobile_number = copy.mobile_number
        self.email_id = copy.email_id
        self.user_status = copy.user_status
        self.paypal_email_id = copy.paypal_email_id
        self.user_name = String(format:"%@ %@",self.first_name, self.last_name)
        self.user_thumb_image = copy.user_thumb_image
        self.email_id = copy.email_id
        self.user_id = copy.user_id
        self.country_code = copy.country_code
        self.home_location_name = copy.home_location_name
        self.work_location_name = copy.work_location_name
        self.home_location_latitude = copy.home_location_latitude
        self.home_location_longitude = copy.home_location_longitude
        self.work_location_latitude = copy.work_location_latitude
        self.work_location_longitude = copy.work_location_longitude
        self.wallet_amount = copy.wallet_amount
//        self.paypal_app_id = copy.paypal_app_id
//        self.paypal_mode = copy.paypal_mode
        self.arrTemp1 = copy.arrTemp1
        self.arraycount = copy.arraycount
        self.currency_symbol = copy.currency_symbol
        self.currencyCode = copy.currencyCode
        self.gender = copy.gender
        self.requestOptions = copy.requestOptions.compactMap({RequestOptions(copy: $0)})
    }
    func update(fromData data : RiderDataModel){
        for index in 0 ..< data.requestOptions.count{
            self.requestOptions[index].update(fromData: data.requestOptions[index])
        }
    }
    func storeRiderBasicDetail(){
        Constants().STOREVALUE(value: self.currency_symbol, keyname: USER_CURRENCY_SYMBOL_ORG)
        Constants().STOREVALUE(value: self.currencyCode, keyname: USER_CURRENCY_ORG)
        Constants().STOREVALUE(value: self.arraycount, keyname: USER_PROMO_CODE)
        Constants().STOREVALUE(value: self.user_name, keyname: USER_FULL_NAME)
        Constants().STOREVALUE(value: self.first_name, keyname: USER_FIRST_NAME)
        Constants().STOREVALUE(value: self.last_name, keyname: USER_LAST_NAME)
        Constants().STOREVALUE(value: self.user_thumb_image, keyname: USER_IMAGE_THUMB)
        Constants().STOREVALUE(value: self.email_id, keyname: USER_EMAIL_ID)
        Constants().STOREVALUE(value: self.mobile_number, keyname: USER_PHONE_NUMBER)
        Constants().STOREVALUE(value: self.country_code, keyname: USER_COUNTRY_CODE)
        Constants().STOREVALUE(value: self.home_location_name, keyname: USER_HOME_LOCATION)
        Constants().STOREVALUE(value: self.work_location_name, keyname: USER_WORK_LOCATION)
        Constants().STOREVALUE(value: self.home_location_latitude, keyname: USER_HOME_LATITUDE)
        Constants().STOREVALUE(value: self.home_location_longitude, keyname: USER_HOME_LONGITUDE)
        Constants().STOREVALUE(value: self.work_location_latitude, keyname: USER_WORK_LATITUDE)
        Constants().STOREVALUE(value: self.work_location_longitude, keyname: USER_WORK_LONGITUDE)
        Constants().STOREVALUE(value: self.gender, keyname: USER_GENDER)
    }
    func storeRiderImprotantData(){
        
        if !self.access_token.isEmpty{
            Constants().STOREVALUE(value: self.access_token, keyname: USER_ACCESS_TOKEN)
        }
        if !self.user_id.isEmpty{
            Constants().STOREVALUE(value: self.user_id, keyname: USER_ID)
        }
        Constants().STOREVALUE(value: self.paypal_email_id, keyname: USER_PAYPAL_EMAIL_ID)
        Constants().STOREVALUE(value: self.wallet_amount, keyname: USER_WALLET_AMOUNT)
//        Constants().STOREVALUE(value: self.paypal_app_id, keyname: USER_PAYPAL_APP_ID)
//        Constants().STOREVALUE(value: self.paypal_mode, keyname: USER_PAYPAL_MODE)
    }
}
