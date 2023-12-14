//
//  LoginVC.swift
//  UberClone
//
//  Created by Seentechs Technologies on 29/03/17.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Social
import FBSDKLoginKit
import FBSDKCoreKit
import AuthenticationServices
import GoogleSignIn

class AuthenticationVC : UIViewController, MFMailComposeViewControllerDelegate, GIDSignInDelegate, APIViewProtocol{
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch (API,response) {
        
        default:
            break
        }
    }
    
    var apiInteractor: APIInteractorProtocol?
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var btnSignIn : UIButton!
    @IBOutlet weak var btnSignUp : UIButton!
    @IBOutlet weak var appleHolder: UIView!
    @IBOutlet weak var facebookHolder: UIView!
    @IBOutlet weak var googleHolder: UIView!
    @IBOutlet weak var lblDriver: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var appLogo: UIImageView!
    @IBOutlet weak var langValueLbl : UILabel!
    @IBOutlet weak var langView : UIView!
    @IBOutlet weak var socialLoginStack: UIStackView!
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    var fullWidth = false
    var signUpType : SignUpType = .notDetermined
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var pushManager : PushNotificationManager!
    // MARK: - ViewController Methods
    func setFonts()
    {
        self.lblDriver.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 37)
        self.lblDriver.textColor = .Title
        self.subTitle.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 25)
        self.subTitle.textColor = .Title
        self.btnSignIn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.btnSignIn.setTitleColor(.Subtitle, for: .normal)
        self.btnSignIn.backgroundColor = .ThemeYellow
        self.btnSignUp.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        self.btnSignUp.setTitleColor(.Title, for: .normal)
        self.langValueLbl.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        self.langValueLbl.textColor = .Title
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)

        self.appDelegate.pushManager.registerForRemoteNotification()
        self.btnSignIn.isExclusiveTouch = true
        self.btnSignIn.setTitle(self.language.continueWithPhone, for: .normal)
        self.subTitle.text = self.language.loginToContinue
        self.btnSignUp.setTitle(self.language.register.capitalized, for: .normal)
        self.langValueLbl.text = Language.default.displayName
        self.initView()
        startAnimation()
        self.appLogo.image = UIImage(named: iApp.appLogo)
        makeMenuAnimation()
        lblDriver.text = self.language.welcomeBack
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let flag = CountryModel(withCountry: countryCode)
            flag.store()
        }
        self.setDesign()
        self.setFonts()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.initButtons()
        }
    }
    func setDesign(){
        self.btnSignUp.layer.cornerRadius = 10.0
        self.btnSignIn.layer.cornerRadius = 10.0
        self.btnSignUp.border(1, .Border)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK:- initializers
    func initView(){
        self.langView.addAction(for: .tap) { [weak self] in
            let view = SelectLanguageVC.initWithStory()
            view.modalPresentationStyle = .overCurrentContext
            self?.present(view, animated: true, completion: nil)
        }
    }
    //MARK:- initWithstory
    class func initWithStory() -> AuthenticationVC{
        return UIStoryboard.payment.instantiateViewController()
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
            if Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == "" {
                appDelegate.createToastMessage(self.language.tryAgain, bgColor: UIColor.black, textColor: UIColor.white)
                DispatchQueue.main.async {
                    self.pushManager.registerForRemoteNotification()
                }
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
            Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == "" {
            appDelegate.createToastMessage(self.language.tryAgain, bgColor: UIColor.black, textColor: UIColor.white)
            DispatchQueue.main.async {
                self.pushManager.registerForRemoteNotification()
            }
            self.view.endEditing(true)
            return
        }
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.presentInFullScreen(mobileValidationVC, animated: true, completion: nil)
    }
    func verifyMobileNumberAPI(number: String,country : CountryModel){
        var parms = [String:Any]()

        if self.userDataFromSocialLogin != nil {
            parms = self.userDataFromSocialLogin ?? JSON()
        }else{
            self.signUpType = .email
        }
        parms["mobile_number"] = number
        parms["country_code"] = country.country_code
        let viewEditProfile = SocialInfoVC.initWithStory(using: self.signUpType, params: parms ?? JSON())
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
        if !iApp.isSimulator &&
            (Constants().GETVALUE(keyname: USER_DEVICE_TOKEN) == ""){
            appDelegate.createToastMessage(self.language.tryAgain, bgColor: UIColor.black, textColor: UIColor.white)
            DispatchQueue.main.async {
                self.pushManager.registerForRemoteNotification()
            }
            self.view.endEditing(true)
        }
        else{
            let socialVC = SocialLoginVC.initWithStory()
            self.navigationController?.pushViewController(socialVC, animated: true)
        }
    }
    
    //MARK:- initButtons
    func initButtons(){
        self.appleHolder.isHidden = true
        self.googleHolder.isHidden = true
        self.facebookHolder.isHidden = true
        if Shared.instance.facebookLogin && Shared.instance.googleLogin {
            fullWidth = true
        }else{
            fullWidth = false
        }
        if self.language.isRTLLanguage(){
            
        }else{
            
        }
        if Shared.instance.appleLogin{
            if #available(iOS 13.0, *) {
                self.setupAppleButton()
                self.appleHolder.isHidden = false
            }else{
                self.appleHolder.isHidden = true
            }
        }
        if Shared.instance.facebookLogin{
            self.setupFacebookButton()
            self.facebookHolder.isHidden = false
        }
        if Shared.instance.googleLogin{
            self.setupGoogleButton()
            self.googleHolder.isHidden = false
        }
      
       
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
       

    }
    func setupAppleButton(){
        guard #available(iOS 13.0, *) else{
            self.appleHolder.isHidden = true
            return
        }
        self.appleHolder.isHidden = false
        let nib = UINib(nibName: "ImageButton", bundle: nil)
        let authorizationButton = nib.instantiate(withOwner: nil, options: nil)[0] as! ImageButton
        authorizationButton.frame = CGRect(x: 0, y: 0, width: self.appleHolder.frame.width, height: 45)
        authorizationButton.setTitle("Sign in with Apple")
        authorizationButton.setCenterImage("apple")
        authorizationButton.setTitle(color: .Title)
        authorizationButton.setBackground(color: UIColor(hex: "FFFFFF"))
        authorizationButton.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        authorizationButton.isRoundCorner = true
        authorizationButton.elevate(2)
        authorizationButton.addAction(for: .tap) { [weak self] in
            self?.handleLogInWithAppleIDButtonPress()
        }
        authorizationButton.removeFromSuperview()
        self.appleHolder.addSubview(authorizationButton)
    }
    func setupFacebookButton(){
        let nib = UINib(nibName: "ImageButton", bundle: nil)
        let fbButton = nib.instantiate(withOwner: nil, options: nil)[0] as! ImageButton
        if self.language.isRTLLanguage(){
            fbButton.frame = CGRect(x: self.facebookHolder.frame.origin.x, y: self.facebookHolder.frame.origin.y, width: self.fullWidth ? (self.view.frame.width - 50)/2 : 100, height: 45)
        }else{
            fbButton.frame = CGRect(x: self.googleHolder.frame.origin.x, y: self.googleHolder.frame.origin.y, width: self.fullWidth ? (self.view.frame.width - 50)/2 : self.view.frame.width - 40, height: 45)
        }

        fbButton.setTitle(self.language.faceBook)
        fbButton.setCenterImage("facebook")
        fbButton.setTitle(color: .Title)
        fbButton.setBackground(color: UIColor(hex: "FFFFFF"))
        fbButton.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        fbButton.isRoundCorner = true
        fbButton.elevate(2)
        fbButton.addAction(for: .tap) { [weak self] in
            self?.doFacebookLogin()
        }
        fbButton.removeFromSuperview()
        self.facebookHolder.addSubview(fbButton)
    }

    func setupGoogleButton(){
        
        let nib = UINib(nibName: "ImageButton", bundle: nil)
        let googleButton = nib.instantiate(withOwner: nil, options: nil)[0] as! ImageButton
//        googleButton.frame = CGRect(x: self.googleHolder.frame.origin.x, y: self.googleHolder.frame.origin.y, width: self.fullWidth ? (self.view.frame.width - 50)/2 : self.view.frame.width - 40, height: 45)
        googleButton.frame = CGRect(x: self.googleHolder.frame.origin.x, y: self.googleHolder.frame.origin.y, width: self.fullWidth ? (self.view.frame.width - 50)/2 : 100, height: 45)
        if self.language.isRTLLanguage(){
            googleButton.frame = CGRect(x: self.facebookHolder.frame.origin.x, y: self.facebookHolder.frame.origin.y, width: self.fullWidth ? (self.view.frame.width - 50)/2 : 100, height: 45)
        }
        googleButton.setTitle(self.language.google)
        googleButton.setCenterImage("google")
        googleButton.setTitle(color: .Title)
        googleButton.setBackground(color: UIColor(hex: "FFFFFF"))
        googleButton.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        googleButton.isRoundCorner = true
        googleButton.elevate(2)

        googleButton.addAction(for: .tap) { [weak self] in
            self?.doGoogleLogin()
        }
        googleButton.removeFromSuperview()
        self.googleHolder.addSubview(googleButton)
    }

    //MARK:- Actions
    @objc
    func handleLogInWithAppleIDButtonPress(){
        guard #available(iOS 13.0, *) else{return}
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func doFacebookLogin(){
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(
            permissions: ["public_profile","email","user_location","user_birthday","user_hometown"],
            from: self) { (result, error) in
            if (error == nil)
            {
                let fbloginresult = result!
                
                if(fbloginresult.grantedPermissions.contains("public_profile"))
                {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
            }
        }
    }
    func doGoogleLogin(){
        var _: NSError?
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    // MARK: Facebook Response handling
    
    func getFBUserData()
    {
        if let accessToken = AccessToken.current?.tokenString{
            if accessToken.count > 0{
                Constants().STOREVALUE(
                    value: accessToken,
                    keyname: CEO_FacebookAccessToken
                )
            }
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, birthday, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let newresult = result as? NSDictionary
                    var dicts = [String: Any]()
                    dicts["email"] = (newresult?["email"] != nil) ? newresult?["email"] as? String ?? String() : ""
                    dicts["first_name"] = newresult?["first_name"] as? String ?? String()
                    dicts["last_name"] = newresult?["last_name"] as? String ?? String()
                    dicts["fb_id"] = newresult?["id"] as? String ?? String()
                    Constants().STOREVALUE(value: dicts["first_name"] as? String ?? String(), keyname: USER_FIRST_NAME)
                    Constants().STOREVALUE(value: dicts["last_name"] as? String ?? String(), keyname: USER_LAST_NAME)
                    Constants().STOREVALUE(value: dicts["fb_id"] as? String ?? String(), keyname: USER_FB_ID)
                    
                    
                    let fbID = newresult?["id"] as? String ?? String()
                    
                    
                    if newresult?.value(forKeyPath:"picture.data.url") != nil{
                        dicts["user_image"] = newresult?.value(forKeyPath:"picture.data.url") as? String ?? String()
                        Constants().STOREVALUE(value: dicts["user_image"] as? String ?? String(), keyname: USER_IMAGE_THUMB)
                    }
                    self.checkSocialMediaId(userData: dicts,
                                            signUpType: .facebook(id: fbID))
                }
                else{
                    UberSupport().removeProgress(viewCtrl: self)
                }
            })
        }
    }
    // MARK: Google Response Handling
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if (error == nil)  // SIGN IN SUCCESSFUL
        {
            
            // Perform any operations on signed in user here.
            let userId = user.userID ?? ""                  // For client-side use only!
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            var dicts = [String: Any]()
            
            if GIDSignIn.sharedInstance().currentUser.profile.hasImage {
                let dimension = round(120 * UIScreen.main.scale)
                let imageURL = user.profile.imageURL(withDimension: UInt(dimension))
                dicts["user_image"] = imageURL?.absoluteString
            }
            dicts["email"] = email
            dicts["first_name"] = givenName
            dicts["last_name"] = familyName
            self.checkSocialMediaId(userData: dicts,
                                    signUpType: .google(id: userId))
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().disconnect()
        }
        else
        {
            UberSupport().removeProgress(viewCtrl: self)
        }
    }
    // MARK: - CHECKING SOCIAL MEIDA ID - API CALL
   
    func checkSocialMediaId(userData: [String: Any],
                            signUpType: SignUpType)
    {
        var parameters = [String:Any]()
        for item in signUpType.getParamValueForType{
            parameters[item.key] = item.value
        }
//        self.apiInteractor?
//            .getResponse(forAPI: .socialSignup,
//                         params: parameters,
//                         responseValue: {
//                            (result) in
//                            switch result{
//                            case .success(let response):
//                                if case ResponseEnum.newUserNotAuthenticatedYet = response{
//                                    self.verifyMobileNumberAK(params: userData,
//                                                              signUpType: signUpType)
//
//                                }else if case ResponseEnum.onAuthenticate(_) = response{
//                                    self.userIsAuthenticatedGoToHome()
//                                }
//                            case .failure(let error):
//                                self.appDelegate.createToastMessage(error.localizedDescription)
//                            }
//                         }).shouldLoad(true)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .socialSignup,params: parameters)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    switch json.status_code {
                    case 1://ExistingUser
                        let loginData = RiderDataModel(json)
                        loginData.storeRiderBasicDetail()
                        loginData.storeRiderImprotantData()
                        self.userIsAuthenticatedGoToHome()
                    case 2://newUser
                        self.verifyMobileNumberAK(params: userData,
                                                  signUpType: signUpType)
                    default:
                        break
                    }
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

    }
    func userIsAuthenticatedGoToHome(){
        let userDefaults = UserDefaults.standard
        userDefaults.set("rider", forKey:"getmainpage")
        userDefaults.synchronize()
        
        self.appDelegate.onSetRootViewController(viewCtrl: self)
    }
    var userDataFromSocialLogin : [String:Any]?
    func verifyMobileNumberAK(params : [String:Any],
                              signUpType : SignUpType){
        //mobile_number
        self.signUpType = signUpType
        self.userDataFromSocialLogin = params
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.presentInFullScreen(mobileValidationVC, animated: true, completion: nil)
        
    }
    
}
extension AuthenticationVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        self.verifyMobileNumberAPI(number: number.number,
                                   country: number.flag)
    }
}
extension AuthenticationVC : UIViewControllerTransitioningDelegate{
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect{
        let bounds = UIScreen.main.bounds
        return CGRect(x: 0,
                      y: (bounds.height)/2,
                      width: bounds.width,
                      height: bounds.height/2)
    }
}
//MARK:- ASAuthorizationControllerDelegate
extension AuthenticationVC : ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //        self.appDelegate.createToastMessage(self.language.authenticationCancelled)
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account in your system.
            // For the purpose of this demo app, store the these details in the keychain.
            self.handleAppleData(forSuccess: appleIDCredential)
            
            //Show Home View Controller
            //            HomeViewController.Push()
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            
        }
    }
    @available(iOS 13.0, *)
    func handleAppleData(forSuccess appleIDCredential : ASAuthorizationAppleIDCredential){
        let email : String?
        if let appleEmail = appleIDCredential.email {
            email = appleEmail
            KeychainItem.currentUserEmail = appleEmail
        }else{
           // email = KeychainItem.currentUserEmail
            email = ""
        }
        var userData = [String : Any]()
        if let fullName = appleIDCredential.fullName,
           let givenName = fullName.givenName,
           let familyName = fullName.familyName{
            userData["first_name"] = givenName
            userData["last_name"] = familyName
            KeychainItem.currentUserFirstName = givenName
            KeychainItem.currentUserLastName = familyName
        }else{
            //userData["first_name"] = KeychainItem.currentUserFirstName
           // userData["last_name"] = KeychainItem.currentUserLastName
        }
        guard let validEmai = email else{
            self.appDelegate
                .createToastMessage(iApp.NewTaxiError.server.localizedDescription)
            return
        }
        userData["email"] = validEmai
        self.checkSocialMediaId(userData: userData,
                                signUpType: .apple(id: appleIDCredential.user,
                                                   email: validEmai))
        if let identityTokenData = appleIDCredential.identityToken,
           let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            debug(print: "Identity Token \(identityTokenString)")
        }
    }
}

extension AuthenticationVC : ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
