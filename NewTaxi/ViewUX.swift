//
//  ViewUX.swift
// NewTaxi
//
//  Created by Seentechs on 03/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//
import Foundation
import UIKit




fileprivate var padding_left: UInt8 = 55
fileprivate var padding_right: UInt8 = 65
fileprivate var padding_top : UInt = 76
fileprivate var padding_bottom : UInt = 86
extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13,*){
            let tag = 987654321

            if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
                return statusBar
            }
            else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag

                UIApplication.shared.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        }else if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        
        return nil
    }
}
//USAGE::::::::::UIApplication.shared.statusBarView?.backgroundColor = .red


public extension UIView{
    
    func elevate(_ elevation : CGFloat,
                 radius : CGFloat,
                 opacity : Float = 0.3,
                 fillcolor : UIColor = .clear,
                 shadowColor : UIColor = .darkGray){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            let shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
            shadowLayer.fillColor = fillcolor.cgColor
            
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: elevation, height: elevation)
            shadowLayer.shadowOpacity = opacity
            shadowLayer.shadowRadius = elevation
            shadowLayer.shouldRasterize = true
            shadowLayer.rasterizationScale = UIScreen.main.scale
            self.layer.sublayers?.forEach({ (sub) in
                sub.removeFromSuperlayer()
            })
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    func elevate(_ elevation: Double,shadowColor : UIColor = .black,opacity : Float = 0.3) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: elevation)
        self.layer.shadowRadius = abs(elevation > 0 ? CGFloat(elevation) : -CGFloat(elevation))
        self.layer.shadowOpacity = opacity
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func width(ofCent percent: CGFloat)-> CGFloat{
        return self.frame.width * (percent/100)
    }
    func height(ofCent percent: CGFloat)-> CGFloat{
        return self.frame.height * (percent/100)
    }
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
    
    
    public var isElevated : Bool {
        get{
            return self.layer.shadowRadius != 0.0
        }
        set(newValue){
            if newValue{
                self.elevation(width: 0, height: 5,border: 0.24)
            }else{
                self.elevation(width: 0, height: 0, border: 0)
            }
        }
    }
    public var isCarded : Bool {
        get{
            return self.layer.shadowRadius != 0.0
        }
        set(newValue){
            if newValue{
                self.elevation(width: 5, height: 5,border: 0.24)
            }else{
                self.elevation(width: 0, height: 0, border: 0)
            }
        }
    }
    public var isClippedCorner : Bool{
        get{
            return self.layer.cornerRadius != 0
        }
        set(newValue){
            if newValue{
                self.clipsToBounds = true
                self.layer.cornerRadius = self.frame.height * (8/100)
            }else{
                self.layer.cornerRadius = 0
            }
        }
    }
    public var isCurvedCorner : Bool{
        get{
            return self.layer.cornerRadius != 0
        }
        set(newValue){
            if newValue{
                self.clipsToBounds = true
                self.layer.cornerRadius = self.frame.height * (25/100)
            }else{
                self.layer.cornerRadius = 0
            }
        }
    }
    public var isRoundCorner : Bool{
        get{
            return self.layer.cornerRadius != 0
        }
        set(newValue){
            if newValue{
                self.clipsToBounds = true
                self.layer.cornerRadius = self.frame.height / 2
            }else{
                self.layer.cornerRadius = 0
            }
        }
    }
    public func shadow(_ shadowSize : CGFloat = 5.0,xDir :CGFloat = 0,yDir:CGFloat = 0){
        let shadowPath = UIBezierPath(rect: self.bounds)
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: xDir, height: yDir)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shouldRasterize = true
    }
    public func elevation(width : CGFloat,height : CGFloat,border : CGFloat){
        if width == 5{
            self.layer.cornerRadius = self.frame.height * (3/100)
        }
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width : width, height : height)
        self.layer.shadowRadius = CGFloat(height)
        self.layer.shadowOpacity = Float(border)
        
        if width != 0.0 && height != 0.0 && border != 0.0{
            self.backgroundColor = self.backgroundColor == UIColor.white ? UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 0.5) : self.backgroundColor
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = border - 0.04
            self.layer.shadowColor = UIColor(red: 225.0 / 255.0, green: 228.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0).cgColor
        }
    }
    public var isShimmering : Bool{
        get{
            return self.layer.mask != nil
        }
        set(newValue){
            if newValue{
                let light = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
                let dark = UIColor.black.cgColor
                
                let gradient: CAGradientLayer = CAGradientLayer()
                gradient.colors = [dark, light, dark]
                gradient.frame = CGRect(x: -self.bounds.size.width, y: 0, width: 3*self.bounds.size.width, height: self.bounds.size.height)
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
                gradient.locations = [0.4, 0.5, 0.6]
                self.layer.mask = gradient
                
                let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
                animation.fromValue = [0.0, 0.1, 0.2]
                animation.toValue = [0.8, 0.9, 1.0]
                
                animation.duration = 1.5
                animation.repeatCount = HUGE
                gradient.add(animation, forKey: "shimmer")
            }else{
                self.layer.mask = nil
            }
        }
    }
    var clip : UIRectCorner{
        get{
            return UIRectCorner()
        }
        set(newValue){
            let cut = self.frame.height * (5/100)
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: newValue, cornerRadii:CGSize(width: cut, height: cut ))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
            self.layoutIfNeeded()
        }
    }
}

//MARK: new
fileprivate var maxE  = 1.0
fileprivate var minE = 0.3

extension UIView{
    enum gradientDirection : Int{
        case top2Bottom = 0
        case bottom2Top = 1
        case left2Right = 2
        case right2Left = 3
    }
    func applyGradient(colors:[CGColor],axis:gradientDirection){
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        
        gradientLayer.colors = [colors]
        switch axis{
        case .top2Bottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .bottom2Top:
            gradientLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        case .left2Right:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        case .right2Left:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        }
        
        
        self.layer.addSublayer(gradientLayer)
    }
    
    
    public var is_Elevated : Bool {
        get{
            return self.layer.shadowOpacity == 0.5
        }
        set(newValue){
            if newValue{
                //  self.elevation(width: 0, height: 3,border: 0.24)
                self.elevated(width: 0, height: minE, cornerRadius: self.height(ofCent: CGFloat(minE)))
            }else{
                self.elevated(width: 0, height: 0, cornerRadius: 0)
            }
        }
    }
    
    
    public var is_Boxed :Bool{
        get{
            return self.layer.shadowOpacity == 0.5
        }
        set(newValue){
            if newValue{
                //self.elevation(width: 3, height: 3,border: 0.0)
                self.elevated(width: -minE, height: -minE, cornerRadius: self.height(ofCent: CGFloat(minE)))
            }else{
                //self.elevation(width: 0, height: 0, border: 0)
                self.elevated(width: 0, height: 0, cornerRadius: 0)
            }
        }
    }
    public var is_Carded : Bool {
        get{
            return self.layer.shadowOpacity == 0.5
        }
        set(newValue){
            if newValue{
                //self.elevation(width: 0, height: 5,border: 0.24)
                self.elevated(width: 0, height: maxE, cornerRadius: self.height(ofCent: CGFloat(maxE)))
            }else{
                //self.elevation(width: 0, height: 0, border: 0)
                self.elevated(width: 0, height: 0, cornerRadius: 0)
            }
        }
    }
    public var is_ClipCarded : Bool {
        get{
            return self.layer.shadowOpacity == 0.5
        }
        set(newValue){
            if newValue{
                // self.elevation(width: 5, height: 5,border: 0.24)
                self.elevated(width: -maxE, height: maxE, cornerRadius: self.height(ofCent: CGFloat(maxE)))
            }else{
                //self.elevation(width: 0, height: 0, border: 0)
                self.elevated(width: 0, height: 0, cornerRadius: 0)
            }
        }
    }
    public var is_ClippedCorner : Bool{
        get{
            return self.layer.cornerRadius != 0
        }
        set(newValue){
            if newValue{
                self.clipsToBounds = true
                self.layer.cornerRadius = self.frame.height * (5/100)
            }else{
                self.layer.cornerRadius = 0
            }
        }
    }
    
    
    func elevated(width : Double,height : Double,cornerRadius : CGFloat,shadowColor : UIColor = UIColor(hex: "484848"),shadowOpacity : Float = 0.5){
        
        self.layer.cornerRadius = cornerRadius
        // let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height);
        self.layer.shadowOpacity = shadowOpacity
        if width == 0, height == 0{
            self.layer.shadowPath = nil;return
        }
        //  self.layer.shadowPath = shadowPath.cgPath
    }
}

typealias GradientType = (start: CGPoint, end: CGPoint)

enum GradientPoint {
    case leftRight
    case rightLeft
    case topBottom
    case bottomTop
    case topLeftBottomRight
    case bottomRightTopLeft
    case topRightBottomLeft
    case bottomLeftTopRight
    
    fileprivate func draw() -> GradientType {
        switch self {
        case .leftRight:
            return (start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
        case .rightLeft:
            return (start: CGPoint(x: 1, y: 0.5), end: CGPoint(x: 0, y: 0.5))
        case .topBottom:
            return (start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1))
        case .bottomTop:
            return (start: CGPoint(x: 0.5, y: 1), end: CGPoint(x: 0.5, y: 0))
        case .topLeftBottomRight:
            return (start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 1))
        case .bottomRightTopLeft:
            return (start: CGPoint(x: 1, y: 1), end: CGPoint(x: 0, y: 0))
        case .topRightBottomLeft:
            return (start: CGPoint(x: 1, y: 0), end: CGPoint(x: 0, y: 1))
        case .bottomLeftTopRight:
            return (start: CGPoint(x: 0, y: 1), end: CGPoint(x: 1, y: 0))
        }
    }
}
struct gradient{
    var color : CGColor = UIColor.black.cgColor
    var position : NSNumber = 0.0
    init(_ color : UIColor,_ position : NSNumber){
        self.color = color.cgColor
        self.position = position
    }
}
extension UIView{
    func setGradient(_ gradients : [gradient],_ direction :GradientPoint){
        self.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = gradients.compactMap{$0.color}
        gradientLayer.locations = gradients.compactMap{$0.position}
        gradientLayer.startPoint = direction.draw().start
        gradientLayer.endPoint = direction.draw().end
        gradientLayer.name = "ar_gradient_layer"
        self.layer.addSublayer(gradientLayer)
    }
    func border(_ width : CGFloat,_ color : UIColor){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
extension UITableView{
    func springReloadData() {
        self.reloadData()
        
        let cells = self.visibleCells
        let tableHeight: CGFloat = self.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1, delay: 0.05 * Double(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            index += 1
        }
        self.scrollsToTop = true
    }
}
extension UIButton{
    var noInteraction : Bool{
        get{
            return self.isUserInteractionEnabled
        }
        set{
            self.isUserInteractionEnabled = !newValue
            self.backgroundColor = newValue ? self.backgroundColor?.withAlphaComponent(0.5) : self.backgroundColor?.withAlphaComponent(1)
        }
    }
   
}


extension UIViewController{
    //keyboard
    func listen2Keyboard(withView view : UIView){

        
        self.view.subviews.forEach { (childView) in
            if childView == view{
                childView.tag = 23
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func listen2Keyboard(withViews views : [UIView]){
        
        
        self.view.subviews.forEach { (childView) in
            views.forEach({ (moveableView) in
                if childView == moveableView{
                    childView.tag = 23
                }
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func ignore2Keyboard(){
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    @objc func KeyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let bottomSafeArea = self.view.safeAreaInsets.bottom
        debug(print: "Bottom Safe Area" + bottomSafeArea.description)
        self.view.subviews.forEach { (childView) in
            if childView.tag == 23{
                UIView.animate(withDuration: 0.15) {
                    childView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + bottomSafeArea)
                }
            }
        }
     
    }
    //hide the keyboard
    @objc func KeyboardHidden(notification: NSNotification)
    {
       
        self.view.subviews.forEach { (childView) in
            if childView.tag == 23{
                UIView.animate(withDuration: 0.15) {
                    childView.transform = .identity
                }
            }
        }
    }
    func isPresented() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
//    func setSemantic(_ val : Bool)->Bool{//If semantic is set to RTL returns true
//        return val
//        if val{
//            if Language.default.object.isRTLLanguage(){
//                UIView.appearance().semanticContentAttribute = .forceRightToLeft
//                return true
//            }else{
//                UIView.appearance().semanticContentAttribute = .forceLeftToRight
//                return false
//            }
//        }else{
//                /*if UIView.appearance().semanticContentAttribute == .forceRightToLeft{
//                UIView.appearance().semanticContentAttribute = .forceLeftToRight
//                return true
//            }*/
//            return false
//        }
//    
//    }
}
extension UILabel{
    func setResponisveFont(withSize rSize : CGFloat){
        let currentFontName = self.font.fontName
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height {
        case 480.0: //Iphone 3,4,SE => 3.5 inch
            self.font = UIFont(name: currentFontName, size: rSize * 0.7)
        case 568.0: //iphone 5, 5s => 4 inch
            self.font = UIFont(name: currentFontName, size: rSize * 0.8)
        case 667.0: //iphone 6, 6s => 4.7 inch
            self.font = UIFont(name: currentFontName, size: rSize * 0.9)
        case 736.0: //iphone 6s+ 6+ => 5.5 inch
            self.font = UIFont(name: currentFontName, size: rSize)
        default:
            print("not an iPhone")
            self.font = UIFont(name: currentFontName, size: rSize)!
        }
    }
}
extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    enum BarPosition{
        case bottom
        case top
    }
    func addBar(at position : BarPosition,
                lineWidth : CGFloat = 1,
                color : UIColor = .lightGray){
        

        let line = CALayer()
        line.frame = CGRect(x: 0.0,
                            y: position == .top ? 0.2 : self.bounds.height - lineWidth,
                            width: self.bounds.width,
                            height: lineWidth)
        
        line.backgroundColor = color.cgColor
        
        self.layer.addSublayer(line)
        
    }
}

extension UIViewController{
    func applyTopMargin(forView child: UIView){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            let margin = self.view.layoutMarginsGuide
            let safeFrame = margin.layoutFrame
            let childFrame = child.frame
            child.frame = CGRect(x: childFrame.minX,
                                 y: safeFrame.minY + childFrame.minY,
                                 width: childFrame.width,
                                 height: childFrame.height)
        }
    }
    func applyTopMargin(toViews childs : [UIView]){
        for child in childs{
            self.applyTopMargin(forView: child)
        }
    }
    func applyBottomMargin(forView child : UIView){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            let margin = self.view.layoutMarginsGuide
            let safeFrame = margin.layoutFrame
            let childFrame = child.frame
            let bottomDifference = margin.owningView?.frame.height ?? self.view.frame.height - safeFrame.height
            child.frame = CGRect(x: childFrame.minX,
                                 y: childFrame.minY - bottomDifference,
                                 width: childFrame.width,
                                 height: childFrame.height)
        }
    }
    func applyBottomMargin(toViews childs : [UIView]){
        for child in childs{
            self.applyBottomMargin(forView: child)
        }
    }
}
extension UIView{
    func shake(_ completion : @escaping ()->()){
        let translationY : CGFloat = self.frame.width * 0.065
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeLinear], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.transform =  CGAffineTransform(translationX: 0, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransform(translationX: -translationY, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransform(translationX: translationY, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransform(translationX: -translationY, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.1, animations: {
                self.transform = CGAffineTransform(translationX: translationY, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                self.transform =  .identity
            })
        }) { (completed) in
            if completed{
                completion()
            }
        }
    }
}
extension UIView{
    func freeze(for time : DispatchTime = .now() + 2){
        guard self.isUserInteractionEnabled else{return}
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.isUserInteractionEnabled = true
        }
    }
}
