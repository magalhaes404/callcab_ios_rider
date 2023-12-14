//
//  SharedPreferences.swift
// NewTaxi
//
//  Created by Seentechs on 16/09/21.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Lottie

class Shared {
    private init(){}
    static let instance = Shared()
    fileprivate let preference = UserDefaults.standard
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var permissionDenied = false
    var resumeTripHitCount = 0
    var nonessentialdata = Bool()
    var driverRadiusKM : Int = 5
    var chatVcisActive = false
    var needToShowChatVC = false
    var appleLogin = false
    var googleLogin = false
    var facebookLogin = false
    var otpEnabled = false
    var supportArray : [Support]? = nil
    var isWebPayment = false
    var isCovidEnable = false

    //REferral
    private var enableReferral = Bool()
    func enableReferral(_ on : Bool){
        self.enableReferral = on
    }
    func isReferralEnabled() -> Bool{
        return self.enableReferral
    }
    fileprivate var gifLoaders : [UIView:GifLoaderValue] = [:]
    func isLoading(in view : UIView? = nil) -> Bool{
        if let _view = view,
            let _ = self.gifLoaders[_view]{
            return true
        }
        if let window = AppDelegate.shared.window,
            let _ = self.gifLoaders[window]{
            return true
        }
        return false
    }
    func socialLoginSupport(appleLogin : Bool,facebookLogin: Bool,googleLogin : Bool,otpEnabled: Bool,supportArr : [Support]){
        self.appleLogin = appleLogin
        self.googleLogin = googleLogin
        self.facebookLogin = facebookLogin
        self.otpEnabled = otpEnabled
        self.supportArray = supportArr
    }
}
//MARK:- UserDefaults property observers
extension Shared{
    var device_token : String{
        get{return preference.string(forKey: USER_DEVICE_TOKEN) ?? String()}
        set{preference.set(newValue, forKey: USER_DEVICE_TOKEN)}
    }
}
//MARK:- functions
extension Shared{
    func resetUserData(){
        preference.set("", forKey:"getmainpage")
        preference.removeObject(forKey: USER_CARD_BRAND)
        preference.removeObject(forKey: USER_CARD_LAST4)
        preference.removeObject(forKey: USER_ACCESS_TOKEN)
        PaymentOptions.cash.setAsDefault()
        preference.set("No", forKey: USER_SELECT_WALLET)
        preference.synchronize()
    }
   
 
}

extension Shared{
    func showLoader(in view : UIView){
        guard Shared.instance.gifLoaders[view] == nil else{return}
        let gifValue : GifLoaderValue
        if let existingLoader = self.gifLoaders[view]{
            gifValue = (loader: existingLoader.loader,count: existingLoader.count + 1)
        }else{

            let gif = self.getLoaderGif(forFrame: view.bounds)
            view.addSubview(gif)
            gif.frame = view.frame
            gif.center = view.center
            gifValue = (loader: gif,count: 1)
        }
        Shared.instance.gifLoaders[view] = gifValue
    }
    func removeLoader(in view : UIView){
        
        guard let existingLoader = self.gifLoaders[view] else{
            return
        }
        let newCount = existingLoader.count - 1
        if newCount == 0{
            Shared.instance.gifLoaders[view]?.loader.removeFromSuperview()
            Shared.instance.gifLoaders.removeValue(forKey: view)
        }else{
            Shared.instance.gifLoaders[view] = (loader: existingLoader.loader,
                                                count: newCount)
        }
    }
    func getLoaderGif(forFrame parentFrame: CGRect) -> UIView{
        // Creatting a Background View
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = parentFrame
        
        // Creatting a Lottie Loader View
        let loader = self.createLottieView(view: view)
        view.addSubview(loader)
        
        // Setting Loader For Loader View
        loader.anchor(toView: view)
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loader.heightAnchor.constraint(equalToConstant: 80).isActive = true
        loader.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Setting Tag For The Loader
        view.tag = 2596
        
        return view
    }
    
    func createLottieView(view: UIView) -> AnimationView{
        
        let animationView = AnimationView.init(name: "app_loader")
        
        animationView.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView.loopMode = .loop
        
        // 5. Adjust animation speed
        
        animationView.animationSpeed = 1.5
        
        // 6. Play animation
        
        animationView.play()
        return animationView
    }
    
    func showLoaderInWindow(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let window = appDelegate.window{
            self.showLoader(in: window)
        }
    }
    func removeLoaderInWindow(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let window = appDelegate.window{
            self.removeLoader(in: window)
        }
    }
}
