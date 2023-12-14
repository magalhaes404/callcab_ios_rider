//
//  MobileValidationVC.swift
// NewTaxi
//
//  Created by Seentechs on 11/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Alamofire

protocol MobileNumberValiadationProtocol {
    func verified(number : MobileNumber)
}

class MobileValidationVC: UIViewController,APIViewProtocol,CheckStatusProtocol, UITextFieldDelegate {
    //MARK:- API
    var apiInteractor: APIInteractorProtocol?
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    var mobileNumberUpdated : Bool = false

    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        self.removeProgress()
        switch response {
//        case .number(isValid: let valid,
//                     OTP: let otp,
//                     message: let message):
//            if valid{
//                if Shared.instance.otpEnabled{
//                    if self.currentScreenState  != .OTP{//if already not in otp screen
//                        self.aniamateView(for: .OTP)
//                    }
//                    self.otpFromAPI = otp
//                    print("otp\(otpFromAPI)")
//
//                    appDelegate.createToastMessage("OTP \(otp)")
//                }
//                else{
//                    self.onSuccess()
//                }
//
//            }else{
//                self.otpFromAPI = nil
//                self.showError(message)
//            }
        default:
            break
        }
    }
    
    func onFailure(error: String,for API : APIEnums) {
//        self.showError(error)
//        self.removeProgress()
    }
    /**
     MobileNumberValidation Screen States
     - States:
        - mobileNumber
        - OTP
     */
    enum ScreenState{
        case mobileNumber
        case OTP
    }
    enum NumberValidationPurpose{
        case forgotPassword
        case register
        case changeNumber
    }
    //MARK:- outlets
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var contentHolderView : UIView!
    @IBOutlet weak var titleIV : UIImageView!
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var descLbl : UILabel!
    @IBOutlet weak var inputFieldHolderView : UIView!
    @IBOutlet weak var nextBtn : UIButton!
    @IBOutlet weak var bottomDescLbl : UILabel!
    @IBOutlet weak var bottomBtn :UIButton!
    @IBOutlet weak var headertitle : UILabel!

    //MARK:- variables
    var purpose : NumberValidationPurpose!
    
    var otpFromAPI : String?{
        didSet{
            guard self.otpFromAPI != nil else{return}
            self.startOTPTimer()
        }
    }
    var flag : CountryModel?{
        didSet{
            self.mobileNumberView.flag = self.flag
        }
    }
    var currentScreenState : ScreenState{
        return otpFromAPI == nil ? .mobileNumber : .OTP
    }
    lazy var mobileNumberView : MobileNumberView = {
        let mnView = MobileNumberView.getView(with: self.inputFieldHolderView.bounds)
        mnView.countryHolderView.addAction(for: .tap, Action: {
            self.pushToCountryVC()
        })
        return mnView
    }()
    lazy var otpView : OTPView = {
        let _otpView = OTPView.getView(with: self,
                                       using: self.inputFieldHolderView.bounds)
        if iApp.instance.isRTL{
            _otpView.rotate()
        }
        return _otpView
    }()
    lazy var toolBar : UIToolbar = {
        let tool = UIToolbar(frame: CGRect(origin: CGPoint.zero,
                                              size: CGSize(width: self.view.frame.width,
                                                           height: 30)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(self.doneAction))
        let clear = UIBarButtonItem(barButtonSystemItem: .refresh,
                                   target: self,
                                   action: #selector(self.clearAction))
        tool.setItems([clear,space,done], animated: true)
        tool.sizeToFit()
        return tool
    }()
     var spinnerView = JTMaterialSpinner()
    var remainingOTPTime = 0
    var validationDelegate : MobileNumberValiadationProtocol?
    //MARK:- View life cycle

    override func viewDidDisappear(_ animated: Bool) {
      if mobileNumberUpdated {
        self.mobileNumberUpdated = true
      } else {
        self.mobileNumberUpdated = false
        //release
      }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setfonts()
        self.initView()
//        self.headertitle.text = language.register.capitalized
        self.headertitle.text = ""
        self.contentHolderView.setSpecificCornersForTop(cornerRadius: 35)
        self.contentHolderView.elevate(8)
        // Do any additional setup after loading the view.
    }
    //MARK:- Change StatusBar style function
    func BarFunction(){


    }
    func setfonts(){
        self.headertitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.descLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 20)
        self.titleLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 24)
        self.bottomDescLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 16)
        self.bottomBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
    }
    //MARK:- initializers
    

    func initView(){


        self.setContentData(for: self.currentScreenState)
        if let code = UserDefaults.standard.string(forKey: USER_DIAL_CODE){
            let country = UserDefaults.standard.string(forKey: USER_COUNTRY_CODE)
            self.flag = CountryModel(forDialCode: code,withCountry: country)
            
        }else{
            self.flag = CountryModel()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initLayers()
        }
        self.bottomBtn.alpha =  0
        self.bottomDescLbl.alpha =  0
        
        
        if self.language.isRTLLanguage(){
            self.nextBtn.setTitle("e", for: .normal)
            self.backBtn.setTitle("I", for: .normal)
        }else{
            self.nextBtn.setTitle("I", for: .normal)
            self.backBtn.setTitle("e", for: .normal)
        }
        if UIScreen.main.bounds.height <= 570{ //5s or less
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShows), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHiddens), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    func initLayers(){
        self.nextBtn.cornerRadius = 9
        self.checkStatus()
    }
    @objc func KeyboardShows(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.15) {
            self.contentHolderView.transform = CGAffineTransform(translationX: 0,
                                                                 y: -keyboardFrame.height * 0.3)
        }
        
    }
    //hide the keyboard
    @objc func KeyboardHiddens(notification: NSNotification)
    {
        
        
        UIView.animate(withDuration: 0.15) {
            self.contentHolderView.transform = .identity
        }
        
    }
    //MARK:- init with story
    /**
     Static function to initialize MobileValidationVC
     - Author: Abishek Robin
     - Parameters:
        - delegate: MobileNumberValiadationProtocol to be parsed
        - purpose: forgotPassword,register,changeNumber
     - Returns: MobileValidationVC object
     - Warning: Purpose must be parsed properly
     */
    class func initWithStory(usign delegate : MobileNumberValiadationProtocol,
                             for purpose : NumberValidationPurpose)-> MobileValidationVC{
        let view : MobileValidationVC = UIStoryboard.jeba.instantiateIDViewController()
       
        view.apiInteractor = APIInteractor(view)
        view.purpose = purpose
        view.validationDelegate = delegate
        return view
    }

    //MARK:- Actions
    @IBAction func backAction(_ sender : UIButton){
        if self.currentScreenState == .mobileNumber{
            if self.isPresented(){

                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else{
                self.otpFromAPI = nil
                self.otpView.clear()
                self.aniamateView(for: .mobileNumber)
         }
    }
    @IBAction func nextAction(_ sender : UIButton){
        if self.currentScreenState == .mobileNumber{
           // self.otpView.tf1.becomeFirstResponder()
            self.wsToVerifyNumber()
        }else{
//            if let typedOTP = self.otpView.otp,
//                let originalOTP = self.otpFromAPI,
//                typedOTP == originalOTP{//Validation completed
//                self.onSuccess()
//
//            }else{//Invalid otp
//                self.otpView.invalidOTP()
//            }
            if let typedOTP = self.otpView.otp,let number = self.mobileNumberView.number, let countryCode = self.flag?.dial_code {
                self.otpVerification(enteredOTP: typedOTP,mobileNumber: number,countryCode: countryCode)
            }else{
                print("local otp problem")
            }
        }
    }
    func otpVerification(enteredOTP : String,
                           mobileNumber : String,
                           countryCode : String) {
          
          let param = ["otp" : enteredOTP,
                       "mobile_number":mobileNumber,
                       "country_code":countryCode]
          
          self.wsToVerifyOTP(param: param)
      }
    func wsToVerifyOTP(param:JSON) {
            self.wsToVerifyOTP(parms: param) { (response) in
                switch response {
                case .success(let result):
                    if result {
                        self.onSuccess()
                    } else {
                        self.otpView.invalidOTP()
                    }
                case .failure(let err):
                    AppDelegate.shared.createToastMessage(err.localizedDescription)
                   
                }
            }
        }
    func wsToVerifyOTP(parms: JSON,completionHandler : @escaping (Result<Bool,Error>) -> Void) {
        self.apiInteractor?
            .getRequest(for: .otpVerification,params: parms)
            .responseJSON({ (json) in
                if json.isSuccess{
                    completionHandler(.success(true))
                }else{
                    completionHandler(.success(false))
                }
            }).responseFailure({ (error) in
                self.showError(error)
                self.removeProgress()
            })
    }
    @IBAction func bottomBtnAction(_ sender : UIButton){
        if self.currentScreenState == .OTP{//Resend OTP
            self.otpView.clear()
            self.view.endEditing(true)
            self.wsToVerifyNumber()
        }else{
            switch self.purpose{//Currenty not using these cases
            case NumberValidationPurpose.register?:
                self.backAction(self.backBtn)
            case NumberValidationPurpose.changeNumber?:
                self.backAction(self.backBtn)
            case NumberValidationPurpose.forgotPassword?:
                break
                
            default:
                break
            }
        }
    }
    @objc func doneAction(){
        self.view.endEditing(true)
        self.checkStatus()
    }
    @objc func clearAction(){
        if self.currentScreenState == .mobileNumber{
            self.mobileNumberView.clear()
         
        }else{
            
            self.otpView.clear()
        }
    }
    //MARK:- Animations
    /**
     Set Data for screen content based on states
     - Author: Abishek Robin
     - Parameters:
        - state: ScreenState(mobile/otp)
     */
    func setContentData(for state : ScreenState){
        self.inputFieldHolderView.subviews.forEach({$0.removeFromSuperview()})
        let titleImage : UIImage?
        if state == .mobileNumber{
            titleImage = UIImage(named: "mobileverify")?.withRenderingMode(.alwaysTemplate)
//            self.titleLbl.text = "Mobile Verification".localize
            self.titleLbl.text = self.language.mobileVerify
//            self.descLbl.text = "Please enter your mobile number".localize
             self.descLbl.text = self.language.enterMobileno
            self.bottomDescLbl.text = ""
//            self.bottomBtn.setTitle("LOGIN".localize, for: .normal)
             self.bottomBtn.setTitle(self.language.login.uppercased(), for: .normal)
            self.inputFieldHolderView.addSubview(self.mobileNumberView)
            self.inputFieldHolderView.bringSubviewToFront(self.mobileNumberView)
            self.mobileNumberView.numberTF.inputAccessoryView = self.toolBar
            self.mobileNumberView.numberTF.delegate = self
            self.mobileNumberView.numberTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        }else{
            titleImage = UIImage(named: "mobileotp")?.withRenderingMode(.alwaysTemplate)
//            self.titleLbl.text = "Enter OTP".localize
             self.titleLbl.text = self.language.enterOtp
//            self.descLbl.text = "We have sent you access code via SMS for mobile number verification".localize
            self.descLbl.text = self.language.sentCodeMob
//            self.bottomDescLbl.text = "Din't Receive the OTP?".localize
            self.bottomDescLbl.text = self.language.didntRecOtp
//            self.bottomBtn.setTitle("Resend OTP".localize, for: .normal)
             self.bottomBtn.setTitle(self.language.resendOtp, for: .normal)
            self.inputFieldHolderView.insertSubview(self.otpView, at: 0)//(self.otpView)
            self.inputFieldHolderView.bringSubviewToFront(self.otpView)
            self.otpView.setToolBar(self.toolBar)
          
        }
       
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.checkStatus()
    }
    
    func aniamateView(for state : ScreenState){
        let transformation : CGAffineTransform
        let change : CGFloat = iApp.instance.isRTL ? -1 : 1
        if state == .OTP  {
            transformation = CGAffineTransform(translationX: -self.view.frame.width * change,
                                               y: 0)
        }else{
            transformation = CGAffineTransform(translationX:    self.view.frame.width * change,
                                               y: 0)
        }
        UIView.animateKeyframes(withDuration: 0.0,
                                delay: 0.0,
                                options: [.calculationModeCubic,.calculationModeCubicPaced],
                                animations: {
                  self.animate(with: transformation)
        }) { (completed) in
            if completed{
                self.setContentData(for: state)
                UIView.animateKeyframes(withDuration: 0.0,
                                        delay: 0.0,
                                        options: [.calculationModeCubic,.calculationModeCubicPaced],
                                        animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0,
                                           relativeDuration: 0,
                                           animations: {
                            self.prepareScreen(forIntermediateAniamtion: state)
                        })
                                            UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                               relativeDuration: 0.0,
                                           animations: {
                                self.bottomBtn.alpha = state == .OTP ? 1 : 0
                                self.bottomDescLbl.alpha = state == .OTP ? 1 : 0
                        })
                        self.animate(with: .identity)
                }) { (completed) in
                }
            }
        }
    }
    
    func prepareScreen(forIntermediateAniamtion state : ScreenState){
        let transformation : CGAffineTransform
        let change : CGFloat = iApp.instance.isRTL ? -1 : 1
        if state == .OTP{
            transformation = CGAffineTransform(translationX: self.view.frame.width * change,
                                               y: 0)
        }else{
            transformation = CGAffineTransform(translationX: -self.view.frame.width * change,
                                               y: 0)
        }
    //    self.titleIV.transform = transformation
        self.titleLbl.transform = transformation
        self.descLbl.transform = transformation
        self.inputFieldHolderView.transform = transformation
        self.checkStatus()
    }
    func animate(with transformation : CGAffineTransform){
        let relativeDuration = 0.0
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 0,
                           relativeDuration: relativeDuration,
                           animations: {
                       //     self.titleIV.transform = transformation
        })
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 1,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.titleLbl.transform = transformation
        })
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 2,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.descLbl.transform = transformation
        })
        
        UIView.addKeyframe(withRelativeStartTime: relativeDuration * 3,
                           relativeDuration: relativeDuration,
                           animations: {
                            self.inputFieldHolderView.transform = transformation
        })
    }
    //MARK:- OTP timers
    /**
     restrict next otp request for 120 seconds
     */
    func startOTPTimer(){
        self.remainingOTPTime = 120
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                if self.currentScreenState != .OTP{
                    timer.invalidate()
                    return
                }
                self.handleRemainingOTPtime()
                self.remainingOTPTime -= 1
                if self.remainingOTPTime <= 0 {
                    timer.invalidate()
                    self.canSendOTP()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    func handleRemainingOTPtime(){
//        self.bottomDescLbl.text = "You can send OTP again in".localize + " \(self.remainingOTPTime)"
         self.bottomDescLbl.text = "\(self.language.otpSendAgain)  \(self.remainingOTPTime)"
        self.bottomBtn.setTitleColor(.gray, for: .normal)
        self.bottomBtn.isUserInteractionEnabled = false
    }
    func canSendOTP(){
//        self.bottomDescLbl.text = "Din't Receive the OTP?".localize
         self.bottomDescLbl.text = self.language.didntRecOtp
        self.bottomBtn.setTitleColor(.ThemeYellow, for: .normal)
        self.bottomBtn.isUserInteractionEnabled = true
    }
    //MARK:- UDF
    func checkStatus(){
        
        let isActive : Bool
        if self.currentScreenState == .mobileNumber{
            isActive = self.mobileNumberView.number?.count ?? 0 > 6 && flag != nil
            self.bottomDescLbl.text = ""
        }else{
            if let _otp = self.otpView.otp{
                isActive = _otp.count == 4//_otp == self.otpView.otp
            }else{
                isActive = false
            }
                
        }
        self.bottomDescLbl.textColor = .black
        self.nextBtn.backgroundColor = isActive ? .ThemeYellow : .Border
        self.nextBtn.isUserInteractionEnabled = isActive
        
    }
    func onSuccess(){
        
        guard let number = self.mobileNumberView.number,
            let flag = self.flag else {return}
        self.validationDelegate?
            .verified(number: MobileNumber(number: number,
                                           flag: flag))
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func pushToCountryVC(){
        
        let propertyView = CountryListVC.initWithStory(selectedFlag: self.flag)
        propertyView.delegate = self
      self.presentInFullScreen(propertyView, animated: true, completion: nil)
    }
    /**
     Show error on bottom desc label with shake animation
     - Author: Abishek Robin
     - Parameters:
        - error: Error message
     - Note: error message will change to default state on interaction
     */
    func showError(_ error : String){
        self.view.endEditing(true)
        self.bottomDescLbl.text = error
        self.bottomDescLbl.alpha = 1
       
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeLinear], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.bottomDescLbl.textColor = .red
                self.bottomDescLbl.transform =  CGAffineTransform(translationX: 0, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: -5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: 5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.8, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: -5, y: 0)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.9, animations: {
                self.bottomDescLbl.transform = CGAffineTransform(translationX: 5, y: 0)
            })
        }) { (_) in
            self.bottomDescLbl.transform =  .identity
        }
      
    }
    //MARK:- Webservice
    func wsToVerifyNumber(){
        guard let number = self.mobileNumberView.number,
            let country = self.flag else{ return }
        var params = Parameters()
        params["mobile_number"] = number
        params["country_code"] = country.country_code
        params["forgotpassword"] = self.purpose == NumberValidationPurpose.forgotPassword ? 1 : 0
        params["language"] = appDelegate.language
//        self.apiInteractor?.getResponse(forAPI: .validateNumber, params: params).shouldLoad(false)
        self.apiInteractor?
            .getRequest(for: .validateNumber,params: params)
            .responseJSON({ (json) in
                if json.isSuccess{
                    self.removeProgress()
                    let isValid = json.isSuccess
                    let otp = json.string("otp")
                    let message = json.status_message
                    if isValid{
                        if Shared.instance.otpEnabled{
                            if self.currentScreenState  != .OTP{//if already not in otp screen
                                self.aniamateView(for: .OTP)
                            }
                            self.otpFromAPI = otp
                            print("otp\(self.otpFromAPI)")
                            
                           // appDelegate.createToastMessage("OTP \(otp)")
                        }
                        else{
                            self.onSuccess()
                        }
                        
                    }else{
                        self.otpFromAPI = nil
                        self.showError(message)
                    }
                }else{
                    self.showError(json.status_message)
                    self.removeProgress()

                }
            }).responseFailure({ (error) in
                self.showError(error)
                self.removeProgress()
            })
        self.addProgress()
    }
    // Add progress when api call done
    func addProgress()
    {
        nextBtn.titleLabel?.text = ""
        nextBtn.setTitle("", for: .normal)
        spinnerView.frame = CGRect(x: 5, y: 5, width: 45, height: 45)
        nextBtn.addSubview(spinnerView)
        nextBtn.bringSubviewToFront(spinnerView)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
        spinnerView.beginRefreshing()
    }
    // Remove progress when api call done
    func removeProgress()
    {
        if iApp.instance.isRTL{
            self.nextBtn.setTitle("e", for: .normal)
        }else{
            self.nextBtn.setTitle("I", for: .normal)
        }
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
}
extension MobileValidationVC : CountryListDelegate{
    func countryCodeChanged(countryCode: String, dialCode: String, flagImg: UIImage) {
        let flag = CountryModel(forDialCode: dialCode, withCountry: countryCode)
        if !flag.isAccurate{
            flag.country_code = countryCode
            flag.dial_code = dialCode
            flag.flag = flagImg
        }
        self.flag = flag
        self.checkStatus()
    }
    
    
}



