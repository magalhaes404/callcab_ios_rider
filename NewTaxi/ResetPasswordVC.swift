/**
* ResetPasswordVC.swift
*
* @package UberDriver
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import MessageUI

class ResetPasswordVC : UIViewController,UITextFieldDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var txtFldConfirmPassword: UITextField!
    @IBOutlet weak var viewObjHolder: UIView!
    @IBOutlet weak var visible1: UIView!
    @IBOutlet weak var lblErrorMsg: UILabel!
    @IBOutlet weak var eyebtn: UIButton!
  
    
    @IBOutlet weak var eyebtn1: UIButton!
    
    
    @IBOutlet weak var cnfrmpasswordview: UIView!
    @IBOutlet weak var passwordview: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblResetPassword: UILabel!
    let userDefaults = UserDefaults.standard
    var iconClick = true
    var confirmpassswordclick = true
    var strMobileNo = ""
    var isFromProfile:Bool = false
    var isFromForgotPage:Bool = false
    var country : CountryModel!
    var spinnerView = JTMaterialSpinner()
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    
    
    var pushManager: PushNotificationManager!
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        self.apiInteractor = APIInteractor(self)
        super.viewDidLoad()
        eyebtn.setImage( UIImage.init(named: "Visible"), for: .normal)
        self.eyebtn.tintColor = .ThemeMain
        eyebtn1.setImage( UIImage.init(named: "Visible"), for: .normal)
        self.eyebtn1.tintColor = .ThemeMain
        

        self.setfonts()
        self.setcolor()
        self.viewObjHolder.setSpecificCornersForTop(cornerRadius: 35)
        self.viewObjHolder.elevate(10)
       if iApp.instance.isRTL{
         self.btnSignIn.setTitle("e", for: .normal)
        }else{
            self.btnSignIn.setTitle("I", for: .normal)
        }
        self.lblResetPassword.text = self.language.resetPassword.capitalized
       // self.lblResetPassword.text = self.language.resetPassword
      //  self.btnClose.setTitle(self.language.close, for: .normal)
        self.passwordview.border(1, .Border)
        self.passwordview.cornerRadius = 8
        self.cnfrmpasswordview.border(1, .Border)
        self.cnfrmpasswordview.cornerRadius = 8
        self.txtFldPassword.placeholder = self.language.password
        self.txtFldConfirmPassword.placeholder = self.language.confirmPassword
        if #available(iOS 10.0, *) {
            txtFldPassword.keyboardType = .asciiCapable
            txtFldConfirmPassword.keyboardType = .asciiCapable
        } else {
            // Fallback on earlier versions
            txtFldPassword.keyboardType = .default
            txtFldConfirmPassword.keyboardType = .default
        }
        self.navigationController?.isNavigationBarHidden = true
        btnSignIn.cornerRadius = 8
        lblErrorMsg.isHidden = true
        txtFldConfirmPassword.setLeftPaddingPoints(10)
        txtFldConfirmPassword.setRightPaddingPoints(10)
        
        txtFldPassword.setLeftPaddingPoints(10)
        txtFldPassword.setRightPaddingPoints(10)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func setfonts(){
        self.lblResetPassword?.font = iApp.NewTaxiFont.centuryBold.font(size: 17)
       // self.btnClose.titleLabel?.font = iApp.NewTaxiFont.centuryBold.font(size: 14)
        self.txtFldPassword?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        self.txtFldConfirmPassword?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        self.lblErrorMsg?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)

    }
    func setcolor(){
        self.lblResetPassword.textColor = .Title
        self.txtFldPassword.textColor = .Title
        self.txtFldConfirmPassword.textColor = .Title
        
    }
    
    @IBAction func eyebtnaction(_ sender: Any) {
        if(iconClick == true) {
        //    self.txtFldPassword.isHidden = false
            eyebtn.setImage( UIImage.init(named: "Invisible"), for: .normal)
            self.eyebtn.tintColor = .Title
            txtFldPassword.isSecureTextEntry = false
              } else {
               // self.txtFldPassword.isHidden = false
                eyebtn.setImage( UIImage.init(named: "Visible"), for: .normal)
                self.eyebtn.tintColor = .Title
                txtFldPassword.isSecureTextEntry = true
              }

              iconClick = !iconClick
    }
    @IBAction func eyebtn1(_ sender: Any) {
        if(confirmpassswordclick == true) {
          //  self.txtFldConfirmPassword.isHidden = false
            eyebtn1.setImage( UIImage.init(named: "Invisible"), for: .normal)
            self.eyebtn.tintColor = .Title
            txtFldConfirmPassword.isSecureTextEntry = false
              } else {
              //  self.txtFldConfirmPassword.isHidden = false
                eyebtn1.setImage( UIImage.init(named: "Visible"), for: .normal)
                self.eyebtn1.tintColor = .Title
                txtFldConfirmPassword.isSecureTextEntry = true
              }

        confirmpassswordclick = !confirmpassswordclick
    }
    //Show the keyboard
    
    class func initWithStory(for number : String, of country : CountryModel) -> ResetPasswordVC{
        
        let resetPasswordVC : ResetPasswordVC = UIStoryboard.jeba.instantiateViewController()
        resetPasswordVC.strMobileNo = number
        resetPasswordVC.country = country
        return resetPasswordVC
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
       // UberSupport().keyboardWillShowOrHide(keyboarHeight: keyboardFrame.size.height, btnView: btnSignIn)
    }
    //Hide the keyboard

    @objc func keyboardWillHide(notification: NSNotification)
    {
       // UberSupport().keyboardWillShowOrHide(keyboarHeight: 0, btnView: btnSignIn)
    }
    
    // MARK: TextField Delegate Method
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
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
    
    // MARK: Checking Next Button status
    /*
     First & Last name filled or not
     and making user interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        lblErrorMsg.isHidden = true
        if (txtFldConfirmPassword.text?.count)!>5 && (txtFldPassword.text?.count)!>5
        {
            btnSignIn.backgroundColor = UIColor.ThemeYellow
            btnSignIn.isUserInteractionEnabled = true
        }
        else
        {
            btnSignIn.backgroundColor = UIColor.ThemeInactive
            btnSignIn.isUserInteractionEnabled = false
        }
    }
    
    // MARK: API CALLING - UDPATE NEW PASSWORD
    /*
     After filled Password & Confirm Password
     */
    @IBAction func onSignInTapped(_ sender:UIButton!)
    {
        if YSSupport.checkDeviceType()
        {
            if !(UIApplication.shared.isRegisteredForRemoteNotifications)
            {
                let settingsActionSheet: UIAlertController = UIAlertController(title: self.language.message, message: self.language.enPushNotifyLogin, preferredStyle:UIAlertController.Style.alert)


                settingsActionSheet.addAction(UIAlertAction(title: self.language.ok, style:UIAlertAction.Style.cancel, handler:{ action in
                   // self.appDelegate.registerForRemoteNotification()
                  self.appDelegate.pushManager.registerForRemoteNotification()
                }))
                present(settingsActionSheet, animated:true, completion:nil)
                return
            }
        }

        if txtFldConfirmPassword.text != txtFldPassword.text
        {
            lblErrorMsg.isHidden = false
//            lblErrorMsg.text = NSLocalizedString("Password Mismatch", comment: "")
            lblErrorMsg.text = self.language.passwordMismatch
            self.lblErrorMsg?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
            return
        }
        
        addProgress()
        spinnerView.beginRefreshing()
        
        var dicts = [AnyHashable: Any]()
        dicts["mobile_number"] = String(format:"%@",strMobileNo)
        dicts["country_code"] = self.country.country_code
        dicts["password"] = String(format:"%@",txtFldPassword.text!)
        let dialCode = self.country.country_code
        self.apiInteractor?.getRequest(
            for: APIEnums.updatePassword,
            params: [
                "mobile_number" : strMobileNo,
                "password" : txtFldPassword.text!,
                "country_code" : dialCode
        ]).responseJSON({ (json) in
            let loginData = RiderDataModel(json)
            if json.isSuccess{
                loginData.storeRiderBasicDetail()
                loginData.storeRiderImprotantData()
                self.userDefaults.set("rider", forKey:"getmainpage")
                self.userDefaults.synchronize()
                let propertyView = MainMapView.initWithStory()
                self.navigationController?.pushViewController(propertyView, animated: true)
            }else{
                self.lblErrorMsg.isHidden = false
                self.lblErrorMsg.text = loginData.status_message
                self.lblErrorMsg?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
                self.removeProgress()
                
            }
        }).responseFailure({ (error) in
            self.lblErrorMsg.isHidden = false
            self.lblErrorMsg.text = error
            self.lblErrorMsg?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
            self.removeProgress()
        })
            
     
    }
    
    // Display round progress when user calling api
    func addProgress()
    {
        lblErrorMsg.isHidden = true
        self.btnSignIn.isUserInteractionEnabled = false
        btnSignIn.titleLabel?.text = ""
        btnSignIn.setTitle("", for: .normal)
        btnSignIn.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
    }
    
    // Remove progress when api call done
    func removeProgress()
    {
        self.btnSignIn.isUserInteractionEnabled = true
        btnSignIn.titleLabel?.text = NSLocalizedString(NEXT_ICON_NAME, comment: "")
        btnSignIn.setTitle(NSLocalizedString(NEXT_ICON_NAME, comment: ""), for: .normal)
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController!.popViewController(animated: true)
    }

    
}

