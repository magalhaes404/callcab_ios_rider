//
//  ProjectConfig.swift
// NewTaxi
//
//  Created by Seentechs on 11/09/21.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

final class iApp : NSObject  {
    //MARK:- ******************** (Package Data) **********************************************
    
    static let appName = "Jepees"
    static let appLogo = "Rider Logo"
    static let GOOGLE_MAP_API_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let GOOGLE_MAP_DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"
    static let kGoogleAPINSErrorCode = 42
    static let GOOGLE_PLACES_API_KEY = "AIzaSyDfPZLkGFSJVBQcLaRxy5GydvtIryBdSs8"
    static let PARAMETRE_RADIUS = "10000"
    static let RESPONSE_KEY_STATUS = "status"
    static let RESPONSE_STATUS_OK = "OK"
    static let RESPONSE_KEY_PREDICTIONS = "predictions"
    static let RESPONSE_KEY_DESCRIPTION = "description"
    static let RESPONSE_KEY_REFERENCE = "reference"
    static let RESPONSE_KEY_RESULT = "result"
    static let RESPONSE_KEY_ATTRIBUTIONS = "html_attributions"
    static let RESPONSE_KEY_NAME = "name"
    static let RESPONSE_KEY_LOCATION = "location"
    static let RESPONSE_KEY_GEOMETRY = "geometry"
    static let RESPONSE_KEY_LATITUDE = "lat"
    static let RESPONSE_KEY_LONGITUDE = "lng"
    static let RESPONSE_KEY_VICINITY = "vicinity"
    static let RESPONSE_KEY_FORMATTED_ADDRESS = "formatted_address"
    static let GOOGLE_PLACES_ERROR_DOMAIN = "ADGooglePlacesErrorDomain"
    static let ADDRESS_COMPONENTS = "address_components"
    static let ADDRESS_TYPES = "types"
    //MARK: ServerType
    enum ServerTypes : String{
        case live = "https://newtaxi.seentechs.com/"
        case demo = "http://cyrus.seentechs.com/"
    }
    static let baseURL : ServerTypes = .live
    
    //MARK: Deployment environments (live / sandbox)
    
    static let deploymentEnvironment : CallManager.Environment = .live
    static let firebaseEnvironment : FireBaseEnvironment = baseURL == .live ? .live : .demo
    
   
     @objc let GoogleApiKey = "AIzaSyDbSqbaR3Z5XQ_SCYIL_OisAdgDlE_25QE"
   
    
    struct Rider: iTunesData{
        var appName = "NewTaxi"
        var appStoreDisplayName = "NewTaxi-app"
        var appID = "#"
    }
    struct Driver: iTunesData{
        var appName = "NewTaxiDriver"
        var appStoreDisplayName = "NewTaxi-driver-app"
        var appID = "##"
    }
    
    
    //MARK:- *********************************************************************************************
    
    enum NewTaxiFont: String {
        case light = "ClanPro-Book"
        case medium = "ClanPro-News"
        case bold = "ClanPro-Medium"
        case image = "uber-clone-mobile"
        case googleBold = "ProductSans-Bold"
        case googleRegular = "ProductSans-Regular"
        case centuryBold = "CenturyGothic-Bold"
        case centuryRegular = "CenturyGothic"
        
        
        
        func  font(size:CGFloat) -> UIFont{
            return UIFont(name: self.rawValue, size: size) ?? .systemFont(ofSize: size)
        }
        
        
    }
    
     enum NewTaxiError : Error,LocalizedError {
        case server
        case connection
        //        case upload = "Internal server error, please try again."

        var errorDescription: String?{
            return self.localizedDescription
        }
        var localizedDescription: String{
            let lang = Language.default.object
            switch self {
            case .server:
                return lang.internalServerError
            case .connection:
                return lang.noInternetConnection
            }
        }
    }
    
    enum NewTaxiErrors : Error{
        case StripeServerError
    }

    
    //Resticting initalizer
    private override init(){super.init()}
    static let APIBaseUrl = iApp.baseURL.rawValue + "api/"
    
    static let CanRequestSinchNotification = true
    static let instance = iApp()
    static var img = ImageConstants()
    
    static var isSimulator : Bool{
        return TARGET_OS_SIMULATOR != 0
    }

    
    //MARK:- Important
  
    
    //MARK:- Required delarations
    let userType = "Rider"
    let deviceType = "1"
    
    
    //MARK:- UserFull declarations
    lazy var version : String? = {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }()
    var isRTL : Bool  {
        return Language.default.object.isRTLLanguage()
    }
    var showDriverLiveTrackingWithMovement : Bool{
        return true
    }
    /**
     To initiate firebase crash analytics set 'true'
     - Warning: make sure you set 'false' before launching
     */
    static let crashApplicationOnSplash = false
}


 

//MARK:- Theme Colors
extension UIColor{
    static var ThemeMain : UIColor  {
        return UIColor(named: "ThemMain") ?? UIColor(hex: "000000")
    }
    static var ThemeInactive : UIColor {
       return UIColor(named: "ThemeInactive") ?? UIColor(hex : "A4A4AB")
    }
    static var ThemeLight : UIColor {
        return UIColor(named: "ThemeLight") ?? UIColor(hex: "f9b333")
    }
    static var ThemeBgrnd : UIColor{
         return UIColor(named: "ThemeBgrnd") ?? UIColor(hex: "FFFFFF")
    }
    static var BorderCell : UIColor {
        return UIColor(hex: "F4F4F4")
    }
    static var Title : UIColor{
         return UIColor(named: "Title") ?? UIColor(hex: "FFFFFF")
    }
    static var DarkTitle : UIColor{
         return UIColor(named: "DarkTitle") ?? UIColor(hex: "FFFFFF")
    }
    static var Subtitle : UIColor{
         return UIColor(named: "Subtitle") ?? UIColor(hex: "FFFFFF")
    }
    static var Border : UIColor{
         return UIColor(named: "Border") ?? UIColor(hex: "FFFFFF")
    }
    static var ThemeYellow : UIColor{
        return UIColor(named: "ThemeYellow") ?? UIColor(hex: "FFFFFF")
    }
    static var Background : UIColor{
        return UIColor(named: "Background") ?? UIColor(hex: "FFFFFF")
    }
    static let ThemeTipInactive = UIColor(hex: "EAEAEA")
    static let ThemeTipActive = UIColor(hex: "27AA0B")
}
extension UIView {
    
    //Corner Radius
    @IBInspectable
    var cornerRadius : CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    //Border Width
    @IBInspectable
    var borderWidth : CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    //Border Color
    @IBInspectable
    var borderColor : UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    // The color of the shadow. Defaults to opaque black. Colors created from patterns are currently NOT supported. Animatable.
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor!)
        }
        set {
            layer.masksToBounds = false
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    
    //The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            self.layer.shadowOpacity = newValue
        }
    }
    
    //The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            self.layer.shadowOffset = newValue
        }
    }
    
    //The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable
    var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            layer.masksToBounds = false
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           layer.mask = mask
       }
    func anchor(toView : UIView,
                   leading : CGFloat? = nil,
                   trailing : CGFloat? = nil,
                   top : CGFloat? = nil,
                   bottom : CGFloat? = nil){
           
           self.translatesAutoresizingMaskIntoConstraints = false
           if let _leading = leading{
               self.leadingAnchor
                   .constraint(equalTo: toView.leadingAnchor, constant: _leading)
                   .isActive = true
           }
           if let _trailing = trailing{
               self.trailingAnchor
                   .constraint(equalTo: toView.trailingAnchor, constant: _trailing)
                   .isActive = true
           }
           if let _top = top{
               self.topAnchor
                   .constraint(equalTo: toView.topAnchor, constant: _top)
                   .isActive = true
           }
           if let _bottom = bottom{
               self.bottomAnchor
                   .constraint(equalTo: toView.bottomAnchor, constant: _bottom)
                   .isActive = true
           }
           
       }
}
extension UIStackView {

    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }

}

/*
 * Files Added for New Mobile Number Verificaiton
    • CheckStatus.swift
    • MobileNumber.swift
    • MobileValidationVC.swift
    • MobileNumberView.swift & MobileNumberView.xib
    • OTPView.xib.swift & OTPView.xib.xib
    • two icons in assets (mobileotp & mobileverify)
 * Files updated for New Mobile Number Verificaiton
    • iAPP.swift - 105
    • Account.storyboard
    • APIEnums.swift - 16,41
    • APIInteractor.swift - 16,17,92,105
    • ViewUX.swift - 603
    • CountryListVC - 100,154(back actions)
    • Remove device token from default on signout
 * Implement new validaiton in the following screens
    • LoginVC
    • NewSignInVC
    • SocialInfoVC
    • SocialLoginVC
    • EditProfileVC -- Major changes
*/
