/**
* CancelRideVC.swift
*
* @package UberDriver
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/


import UIKit
import Foundation
import Alamofire

class CancelRideVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,APIViewProtocol
{
    //MARK:- APIInteractor
    
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
//        case .cancelReason(let reasons):
//            self.cancelReasons = reasons
//            let height = tblCancelList.frame.height
//            let  contentHeight = 50 * reasons.count
//            let size : CGFloat = Int(height) > contentHeight ? CGFloat(contentHeight) : height
//            let originalFrame = tblCancelList.frame
//            tblCancelList.frame = CGRect(x: originalFrame.minX,
//                                         y: originalFrame.minY,
//                                         width: originalFrame.width,
//                                         height: size > 450 ? 450 : size)
//            self.tblCancelList.reloadData()
        default:
            break
        }
    }
    func onFailure(error: String,for API : APIEnums) {
//        self.appDelegate.createToastMessage(error)
    }
    //MARK:- Outlets
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var isToCancelSchedule = false
    @IBOutlet weak var tblCancelList: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCanceReason: UIButton!
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var txtViewCancel: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var lblPageTitle : UILabel!
    
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainBgView: UIView!
    @IBOutlet weak var containerBGView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var holderView: UIView!
    
    
    func setDesign() {
        self.lblPageTitle.textColor = .Title
        self.lblPageTitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.txtViewCancel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.mainBgView.backgroundColor = .white
        self.mainBgView.setSpecificCornersForTop(cornerRadius: 20)
        self.mainBgView.elevate(4)
        
        self.viewHolder.cornerRadius = 10
        self.viewHolder.border(1, .Border)
        
        self.holderView.cornerRadius = 10
        self.holderView.border(1, .Border)
        
        self.btnSave.clipsToBounds = true
        self.btnSave.cornerRadius = 10
        
        
        self.btnCanceReason.setTitleColor(.Title, for: .normal)
        self.btnCanceReason.backgroundColor = .white
        self.btnCanceReason.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
        
        self.btnSave.setTitleColor(.Title, for: .normal)
    }
    
    
    let dropImage = UIImage(named: "dropdown")
    var rotatedArrow: UIImage?
    var strCancelReason = ""


    var cancelReasons = [CancelReason]()
    var strTripId = ""
    var usertype = ""
    var cancel_reason_id : Int = 0
   // MARK: - ViewController Methods

    lazy var language : LanguageProtocol = {Language.default.object}()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.cancelReasonsApi()
        self.initView()
        self.initNotification()
        self.initLanguage()
        self.checkForTextColor()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initLayer()
        }
        checkSaveButtonStatus()
     
    }
    func cancelReasonsApi()
    {
//        self.apiInteractor?.getResponse(for: .cancel_reasons).shouldLoad(true)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .cancel_reasons)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let reasons = json.array("cancel_reasons").compactMap({CancelReason($0)})
                    self.cancelReasons = reasons
                    let height = self.tblCancelList.frame.height
                    let  contentHeight = 50 * reasons.count
                    let size : CGFloat = Int(height) > contentHeight ? CGFloat(contentHeight) : height
                    let originalFrame = self.tblCancelList.frame
                    self.tblCancelList.frame = CGRect(x: originalFrame.minX,
                                                 y: originalFrame.minY,
                                                 width: originalFrame.width,
                                                 height: size > 450 ? 450 : size)
                    self.tblCancelList.reloadData()
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

    }
    //MARK:- initView
    func initView(){

        self.arrow.image = self.dropImage
        self.rotatedArrow = self.dropImage?.rotate(radians: .pi)
        tblCancelList.isHidden = true
    }
    
    //MARK:- initLayer
    func initLayer(){
        self.setDesign()
    }
    //MARK:- initLanguage
    func initLanguage(){
        self.btnBack.setTitle(self.language.getBackBtnText(), for: .normal)
        self.btnCanceReason.setTitle(self.language.cancelReason, for: .normal)
        self.btnSave.setTitle(self.language.cancelTrip, for: .normal)
        self.lblPageTitle.text = self.language.cancelYourRide
        self.lblPlaceHolder.text = self.language.writeYourComment
    }
    //MARK:- initNotification
    func initNotification(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMainView), name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrip.rawValue), object: nil)
    }
    //MARK:- initWithStory
    class func initWithStory() -> CancelRideVC{
        let view : CancelRideVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        view.apiInteractor = APIInteractor(view)
        
        return view
    }
    //MARK: - WHILE GETTING PUSH NOTIFICATION FROM DRIVER
    /*
     NOTIFICATION TYPE ARRIVE NOW OR BEGIN TRIP STARTED
     */
    @objc func gotoMainView(notification: Notification)
    {
        let str2 = notification.userInfo
        let getNotificationType = str2?["type"] as? String ?? String()
        if getNotificationType != "arrivenow"
        {
            self.onBackTapped(nil)
        }
    }

    // MARK: - ViewController Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
    }

    
    
    

    // MARK: - API CALL -> CANCELLING TRIP
    @IBAction func onCancelTripTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        btnSave.isUserInteractionEnabled = false
        UberSupport().showProgressInWindow(viewCtrl: self, showAnimation: true)
        var dicts = [AnyHashable: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["trip_id"] = strTripId
        
        if txtViewCancel.text != self.language.writeYourComment {
            dicts["cancel_comments"] = txtViewCancel.text!
        } else {
            dicts["cancel_comments"] = ""
        }
        
        dicts["cancel_reason_id"] = cancel_reason_id.description
        dicts["user_type"] = usertype
        if self.isToCancelSchedule{
            self.cancelScheduleRide(dict: dicts)
        }else{
            self.cancelRide(dicts: dicts)
        }
    }
    func cancelScheduleRide(dict : [AnyHashable:Any]){
        var params = Parameters()
        dict.forEach { ( hashKey,value) in
            params[hashKey as? String ?? String()] = value
        }
        UberSupport.init().showProgressInWindow(showAnimation: true)
        AF.request(iApp.APIBaseUrl+APIEnums.cancelScheduleRide.rawValue,
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil).responseJSON { (jsonResponse) in
                            UberSupport.init().removeProgressInWindow()
                            UberSupport.init().removeProgress(viewCtrl: self)
                            print(jsonResponse.request?.url)
                            switch jsonResponse.result{
                            case .success(let data):
                                if let json = data as? JSON{
                                    if json.status_code == 1{
                                        self.appDelegate.createToastMessage(json.status_message,
                                                                            bgColor: .black,
                                                                            textColor: .white)
                                        
                                        self.gotoMainMapView()
                                    }else{
                                        self.appDelegate.createToastMessage(json.status_message,
                                                                            bgColor: .black,
                                                                            textColor: .white)
                                    }
                                }else{
                                    self.appDelegate.createToastMessage(iApp.NewTaxiError.server.localizedDescription,
                                                                        bgColor: .black,
                                                                        textColor: .white)
                                }
                                case .failure(let error):
                                    self.appDelegate.createToastMessage(error.localizedDescription,
                                                                        bgColor: .black,
                                                                        textColor: .white)
                            }
        }
        UberSupport().removeProgressInWindow(viewCtrl: self)
    }
    func cancelRide(dicts : [AnyHashable: Any]){
        guard let parameter = dicts as? JSON else{
            AppDelegate.shared.createToastMessage(self.language.internalServerError)
            return
        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(
                for: APIEnums.cancelTrip,
                params: parameter)
            .responseJSON({ (json) in
                UberSupport.shared.removeProgressInWindow()
                if json.isSuccess{
                    self.gotoMainMapView()
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    self.btnSave.isUserInteractionEnabled = true
                }
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
                self.btnSave.isUserInteractionEnabled = true
            })
       
    }
    // AFTER CANCELLING TRIP WE SHOULD NAVIGATE TO HOME PAGE
    func gotoMainMapView()
    {

        /*
         * 2.3
             let appDelegate = UIApplication.shared.delegate as! AppDelegate
             appDelegate.onSetRootViewController(viewCtrl: nil)
         */
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
    }
    
    // MARK: When User Press Back Button
    @IBAction func chooseCancelDropDown(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.arrow.image = rotatedArrow
        tblCancelList.isHidden = !tblCancelList.isHidden
        if tblCancelList.isHidden == true {
            self.arrow.image = UIImage(named: "dropdown")
        }
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
//        dismiss(animated: true, completion: nil)
        self.navigationController!.popViewController(animated: true)
    }
    
    //MARK: - TEXTVIEW DELEGATE METHOD
    func textViewDidChange(_ textView: UITextView)
    {
//        lblPlaceHolder.isHidden = (txtViewCancel.text.count > 0) ? true : false
//        self.checkForTextColor()
        checkSaveButtonStatus()
    }
    
    func checkForTextColor() {
        if txtViewCancel.text == self.language.writeYourComment {
            txtViewCancel.text = ""
            txtViewCancel.textColor = .Title
        } else if txtViewCancel.text == "" {
            txtViewCancel.text = self.language.writeYourComment
            txtViewCancel.textColor = UIColor.Title.withAlphaComponent(0.29)
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.checkForTextColor()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.checkForTextColor()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if range.location == 0 && (text == " ") {
            return false
        }
        if (text == "") {
            return true
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    //MARK: TEXTVIEW DELEGATE END

    //MARK: - ***** Cancel Reason Table view Datasource Methods *****
    /*
     Cancel Reason List View Table Datasource & Delegates
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.cancelReasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellEarnItems = tblCancelList.dequeueReusableCell(withIdentifier: "CellEarnItems")! as! CellEarnItems
        cell.lblTitle?.text = cancelReasons[indexPath.row].description
        cell.checkIV.image = strCancelReason == cell.lblTitle.text ? #imageLiteral(resourceName: "checkbox") : #imageLiteral(resourceName: "checkbox-Outline")
        
//        cell.lblAccessory?.layer.borderColor = UIColor.black.cgColor
//        cell.lblAccessory?.layer.borderWidth = 1.0
//        cell.lblAccessory?.text = (strCancelReason == cell.lblTitle.text) ? "3" : ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        strCancelReason = cancelReasons[indexPath.row].description
        cancel_reason_id = cancelReasons[indexPath.row].id
        usertype = cancelReasons[indexPath.row].cancelled_by.description
        btnCanceReason.setTitle(strCancelReason,for:.normal)
        btnCanceReason.titleLabel?.text = strCancelReason
        tblCancelList.isHidden = true
        let againRotate = self.rotatedArrow?.rotate(radians: .pi)
        self.arrow.image = againRotate
        tblCancelList.reloadData()
        checkSaveButtonStatus()
    }
    
    func checkSaveButtonStatus()
    {
        if btnCanceReason.titleLabel?.text != self.language.cancelReason
        {
            btnSave.isUserInteractionEnabled = true
            btnSave.backgroundColor = UIColor.ThemeYellow
        }
        else
        {
            btnSave.backgroundColor = UIColor.ThemeInactive
            btnSave.isUserInteractionEnabled = false
        }
    }

}

class CellEarnItems: UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
//    @IBOutlet var lblAccessory: UILabel!
    @IBOutlet weak var checkIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    
    func setDesign() {
        self.contentView.clipsToBounds = true
        self.lblTitle.textColor = .Title
        self.lblTitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    }
}
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
