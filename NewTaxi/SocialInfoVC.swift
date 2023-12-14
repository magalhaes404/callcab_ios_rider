/**
 * SocialInfoVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */



import UIKit
import Foundation
import TTTAttributedLabel
import IQKeyboardManagerSwift

class SocialInfoVC: UIViewController,UITextFieldDelegate,CountryListDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
var iconClick = true
    @IBOutlet weak var eyepassword: UIButton!
    @IBOutlet weak var txtFldFirstName: PaddingTextField!
    @IBOutlet weak var txtFldLastName: PaddingTextField!
    @IBOutlet weak var txtFldEmail: PaddingTextField!
    @IBOutlet weak var txtFldPhoneNo: UITextField!
    @IBOutlet weak var txtFldPassword: PaddingTextField!
    @IBOutlet weak var lblDialCode: UILabel!
    @IBOutlet weak var imgCountryFlag: UIImageView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewLoginHolder: UIView!
    @IBOutlet weak var lblLoginError: UILabel!
    @IBOutlet weak var viewNextHolder: UIView!
    @IBOutlet weak var viewCancelHolder: UIView!
    @IBOutlet weak var separatecancelview: UIView!
    

    @IBOutlet weak var txtFieldReferal : UITextField!
   
 //   @IBOutlet var terms_and_condition: TTTAttributedLabel!
    @IBOutlet weak var scrollObjHolder: UIScrollView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var cancelAcclbl: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var infoNotSaved: UILabel!
    @IBOutlet weak var registerUrInfo : UILabel!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var haveAnAccount: UILabel!
    
    
    // Holder Views
    @IBOutlet weak var firstNameStack: UIStackView!
    @IBOutlet weak var lastNameStack: UIStackView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var mobileStack: UIStackView!
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var referralStack: UIStackView!
    
    
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
//    var dictParms = [AnyHashable: Any]()
    lazy var dictParms = JSON()

    var strPhoneNo = ""
    var signUpType : SignUpType = .notDetermined
    lazy var spinnerView = JTMaterialSpinner()
    var genderType: Gender = .none
    //Gender update
    
  
    @IBOutlet weak var separateview: UIView!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleRadio: UIImageView!
    @IBOutlet weak var femaleLbl: UILabel!
    @IBOutlet weak var maleRadio: UIImageView!
    @IBOutlet weak var maleLbl: UILabel!
    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var genderStack: UIStackView!
    // MARK: - ViewController Methods
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
      //  self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.elevate(10)
        self.separatecancelview.setSpecificCornersForTop(cornerRadius: 38)

        self.setfonts()
        self.setcolor()
        self.setDesign()
        self.btnCancel.cornerRadius = 8
        self.btnCancel.elevate(2)
        self.btnConfirm.cornerRadius = 8
        self.apiInteractor = APIInteractor(self)
        self.eyepassword.setImage( UIImage.init(named: "Visible"), for: .normal)
//        self.registerUrInfo.text = "Register your information".localize
        if language.isRTLLanguage(){
            self.txtFldFirstName.textAlignment = .right
            self.txtFldLastName.textAlignment = .right
            self.txtFldPassword.textAlignment = .right
            self.txtFieldReferal.textAlignment = .right
            self.txtFldEmail.textAlignment = .right
            self.txtFldPhoneNo.textAlignment = .right
//            self.btnNext.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        self.genderLbl.text = self.language.gender
        self.maleLbl.text = self.language.male
        self.femaleLbl.text = self.language.female
        self.haveAnAccount.text = language.haveAnAccount
        login.setTitle(language.login.capitalized, for: .normal)
      //  self.listen2Keyboard(withView: self.viewNextHolder)
        self.registerUrInfo.text = self.language.register.capitalized
        self.txtFldFirstName.placeholder = self.language.firstName
        self.txtFldLastName.placeholder = self.language.lastName
        self.txtFldPassword.placeholder = self.language.password
        self.txtFieldReferal.placeholder = self.language.referral
        self.txtFldEmail.placeholder = self.language.email.capitalized
        self.cancelAcclbl.text = self.language.cancelAccCreation
        self.infoNotSaved.text = self.language.infoNotSaved
        self.btnCancel.setTitle(self.language.cancel, for: .normal)
        self.btnConfirm.setTitle(self.language.confirm, for: .normal)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        self.btnNext.setTitle(self.language.continue_, for: .normal)
        
        if #available(iOS 10.0, *) {
            txtFldFirstName.keyboardType = .asciiCapable
            txtFldLastName.keyboardType = .asciiCapable
            txtFldPassword.keyboardType = .asciiCapable
            txtFldEmail.keyboardType = .asciiCapable
            txtFldPhoneNo.keyboardType = .asciiCapableNumberPad
            txtFieldReferal.keyboardType = .asciiCapable
            
        } else {
            // Fallback on earlier versions
            txtFldFirstName.keyboardType = .default
            txtFldLastName.keyboardType = .default
            txtFldPassword.keyboardType = .default
            txtFldEmail.keyboardType = .default
            txtFldPhoneNo.keyboardType = .numberPad
            txtFieldReferal.keyboardType = .default
            
        }
        self.txtFieldReferal.isSecureTextEntry = false
        btnNext.backgroundColor = UIColor.ThemeInactive
  //      btnNext.layer.cornerRadius = btnNext.frame.size.height/2
        //btnCancel.layer.borderColor = UIColor.ThemeMain.cgColor
      //  btnCancel.layer.borderWidth = 1.0
        viewCancelHolder.isHidden = true
        viewLoginHolder.isHidden = true
        
        if self.signUpType == .email {
            self.passwordStackView.isHidden = false
        }else {
            self.passwordStackView.isHidden = true
        }
        //scrollObjHolder.contentSize = CGSize(width: scrollObjHolder.frame.size.width, height:  viewReferalSeperator.frame.origin.y + 100)
        
        self.setCountryFlatAndDialCode()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        if dictParms.count > 0
        {
            self.setUserInfo()
        }
        self.setHyperLink()
        if !Shared.instance.isReferralEnabled(){
          
            self.txtFieldReferal.isHidden = true
        }
        
    }
    func setDesign() {
        self.firstNameStack.cornerRadius = 10
        self.firstNameStack.border(1, .Border)
        
        self.lastNameStack.cornerRadius = 10
        self.lastNameStack.border(1, .Border)
        
        self.txtFldEmail.cornerRadius = 10
        self.txtFldEmail.border(1, .Border)
        
        self.mobileStack.cornerRadius = 10
        self.mobileStack.border(1, .Border)
        
        self.passwordStackView.cornerRadius = 10
        self.passwordStackView.border(1, .Border)
        
        self.txtFieldReferal.cornerRadius = 10
        self.txtFieldReferal.border(1, .Border)
    }
    //MARK:- initwithStory
    class func initWithStory(using method : SignUpType,params : [String:Any]) -> SocialInfoVC{
        let vc : SocialInfoVC =  UIStoryboard.jeba.instantiateViewController()
        vc.signUpType = method
        vc.dictParms = params
        return vc
    }
    @IBAction func genderButtonFunctionality(_ sender: UIButton) {
        genderType = sender.tag == 1 ? .male : .female
        setGender()
    }
    
    @IBAction func eyepasswordaction(_ sender: Any) {
        if(iconClick == true) {
            self.passwordStackView.isHidden = false
            eyepassword.setImage( UIImage.init(named: "Invisible"), for: .normal)
            self.eyepassword.tintColor = .Title
            txtFldPassword.isSecureTextEntry = false
              } else {
                self.passwordStackView.isHidden = false
                eyepassword.setImage( UIImage.init(named: "Visible"), for: .normal)
                self.eyepassword.tintColor = .Title
                txtFldPassword.isSecureTextEntry = true
              }

              iconClick = !iconClick
        
    }
    @IBAction func LoginAction(_ sender: Any) {
        let vc = NewSignInVC.initWithStory()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getNextBtnText() -> String{
        return self.language.isRTLLanguage() ? "e" : "I"
    }
    func setGender()
    {
        self.maleRadio.image = genderType == .male ? #imageLiteral(resourceName: "radio_on") : #imageLiteral(resourceName: "radio_off")
        self.femaleRadio.image = genderType == .female ? #imageLiteral(resourceName: "radio_on") : #imageLiteral(resourceName: "radio_off")
    }
    func setfonts(){
        self.txtFldFirstName?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtFldLastName?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtFldEmail?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtFldPhoneNo?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtFldPassword?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtFieldReferal?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.genderLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.btnNext?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
        self.haveAnAccount.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 16)
        self.login?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.registerUrInfo?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.cancelAcclbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
        self.infoNotSaved?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 14)
        self.btnConfirm?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.btnCancel?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
    }
    func setcolor(){
        self.txtFldFirstName.textColor = .Title
        self.txtFldLastName.textColor = .Title
        self.txtFldEmail.textColor = .Title
        self.txtFldPhoneNo.textColor = .Title
        self.txtFldPassword.textColor = .Title
        self.txtFieldReferal.textColor = .Title
        self.haveAnAccount.textColor = .Title
        self.cancelAcclbl.textColor = .Title
        self.infoNotSaved.textColor = .Title
        self.genderLbl.textColor = .Title
     
    }
    // setting social loggedin user infomation
    func setUserInfo()
    {
        setGender()
        txtFldFirstName.text = dictParms["first_name"] as? String
        txtFldLastName.text = dictParms["last_name"] as? String
        txtFldEmail.text = dictParms["email"] as? String
        txtFldPhoneNo.text = dictParms["mobile_number"] as? String
        txtFieldReferal.text = dictParms["referral_code"] as? String
        // txtFldPhoneNo.textColor = .gray
        txtFldPhoneNo.isUserInteractionEnabled = false
        // lblDialCode.textColor = .gray
        let code = dictParms["country_code"] as? String ?? String()
        let flag = CountryModel(withCountry: code)
        self.imgCountryFlag.image = flag.flag
        self.selectedFlag = flag
        self.lblDialCode.text = flag.dial_code
        if case SignUpType.apple(id: _, email: let email) = self.signUpType,
            let _email = email,
            !_email.isEmpty{
                txtFldEmail.text = _email
            self.txtFldEmail.isUserInteractionEnabled = false
        }else{
            self.txtFldEmail.isUserInteractionEnabled = true
        }
    }
    var selectedFlag : CountryModel?
    // GETTING USER CURRENT COUNTRY CODE AND FLAG IMAGE
    func setCountryFlatAndDialCode()
    {
        return
        if appDelegate.language == "en" || appDelegate.language == "es" {
            var rectTxtFld = txtFldPhoneNo.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
            txtFldPhoneNo.frame = rectTxtFld
        }
        
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let flag = CountryModel(withCountry: countryCode)
            imgCountryFlag.image = flag.flag
            lblDialCode.text = flag.dial_code
        }
        
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: lblDialCode.text! as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
    }
    //Show the keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
//        let info = notification.userInfo!
//        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
       // UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: viewNextHolder)
//        scrollObjHolder.contentSize = CGSize(width: scrollObjHolder.frame.size.width, height:  scrollObjHolder.frame.size.height+keyboardFrame.size.height + 50)
    }
    //Hide the keyboard
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
       
       // UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: viewNextHolder)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        self.checkNextButtonStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    // MAKING ALL SEPARATOR COLOR AS LIGHT GRAY
    func changeSeparatorNormalColor()
    {
//        viewEmailSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        viewFirstNameSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        viewLastNameSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        viewPhoneSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        viewPasswordSepartor.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        viewReferalSeperator.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    // MARK: - TextField Delegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
//        changeSeparatorNormalColor()
//        if !viewLoginHolder.isHidden
//        {
//            self.viewLoginHolder.isHidden = true
//        }
//
//        if textField.tag == 1   // FIRST NAME
//        {
//            scrollObjHolder.setContentOffset(CGPoint(x: 0,y :10), animated: true)
//        //    viewFirstNameSepartor.backgroundColor = UIColor.black
//        }
//        else if textField.tag == 2   // LAST NAME
//        {
//            scrollObjHolder.setContentOffset(CGPoint(x: 0,y :10), animated: true)
//          //  viewLastNameSepartor.backgroundColor = UIColor.black
//        }
//        else if textField.tag == 3   // EMAIL ID
//        {
//            scrollObjHolder.setContentOffset(CGPoint(x: 0,y :50), animated: true)
//         //   viewEmailSepartor.backgroundColor = UIColor.black
//        }
//        else if textField.tag == 4   // PHONE NO
//        {
//            scrollObjHolder.setContentOffset(CGPoint(x: 0,y :200), animated: true)
//          //  viewPhoneSepartor.backgroundColor = UIColor.black
//
//        }
//        else if textField.tag == 5   // PASSWORD
//        {
//            scrollObjHolder.setContentOffset(CGPoint(x: 0,y :230), animated: true)
//          //  viewPasswordSepartor.backgroundColor = UIColor.black
//        }
//        else if textField.tag == 6 //Referral
//        {
//            scrollObjHolder.setContentOffset(CGPoint(x: 0, y: 260), animated: true)
//         //   viewReferalSeperator.backgroundColor = UIColor.black
//        }
        return true
    }
    
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtFieldReferal{
            let ACCEPTABLE_CHARACTERS = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered: String = string.components(separatedBy: cs).joined(separator: "")
            return string == filtered
        }
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == " ") {
            return false
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        return true
    }
    
    // MARK: - Checking Next Button status
    /*
     Checking all textfield values exist
     and making next button interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        if ((txtFldFirstName.text?.count)!>0 && (txtFldLastName.text?.count)!>0 && ((txtFldEmail.text?.count)!>0 && UberSupport().isValidEmail(testStr: txtFldEmail.text!)) && (txtFldPhoneNo.text?.count)!>5 && ((txtFldPassword.text?.count)!>5 || self.signUpType != .email))
        {
            btnNext.isUserInteractionEnabled = true
            btnNext.backgroundColor = UIColor.ThemeYellow
        }
        else
        {
            btnNext.isUserInteractionEnabled = false
            btnNext.backgroundColor = UIColor.ThemeInactive
        }
    }
    
    // MARK: API CALLING - CHANGE DIAL CODE
    /*
     */
    @IBAction func onChangeDialCodeTapped(_ sender:UIButton!)
    {
        return
        let propertyView = CountryListVC.initWithStory(selectedFlag: self.selectedFlag!)
        propertyView.delegate = self
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // CountryListVC Delegate Method
    internal func countryCodeChanged(countryCode:String, dialCode:String, flagImg:UIImage)
    {
        lblDialCode.text = "\(dialCode)"
        imgCountryFlag.image = flagImg
        
        Constants().STOREVALUE(value: dialCode, keyname: USER_DIAL_CODE)
        Constants().STOREVALUE(value: countryCode, keyname: USER_COUNTRY_CODE)
        
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: dialCode as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        if appDelegate.language == "en" || appDelegate.language == "es" {
            var rectTxtFld = txtFldPhoneNo.frame
            rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
            rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
            txtFldPhoneNo.frame = rectTxtFld
        }
        
        
        
    }
    
    // MARK: Navigating to Main Map Page
    /*
     After filled all user details validating api will call
     */
    var isNoVerified = false
    @IBAction func onNextTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if isNoVerified{
            var dictTotalParams : JSON = dictParms

//            let dictTotalParams : NSMutableDictionary = NSMutableDictionary(dictionary:dictParms)
//            if dictParms.count > 0
//            {
//                dictTotalParams.addEntries(from: dictParms)
//            }
            dictTotalParams["first_name"]    = txtFldFirstName.text!
            dictTotalParams["last_name"]    = txtFldLastName.text!
            if self.signUpType == .email {
                dictTotalParams["password"]    = txtFldPassword.text!
            }
            else {
                dictTotalParams.removeValue(forKey: "password")
            }
           
            dictTotalParams["mobile_number"]    = txtFldPhoneNo.text!
            dictTotalParams["email_id"]    = txtFldEmail.text!
            dictTotalParams["referral_code"] = txtFieldReferal.text
            dictTotalParams["country_code"] = (self.selectedFlag ?? .default).country_code
            dictTotalParams["gender"] = genderType.rawValue
            for json in self.signUpType.getParamValueForType{
                dictTotalParams[json.key] = json.value
            }
//            self.callSocialSignUpAPI(parms: dictTotalParams as NSDictionary? as? [AnyHashable: Any] ?? [AnyHashable: Any]())
            self.callSocialSignUpAPI(parms: dictTotalParams)

        }else{
            self.validateMobileNumber()
        }
    }
    
    // MARK: CALLING API FOR SOCIAL SIGNUP
    var isNormalRegistration = false
    
    func callSocialSignUpAPI(parms: JSON)
    {
//        guard var parameters = parms as? JSON else{
//            AppDelegate.shared.createToastMessage(self.language.internalServerError)
//            return
//
//        }
        var parameters = parms
       
        
        addProgress()
        spinnerView.beginRefreshing()
        
        btnNext.isUserInteractionEnabled = false
        
        
        if !isNormalRegistration{
            parameters["new_user"] = 1
        }else{
            parameters["new_user"] = 0
        }
    
        self.apiInteractor?
            .getRequest(
                for: APIEnums.signUp ,//isNormalRegistration ? APIEnums.signUp : APIEnums.socialSignup,
                params: parameters
        ).responseJSON({ (json) in
            let loginData = RiderDataModel(json)
            if json.isSuccess{
                loginData.storeRiderBasicDetail()
                loginData.storeRiderImprotantData()
                self.appDelegate.createToastMessage(loginData.status_message)
                self.selectedFlag?.store()
                let userDefaults = UserDefaults.standard
                userDefaults.set("rider", forKey:"getmainpage")
                userDefaults.synchronize()
                
                self.appDelegate.onSetRootViewController(viewCtrl: self)
            }else{
                AppDelegate.shared.createToastMessage(json.status_message)
                
            }
            self.removeProgress()
            self.btnNext.isUserInteractionEnabled = true
            
        }).responseFailure({ (error) in
            self.removeProgress()
            self.btnNext.isUserInteractionEnabled = true
            AppDelegate.shared.createToastMessage(error)
            
        })
            
       
    }
    // Add progress View
    func addProgress()
    {
        btnNext.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 5, y: 5, width: 45, height: 45)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
    }
    //Remove Progress View
    func removeProgress()
    {
      
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
    
    // MARK: API CALLING - VALIDATE MOBILE NO
    /*
     statuscode = 1 => Number Not exist - goto OTP Page
     statuscode = 2 => Number exist - Display error message
     */
    func validateMobileNumber(){
        self.view.endEditing(true)
        
        addProgress()
        spinnerView.beginRefreshing()
        
        btnNext.isUserInteractionEnabled = false
        
        
        var dicts = [AnyHashable: Any]()
        dicts["mobile_number"] = String(format:"%@",txtFldPhoneNo.text!)
        
        self.apiInteractor?
            .getRequest(
                for: APIEnums.validateNumber,
                params: [
                    "mobile_number" : txtFldPhoneNo.text!
            ]).responseJSON({ (json) in
                if json.status_code == 1{  // Number not registered in Server
                    
                    self.initializeAccountKitVerification()
                }else if json.status_code == 2 {// Number registered in Server
                    
                    self.isNoVerified = false
                    self.lblLoginError.text = json.status_message
                    self.viewLoginHolder.isHidden = false
                }else if json.string("otp").count > 0{
                    self.initializeAccountKitVerification()
                }else{
                    self.isNoVerified = false
                    self.lblLoginError.text = json.status_message
                    self.viewLoginHolder.isHidden = false
                }
                
                self.removeProgress()
                self.btnNext.isUserInteractionEnabled = true
            }).responseFailure({ (error) in
                
                self.removeProgress()
                self.btnNext.isUserInteractionEnabled = true
                AppDelegate.shared.createToastMessage(error)
            })
        
        
    }
    var verifyingNumber : MobileNumber?
    func initializeAccountKitVerification(){
        
        
        guard let _number = self.txtFldPhoneNo.text,
        let _dial = self.lblDialCode.text else{return}
        self.verifyingNumber = MobileNumber(number: _number,
                                            flag: CountryModel(forDialCode: _dial))
//        let given_no = PhoneNumber(countryCode: _dial, phoneNumber: _number)
           
            let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                      for: .register)
            
            self.presentInFullScreen(mobileValidationVC, animated: true, completion: nil)
        
        //        /AccountKitHelper.instance.verifyWithView(self, number: given_no, success: { (account) in
        //            if let k_number = account?.phoneNumber?.phoneNumber,
        //                let dial_code = account?.phoneNumber?.countryCode,
        //                k_number == _number{
        //                UserDefaults.standard.set(dial_code, forKey: USER_DIAL_CODE)
        //                self.isNoVerified = true
        //                self.onNextTapped(nil)
        //            }else{
        //                self.isNoVerified = false
        //                self.appDelegate.createToastMessage("Invalid data".localize, bgColor: .black, textColor: .white)
        //            }
        //        }, failure: {
        //            self.isNoVerified = false
        //        })
    }
    // MARK: Goto OTP Page
//    func gotoOTPPage(otpCode: String)
//    {
//        let dictTotalParams : NSMutableDictionary = NSMutableDictionary(dictionary:dictParms)
//        if dictParms.count > 0
//        {
//            dictTotalParams.addEntries(from: dictParms)
//        }
//        dictTotalParams["first_name"]    = txtFldFirstName.text!
//        dictTotalParams["last_name"]    = txtFldLastName.text!
//        dictTotalParams["password"]    = txtFldPassword.text!
//        dictTotalParams["mobile_number"]    = txtFldPhoneNo.text!
//        dictTotalParams["email_id"]    = txtFldEmail.text!
//
//        let propertyView = UIStoryboard.main.instantiateViewController(withIdentifier: "OTPVerifyVC") as! OTPVerifyVC
//        propertyView.strPhoneNo = String(format:"%@%@",lblDialCode.text!,txtFldPhoneNo.text!)
//        propertyView.strOTPCode = otpCode
//        propertyView.dictParms = (dictTotalParams as NSDictionary? as? [AnyHashable: Any])!
//        propertyView.isFromSocialLogin = true
//        self.navigationController?.pushViewController(propertyView, animated: false)
//    }
    
    // If user already exist - display login popup
    @IBAction func gotoLoginPage(_ sender: UIButton!)
    {
//        let propertyView = UIStoryboard.main.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
//        propertyView.strPhoneNo = String(format:"%@",txtFldPhoneNo.text!)
//        propertyView.isNumberExist = true
//        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    /*
     If we click confirm button the social logged user information will destroy
     */
    @IBAction func onConfirmTapped(_ sender:UIButton!)
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        self.viewCancelHolder.backgroundColor = UIColor.clear
        viewCancelHolder.isHidden = false
        view.transform = CGAffineTransform(translationX: 0, y: self.viewCancelHolder.frame.size.height)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        },  completion: { (finished: Bool) -> Void in
            self.viewCancelHolder.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        })
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if sender.tag == 11
        {
            self.view.bringSubviewToFront(self.viewCancelHolder)
            viewCancelHolder.isHidden = true
        }
        else
        {
            setupShareAppViewAnimationWithView(viewCancelHolder)
        }
    }
    
}

//MARK:  Hyper link Attribute text
extension SocialInfoVC : TTTAttributedLabelDelegate{
    func setHyperLink(){
//        let full_text = NSLocalizedString("By continuing, I confirm that i have read and agree to the Terms & Conditions and Privacy Policy.", comment: "")
//        let terms_text = NSLocalizedString("Terms & Conditions", comment: "")
//        let privacy_text = NSLocalizedString("Privacy Policy", comment: "")
        let full_text = self.language.agreeTcPolicy
        let terms_text = self.language.termsCondition
        let privacy_text = self.language.privacyPolicy
        
//        self.terms_and_condition.setText(full_text, withLinks: [
//            HyperLinkModel(url: URL(string: "\(iApp.baseURL.rawValue)terms_of_service")!, string: terms_text),
//            HyperLinkModel(url: URL(string: "\(iApp.baseURL.rawValue)privacy_policy")!, string: privacy_text)
//            ])
        
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
    
}
extension SocialInfoVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        if let _verifyingNumber = self.verifyingNumber,
            number.number == _verifyingNumber.number{
            UserDefaults.standard.set(number.flag.dial_code, forKey: USER_DIAL_CODE)
            self.isNoVerified = true
            self.onNextTapped(nil)
        }
    }
    
    
}


class PaddingTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25);
    var isStopCopyPaste: Bool = false
    
    override func awakeFromNib() {
        self.textColor = .Title
//        self.tintColor = .alphaThemeColor
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)//UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)//UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)//UIEdgeInsetsInsetRect(bounds, padding)
    }
    

    
}
