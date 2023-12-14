//
//  LanguageEnum.swift
//  Makent
//
//  Created by Seentechs on 08/08/19.
//  Copyright Â© 2021 Seen Technologies. All rights reserved.
//

import Foundation

import ObjectiveC
//MARK:- SupportedLanugages
enum Language : String{
    
    case english = "en"
    case spanish = "es"
    case arabic = "ar"
    case portugal = "pt"
    case persian = "fa"
    case japanese = "ja"
    
    
    var object : LanguageProtocol{
        switch self {
        case .english:
            return English()
        case .arabic:
            return Arabic()
        case .spanish:
            return Spanish()
        case .portugal:
            return Portugal()
        case .persian:
            return Persian()
        case .japanese:
            return Japanese()
        default:
            return English()
            
        }
    }
    var displayName : String{
        switch self {
             case .english:
                 return "English"
             case .arabic:
                 return "عربى"
             case .spanish:
                 return "Español"
             case .portugal:
                 return "Português"
             case .persian:
                 return "فارسی"
             case .japanese:
                 return "日本語"
             default:
                 return "English"
                 
             }
    }
    static var AvailableLanguages : [Language] {
        return [.english, .spanish, .portugal, .arabic, .persian]//, .japanese
    }
}

extension Language{
    
    static func localizedInstance()-> LanguageProtocol{
        return self.default.getLocalizedInstance()
    }
    
    //MARK:- get Current Language
    static var `default` : Language{
       /* let pre = Locale.preferredLanguages[0]
        let lang = pre.components(separatedBy: "-")
        
        let locale = lang.first ?? "en"
        return  Language(rawValue: locale) ?? .english*/
        let rawValue = UserDefaults.value(for: .default_language_option) ?? Language.english.rawValue
        return Language(rawValue: rawValue) ?? .english
    }
    func saveLanguage(){
        UserDefaults.set(self.rawValue, for: .default_language_option)
       UserDefaults.standard.set(self.rawValue, forKey:  "lang")
        UserDefaults.standard.set([self.rawValue], forKey: "AppleLanguages")
        Bundle.setLanguage(self.rawValue)
    }
    //MARK:- get localization  instace
    func getLocalizedInstance()-> LanguageProtocol{
        
        switch self{
        case .arabic:
            return Arabic()
        case .spanish:
            return Spanish()
        case .portugal:
            return Portugal()
        case .persian:
            return Persian()
        case .japanese:
            return Japanese()
            
        default:
            return English()
        }
        
    }
    
    var isRTL : Bool{
        return Language.default.object.isRTLLanguage()
    }
    var locale : Locale{
        switch self {
        case .arabic:
            return Locale(identifier: "ar")
        case .persian:
            return Locale(identifier: "fa")
        
        default:
            return Locale(identifier: self.rawValue)
        }
    }
    //NSCalendar(calendarIdentifier:
    var identifier : NSCalendar{
        switch self {
        case .arabic:
            return NSCalendar.init(identifier: NSCalendar.Identifier.islamicCivil)!
        default:
            return NSCalendar.init(identifier: NSCalendar.Identifier.gregorian)!
        }
    }
    var calIdentifier : Calendar{
        switch self {
        case .arabic:
            return Calendar.init(identifier: Calendar.Identifier.islamicCivil)
        default:
            return Calendar.init(identifier: Calendar.Identifier.gregorian)
        }
    }
    //MARK:- get display semantice
    var getSemantic:UISemanticContentAttribute {
        
        return self.isRTL ? .forceRightToLeft : .forceLeftToRight
        
    }
    
    //MARK:- for imageView Transform Display
    var getAffine:CGAffineTransform {
        
        return self.isRTL ? CGAffineTransform(scaleX: -1.0, y: 1.0) : CGAffineTransform(scaleX: 1.0, y: 1.0)
        
    }
    
    //MARK:- for Text Alignment
    func getTextAlignment(align : NSTextAlignment) -> NSTextAlignment{
        guard self.getSemantic == .forceRightToLeft else {
            return align
        }
        switch align {
        case .left:
            return .right
        case .right:
            return .left
        case .natural:
            return .natural
        default:
            return align
        }
    }
    
    //MARK:- for ButtonText Alignment
    func getButtonTextAlignment(align : UIControl.ContentHorizontalAlignment) -> UIControl.ContentHorizontalAlignment{
        guard self.getSemantic == .forceRightToLeft else {
            return align
        }
        switch align {
        case .left:
            return .right
        case .right:
            return .left
        case .center:
            return .center
        default:
            return align
        }
    }
    
    
}
class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.3).cgColor
        let colorBottom = UIColor(red: 0.0/255.0,
                                  green: 0.0/255.0,
                                  blue: 0.0/255.0, alpha: 0.0)
            .cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.gl.endPoint = CGPoint(x: 0.5, y: 1)
        self.gl.locations = [1.0, 0.0]
        
    }
}

private var associatedLanguageBundle:Character = "0"

class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))

    }
}

extension Bundle {
    class func setLanguage(_ language: String) {
        var onceToken: Int = 0

        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
