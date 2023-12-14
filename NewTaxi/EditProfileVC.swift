/**
* EditProfileVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import AVFoundation

protocol EditProfileDelegate
{
    func setprofileInfo()
}


class EditProfileVC : UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, ChoosePhotoDelegate,UINavigationControllerDelegate,APIViewProtocol //, ViewOfflineDelegate
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    @IBOutlet weak var separateview: UIView!
    @IBOutlet weak var scrollHolder : UIScrollView!
    @IBOutlet weak var imgUserThumb : UIImageView!
    @IBOutlet weak var btnSave : UIButton!
    @IBOutlet weak var btnEditIcon : UILabel!
    @IBOutlet weak var lblDialCode: UILabel!
    @IBOutlet weak var imgCountryFlag: UIImageView!
    @IBOutlet weak var txtFldFirstName: UITextField!
    @IBOutlet weak var txtFldLastName: UITextField!
    @IBOutlet weak var txtFldEmailID: UITextField!
    @IBOutlet weak var btnPhoneNo: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var editAccoutnTitleLbl : UILabel?
 
    @IBOutlet weak var genderTitleLbl: UILabel!
    @IBOutlet weak var femaleLbl: UILabel!
    @IBOutlet weak var maleLbl: UILabel!
    @IBOutlet weak var maleRadioImg: UIImageView!
    @IBOutlet weak var femaleRadioImg: UIImageView!
    
    var changedMobileNumber : MobileNumber?
    lazy var imagePicker = UIImagePickerController()
    var proImageModel : ProfileImageModel!
    lazy var modelProfileData = ProfileModel()
    var delegate: EditProfileDelegate?
    var arrPickerData : NSArray!
    var selectedCell : CellEditProfile!
    var imgUser : UIImage!
    var existingCountry : CountryModel!
    var newCountry : CountryModel?
    
    let arrTitle = ["First name","Last name","Phone Number","Email","Password"]//Title names
    let arrPlaceHolderTitle = ["Enter First name","Enter Last name","Enter Phone Number","Enter Email","Enter Password"]//Text placeholders
    lazy var arrValues = [String]()
    lazy var arrDummyValues = [String]()
    var strFirstName:String = ""
    var strLastName:String = ""
    var strPhoneNo:String = ""
    var strEmail:String = ""
    var strPassword:String = ""
    var strUserImgUrl:String = ""
    var strOriginalDate = ""
    var selectedCountry : CountryModel?
    var strGender:String = ""
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    
    // MARK:- View life cycles
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.elevate(10)
        self.apiInteractor = APIInteractor(self)
        self.setfonts()
        self.setcolor()
        self.txtFldFirstName.placeholder = self.language.firstName.capitalized
        self.txtFldLastName.placeholder = self.language.lastName.capitalized
        self.txtFldEmailID.placeholder = self.language.email.capitalized
        if #available(iOS 10.0, *) {
            txtFldFirstName.keyboardType = .asciiCapable
            txtFldLastName.keyboardType = .asciiCapable
            txtFldEmailID.keyboardType = .asciiCapable

        } else {
            // Fallback on earlier versions
            txtFldFirstName.keyboardType = .default
            txtFldLastName.keyboardType = .default
            txtFldEmailID.keyboardType = .emailAddress
        }
        if language.isRTLLanguage(){
         //   phoneNumberLbl?.textAlignment = .right
            btnPhoneNo.titleLabel?.textAlignment = .left
        }
        self.genderTitleLbl.text = self.language.gender.capitalized
        self.femaleLbl.text = self.language.female
        self.maleLbl.text = self.language.male
        self.txtFldEmailID.textAlignment = self.language.getTextAlignment(align: .left)
        self.txtFldLastName.textAlignment = self.language.getTextAlignment(align: .left)
        self.txtFldFirstName.textAlignment = self.language.getTextAlignment(align: .left)
     //   self.phoneNumberLbl?.textAlignment = self.language.getTextAlignment(align: .left)
        imgUserThumb.cornerRadius = 10
        imgUserThumb.clipsToBounds = true
        txtFldFirstName.delegate = self
        txtFldLastName.delegate = self
        txtFldEmailID.delegate = self
        scrollHolder.contentSize = CGSize(width: scrollHolder.frame.size.width, height:  scrollHolder.frame.size.height)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        btnEditIcon.layer.cornerRadius = btnEditIcon.frame.size.width / 2
        btnEditIcon.clipsToBounds = true
        setProfileUserInfo()
        self.checkSaveButtonStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateNewPhoneNo), name: Notification.Name(rawValue: NotificationTypeEnum.phonenochanged.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.BarFunction()
        self.initLanguage()
    }
    func setfonts(){
        self.editAccoutnTitleLbl?.font = iApp.NewTaxiFont.centuryBold.font(size: 17)
        self.txtFldFirstName?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        self.txtFldLastName?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        self.txtFldEmailID?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        self.btnPhoneNo?.titleLabel?.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        self.genderTitleLbl?.font = iApp.NewTaxiFont.centuryBold.font(size: 15)
        self.maleLbl?.font =  iApp.NewTaxiFont.centuryRegular.font(size: 13)
        self.femaleLbl?.font =  iApp.NewTaxiFont.centuryRegular.font(size: 13)
        self.btnSave?.titleLabel?.font = iApp.NewTaxiFont.centuryBold.font(size: 14)
        self.lblDialCode?.font = iApp.NewTaxiFont.centuryRegular.font(size: 13)
    }
    func setcolor(){
        
        self.editAccoutnTitleLbl?.textColor = .Title
        self.txtFldLastName?.textColor = .Title
        self.txtFldFirstName?.textColor = .Title
        self.editAccoutnTitleLbl?.textColor = .Title
        self.txtFldEmailID?.textColor = .Title
        self.genderTitleLbl?.textColor = .Title
        self.maleLbl?.textColor = .Title
        self.femaleLbl?.textColor = .Title
        self.btnSave?.setTitleColor(.Title, for: .normal)
    }
    func initLanguage(){
       
        self.editAccoutnTitleLbl?.text = self.language.editAccount.capitalized
        self.btnSave.setTitle(
            self.language.save.capitalized,
            for: .normal
        )
    }
    //MARK:- Change StatusBar style function
    func BarFunction(){

    }
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.BarFunction()
    }
    //MARK:- UDF
   //HIDE KEYBOARDS
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollHolder.contentSize = CGSize(width: scrollHolder.frame.size.width, height:  scrollHolder.frame.size.height+keyboardFrame.size.height - 120)
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        scrollHolder.contentSize = CGSize(width: scrollHolder.frame.size.width, height:  btnSave.frame.origin.y + 100)
    }
    //UPDATE THE MOBILE NUMBER
    @objc func updateNewPhoneNo(notification: Notification)
    {
       
        
        let str2 = notification.userInfo
        guard let number = str2?["number"] as? MobileNumber else {return}
        self.changedMobileNumber = number
        let strNewPhoneNo = number.number
        self.newCountry = number.flag

        let flag = number.flag
        imgCountryFlag.image = flag.flag
        lblDialCode.text = flag.dial_code
        self.selectedCountry = flag
        btnPhoneNo.setTitle(strNewPhoneNo, for: .normal)
        btnPhoneNo.titleLabel?.text = strNewPhoneNo
        strPhoneNo = strNewPhoneNo
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: lblDialCode.text! as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        
        var rectTxtFld = btnPhoneNo.frame
        rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
        rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
        btnPhoneNo.frame = rectTxtFld
        arrValues = [strFirstName,strLastName,strPhoneNo,strEmail,strUserImgUrl,strGender]
        checkSaveButtonStatus()
    }
   // CHANGE THE COUNTRYFLAG
    func changeCountryFlag()
    {
        let strDialCode = Constants().GETVALUE(keyname: USER_DIAL_CODE)
        let strCountryCode = Constants().GETVALUE(keyname: USER_COUNTRY_CODE)
        if strDialCode != "" && strCountryCode != ""
        {
//            let flagImg = UIImage.imageFlagBundleNamed(named: (strCountryCode).lowercased() + ".png") as UIImage
            let flagImg = UIImage(named: (strCountryCode).lowercased())

            imgCountryFlag.image = flagImg
            
            Constants ().STOREVALUE(value: lblDialCode.text!, keyname: USER_DIAL_CODE)
            
            Constants().STOREVALUE(value: strCountryCode, keyname: USER_COUNTRY_CODE)
        }
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: lblDialCode.text! as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        var rectTxtFld = btnPhoneNo.frame
        rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
        rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
        btnPhoneNo.frame = rectTxtFld
    }
    //GOTO PHONE NO PAGE
    @IBAction func gotoPhoneNoPage()
    {
        let mobileValidationVC = MobileValidationVC.initWithStory(usign: self,
                                                                  for: .register)
        self.presentInFullScreen(mobileValidationVC, animated: true, completion: nil)

    }
    //Verify weather number is registered already or not
    func verifyToAPI(number : String,dialCode : String){
        AccountInteractor.instance.checkRegistrationStatus(forNumber: number,countryCode: dialCode,{ (isRegistered, message) in
                            if !isRegistered{
                                let info: [AnyHashable: Any] = [
                                            "phone_no" : number,
                                            "dial_no" : dialCode
                                        ]
                                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.phonenochanged.rawValue), object: self, userInfo: info)
                            }else{
                                self.appDelegate.createToastMessage(message, bgColor: .black, textColor: .white)
                            }
        })
    }

 //SET THE USER PROFILE FROM API
    func setProfileUserInfo()
    {
        strFirstName = Constants().GETVALUE(keyname: USER_FIRST_NAME)
        strLastName = Constants().GETVALUE(keyname: USER_LAST_NAME)
        strPhoneNo = Constants().GETVALUE(keyname: USER_PHONE_NUMBER)
        strEmail = Constants().GETVALUE(keyname: USER_EMAIL_ID)
        strGender = Constants().GETVALUE(keyname: USER_GENDER)
        txtFldFirstName.text = strFirstName
        txtFldLastName.text = strLastName
        txtFldEmailID.text = strEmail

        if strGender.lowercased() == "male"
        {
            self.maleRadioImg.image = #imageLiteral(resourceName: "radio_on")
            self.femaleRadioImg.image = #imageLiteral(resourceName: "radio_off")
        }else{
            self.femaleRadioImg.image = #imageLiteral(resourceName: "radio_on")
            self.maleRadioImg.image = #imageLiteral(resourceName: "radio_off")
        }
        btnPhoneNo.setTitle(strPhoneNo, for: .normal)
        btnPhoneNo.titleLabel?.text = strPhoneNo
        strUserImgUrl = Constants().GETVALUE(keyname: USER_IMAGE_THUMB)
        arrValues = [strFirstName,strLastName,strPhoneNo,strEmail,strUserImgUrl]
        imgUserThumb?.sd_setImage(with: NSURL(string: strUserImgUrl)! as URL, placeholderImage:UIImage(named:""))
        arrDummyValues = arrValues
        let dial_code = Constants().GETVALUE(keyname: USER_DIAL_CODE)
        lblDialCode.text = dial_code
        self.selectedCountry = CountryModel(withCountry: Constants().GETVALUE(keyname: USER_COUNTRY_CODE))
        var rect = lblDialCode.frame
        rect.size.width = UberSupport().onGetStringWidth(lblDialCode.frame.size.width, strContent: lblDialCode.text! as NSString, font: lblDialCode.font)
        lblDialCode.frame = rect
        
        var rectTxtFld = btnPhoneNo.frame
        rectTxtFld.origin.x = lblDialCode.frame.origin.x + lblDialCode.frame.size.width + 5
        rectTxtFld.size.width = self.view.frame.size.width - rectTxtFld.origin.x - 20
        btnPhoneNo.frame = rectTxtFld
        
        var flag = CountryModel(withCountry: Constants().GETVALUE(keyname: USER_COUNTRY_CODE))
        self.existingCountry = flag
        if !flag.isAccurate{
            let country_code = Constants().GETVALUE(keyname: USER_COUNTRY_CODE)
            
            //country_code = country_code.replacingOccurrences(of: " ", with: "")
            flag = CountryModel(withCountry: country_code)
        }
        self.imgCountryFlag.image = flag.flag
        lblDialCode.text = flag.dial_code
     
      self.selectedCountry = flag

        
    }
    // MARK: When User Press Add Button

    @IBAction func onAddPhotoTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        
        let viewPhoto = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController(withIdentifier: "ChoosePhoto") as! ChoosePhoto
        viewPhoto.view.backgroundColor = UIColor.clear
        viewPhoto.delegate = self
        viewPhoto.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        present(viewPhoto, animated: false, completion: nil)
    }
    //update user photo methods Action sheect delegate methods
    func onPhotoChoosedDelegateTapped(btnTag:Int)
    {
        if btnTag == 11
        {
            self.takePhoto()
        }
        else if btnTag == 22
        {
            self.choosePhoto()
        }
    }
    
    func onGalleryAlertTapped(_ sender: UIButton!)
    {
        if sender.tag == 11
        {
            self.takePhoto()
        }
        else if sender.tag == 22
        {
            self.choosePhoto()
        }
    }
    
    func takePhoto()
    {
        let permissionManager = PermissionManager(self,MediaConfig(.camera))
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) in
            })

            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if permissionManager.isEnabled{
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            permissionManager.forceEnableService()

        }
        

    }
    
    func choosePhoto()
    {
        let permissionManager = PermissionManager(self,MediaConfig(.photoLibrary))
        if permissionManager.isEnabled{
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            permissionManager.forceEnableService()
        }
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if (info[.originalImage] as? UIImage) != nil {
            let pickedImageEdited: UIImage? = (info[.originalImage] as? UIImage)
            imgUserThumb.image = pickedImageEdited
            
//            self.uploadProfileImage(displayPic:imgUserThumb.image!.fixOrientation())
            self.uploadProfileImage(displayPic: pickedImageEdited!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ##### Uploading Proifle Picture Operation #####
    //  Reference : http://stackoverflow.com/questions/39728626/xcode-8-swift-3-image-file-wont-upload-to-server
    func uploadProfileImage(displayPic:UIImage)
    {
        var paramDict = JSON()
        guard let image_data: Data = displayPic.jpegData(compressionQuality: 0.60) else{
            return
        }
        paramDict["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        WebServiceHandler.sharedInstance
            .uploadPost(
                wsMethod: APIEnums.uploadProfileImage.rawValue,
                paramDict: paramDict,
                imgData: image_data,
                viewController: self,
                isToShowProgress: true,
                isToStopInteraction: true) { (responseDict) in
            if responseDict.isSuccess {
                if responseDict["image_url"] != nil
                {
                    self.strUserImgUrl = responseDict["image_url"] as? String ?? String()
                    self.btnSave.isUserInteractionEnabled = true
                    self.btnSave.backgroundColor = UIColor.ThemeYellow
                }
            }else {
//                self.appDelegate.createToastMessage(NSLocalizedString("Upload failed. Please try again", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)
                 self.appDelegate.createToastMessage(self.language.uploadFailed, bgColor: UIColor.black, textColor: UIColor.white)
            }
        }
        

        
    }
    
    func generateBoundaryString() -> String {
        
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    // MARK: - TextField Delegate Method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        //Restricting empty characters in field
//        if range.location == 0 && (string == " ") {
//            return false
//        }
        if range.location == 0 {
            return true
        }
        if (string == "") {
            return true
        }
//        else if (string == " ") {
//            return false
//        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if textField.tag == 0   // FIRST NAME
        {
            scrollHolder.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(10.0)), animated: true)
        }
        else if textField.tag == 1   // LAST NAME
        {
            scrollHolder.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(10.0)), animated: true)
        }
        else if textField.tag == 2   // EMAIL ID
        {
            scrollHolder.setContentOffset(CGPoint(x: CGFloat(0.0), y: CGFloat(150.0)), animated: true)
        }
        return true
    }
    
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        if textField.tag == 0   // FIRST NAME
        {
            strFirstName = txtFldFirstName.text!
        }
        else if textField.tag == 1   // LAST NAME
        {
            strLastName = txtFldLastName.text!
        }
        else if textField.tag == 2   // EMAIL ID
        {
            strEmail = txtFldEmailID.text!
        }
        
        arrValues = [strFirstName,strLastName,strPhoneNo,strEmail,strUserImgUrl]
        checkSaveButtonStatus()
    }
    
    //update button status based on data changes
    func checkSaveButtonStatus()
    {
        let countryChanged = self.newCountry != nil &&
            self.existingCountry != nil &&
            self.newCountry != self.existingCountry
        if countryChanged || arrValues != arrDummyValues {
            btnSave.isUserInteractionEnabled = true
            btnSave.backgroundColor = UIColor.ThemeYellow
        } else {
            btnSave.isUserInteractionEnabled = false
            btnSave.backgroundColor = UIColor.ThemeInactive
        }
    }
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController!.popViewController(animated: true)
    }
    
    
    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
    internal func RetryTapped()
    {
//        onSaveTapped(nil)
    }
    
    // MARK: API CALL - UPDATE USER PROFILE INFO
    /*
     */
  
    @IBAction func saveButtonTapped()
    {
        self.view.endEditing(true)
        
        if !UberSupport().isValidEmail(testStr: txtFldEmailID.text!)
        {
            self.appDelegate.createToastMessage(((txtFldEmailID.text?.count)! > 0) ? self.language.enterValidEmailId : self.language.enterEmailId, bgColor: UIColor.black, textColor: UIColor.white)
            
            return
        }else if let text = txtFldFirstName.text, text.count == 0 || text == " "{
            self.appDelegate.createToastMessage(self.language.enterFirstName, bgColor: .black, textColor: .white)
            return
        }else if let text = txtFldLastName.text, text.count == 0 || txtFldLastName.text == " "{
            self.appDelegate.createToastMessage(self.language.enterlastName, bgColor: .black, textColor: .white)
            return
        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        
        var dicts = JSON()
        
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        
        dicts["first_name"] = strFirstName
        dicts["last_name"] = strLastName
        dicts["country_code"] = (self.selectedCountry ?? .default).country_code
        
        dicts["mobile_number"] = strPhoneNo
        dicts["email_id"] = strEmail
        dicts["profile_image"] = strUserImgUrl
        
        self.apiInteractor?
            .getRequest(
                for: APIEnums.updateRiderProfile,
                params: dicts
        ).responseJSON({ (json) in
            UberSupport.shared.removeProgressInWindow()
            if json.isSuccess{
                self.updateProfileModel()
                
                if let _changedNumber = self.changedMobileNumber{
                    _changedNumber.flag.store()
                }
            }else{
                AppDelegate.shared.createToastMessage(json.status_message)
            }
            
        }).responseFailure({ (error) in
            UberSupport.shared.removeProgressInWindow()
            AppDelegate.shared.createToastMessage(error)
        })
        
    }
    //Update profile data to cache
    func updateProfileModel()
    {
        modelProfileData.first_name = strFirstName
        modelProfileData.last_name = strLastName
        modelProfileData.email_id = strEmail
        modelProfileData.user_normal_image_url = strUserImgUrl
        modelProfileData.phone = strPhoneNo
        modelProfileData.user_name =  String(format:"%@ %@",modelProfileData.first_name,modelProfileData.last_name)
        
        Constants().STOREVALUE(value: strUserImgUrl, keyname: USER_IMAGE_THUMB)
        Constants().STOREVALUE(value: strFirstName, keyname: USER_FIRST_NAME)
        Constants().STOREVALUE(value: strLastName, keyname: USER_LAST_NAME)
        Constants().STOREVALUE(value: modelProfileData.user_name, keyname: USER_FULL_NAME)
        Constants().STOREVALUE(value: strEmail, keyname: USER_EMAIL_ID)
        Constants().STOREVALUE(value: strPhoneNo, keyname: USER_PHONE_NUMBER)
        delegate?.setprofileInfo()
        strUserImgUrl = ""
        self.onBackTapped(nil)
    }
    
}
//Reusable profile date cell
class CellEditProfile : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var txtTitle: UITextField?
}


extension EditProfileVC : MobileNumberValiadationProtocol{
    func verified(number: MobileNumber) {
        let info: [AnyHashable: Any] = [
            "phone_no" : number.number,
            "dial_no" : number.flag.dial_code,
            "number" : number
        ]
    
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.phonenochanged.rawValue), object: self, userInfo: info)
    }
    
    
}
