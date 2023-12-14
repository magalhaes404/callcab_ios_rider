//
//  NewSignInVC.swift
// NewTaxi
//
//  Created by Seentechs on 06/02/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class NewSignInVC: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    

    
    @IBOutlet weak var separateview: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var Visible: UIButton!
    
    @IBOutlet weak var phnNoTextField: UITextField!
    @IBOutlet weak var dialCodelbl: UILabel!
    @IBOutlet weak var flagIV: UIImageView!
    @IBOutlet weak var phnNoBar: UILabel!
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordBar: UILabel!
    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBOutlet weak var signInBtn : UIButton!
    @IBOutlet weak var forgotPasswordBtn : UIButton!
    var iconClick = true
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    var selectedCountry : CountryModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.elevate(8)
        
       _ = self.checkBtnStatus()
        self.apiInteractor = APIInteractor(self)
//        self.setStatusBarStyle(.lightContent)
        Visible.setImage( UIImage.init(named: "Visible"), for: .normal)
        self.Visible.tintColor = .ThemeMain
       
       
        DispatchQueue.main.async {
            self.signInBtn.cornerRadius = 10
           
        }
        
        self.passwordTF.textColor = .Title
        self.setfonts()

        self.listen2Keyboard(withView: self.bottomContainerView)
        self.initView()
        self.initLanguage()
        // Do any additional setup after loading the view.
    }
    func setfonts(){
        self.signInBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.dialCodelbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        self.phnNoTextField?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        self.passwordTF?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        self.pageTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
    }
    func initLanguage(){
        
        self.backButton.setTitle(self.language.getBackBtnText(), for: .normal)
        self.phnNoTextField.textAlignment = self.language.getTextAlignment(align: .left)
        self.passwordTF.textAlignment = self.language.getTextAlignment(align: .left)
    }
    func initView(){
        self.phnNoTextField.delegate = self
        self.passwordTF.delegate = self
        
//        self.passwordTF.placeholder = "PASSWORD".localize
//        self.pageTitle.text = "SIGN IN".localize
//        self.forgotPasswordBtn.setTitle("Forgot Password?".localize, for: .normal)
//        self.signInBtn.setTitle("SIGN IN".localize, for: .normal)
       
        self.passwordTF.placeholder = self.language.password.capitalized
        self.pageTitle.text = self.language.signIn.capitalized
        self.forgotPasswordBtn.setTitle(self.language.forgotPassword, for: .normal)
        self.signInBtn.setTitle(language.signIn.capitalized, for: .normal)

        
        if let code = UserDefaults.standard.string(forKey: USER_DIAL_CODE){
            let flag = CountryModel(forDialCode: code)
            self.flagIV.image = flag.flag
            self.dialCodelbl.text = flag.dial_code
            self.dialCodelbl.textColor = .Title
            self.dialCodelbl.alpha = 0.5
            self.selectedCountry = flag
        }else{
            let flag = CountryModel()
            self.flagIV.image = flag.flag
            self.dialCodelbl.text = flag.dial_code
            self.dialCodelbl.textColor = .Title
            self.dialCodelbl.alpha = 0.5
            self.selectedCountry = flag
        }
        
        self.view.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        
        self.signInBtn.isClippedCorner = true
    }

    class func initWithStory() -> NewSignInVC{
        let vc : NewSignInVC = UIStoryboard.jeba.instantiateViewController()
        return vc
    }

    //MARK:Actions
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func changeFlagAction(_ sender: Any) {
//        let mainStory = Stories.Main.instance
        let propertyView = CountryListVC.initWithStory(selectedFlag: self.selectedCountry!)
        propertyView.delegate = self
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    @IBAction func textFieldAltering(_ sender: Any) {
        _ = self.checkBtnStatus()
    }
    @IBAction func textFieldEditing(_ sender: Any) {
        _ = self.checkBtnStatus()
    }
    @IBAction func signInAction(_ sender: Any) {
       
        self.view.endEditing(true)
        guard let phoneNo = self.phnNoTextField.text,!phoneNo.isEmpty,
            let code = dialCodelbl.text,!code.isEmpty else{
            appDelegate.createToastMessage("Error")
                return
        }
        guard let password = self.passwordTF.text,!password.isEmpty else{
//            appDelegate.createToastMessage("Please enter your password".localize)
            appDelegate.createToastMessage(self.language.enterPassword)
            return
        }
        let country = self.selectedCountry ?? .default

        var dicts = [AnyHashable:Any]()
        
        dicts["country_code"] = country.country_code
        dicts["mobile_number"] = String(format:"%@",phoneNo)
        dicts["password"] = String(format:"%@",password)
        
//        AccountInteractor.instance.checkRegistrationStatus(forNumber: phoneNo, countryCode: code) { (isRegistered, message) in
//            if isRegistered{
                self.callLoginAPI(parms: dicts)
//            }else{
//                self.appDelegate.createToastMessage(message)
//            }
//        }
    }
    
    @IBAction func VisibleAction(_ sender: Any) {
        if(iconClick == true) {

            Visible.setImage( UIImage.init(named: "Invisible"), for: .normal)
            self.Visible.tintColor = .ThemeMain
            passwordTF.isSecureTextEntry = false
              } else {
                Visible.setImage( UIImage.init(named: "Visible"), for: .normal)
                self.Visible.tintColor = .ThemeMain
                  passwordTF.isSecureTextEntry = true
              }

              iconClick = !iconClick
    }
    @IBAction func forgotPasswordAction(_ sender: Any) {
            let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                      for: .forgotPassword)
            self.presentInFullScreen(mobileValidationVC, animated: true, completion: nil)
      
      
//        AccountKitHelper.instance.verifyWithView(self, number: nil, success: { (account) in
//            let number = account?.phoneNumber
//            AccountInteractor.instance.checkRegistrationStatus(forNumber: number!.phoneNumber, countryCode: number!.countryCode, { (isRegistered, message) in
//                if isRegistered{
//                    self.gotoResetPasswordPage(withPhoneNo: number!.phoneNumber)
//                }else{
//                    self.appDelegate.createToastMessage(message)
//                }
//            })
//        }, failure: {
//
//        })
        

    }
    func gotoResetPasswordPage(withPhoneNo no : String,country : CountryModel)
    {
        
        
        let otpView : ResetPasswordVC = .initWithStory(for: no, of: country)
        self.navigationController?.pushViewController(otpView, animated: true)
    }
    // MARK: CALLING API FOR CREATE FB OR GOOGLE ACC
    var arrPromoData : NSMutableArray = NSMutableArray()

    func callLoginAPI(parms: [AnyHashable: Any])
    {
        guard var params = parms as? JSON else{
            AppDelegate.shared.createToastMessage(self.language.internalServerError)
            return
        }
//        if let countryCode = params["country_code"] as? String{
//            params["country_code"] = countryCode.replacingOccurrences(of: "+", with: "")
//        }else{
//            params["country_code"] = (self.dialCodelbl.text ?? CountryModel.default.dial_code).replacingOccurrences(of: "+", with: "")
//        }
        
        self.signInBtn.isUserInteractionEnabled = false
        
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(
                for: APIEnums.login,
                params: params
        ).responseJSON({ (json) in
            UberSupport.shared.removeProgressInWindow()
            let loginData = RiderDataModel(json)
            if json.isSuccess{
                loginData.storeRiderBasicDetail()
                loginData.storeRiderImprotantData()
                self.signInBtn.isUserInteractionEnabled = true
                let userDefaults = UserDefaults.standard
                userDefaults.set("rider", forKey:"getmainpage")
                userDefaults.synchronize()
                self.appDelegate.isFirstTime = true
                self.arrPromoData.addObjects(from: (loginData.arrTemp1 as NSArray) as! [Any])
                self.gotoHomePage(loginData.promo_details)
                let flag = CountryModel(forDialCode: self.dialCodelbl.text ?? "+01")
                flag.store()
                
            }else if loginData.status_message == "Those credentials don't look right. Please try again"{
                
                self.signInBtn.isUserInteractionEnabled = true
                
                let msgTxt = self.language.credentialdon_tRight
                self.appDelegate.createToastMessage(msgTxt)
            }else{
                self.signInBtn.isUserInteractionEnabled = true
                AppDelegate.shared.createToastMessage(json.status_message)
            }
        }).responseFailure({ (error) in
            UberSupport.shared.removeProgressInWindow()
            self.signInBtn.isUserInteractionEnabled = true
            AppDelegate.shared.createToastMessage(error)
        })
       
    }
    //gotoHomePage
    func gotoHomePage(_ modelData: PromoCodeModel){
        print("go home")
        
        self.appDelegate.onSetRootViewController(viewCtrl: self)
//        let modelData = UserDefaults.standard.array(forKey: "items")
        
        //propertyView.PromoModel = modelData
//        self.navigationController?.pushViewController(propertyView, animated: true)
        
    }
    func checkBtnStatus()->Bool{
        if self.phnNoTextField.text?.count ?? 0 < 6 || self.passwordTF.text?.count ?? 0 < 6{
            
            self.signInBtn.backgroundColor = .ThemeInactive
            self.signInBtn.isUserInteractionEnabled = false
            return false
        }else{
            self.signInBtn.backgroundColor = .ThemeYellow
            self.signInBtn.isUserInteractionEnabled = true
            return true
        }
    }
}
extension NewSignInVC : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty ?? true{
            self.view.endEditing(true)
            return true
        }
        switch textField {
        case self.phnNoTextField:
            self.passwordTF.becomeFirstResponder()
            
        case self.passwordTF:
            textField.endEditing(true)
            if self.checkBtnStatus(){
                self.signInAction(self.signInBtn)
            }
        default:
            self.view.endEditing(true)
        }
        return true
    }
    
}
extension NewSignInVC : CountryListDelegate{
    func countryCodeChanged(countryCode: String, dialCode: String, flagImg: UIImage) {
        self.flagIV.image = flagImg
        self.dialCodelbl.text = dialCode
        self.dialCodelbl.textColor = .Title
        self.dialCodelbl.alpha = 0.5
        self.selectedCountry = CountryModel(withCountry: countryCode)
    }
    
    
}
extension NewSignInVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        self.gotoResetPasswordPage(withPhoneNo: number.number,country: number.flag)
    }

    
}
