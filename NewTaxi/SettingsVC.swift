/**
* SettingsVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import AVFoundation
import Firebase
import FirebaseAuth
protocol SettingProfileDelegate
{
    func setprofileInfo()
}


class SettingsVC : UIViewController, UITableViewDelegate, UITableViewDataSource, addLocationDelegate, EditProfileDelegate,currencyListDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    @IBOutlet weak var tblPayment : UITableView!
    @IBOutlet weak var viewProfileHolder:UIView!
    @IBOutlet weak var lblUserName:UILabel!
    @IBOutlet weak var lblPhoneNo:UILabel!
    @IBOutlet weak var lblEmailId:UILabel!
    @IBOutlet weak var imgUserThumb : UIImageView!
    @IBOutlet weak var parentView : UIView!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var signoutBtn: UIButton!
    @IBOutlet weak var btnBackIcon: UIButton!
    @IBOutlet weak var lblArrowIcon: UILabel!
    
    var delegate: SettingProfileDelegate?
    var strCurrency : String = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    let arrTitle = [
        Language.default.object.addHome,
        Language.default.object.addWork
    ]
    var isHomeTapped : Bool = false
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.updateApi()
        if language.isRTLLanguage(){
            self.lblUserName.textAlignment = .right
            self.lblPhoneNo.textAlignment = .right
            self.lblEmailId.textAlignment = .right
//            self.lblArrowIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.btnBackIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        self.lblSettings.text = self.language.settings
        self.lblSettings?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.signoutBtn.setTitle(self.language.signOut, for: .normal)
        self.signoutBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        let userCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let userCurrency1 = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)

        if (userCurrency != nil && userCurrency != "") && (userCurrency1 != nil && userCurrency1 != "")
        {
            strCurrency = "\(userCurrency) \(userCurrency1)"
            
        }
        else
        {
            strCurrency = "USD $"
        }
        imgUserThumb.layer.cornerRadius = 15
        imgUserThumb.clipsToBounds = true
        lblUserName.text = Constants().GETVALUE(keyname: USER_FULL_NAME)
        lblPhoneNo.text = String(format:"%@ %@",Constants().GETVALUE(keyname: USER_DIAL_CODE), Constants().GETVALUE(keyname: USER_PHONE_NUMBER))
        lblEmailId.text = Constants().GETVALUE(keyname: USER_EMAIL_ID)
        let strUserImg = Constants().GETVALUE(keyname: USER_IMAGE_THUMB)
        imgUserThumb.sd_setImage(with: NSURL(string: strUserImg)! as URL, placeholderImage:UIImage(named:""))
        self.setDesignChanges()

    }
    
    func setDesignChanges(){
        self.parentView.clipsToBounds = true
        self.parentView.setSpecificCornersForTop(cornerRadius: 35)
        self.parentView.elevate(10)
        self.lblUserName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
        self.lblEmailId.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 16)
        self.lblPhoneNo.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 16)
    }
    
    
    
    //MARK:- initWithStory
    class func initWithStory() -> SettingsVC{
        return UIStoryboard.karthi.instantiateViewController()
    }
    func updateApi(){
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .riderProfile)
            .responseJSON({ (json) in
                let _ = DriverDetailModel(jsonForRiderProfile: json)
                if json.isSuccess{
                    self.lblUserName.text = Constants().GETVALUE(keyname: USER_FULL_NAME)
                    self.lblPhoneNo.text = String(format:"%@ %@",Constants().GETVALUE(keyname: USER_DIAL_CODE), Constants().GETVALUE(keyname: USER_PHONE_NUMBER))
                    self.lblEmailId.text = Constants().GETVALUE(keyname: USER_EMAIL_ID)
                    let strUserImg = Constants().GETVALUE(keyname: USER_IMAGE_THUMB)
                    self.imgUserThumb.sd_setImage(with: NSURL(string: strUserImg)! as URL, placeholderImage:UIImage(named:""))
                    
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
                UberSupport.shared.removeProgressInWindow()
            }).responseFailure({ (error) in
                if error != ""
                {
                    UberSupport.shared.removeProgressInWindow()
                    AppDelegate.shared.createToastMessage(error)
                }
            })
        
    }
    @IBAction func signoutAction(_ sender: Any) {
        self.callLogoutAPI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblPhoneNo.text = String(format:"%@ %@",Constants().GETVALUE(keyname: USER_DIAL_CODE), Constants().GETVALUE(keyname: USER_PHONE_NUMBER))
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    internal func onCurrencyChanged(currency: String)
    {
        let str = currency.components(separatedBy: " | ")
        strCurrency = String(format:"%@  (%@)", str[0],str[1])
        let indexPath = IndexPath(row: 1, section: 0)
        tblPayment.reloadRows(at: [indexPath], with: .none)
        tblPayment.reloadData()
    }
    
    
    //MARK: ***** Edit Profile Table view Datasource Methods *****
    /*
     Settings List View Table Datasource & Delegates
     */
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//        if(section == 0) {
//            let viewHolder:UIView = UIView()
//            viewHolder.frame =  CGRect(x: 0, y:0, width: (self.view.frame.size.width) ,height: 50)
//            let lblTitle:UILabel = UILabel()
//            if !self.language.isRTLLanguage(){
//                lblTitle.frame =  CGRect(x: 20, y:0, width: viewHolder.frame.size.width-100 ,height: 50)
//            }
//            else{
//                lblTitle.frame =  CGRect(x:view.frame.size.width-50, y:0, width: viewHolder.frame.size.width-100 ,height: 50)
//                lblTitle.textAlignment = .left;
//            }
////            lblTitle.text = NSLocalizedString("Favorites", comment: "")
//            lblTitle.text = self.language.favorites
//            lblTitle.textColor = UIColor.darkGray
//            lblTitle.font = UIFont (name: iApp.NewTaxiFont.medium.rawValue, size: 14)!
//            viewHolder.backgroundColor = UIColor(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
//            viewHolder.addSubview(lblTitle)
//            return viewHolder
//        }
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if(section == 0) {
//            return 50
//        }
//        return 30
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return indexPath.section == 0 ? 85 : 85
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return section == 0 ? arrTitle.count : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section != 0{
            let cell:CellCurrencyTVC = tblPayment.dequeueReusableCell(withIdentifier: "CellCurrencyTVC")! as! CellCurrencyTVC
            cell.lblIconName?.isHidden = true
            if language.isRTLLanguage(){
                cell.lblTitle?.textAlignment = .right
            }
            let isLangOrCurre = indexPath.row == 1
            cell.lblTitle?.text = isLangOrCurre ? self.language.language.capitalized : self.language.currency
            
            let rectTblView = cell.lblTitle?.frame
            cell.lblTitle?.frame = rectTblView!
            cell.selectedLabel?.text = isLangOrCurre ? Language.default.displayName : strCurrency
            if isLangOrCurre{
                cell.imgLogo?.image = UIImage(named: "language-1")
            }else{
                cell.imgLogo?.image = UIImage(named: "Currency")
            }
            return cell
        }
        else{
            let cell:CellPayment = tblPayment.dequeueReusableCell(withIdentifier: "CellPayment")! as! CellPayment
            cell.lblTitle?.text = arrTitle[indexPath.row]
//            var rectTblView = cell.lblTitle?.frame
//            var rectSubTitle = cell.lblSubTitle?.frame
            let isRTL = self.language.isRTLLanguage()
            if language.isRTLLanguage(){
                cell.lblTitle?.textAlignment = .right
                cell.lblSubTitle?.textAlignment = .right
                cell.lblAccessory?.transform = CGAffineTransform(scaleX: -1, y: 1)
                
            }
//            cell.lblTitle?.frame = rectTblView!
//            cell.lblSubTitle?.frame = rectSubTitle!
            if indexPath.row == 0 && Constants().GETVALUE(keyname: USER_HOME_LOCATION).count > 0 {
//                cell.lblTitle?.text = NSLocalizedString("Home", comment: "")
                cell.lblTitle?.text = self.language.home
                cell.lblSubTitle?.isHidden = false
                cell.lblSubTitle?.text = Constants().GETVALUE(keyname: USER_HOME_LOCATION)
            }
            else if indexPath.row == 0 {
                cell.lblSubTitle?.isHidden = true
                cell.lblTitle?.text = arrTitle[indexPath.row]
            }
            
            if indexPath.row == 1 && Constants().GETVALUE(keyname: USER_WORK_LOCATION).count > 0 {
                //                cell.lblTitle?.text = NSLocalizedString("Work", comment: "")
                cell.lblTitle?.text = self.language.work
                cell.lblSubTitle?.isHidden = false
                cell.lblSubTitle?.text = Constants().GETVALUE(keyname: USER_WORK_LOCATION)
            } else if indexPath.row == 1 {
                cell.lblSubTitle?.isHidden = true
                cell.lblTitle?.text = arrTitle[indexPath.row]
            }
            cell.lblTitle?.textColor = UIColor.black
            cell.lblIconName?.isHidden = true
            cell.imgLogo?.image = (indexPath.row == 0) ? UIImage(named: "home")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "work")?.withRenderingMode(.alwaysTemplate)
            cell.imgLogo?.tintColor = UIColor.ThemeYellow
            cell.lblAccessory?.isHidden = false
//            rectTblView?.origin.x = 80
            return cell

        }
       
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(indexPath.section == 0)
        {
            let locationView = AddLocationVC.initWithStory(self)
            locationView.isFromHomeLocation = (indexPath.row == 0) ? true : false
            isHomeTapped = (indexPath.row == 0) ? true : false
            self.navigationController?.pushViewController(locationView, animated: true)
        }
        else
        {
            if indexPath.row == 0{
//                let locView = CurrencyVC.initWithStory(self)
//                locView.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(locView, animated: true)

                let locView = CurrencyPopupVC.initWithStory(self)
                locView.modalPresentationStyle = .overCurrentContext
                self.present(locView, animated: true, completion: nil)
            }else{
                
                let view = SelectLanguageVC.initWithStory()
                view.modalPresentationStyle = .overCurrentContext
                self.present(view, animated: true, completion: nil)
            }
            
        }
    }
    
    // Add Location Delegate method
    internal func onLocationAdded(latitude: CLLocationDegrees, longitude: CLLocationDegrees, locationName: String)
    {
        var dicts = [AnyHashable: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = String(format:"%f",latitude)
        dicts["longitude"] = String(format:"%f",longitude)
        
        if isHomeTapped
        {
            dicts["home"] = locationName
        }
        else
        {
            dicts["work"] = locationName
        }
        self.callUpdateLocationAPI(dicts,latitude: latitude, longitude: longitude, locationName: locationName)
    }

    // STORING WORK/HOME LOCATION AFTER API DONE
    func setLocationName(latitude: CLLocationDegrees, longitude: CLLocationDegrees, locationName: String)
    {
        if isHomeTapped
        {
            Constants().STOREVALUE(value: locationName, keyname: USER_HOME_LOCATION)
            Constants().STOREVALUE(value: String(format:"%f",latitude), keyname: USER_HOME_LATITUDE)
            Constants().STOREVALUE(value: String(format:"%f",longitude), keyname: USER_HOME_LONGITUDE)
        }
        else
        {
            Constants().STOREVALUE(value: locationName, keyname: USER_WORK_LOCATION)
            Constants().STOREVALUE(value: String(format:"%f",latitude), keyname: USER_WORK_LATITUDE)
            Constants().STOREVALUE(value: String(format:"%f",longitude), keyname: USER_WORK_LONGITUDE)
        }
    }
    
    // MARK: - API CALL -> UPDATE WORK/HOME LOCATION
    /*
        HERE WE STORING LOCATION NAME, LATITUDE & LONGIDUDE
     */
    func callUpdateLocationAPI(_ dicts: [AnyHashable: Any],latitude: CLLocationDegrees, longitude: CLLocationDegrees, locationName: String)
    {
        guard let parameter = dicts as? JSON else{
            AppDelegate.shared.createToastMessage(self.language.internalServerError)
            return
        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(
                for: APIEnums.updateRiderLocation,
                        params: parameter
        ).responseJSON({ (json) in
            if json.isSuccess{
                self.setLocationName(latitude: latitude, longitude: longitude, locationName: locationName)
                self.tblPayment.reloadData()
            }else{
                AppDelegate.shared.createToastMessage(json.status_message)
            }
            UberSupport.shared.removeProgressInWindow()
        }).responseFailure({ (error) in
            AppDelegate.shared.createToastMessage(error)
            UberSupport.shared.removeProgressInWindow()
        })
        
        
    }
    
    // MARK: LOGOUT API CALL
    /*
     */
    func callLogoutAPI()
    {
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        var dicts = [AnyHashable: Any]()
        dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        self.apiInteractor?
            .getRequest(
                for: .logout
        ).responseJSON({ (json) in
            if json.isSuccess{
                let userDefaults = UserDefaults.standard
                userDefaults.set("", forKey:"getmainpage")
                userDefaults.synchronize()
                self.resetUserLocations()
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
                
                UserDefaults.removeValue(for: .default_language_option)
                Language.default.saveLanguage()
                userDefaults.removeObject(forKey: USER_CARD_BRAND)
                userDefaults.removeObject(forKey: USER_CARD_LAST4)
                userDefaults.removeObject(forKey: USER_ACCESS_TOKEN)
                
                PaymentOptions.cash.setAsDefault()
                UserDefaults.clearAllKeyValues()
                Constants().STOREVALUE(value: "No" , keyname: USER_SELECT_WALLET)
                self.appDelegate.option = ""
                self.appDelegate.amount = ""
                do{
                    try CallManager.instance.should(waitForCall: false)
                    CallManager.instance.wipeUserData()
                    CallManager.instance.deinitialize()
                }catch{
                }
                self.appDelegate.onSetRootViewController(viewCtrl:self)
            }else{
                AppDelegate.shared.createToastMessage(json.status_message)
            }
            UberSupport.shared.removeProgressInWindow()
        }).responseFailure({ (error) in
            AppDelegate.shared.createToastMessage(error)
            UberSupport.shared.removeProgressInWindow()
        })
        
    }
    
    // AFTER USER LOGOUT, WE SHOULD RESET WORK/HOME LOCATION DETAILS
    func resetUserLocations()
    {
        Constants().STOREVALUE(value: "", keyname: USER_HOME_LOCATION)
        Constants().STOREVALUE(value: "", keyname: USER_HOME_LATITUDE)
        Constants().STOREVALUE(value: "", keyname: USER_HOME_LONGITUDE)
        
        Constants().STOREVALUE(value: "", keyname: USER_WORK_LOCATION)
        Constants().STOREVALUE(value: "", keyname: USER_WORK_LATITUDE)
        Constants().STOREVALUE(value: "", keyname: USER_WORK_LONGITUDE)
    }
    
    // WHEN USER PROFILE HEADER TAPPED
    @IBAction func onProfileTapped(_ sender:UIButton!)
    {
        let propertyView = UIStoryboard.jeba.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        propertyView.delegate = self
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // EDIT PROFILE VC DELEGATE METHOD
    internal func setprofileInfo()
    {
        delegate?.setprofileInfo()
        imgUserThumb?.sd_setImage(with: NSURL(string: Constants().GETVALUE(keyname: USER_IMAGE_THUMB))! as URL, placeholderImage:UIImage(named:""))
        lblUserName.text = Constants().GETVALUE(keyname: USER_FULL_NAME)
        lblEmailId.text = Constants().GETVALUE(keyname: USER_EMAIL_ID)
        lblPhoneNo.text = String(format:"%@ %@",Constants().GETVALUE(keyname: USER_DIAL_CODE), Constants().GETVALUE(keyname: USER_PHONE_NUMBER))

        tblPayment.reloadData()
    }

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController!.popViewController(animated: true)
    }
   
}

class CellPayment : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblSubTitle: UILabel?
    @IBOutlet var lblIconName: UILabel?
    @IBOutlet var imgLogo: UIImageView?
    @IBOutlet var lblAccessory: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.lblSubTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 14)
    }
}


class CellCurrencyTVC : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var selectedLabel: UILabel?
    @IBOutlet var lblIconName: UILabel?
    @IBOutlet weak var imgLogo : UIImageView?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.selectedLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
