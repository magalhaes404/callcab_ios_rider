/**
* Constants.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import MessageUI
import Social



enum PipeLineKey : String{
    case check_splash
    case app_entered_foreground
}

//MARK:- Image Names Colors

struct ImageConstants {
    lazy var phone : String = {"phone.png"}()
    lazy var account : String = {"account.png"}()
    lazy var mapMarker : String = {"map_marker.png"}()
    lazy var clockOutline : String = {"clock_outline.png"}()
    lazy var busIcon : String = {"bus_alert.png"}()
}

//MARK:- UserDefault Keys
extension UserDefaults {
    enum Key : String {
        
//        case google_api_key
        case default_language_option
        
        case access_token
        case device_token
        case user_id
        case login_token
        
        case first_name
        case last_name
        
        case full_name
        case user_email_id
        case phonenumber
        
        case payment_method
        case wallet_payment_method
        case wallet_amount
        case card_brand_name
        case card_last_4
        case brain_tree_display_name
        case stripe_card
        case default_payment_method
        case wallet_payment_enabled
        case admin_mobile_number
        case current_trip_id
        
        case driver_user_id
        case driver_user_image
        case driver_user_name
        case sinch_key
        case sinch_secret_key
        case selectwallet
        
        case payment_gateway_type
        
        case stripe_publish_key
        case paypal_mode
        case paypal_client_key
        case direction_hit_count
        case promo_applied_amount
        case promo_expirey_date
        case promo_applied_code
        
        case job_requesting_duration
        
        case current_job_id
        case is_from_social_login

    }
    internal static var prefernce : UserDefaults{ return UserDefaults.standard}
    
  
    static func value<T>(for key : Key) -> T?{
        return self.prefernce.value(forKey: key.rawValue) as? T
    }
    static func set<T>(_ value : T,for key : Key){
        self.prefernce.set(value, forKey: key.rawValue)
    }
    static func removeValue(for key : Key){
        self.prefernce.removeObject(forKey: key.rawValue)
    }
    static func isNull(for key : Key) -> Bool{
        return self.prefernce.value(forKey: key.rawValue) == nil
    }
    static func clearAllKeyValues(){
        self.removeValue(for: .access_token)
//        self.removeValue(for: .device_token)
        self.removeValue(for: .user_id)
        self.removeValue(for: .login_token)
        self.removeValue(for: .default_language_option)
        
       self.removeValue(for: .first_name)
        self.removeValue(for: .last_name)
        
        
        self.removeValue(for: .card_brand_name)
        self.removeValue(for: .card_last_4)
        self.removeValue(for: .default_payment_method)
        self.removeValue(for: .wallet_payment_enabled)
        self.removeValue(for: .admin_mobile_number)
        self.removeValue(for: .current_trip_id)
        self.removeValue(for: .wallet_payment_method)
        
        self.removeValue(for: .driver_user_id)
        self.removeValue(for: .driver_user_image)
        self.removeValue(for: .driver_user_name)
        self.removeValue(for: .stripe_card)
        self.removeValue(for: .stripe_card)
        self.removeValue(for: .default_payment_method)
        self.removeValue(for: .payment_method)
        self.set("No", for: .selectwallet)

    }
}

enum DisplayErrors : String{
    case somethingWentWrong = "Something went wrong!"
}
//MARK:- DUMDUM method
class Constants : NSObject
{
    
    func STOREVALUE(value : String , keyname : String)
    {
        UserDefaults.standard.setValue(value , forKey: keyname as String)
        UserDefaults.standard.synchronize()
    }
    
    func GETVALUE(keyname : String) -> String
    {
        let value = UserDefaults.standard.value(forKey: keyname)
        if value == nil
        {
            return ""
        }
        return value as? String ?? String()
    }
    
}
extension UIViewController {
    func presentInFullScreen(_ viewController: UIViewController,
                             animated: Bool,
                             completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            viewController.modalPresentationStyle = .overCurrentContext
        } else {
            // Fallback on earlier versions
        }
        
        //    viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: animated, completion: completion)
    }
}
func debug(print msg: String,file : String = #file,fun : String = #function){
    print("∂:/\(fun)->\(msg) ")
}
func debug(print msg: CustomStringConvertible,file : String = #file,fun : String = #function){
    print("∂:/\(fun)->\(msg.description) ")
}

func debug(print msg: CustomDebugStringConvertible,file : String = #file,fun : String = #function){
    print("∂:/\(fun)->\(msg.debugDescription) ")
}
func debug(print msg: Error,file : String = #file,fun : String = #function){
    print("∂:/\(fun)->\(msg.localizedDescription) ")
}
