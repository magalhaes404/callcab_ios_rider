/**
* MainVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import MessageUI
import Social
import FBSDKLoginKit
import FBSDKCoreKit

import AuthenticationServices
import GoogleSignIn


class SocialLoginVC : UIViewController, MFMailComposeViewControllerDelegate, GIDSignInDelegate, APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch (API,response) {
    
        default:
            break
        }
    }
    
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var appleHolder : UIView!
    @IBOutlet weak var facebookHolder : UIView!
    @IBOutlet weak var googleHolder : UIView!
    @IBOutlet weak var accountHolderStack: UIStackView!
    
    var isPresenting = false
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    
    var strEmail = ""
    var strVerses:String = ""
    var strFBID = ""
    var strUserName = ""
    var strFirstName = ""
    var strLastName = ""
    
    
    var signUpType : SignUpType = .notDetermined
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        if iApp.instance.isRTL{
            self.btnBack.setTitle("I", for: .normal)
            self.lblTitle.textAlignment = NSTextAlignment.right
        }else{
            self.btnBack.setTitle("e", for: .normal)
        }
        self.lblTitle.text = self.language.chooseAcc
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.initButtons()
        }
        self.navigationController?.isNavigationBarHidden = true
        if #available(iOS 13,*){
            let height = UIScreen.main.bounds.height * 0.5
            self.view.transform = CGAffineTransform(translationX: 0, y: height)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
       
        if ((self.view.viewWithTag(123456)?.superview) != nil)
        {
            UberSupport().removeProgress(viewCtrl: self)

        }
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    //MARK:- initWithStory
    class func initWithStory() -> SocialLoginVC{
        return UIStoryboard.account.instantiateViewController()
    }
 
    
    //MARK:- initButtons
    func initButtons(){
        
//        self.setupAppleButton()
//        self.setupFacebookButton()
//        self.setupGoogleButton()
//        self.accountHolderStack.removeArrangedSubview(self.appleHolder)
//        self.appleHolder.removeFromSuperview()
//        self.accountHolderStack.removeArrangedSubview(self.googleHolder)
//        self.googleHolder.removeFromSuperview()
//        self.accountHolderStack.removeArrangedSubview(self.facebookHolder)
//        self.facebookHolder.removeFromSuperview()
        self.appleHolder.isHidden = true
        self.googleHolder.isHidden = true
        self.facebookHolder.isHidden = true
        if Shared.instance.appleLogin{
            if #available(iOS 13.0, *) {
                          self.setupAppleButton()
                          self.appleHolder.isHidden = false
                      }else{
                          self.appleHolder.isHidden = true
                      }
//            self.accountHolderStack.addArrangedSubview(self.appleHolder)
        }
        if Shared.instance.facebookLogin{
            self.setupFacebookButton()
            self.facebookHolder.isHidden = false

//            self.accountHolderStack.addArrangedSubview(self.facebookHolder)
        }
        if Shared.instance.googleLogin{
            self.setupGoogleButton()
            self.googleHolder.isHidden = false

//            self.accountHolderStack.addArrangedSubview(self.googleHolder)
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
        
        let isDarkTheme = view.traitCollection.userInterfaceStyle == .dark
        let style: ASAuthorizationAppleIDButton.Style = isDarkTheme ? .white : .black
     
             
        // Create and Setup Apple ID Authorization Button
        let authorizationButton = ASAuthorizationAppleIDButton(type: .default, style: style)
      
        authorizationButton.addTarget(self, action: #selector(handleLogInWithAppleIDButtonPress), for: .touchUpInside)
        authorizationButton.frame = self.appleHolder.bounds
        self.appleHolder.addSubview(authorizationButton)
        let height = authorizationButton.heightAnchor.constraint(equalToConstant: self.appleHolder.frame.height)
              authorizationButton.addConstraint(height)
       
    }
    func setupFacebookButton(){
        let fbButton = ImageButton.initialize(on: self.facebookHolder)
        fbButton.setTitle("\(self.language.signInWith) Facebook")
        fbButton.setCenterImage("fb_logo.png")
        fbButton.setTitle(color: .white)
        fbButton.setTint(color: .white)
        fbButton.setBackground(color: UIColor(hex: "4C5EA0"))
        fbButton.isClippedCorner = true
        fbButton.elevate(1)
        fbButton.addAction(for: .tap) { [weak self] in
            self?.doFacebookLogin()
        }
    }
    
    func setupGoogleButton(){
        let googleButton = ImageButton.initialize(on: self.googleHolder)
        googleButton.setTitle("\(self.language.signInWith) Google")
        googleButton.setCenterImage("google_logo.png")
        googleButton.setTitle(color: .white)
        googleButton.setTint(color: .white)
        googleButton.setBackground(color: UIColor(hex: "D55B3C"))
        googleButton.isClippedCorner = true
        googleButton.elevate(1)
        
        googleButton.addAction(for: .tap) { [weak self] in
            self?.doGoogleLogin()
        }
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
//        fbLoginManager.loginBehavior = FBSDKLoginBehavior.browser
        
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
        var configureError: NSError?
//                 GGLContext.sharedInstance().configureWithError(&configureError)
//                 assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")

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
               // UberSupport().showProgress(viewCtrl: self, showAnimation: true)

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
//                dicts["password"] = ""
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
    /*
        IF ALREADY SOCIAL ID EXIST IT WILL DIRECTLY LOGIN
        ELSE IT WILL GO SOCIAL SIGNUP PAGE (SOCIALINFOVC)
     */
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
//                                        self.verifyMobileNumberAK(params: userData,
//                                                                  signUpType: signUpType)
//                                  
//                                }else if case ResponseEnum.onAuthenticate(_) = response{
//                                    self.userIsAuthenticatedGoToHome()
//                                }
//                            case .failure(let error):
//                                self.appDelegate.createToastMessage(error.localizedDescription)
//                            }
//            }).shouldLoad(true)
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
    var userDataFromSocialLogin : [AnyHashable:Any]?
    func verifyMobileNumberAK(params : [AnyHashable:Any],
                              signUpType : SignUpType){
        //mobile_number
        self.signUpType = signUpType
        self.userDataFromSocialLogin = params
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.presentInFullScreen(mobileValidationVC, animated: true, completion: nil)

    }

    
   

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController!.popViewController(animated: true)
        }
    }

    
    
}
extension SocialLoginVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        guard var parms = self.userDataFromSocialLogin else{return}
        parms["mobile_number"] = number.number
        parms["country_code"] = number.flag.country_code
        let viewEditProfile = SocialInfoVC
            .initWithStory(using: self.signUpType, params: parms as? [String : Any] ?? [:])
        
        viewEditProfile.isNoVerified = true
        self.navigationController?.pushViewController(viewEditProfile, animated: true)
    }
    
    
}
//MARK:- ASAuthorizationControllerDelegate
extension SocialLoginVC : ASAuthorizationControllerDelegate {
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
            email = KeychainItem.currentUserEmail
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
            userData["first_name"] = KeychainItem.currentUserFirstName
            userData["last_name"] = KeychainItem.currentUserLastName
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

extension SocialLoginVC : ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


