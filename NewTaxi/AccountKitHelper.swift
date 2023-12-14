//
//  AccountKitHelper.swift
// NewTaxi
//
//  Created by Seentechs on 18/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
/*
typealias AK_OnSuccess = (Account?) -> ()
typealias MyClosure = ()->()

class AccountKitHelper :NSObject{
    
    //account kit facebook variable
    var _accountKit: AccountKit!
    var baseViewController : UIViewController!
    
    
    var onSuccess : AK_OnSuccess!
    var onFailure : MyClosure!
    
    override init() {
        UberSupport().changeStatusBarStyle(style: .lightContent)

//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = .ThemeMain
//            statusBar.tintColor = .white
//            //UIColor(red: 39.0 / 255.0, green: 112.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0)
//        }
    }
    static let instance = AccountKitHelper()
    //MARK: Facebook initializers
    func verifyWithView(_ vc : UIViewController, number : PhoneNumber?, success : @escaping AK_OnSuccess, failure : @escaping MyClosure) {
        
        self.baseViewController = vc
        self.onSuccess = success
        self.onFailure = failure
        
        if _accountKit == nil {
            _accountKit = AccountKit(responseType: .accessToken)
        }
        self.loginWithPhone(number)
    }
    
    func prepareLoginViewController(_ vc: AKFViewController) {
        vc.delegate = self
        //UI Theming - Optional
        vc.isGetACallEnabled = true
        vc.isSendToFacebookEnabled = true
        vc.uiManager = SkinManager(skinType: .classic, primaryColor: UIColor.ThemeMain)
        
    }
    
    func loginWithPhone(_ no : PhoneNumber?){
        let inputState = UUID().uuidString
        
        if let accountKitVC = (_accountKit?.viewControllerForPhoneLogin(with: no, state: inputState)){
            accountKitVC.isSendToFacebookEnabled = true
            self.prepareLoginViewController(accountKitVC)
            self.baseViewController.setStatusBarStyle(.lightContent)
            accountKitVC.delegate = self
            self.baseViewController.present(accountKitVC as UIViewController , animated: true, completion: nil)
        }
    }
    
  
}
extension AccountKitHelper : AKFViewControllerDelegate{
    //MARK: Facebook account kit delegates
    //onSuccess
    func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith accessToken: AccessToken, state: String) {
        self.baseViewController.setStatusBarStyle(.default)
        print("did complete login with access token \(accessToken.tokenString) ")
        _accountKit.requestAccount { (account, error) in
            if let err = error{
                print("some thing went wrong !",err)
                self.onFailure()
            }else{
                self.onSuccess(account)
                
            }
        }
    }
   
    
    func viewControllerDidCancel(_ viewController: UIViewController & AKFViewController) {
        print("User cancelled facebook login")
        self.baseViewController.setStatusBarStyle(.default)
        self.onFailure()
    }
    func viewController(_ viewController: UIViewController & AKFViewController, didFailWithError error: Error) {
        print("error")
        self.baseViewController.setStatusBarStyle(.default)
        self.onFailure()
    }
   
}

*/
