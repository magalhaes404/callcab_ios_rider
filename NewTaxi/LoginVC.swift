//
//  LoginVC.swift
//  UberClone
//
//  Created by Vignesh Palanivel on 29/03/17.
//  Copyright © 2017 Vignesh Palanivel. All rights reserved.
//

import Foundation
import UIKit


class AuthenticationVC : UIViewController {
    
    @IBOutlet var viewHolder: UIView!
    @IBOutlet fileprivate var selectedView: UIView?
    @IBOutlet var viewTitle: UIView!
    @IBOutlet var imgBg: UIImageView!
    
    @IBOutlet weak var btnSignIn : UIButton!
    @IBOutlet weak var btnSignUp : UIButton!
    @IBOutlet weak var btnSocialSignUp : UIButton!
    
    
    @IBOutlet var lblDriver: UILabel!
    @IBOutlet weak var appLogo: UIImageView!
    
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.registerForRemoteNotification()
     
        self.initView()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initLayers()
        }
        
        startAnimation()
    
        self.appLogo.image = UIImage(named: iApp.appLogo)
        // Do any additional setup after loading the view, typically from a nib.
        iPhoneScreenSizes()
        makeMenuAnimation()
        lblDriver.text = String(format:"%@ %@",NSLocalizedString("Get moving with", comment: ""),iApp.appName)
 
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let flag = FlagModel(withCountry: countryCode)
     
            flag.store()
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UberSupport().changeStatusBarStyle(style: .default)
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK:- initializers
    func initView(){
        
    }
    func initLayers(){
        self.btnSignIn.border(1, .ThemeMain)
        self.btnSignUp.backgroundColor = .ThemeMain
    }
    
    func startRotating(duration: Double = 10) {
        let kAnimationKey = "rotation"
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(.pi * 2.0)
            imgBg.layer.add(animate, forKey: kAnimationKey)
    }
    //set the Ipad screen size
    func iPhoneScreenSizes()
    {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        var rectEmailView = viewTitle.frame
        switch height
        {
        case 568.0:
            rectEmailView.origin.y = viewTitle.frame.origin.y + 20
            imgBg.image = UIImage(named:"pattern568.jpg")
        case 667.0:
            rectEmailView.origin.y = viewTitle.frame.origin.y + 30
            imgBg.image = UIImage(named:"pattern6.jpg")
        case 736.0:
            rectEmailView.origin.y = viewTitle.frame.origin.y + 40
            imgBg.image = UIImage(named:"pattern6.jpg")
        case 1104.0:
            rectEmailView.origin.y = viewTitle.frame.origin.y + 50
            imgBg.image = UIImage(named:"pattern7.jpg")
        default:
            print("")
        }
        viewTitle.frame = rectEmailView
    }

    // Making spring damn animation
    func makeMenuAnimation()
    {
        let initialDelay = 0.5;
        var i = 0.0;
        for view in viewHolder.subviews {
            setupShareAppViewAnimationWithView(view,deleyTime: initialDelay + i)
            i=i + 0.1;
        }
    }

    
    @IBAction func signInAction(_ sender : UIButton?){
        if !iApp.isSimulator {
            if Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == "" || Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == nil {
                appDelegate.createToastMessage(NSLocalizedString("Please try again", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)
                self.appDelegate.registerForRemoteNotification()
                self.view.endEditing(true)
                return
            }
        }
        
        let vc = NewSignInVC.initWithStory()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func signUpAction(_ sender : UIButton?){
        //mobile_number
        if !iApp.isSimulator &&
            Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == "" ||
            Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == nil{
            appDelegate.createToastMessage(NSLocalizedString("Please try again", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)
            self.appDelegate.registerForRemoteNotification()
            self.view.endEditing(true)
            return
        }
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.present(mobileValidationVC, animated: true, completion: nil)
//        AccountKitHelper.instance.verifyWithView(self, number: nil, success: { (account) in
//            let number = account?.phoneNumber!
//            dump(number)
//            self.verifyMobileNumberAPI(number: number!.phoneNumber,
//                                       code: number!.countryCode)
//
//        }) {
//
//        }
    }
    func verifyMobileNumberAPI(number: String,code : String){
        
                var parms = [AnyHashable:Any]()
                parms["mobile_number"] = number
                parms["country_code"] = code
                let viewEditProfile = UIStoryboard.main.instantiateViewController(withIdentifier: "SocialInfoVC") as! SocialInfoVC
                viewEditProfile.dictParms = parms
                viewEditProfile.isNoVerified = true
                viewEditProfile.isNormalRegistration = true
                self.navigationController?.pushViewController(viewEditProfile, animated: true)
        

    }
    // MARK: Show aimation
    func setupShareAppViewAnimationWithView(_ view:UIView,deleyTime:Double)
    {
        view.transform = CGAffineTransform(translationX: 0, y: self.viewHolder.frame.size.height)
        UIView.animate(withDuration: 1.0, delay: deleyTime, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        }, completion: nil)
    }
    func startAnimation()
    {
        self.view.backgroundColor = UIColor.white
        let animation = CircularRevealAnimation(from: CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2), to: self.view.bounds)
        self.view.layer.mask = animation.shape()
        self.view.alpha = 1
        animation.commit(duration: 0.5, expand: true, completionBlock: {
            self.view.layer.mask = nil
        })
    }

    
    // Moving to SocialSignup
 
    @IBAction func onSocialSignupTapped(_ sender:UIButton!)
    {
        if Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == "" || Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == nil  {
            appDelegate.createToastMessage(NSLocalizedString("Please try again", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)
            self.appDelegate.registerForRemoteNotification()
            self.view.endEditing(true)
        }
        else{
            let socialVC = UIStoryboard.main.instantiateViewController(withIdentifier: "SocialLoginVC") as! SocialLoginVC
           
            self.navigationController?.pushViewController(socialVC, animated: true)
        }
    }
    
    
}
extension AuthenticationVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        self.verifyMobileNumberAPI(number: number.number,
                                   code: number.flag.dial_code.replacingOccurrences(of: "+",
                                                                                    with: ""))
    }
    
    
}
