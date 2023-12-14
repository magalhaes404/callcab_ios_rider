/**
* DriverProfileVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/



import UIKit
import Foundation

protocol driverProfileDelegate {
    func setRideStatus(_ val : Bool)
}

class DriverProfileVC : UIViewController,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch response {
//        case .tripDetailData(let detail):
//            self.tripDetailModel = detail
//            self.setTripInfo(withData: detail)
        default:
            break
        }
    }
    
    @IBOutlet weak var outline: UIView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var arrivalMinsView: UIView!
    @IBOutlet weak var lcoation: UIImageView!
    @IBOutlet weak var waiting: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgDriverThumb: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblVehicleName: UILabel!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblPickUpLoc: UILabel!
    @IBOutlet weak var lblArrivalTime: UILabel!
    @IBOutlet weak var lblArrivalMins: UILabel!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewTripHolder: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblEnRoute : UILabel!
    @IBOutlet weak var btnContact : UIButton!
    @IBOutlet weak var lblYourCurrentTrip : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    var isTripStarted : Bool = false
    lazy var language : LanguageProtocol = { Language.default.object}()
    var tripDetailModel : TripDetailDataModel!
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.initView()
        self.initNotificationObservers()
        self.initLanguage()
        self.setFonts()
        self.checkStatus()
    }
    //MARK:- initializers
    func initView(){
        self.separator.isHidden = isTripStarted ? true : false
        self.waiting.isHidden = isTripStarted ? true : false
        self.lblArrivalTime.isHidden = isTripStarted ? true : false
    }
    func setFonts(){
        self.outline.backgroundColor = .BorderCell
        
        self.mainView.setSpecificCornersForTop(cornerRadius: 45)
        self.mainView.elevate(10)
        imgDriverThumb.cornerRadius = 30
        imgDriverThumb.border(2, UIColor(hex: "eaeaea"))
        imgDriverThumb.clipsToBounds = true
        self.btnBack.setTitleColor(.Title, for: .normal)
        self.lblEnRoute.text = self.language.enRoute
        self.lblEnRoute.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.lblEnRoute.textColor = .Title
        self.lblRating.textColor = .ThemeYellow
        self.lblRating.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.arrivalMinsView.backgroundColor = .ThemeYellow
        self.arrivalMinsView.cornerRadius = 10
        self.lblArrivalMins.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        self.lblArrivalMins.textColor = .Subtitle
        self.lblDriverName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblDriverName.textColor = .Title
        self.lblVehicleName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblVehicleName.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.lblVehicleNumber.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblVehicleNumber.backgroundColor = .Background
        self.lblVehicleNumber.cornerRadius = 10
        self.lblVehicleNumber.textColor = .Title
        self.btnCancel.setTitleColor(UIColor.Title.withAlphaComponent(0.45), for: .normal)
        self.btnCancel.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.btnCancel.elevate(2)
        self.btnCancel.border(1, UIColor.init(hex: "eaeaea"))
        self.btnContact.setTitleColor(UIColor.Title,for: .normal)
        self.btnContact.backgroundColor = .ThemeYellow
        self.btnContact.cornerRadius = 5
        self.btnCancel.backgroundColor = .white
        self.btnCancel.cornerRadius = 5
        self.btnContact.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.lblPickUpLoc.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblPickUpLoc.textColor = .Title
        self.lblArrivalTime.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblArrivalTime.textColor = .Title
        self.lblYourCurrentTrip.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.lblYourCurrentTrip.textColor = UIColor.Title.withAlphaComponent(0.45)
        self.lcoation.image = UIImage(named: "location-mark")
        self.waiting.image = UIImage(named: "Time")
    }
    
    func initNotificationObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoHomePage), name: NSNotification.Name(rawValue: NotificationTypeEnum.GotoHomePage.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMainView), name: NSNotification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrip.rawValue), object: nil)
    }
    func initLanguage(){
        self.btnBack.setTitle(self.language.getBackBtnText(), for: .normal)
        self.btnCancel.setTitle(self.language.cancel.capitalized, for: .normal)
        self.btnContact.setTitle(self.language.contact, for: .normal)
        self.lblYourCurrentTrip.text = self.language.yourCurrentTrip
    }
    //MARK:- initWithStory
    class func initWithStory(for trip : TripDetailDataModel,isTripStarted isStarted : Bool) -> DriverProfileVC{
        let driverProfile : DriverProfileVC =  UIStoryboard.payment.instantiateViewController()
        driverProfile.tripDetailModel = trip
        driverProfile.isTripStarted = isStarted
        return driverProfile
    }
    // Check a Trip Status and disable the cancel button
    func checkStatus()
    {
        if isTripStarted
        {
            btnCancel.isUserInteractionEnabled = false
            self.btnCancel.setTitleColor(UIColor.Title.withAlphaComponent(0.45), for: .normal)
        }
        if self.tripDetailModel != nil{
                  self.setTripInfo(withData: self.tripDetailModel)
              }
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
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // when receiving cancel trip notification, we should goto home page
    @objc func gotoHomePage()
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationTypeEnum.GotoHomePage1.rawValue), object: self, userInfo: nil)
        })
        self.navigationController?.popViewController(animated: false)
        CATransaction.commit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.tripDetailModel != nil{
            self.setTripInfo(withData: self.tripDetailModel)
        }else{
//            self.apiInteractor?.getResponse(forAPI: .getTripDetail, params: ["trip_id" : self.tripDetailModel.description])
//            .shouldLoad(true)
            UberSupport.shared.showProgressInWindow(showAnimation: true)
            self.apiInteractor?
                .getRequest(for: .getTripDetail,params: ["trip_id" : self.tripDetailModel.description])
                .responseJSON({ (json) in
                    if json.isSuccess{
                        UberSupport.shared.removeProgressInWindow()
                        let detail = TripDetailDataModel(json)
                        self.tripDetailModel = detail
                        self.setTripInfo(withData: detail)

                    }else{
                        AppDelegate.shared.createToastMessage(json.status_message)
                        UberSupport.shared.removeProgressInWindow()

                    }
                }).responseFailure({ (error) in
                    AppDelegate.shared.createToastMessage(error)
                        UberSupport.shared.removeProgressInWindow()

                })

        }
    }
    // setting driver info from driverinfovc class
    func setTripInfo(withData data : TripDetailDataModel)
    {
        if tripDetailModel.getRating.isZero{
            lblRating.text = ""
            lblDriverName.text = data.driverName
        }else{

            let textAtt =  NSMutableAttributedString(string: "\(data.driverName) \(data.rating) ★")
            textAtt.setColorForText(textToFind: " \(data.rating) ★", withColor: .ThemeYellow)
            textAtt.setColorForText(textToFind: "\(data.driverName)", withColor: .Title)
            lblRating.attributedText = textAtt
            
//            strUberName.setColorForText(textToFind: data.driverName, withColor: .Title)
        }
//        lblRating.isHidden = true
        lblPickUpLoc.text = data.pickupLocation
        imgDriverThumb.sd_setImage(with: NSURL(string: data.driverThumbImage)! as URL)
        lblVehicleName.text = data.vehicleName
        lblVehicleNumber.text = data.vehicleNumber
        let duration = tripDetailModel.etaToDestination.replacingOccurrences(of: " ", with: "")
        self.arrivalMinsView.isHidden = isTripStarted ? true : false
        guard !duration.isEmpty  else{return}
        lblArrivalMins.text = duration
        let minutes_to_arrive : String
        if !isTripStarted{
            minutes_to_arrive = "\(duration) \(language.toArrive.lowercased())"
        }else{
            minutes_to_arrive = "\(duration) \(language.toReach.lowercased())"
        }
        lblArrivalTime.text = minutes_to_arrive
    }
    // MARK: When User Press Contact Driver
    @IBAction func onContacttapped(_ sender:UIButton!)
    {
        let driverContactVC = DriverContactVC.initWithStory(tripDetail: tripDetailModel)
        if let driver_image = self.imgDriverThumb.image{
            driverContactVC.driverimage = driver_image
        }
        self.navigationController?.pushViewController(driverContactVC, animated: true)
    }

    // MARK: When User Cancel Trips
    @IBAction func onCancelTapped(_ sender:UIButton!)
    {
        let cancelRiderVC = CancelRideVC.initWithStory()
        cancelRiderVC.strTripId = self.tripDetailModel.description
        self.navigationController?.pushViewController(cancelRiderVC, animated: false)
    }
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: false)
    }
}
extension DriverProfileVC : driverProfileDelegate{
    func setRideStatus(_ val: Bool) {
        self.isTripStarted = val
        self.checkStatus()
    }
}
