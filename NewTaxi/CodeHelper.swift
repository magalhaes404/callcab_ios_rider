//
//  CodeHelper.swift
// NewTaxi
//
//  Created by Seentechs on 19/12/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
typealias JSON = [String: Any]
extension Dictionary where Dictionary == JSON{
    var status_code : Int{
        return Int(self["status_code"] as? String ?? String()) ?? Int()
    }
    var isSuccess : Bool{
        return status_code != 0
    }
    var status_message : String{
        
        let statusMessage = self.string("status_message")
        let successMessage = self.string("success_message")
        return statusMessage.isEmpty ? successMessage : statusMessage
    }

    var success_message : String{
        return self["success_message"] as? String ?? String()
    }
    
    func array<T>(_ key : String) -> [T]{
        return self[key] as? [T] ?? [T]()
    }
    func array(_ key : String) -> [JSON]{
        return self[key] as? [JSON] ?? [JSON]()
    }
    func json(_ key : String) -> JSON{
        return self[key] as? JSON ?? JSON()
    }
     func string(_ key : String)-> String{
     // return self[key] as? String ?? String()
         let value = self[key]
         if let str = value as? String{
            return str
         }else if let int = value as? Int{
            return int.description
         }else if let double = value as? Double{
            return double.description
         }else{
            return String()
         }
     }
     func int(_ key : String)-> Int{
         //return self[key] as? Int ?? Int()
         let value = self[key]
         if let str = value as? String{
            return Int(str) ?? Int()
         }else if let int = value as? Int{
            return int
         }else if let double = value as? Double{
            return Int(double)
         }else{
            return Int()
         }
     }
     func double(_ key : String)-> Double{
     //return self[key] as? Double ?? Double()
         let value = self[key]
         if let str = value as? String{
            return Double(str) ?? Double()
         }else if let int = value as? Int{
            return Double(int)
         }else if let double = value as? Double{
            return double
         }else{
            return Double()
         }
     }
    
    func bool(_ key : String) -> Bool{
        let value = self[key]
        if let bool = value as? Bool{
            return bool
        }else if let int = value as? Int{
            return int == 1
        }else if let str = value as? String{
            return ["1","true"].contains(str)
        }else{
            return Bool()
        }
    }
}
public extension Bundle {
    
    /**
     Gets the contents of the specified plist file.
     
     - parameter plistName: property list where defaults are declared
     - parameter bundle: bundle where defaults reside
     
     - returns: dictionary of values
     */
    public static func contentsOfFile(plistName: String, bundle: Bundle? = nil) -> [String : AnyObject] {
        let fileParts = plistName.components(separatedBy: ".")
        
        guard fileParts.count == 2,
            let resourcePath = (bundle ?? Bundle.main).path(forResource: fileParts[0], ofType: fileParts[1]),
            let contents = NSDictionary(contentsOfFile: resourcePath) as? [String : AnyObject]
            else { return [:] }
        
        return contents
    }
    public static func contentsOfFileArray(plistName: String, bundle: Bundle? = nil) -> [[String: Any]] {
        let fileParts = plistName.components(separatedBy: ".")
        
        guard fileParts.count == 2,
            let resourcePath = (bundle ?? Bundle.main).path(forResource: fileParts[0], ofType: fileParts[1]),
            let contents = NSArray(contentsOfFile: resourcePath)
            else { return [[String:Any]]() }
        
        return contents as! [[String : Any]]
    }
    
    /**
     Gets the contents of the specified bundle URL.
     
     - parameter bundleURL: bundle URL where defaults reside
     - parameter plistName: property list where defaults are declared
     
     - returns: dictionary of values
     */
    public static func contentsOfFile(bundleURL: NSURL, plistName: String = "Root.plist") -> [String : AnyObject] {
        // Extract plist file from bundle
        guard let contents = NSDictionary(contentsOf: bundleURL.appendingPathComponent(plistName)!)
            else { return [:] }
        
        // Collect default values
        guard let preferences = contents.value(forKey: "PreferenceSpecifiers") as? [String: AnyObject]
            else { return [:] }
        
        return preferences
    }
    
    /**
     Gets the contents of the specified bundle name.
     
     - parameter bundleName: bundle name where defaults reside
     - parameter plistName: property list where defaults are declared
     
     - returns: dictionary of values
     */
    public static func contentsOfFile(bundleName: String, plistName: String = "Root.plist") -> [String : AnyObject] {
        guard let bundleURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle")
            else { return [:] }
        
        return contentsOfFile(bundleURL: bundleURL as NSURL, plistName: plistName)
    }
    
    /**
     Gets the contents of the specified bundle.
     
     - parameter bundle: bundle where defaults reside
     - parameter bundleName: bundle name where defaults reside
     - parameter plistName: property list where defaults are declared
     
     - returns: dictionary of values
     */
    public static func contentsOfFile(bundle: Bundle, bundleName: String = "Settings", plistName: String = "Root.plist") -> [String : AnyObject] {
        guard let bundleURL = bundle.url(forResource: bundleName, withExtension: "bundle")
            else { return [:] }
        
        return contentsOfFile(bundleURL: bundleURL as NSURL, plistName: plistName)
    }
    
}
extension String{
    var localize : String{
        return NSLocalizedString(self, comment: "")
    }
}
extension UIViewController {
        func setStatusBarStyle(_ style: UIStatusBarStyle) {
            if #available(iOS 13.0, *){
                let view = UIApplication.shared.statusBarView
                view?.backgroundColor = style == .lightContent ? UIColor.white : .clear
            }else if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.backgroundColor = style == .lightContent ? UIColor.white : .clear
            }
    }
    
}
extension UIColor{
    public  convenience init(hex : String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


//MARK: MainStory board to use localize concept
extension UILabel{
    @IBInspectable
    var localize : Bool{
        get{
            return false
        }
        set{
            if newValue{
                self.text = self.text?.localize
            }
        }
    }
}

extension UITextField {
    @IBInspectable
    var localizePlaceHolder: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.placeholder = self.placeholder?.localize
            }
        }
    }
}

extension UIButton {
    @IBInspectable
    var localizeTitle: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.setTitle(self.currentTitle?.localize, for: .normal)
            }
        }
    }
}

extension UITextView {
    @IBInspectable
    var localizeText: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.text = self.text.localize
            }
        }
    }
}
extension UIViewController{
    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
                alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                    completion(index)
                }))
        }
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            if let top = topController.presentedViewController{
                top.present(alertController, animated: true, completion: nil)
            }else{
                topController.present(alertController, animated: true, completion: nil)
            }
            
        }else{
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
extension Array{
    
    var isNotEmpty : Bool{
        return !self.isEmpty
    }
    
    func value(atSafe index : Int) -> Element?{
        guard self.indices.contains(index) else {return nil}
        return self[index]
    }
    func find(includedElement: @escaping ((Element) -> Bool)) -> Int? {
        for arg in self.enumerated(){
            let (index,item) = arg
            if includedElement(item) {
                return index
            }
        }
        
        return nil
    }
}
