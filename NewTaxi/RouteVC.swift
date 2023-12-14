/**
 * DriverInfoVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */



import UIKit
import Foundation
import GoogleMaps
import FirebaseDatabase
import ARCarMovement

class RouteVC : UIViewController,
    GMSMapViewDelegate,
    ARCarMovementDelegate,
    ChatViewProtocol,
    MenuResponseProtocol,
    APIViewProtocol
{
    func arCarMovementMoved(_ marker: GMSMarker) {
        driverMarker?.map = nil
        driverMarker?.icon = nil
        driverMarker?.iconView = nil
        driverMarker = marker
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
        imageView.image = UIImage(named: "top view")
        driverMarker?.iconView = imageView
        driverMarker?.map = map
        var updatedCamera = GMSCameraUpdate.setTarget(marker.position)
        if isZoomed == false {
            updatedCamera = GMSCameraUpdate.setTarget(marker.position, zoom: self.cameraDefaultZoom)
            isZoomed = true
        }
        map?.animate(with: updatedCamera)
        self.map?.animate(toBearing: marker.rotation)
    }
    
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch (API,response) {
        default:
            break
        }
    }
    
    func callAdminForManualBooking() {
        
        self.checkMobileNumeber()
        
    }
    
    func routeToView(_ view: UIViewController) {
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    var chatInteractor: ChatInteractorProtocol?
    
    var messages: [ChatModel] = [ChatModel]()
    var isBadgeOn = false
    func setChats(_ message: [ChatModel]) {
        if message.last?.type == .driver{
            self.isBadgeOn = true
        }
        
    }

    lazy var langugage = Language.default.object
    
    @IBOutlet weak var locationImgCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileStack: UIStackView!
    @IBOutlet weak var locationImg: UIImageView!
    @IBOutlet weak var imgDriverThumb: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblVehicleName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblVehicleNumber: UILabel!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewAddressHolder: UIView!
    @IBOutlet weak var mapLocation: UIView!
    @IBOutlet weak var driverDetailsButton: UIButton!
    @IBOutlet weak var otpLabel : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var etaLbl : UILabel!
    //Protocols
    @IBOutlet weak var sosLabel: UILabel!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var lbltitle: UILabel!
    var driver_profile_delegate : driverProfileDelegate?
    
    var driversPositiionAtPath : UInt = 0

    var riderCanValidatePathChanges = false
    var isTripStarted : Bool = false{
        didSet{
           self.onTripStatusChange()
        }
    }
    
    @IBOutlet weak var messageIconOuter: UIView!
    @IBOutlet weak var etaView: UIView!
    var currenRouteData : Route? = nil
    var updateTripHistory : UpdateContentProtocol?
    lazy var polyline = GMSPolyline()
    lazy var path = GMSPath()
    var tripID : Int = 0
    var tripStatus : TripStatus = .pending
    var bookingType : BookingEnum = .auto
    var tripDataModel : TripDataModel!
    var tripDetailModel : TripDetailDataModel?{
        didSet{
            if let data = self.tripDetailModel{
                self.tripDataModel = data
            }
        }
    }
    @IBOutlet weak var sosStack: UIStackView!
    @IBOutlet weak var sosView: UIView!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var messageIcon: UIImageView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var vehicleView: UIView!
    lazy var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    lazy var timerDriverLocation = Timer()
    lazy var updateDriverLocation = Timer()
    lazy var markerDriver = GMSMarker()
    var isPopEexcuted:Bool = Bool()
    var ref: DatabaseReference!
    var postRefHandle: DatabaseHandle!
    var driverMarker: GMSMarker?
    var moveMent: ARCarMovement!
    var oldCoordinate: CLLocationCoordinate2D!
    let cameraDefaultZoom : Float = 16.5
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var map : GMSMapView?
    var lastDirectionAPIHitStamp : Date?
    

    var timerForETA : Timer? = nil
    lazy var waitingTimeLbl : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont(name: iApp.NewTaxiFont.medium.rawValue, size: 11)
        label.textColor = .ThemeMain
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        return label
    }()
    lazy var waitingTimeView : UIView = {
       let waitingView = UIView()
        waitingView.backgroundColor = UIColor(hex: "FEF9EB")
        let referenceFrame = self.viewAddressHolder.frame
        self.waitingTimeLbl.layoutIfNeeded()
        let msg = "$1/min Waiting Fee applies after 3 mins of arrival till trip starts"
        let labelHeight = msg.height(withConstrainedWidth: waitingView.frame.width - 6,
                                font: self.waitingTimeLbl.font) * 2
        waitingView.frame = CGRect(x: referenceFrame.minX + 8,
                            y: referenceFrame.maxY - 10,
                            width: referenceFrame.width - 16,
                            height: labelHeight + 20)
        
        self.waitingTimeLbl.frame = CGRect(x: 40,
                                           y: 12,
                                           width: waitingView.frame.width - 26,
                                           height: labelHeight + 6)
        let imageview = UIImageView(frame: CGRect(x: 5, y: (self.waitingTimeLbl.frame.height / 2) - 3, width: 25, height: 25))
        imageview.image = UIImage(named: "info")
        waitingView.addSubview(imageview)
        waitingView.addSubview(self.waitingTimeLbl)
        waitingView.bringSubviewToFront(self.waitingTimeLbl)
        waitingView.bringSubviewToFront(imageview)

        return waitingView
    }()
    
    func createMap() {
        self.map = GMSMapView()
        guard let map = self.map else { return }
        self.mapLocation.addSubview(map)
        map.anchor(toView: self.mapLocation,
                   leading: 0,
                   trailing: 0,
                   top: 0,
                   bottom: 0)
    }
    
    func remoVeMap() {
        self.map?.removeFromSuperview()
        self.map = nil
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.remoVeMap()
    }
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.attachWaitingTimeView()
        }
    }
    
    func initalSteps() {
        
        locationManager.requestWhenInUseAuthorization()
        self.profileStack.addTap {
            self.onContacttapped()
        }
        currentLocation = locationManager.location
        if currentLocation == nil{
            currentLocation = CLLocation()
        }
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: self.cameraDefaultZoom)
        map?.camera = camera
        self.driverDetailsButton.isUserInteractionEnabled = false
        self.apiInteractor = APIInteractor(self)
        self.initLangugage()
        self.lbltitle.text = langugage.enRoute
        self.initNotifications()
        self.setDesign()
        self.setFonts()
        self.messageIcon.isHidden = true
        self.messageBtn.isHidden = true
        self.messageIconOuter.isHidden = true
        self.messageStack.isHidden = true
        self.messageBtn.setTitle(self.langugage.sendMessage, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if self.bookingType != .manualBooking{
                self.messageIcon.isHidden = false
                self.messageBtn.isHidden = false
                self.messageIconOuter.isHidden = false
                self.messageStack.isHidden = false
                self.messageStack.addTap {
                    self.goToChatVC()
                }
            }
        }
        self.initView()
    }
    
    func setFonts()
    {
        self.lbltitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.etaLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        self.lblLocation.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        self.lblLocation.textColor = .Title
        self.waitingTimeLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 11)
        self.etaLbl.textColor = .white
    
    }
    deinit{
        self.deinitObjects()
    }
    func setDesign()
    {
        self.mapLocation.setSpecificCornersForTop(cornerRadius: 35)
        self.vehicleView.cornerRadius = 10
        self.sosView.cornerRadius = 10
        self.otpView.cornerRadius = 10
        self.vehicleView.backgroundColor = .white
        self.sosView.backgroundColor = .ThemeYellow
        self.otpView.backgroundColor = .ThemeYellow
        self.lblVehicleNumber.backgroundColor = .white
        self.otpLabel.backgroundColor = .ThemeYellow
        self.sosLabel.backgroundColor = .ThemeYellow
        self.lblVehicleNumber.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.sosLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.otpLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
        self.lblVehicleNumber.textColor = .Title
        self.sosLabel.textColor = .Title
        self.lbltitle.textColor = . Title
        self.sosLabel.text = "SOS".localize
        self.otpLabel.textColor = .Title
        viewProfile.backgroundColor = .white
        viewProfile.setSpecificCornersForTop(cornerRadius: 45)
        viewAddressHolder.layer.cornerRadius = 10
        viewAddressHolder.backgroundColor = .white
        imgDriverThumb.cornerRadius = 30
        imgDriverThumb.border(2, UIColor(hex: "eaeaea"))
        imgDriverThumb.clipsToBounds = true
        self.etaView.backgroundColor = .Title
        self.etaView.cornerRadius = 15
        self.locationImg.image = UIImage(named: "map location")?.withRenderingMode(.alwaysTemplate)
        self.locationImg.tintColor = .white
        self.lblDriverName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.lblDriverName.textColor = .Title
        self.lblRating.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.lblVehicleName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.lblVehicleName.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.messageBtn.setTitleColor(.ThemeYellow, for: .normal)
        self.messageBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.messageIcon.image = UIImage(named: "chat")

    }
    /*MARK:-******/
    func deinitObjects(){
        self.deinitNotification()
        updateDriverLocation.invalidate()
        timerDriverLocation.invalidate()
    }
    /*MARK:-******/
    func isPathChanged(byDriver coordinate : CLLocation) -> Bool{
        guard self.path.count() != 0 else{return true}
        
        for range in 0..<path.count(){
            let point = path.coordinate(at: range).location
            if point.distance(from: coordinate) < 75{
                self.driversPositiionAtPath = range
                self.drawRoute(for: self.path)
                return false
            }
        }
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create A Map
        self.createMap()
        
        // Steps For Map Configurations
        self.initalSteps()
    
        
        if !isTripStarted {
            sosView.isHidden = true
            sosLabel.isHidden = true
            sosStack.isHidden = true
            map?.settings.myLocationButton = true
            self.etaLbl.isHidden = false
            self.locationImgCenterConstraint.constant = -10
        } else{
            sosView.isHidden = false
            sosLabel.isHidden = false
            sosStack.isHidden = false
            self.etaLbl.isHidden = true
            self.locationImgCenterConstraint.constant = 0
            map?.settings.myLocationButton = false
        }
        self.navigationController?.isNavigationBarHidden = true
        isPopEexcuted = false
        //yamini hiding it
        DispatchQueue.main.async {
            if let tripData = self.tripDetailModel,!tripData.currencySymbol.isEmpty{
                self.setTripInfo(tripData)
            }else{
                self.getTripDetails()
            }
        }
    }
    func getTripDetails()
    {
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getTripDetail,params: ["trip_id":self.tripID.description])
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let detail = TripDetailDataModel(json)
                    self.tripDetailModel = detail
                    self.tripID = self.tripDetailModel?.id ?? 0
                    self.bookingType = self.tripDetailModel?.bookingType ?? .auto
                    self.tripStatus = self.tripDetailModel?.status ?? .pending
                    self.setTripInfo(detail)//true)
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()
                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })
    }
    //MARK: - Driver Location Tracking
    /*
     Getting driver location from firebase realtime database and pin the marker to right place
     */
    func initView(){
        self.otpLabel.text = "OTP \(self.tripDetailModel != nil ? self.tripDetailModel!.otp : "XXXX")"
        if self.otpLabel.text == "" || self.otpLabel.text == nil {
            self.otpView.backgroundColor = .clear
        }
        moveMent = ARCarMovement()
        moveMent.delegate = self
        ref = Database.database().reference().child(iApp.firebaseEnvironment.rawValue)
        /*MARK:-******/
        self.performRealTimeTracker()
        self.startObservingPathFromFirebase()
        onChangeMapStyle()
        DispatchQueue.main.async {
            UserDefaults.set(self.tripID, for: .current_trip_id)
        }
        self.sosStack.addTap {
            self.sosButtonAction()
        }
        self.mapLocation.setSpecificCornersForTop(cornerRadius: 35)
    }
    func initNotifications(){
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.gotoMainView),
                                               name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrip.rawValue),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.gotoMainView1),
                                               name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrips.rawValue),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.driverCancelledTrip),
                                               name: Notification.Name(rawValue: NotificationTypeEnum.cancel_trips.rawValue),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.gotoHomePage),
                                               name: Notification.Name(rawValue: NotificationTypeEnum.GotoHomePage1.rawValue),
                                               object: nil)
        self.timerForETA = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] (_) in
            self?.calculateETA()
        }
    }
    func deinitNotification(){
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrip.rawValue),
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrips.rawValue),
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: NotificationTypeEnum.cancel_trips.rawValue),
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: NotificationTypeEnum.GotoHomePage1.rawValue),
                                                  object: nil)
        self.timerForETA?.invalidate()
        self.timerForETA = nil
    }
    func initLangugage(){
        self.btnBack.setTitle(self.langugage.getBackBtnText(), for: .normal)
    }
    func onTripStatusChange(){
        guard self.isViewLoaded else{return}
        self.otpLabel.isHidden = self.isTripStarted
        self.etaLbl.isHidden = self.isTripStarted
        self.locationImgCenterConstraint.constant = self.isTripStarted ? 0 : -10
        self.otpView.backgroundColor = self.isTripStarted ? .clear : .ThemeYellow
        self.waitingTimeLbl.text = !self.isTripStarted && self.tripDetailModel != nil
            ? self.tripDetailModel!.appliedWaitingChargeDescription
            : nil
        self.showWaitingTimeView(!self.isTripStarted && self.waitingTimeLbl.text != nil)
    }

    //MARK:- initWithstory
    class func initWithStory() -> RouteVC{
        let view  : RouteVC = UIStoryboard.payment.instantiateViewController()
        view.apiInteractor = APIInteractor(view)
        return view
    }
    
    //MAKR:- UDF
    
    func attachWaitingTimeView(){
        self.waitingTimeLbl.text = "$1/min Waiting Fee applies after 3 mins of arrival till trip starts"
        self.waitingTimeView.cornerRadius = 10
        self.view.addSubview(self.waitingTimeView)
        self.view.bringSubviewToFront(self.waitingTimeView)
        self.view.bringSubviewToFront(self.viewAddressHolder)
        self.waitingTimeView.transform = CGAffineTransform(translationX: 0, y: -self.waitingTimeView.frame.height)
        self.waitingTimeView.isUserInteractionEnabled = false
        self.waitingTimeView.isHidden = true
    }
    func showWaitingTimeView(_ show : Bool){
        guard self.waitingTimeView.isHidden == show else{return}
        self.waitingTimeView.isHidden = false
        UIView.animate(withDuration: 0.6, animations: {
            if show{
                self.waitingTimeView.transform = .identity
            }else{
                self.waitingTimeView.transform = CGAffineTransform(translationX: 0, y: -self.waitingTimeView.frame.height)
            }
        }) { (completed) in
            if completed{
                self.waitingTimeView.isHidden = !show
            }
        }
    }
    func performRealTimeTracker () {
        // yamini hiding it
        guard let tripData = self.tripDetailModel else {
            print("no trip found")
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.ref = Database.database().reference().child(iApp.firebaseEnvironment.rawValue)
                self.performRealTimeTracker()
            }
            return
        }
        ref.removeAllObservers()
        let tracking = self.ref.child(FireBaseNodeKey.live_tracking.rawValue)
        self.postRefHandle =  tracking.child(tripData.description).observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? JSON ?? [:]
            print("∂øƒ",postDict)
            if let lat = postDict["lat"] as? String, let lng =  postDict["lng"] as? String{
                if lat != "" && lng != "" {
                    let driverMod = DriverLocationModel()
                    driverMod.driver_latitude = lat
                    driverMod.driver_longitude = lng
                    if self.tripDetailModel != nil {
                        self.tripDetailModel?.driverLatitude  = postDict.double("lat")
                        self.tripDetailModel?.driverLongitude = postDict.double("lng")
                        
                       
                        DispatchQueue.performAsync(on: .main) { [weak self] in
                            guard let welf = self else{return}
                            if welf.riderCanValidatePathChanges{
                                self?.setRouteAccordingToStaus(skipValidationToHitAPI: false)
                            }else if let welf = self,
                                let tripDetail = welf.tripDetailModel{
                                _ = welf.isPathChanged(byDriver: tripDetail.driverLocation)
                            }
                        }
                    }
                    DispatchQueue.performAsync(on: .main) { [weak self] in
                        self?.moveCarOnMap(driverLocModel:driverMod)
                    }
                    
                }else {
                    
                    self.onGetDriverLocation()
                }
            }
            
            
        }) { (err) in
            
            self.onGetDriverLocation()
        }
    }
    
    // set the status based on the notification
    func setRouteAccordingToStaus(isJustForMarker : Bool = false,skipValidationToHitAPI : Bool){
        guard let tripData = self.tripDetailModel else{return}
        let pickup = tripData.driverLocation.coordinate
        let drop : CLLocationCoordinate2D
        switch tripData.status{
        case .scheduled:
            drop = CLLocationCoordinate2D(latitude: tripData.pickupLatitude,
                                          longitude: tripData.pickupLongitude)
            
        case .beginTrip:
            drop = CLLocationCoordinate2D(latitude: tripData.pickupLatitude,
                                          longitude: tripData.pickupLongitude)
        case .endTrip,.rating:
            isTripStarted = true
            drop = CLLocationCoordinate2D(latitude: tripData.dropLatitude,
                                          longitude: tripData.dropLongitude)
        default:
            drop = CLLocationCoordinate2D(latitude: tripData.dropLatitude,
                                          longitude: tripData.dropLongitude)
        }

        self.onCreateMapMarker(pickUpLatitude: pickup.latitude,
                               pickUpLongitude: pickup.longitude,
                               dropLatitude: drop.latitude,
                               dropLongitude: drop.longitude)
        self.driver_profile_delegate?.setRideStatus(isTripStarted)
        
        if !isJustForMarker {
            
            self.createRoute(pickUpLatitude: pickup.latitude,
                             pickUpLongitude: pickup.longitude,
                             dropLatitude: drop.latitude,
                             dropLongitude: drop.longitude,
                             skipValidationToHitAPI: skipValidationToHitAPI)
        }
       
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // go home page
    @objc func gotoHomePage()
    {
        let info: [AnyHashable: Any] = [
            "cancelled_by" : "NO",
            ]
        
        updateDriverLocation.invalidate()
        timerDriverLocation.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.ShowHomePage.rawValue), object: self, userInfo: info)
    }
    
    //MARK: - WHILE GETTING PUSH NOTIFICATION FROM DRIVER
    /*
     NOTIFICATION TYPE ARRIVE NOW OR BEGIN TRIP STARTED
     */
    
    @objc func gotoMainView(notification: Notification)
    {
        guard let data = tripDetailModel else {
            self.wsToGetTripDetails()
            return
        }
        let str2 = notification.userInfo
        let getNotificationType = str2?["type"] as? String ?? String()
        if getNotificationType == NSLocalizedString("arrivenow", comment: "")
        {
            self.tripDetailModel?.status = TripStatus.beginTrip//.scheduled
                self.tripDataModel.status = TripStatus.beginTrip//.scheduled
            self.tripStatus = TripStatus.beginTrip
            self.setTripInfo(data)//true)
            

        }
       
    }
    //MARK: - WHILE GETTING PUSH NOTIFICATION FROM DRIVER
    /*
     NOTIFICATION TYPE ARRIVE NOW OR BEGIN TRIP STARTED
     */
    @objc func gotoMainView1(notification: Notification)
    {
        guard let data = tripDetailModel else {
           self.wsToGetTripDetails()
           return
        }
        let str2 = notification.userInfo
        let getNotificationType = str2?["type"] as? NotificationTypeEnum
        if sosView.isHidden {
            sosView.isHidden = false
            sosLabel.isHidden = false
            sosStack.isHidden = false
            map?.settings.myLocationButton = false
        }
       

        if getNotificationType == NotificationTypeEnum.begintrip
        {
            self.tripDetailModel?.status = .endTrip
            self.tripDataModel.status = .endTrip
            self.tripStatus = .endTrip
            self.setTripInfo(data)//true)
            if sosView.isHidden {
                sosView.isHidden = true
                sosLabel.isHidden = true
                sosStack.isHidden = false
                map?.settings.myLocationButton = true
            }
        }
        
    }

    
  
    func endTrip(notification: Notification)
    {
        
        updateDriverLocation.invalidate()
        timerDriverLocation.invalidate()
    }
    
    //MARK: - WHILE GETTING DRIVER CANCELLED TRIP PUSH NOTIFICATION FROM DRIVER
    /*
     When driver cancelling trip, that time rider will get apns
     and we have goto home page (i.e Main Map)
     */
    @objc func driverCancelledTrip(notification: Notification)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
        
    }
    // update the driver location to the server
    func onGetDriverLocation()
    {
        var dicts = JSON()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["trip_id"] = self.tripID.description
        self.apiInteractor?
            .getRequest(
                for: APIEnums.getDriverLocation,
                params: dicts
        ).responseJSON({ (json) in
            let driverModel = DriverLocationModel(from: json)
            print(driverModel.driver_latitude,driverModel.driver_longitude)
            if json.isSuccess{}
        }).responseFailure({ (error) in
            print(error)
        })
      
    }
    // SET HE MARKER IN MAP VIEW
    func moveCarOnMap(driverLocModel:DriverLocationModel)
    {
        if driverLocModel.driver_latitude == ""
        {
            return
        }
        let newLocation = CLLocationCoordinate2DMake(Double(driverLocModel.driver_latitude)!, Double(driverLocModel.driver_longitude)!)
        if !isDriverLocationGot {
            driverMarker?.map = nil
            driverMarker?.icon = nil
            driverMarker?.iconView = nil
            driverMarker = nil
            driverMarker = GMSMarker()
            driverMarker?.position = newLocation
            driverMarker?.isFlat = true
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
            imageView.image = UIImage(named: "top view")
            driverMarker?.iconView = imageView

            driverMarker?.map = map
            oldCoordinate = newLocation
            let camera = GMSCameraPosition.camera(withLatitude: newLocation.latitude, longitude: newLocation.longitude, zoom: self.cameraDefaultZoom)
            map?.animate(to: camera)
            isDriverLocationGot = true
            
        }
        if oldCoordinate.latitude.isZero && oldCoordinate.longitude.isZero{
            oldCoordinate = newLocation
        }
        DispatchQueue.performAsync(on: .main) { [weak self] in
            self?.locationChanged(newCoordinate: newLocation)
        }
    }
    
    func locationChanged(newCoordinate:CLLocationCoordinate2D) {
        let new = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        
        let old = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
        
        let distanceInMeters = new.distance(from: old)
        if (distanceInMeters > 15)  {
            moveMent.arCarMovement(marker: driverMarker ?? GMSMarker(), oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, mapView: map ?? GMSMapView(), bearing: 0.0)
            oldCoordinate = newCoordinate
        }
        
    }
    
    var isZoomed = false
    func arCarMovement(_ movedMarker: GMSMarker) {
        driverMarker?.map = nil
        driverMarker?.icon = nil
        driverMarker?.iconView = nil
        driverMarker = movedMarker
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
        imageView.image = UIImage(named: "top view")
        driverMarker?.iconView = imageView

        driverMarker?.map = map
        var updatedCamera = GMSCameraUpdate.setTarget(movedMarker.position)
        if isZoomed == false {
            updatedCamera = GMSCameraUpdate.setTarget(movedMarker.position, zoom: self.cameraDefaultZoom)
            isZoomed = true
        }
        map?.animate(with: updatedCamera)
        self.map?.animate(toBearing: movedMarker.rotation)
    }
    
    
    var isDriverLocationGot = false
    func focusOnCoordinate(coordinate: CLLocationCoordinate2D)
    {
        map?.animate(toLocation: coordinate)
        map?.animate(toBearing: 0)
        map?.animate(toViewingAngle: 0)
    }
    //MARK: - WS to get trip details
    func wsToGetTripDetails(){
        self.getTripDetails()
    }
    
    //MARK: - API CALL -> set driver details from the notifacation
  
    // SETTING DRIVER INFO AFTER API CALL
    func setTripInfo(_ tripData : TripDetailDataModel){
        
        print("∂Setting details from api")
        self.driverDetailsButton.isUserInteractionEnabled = true
        tripData.storeDriverInfo(true)
        
        if Shared.instance.needToShowChatVC{
            self.goToChatVC()
        }
        if tripData.getRating.isZero{
            lblRating.text = ""
            lblDriverName.text = tripData.driverName
        }else {

            let textAtt =  NSMutableAttributedString(string: "\(tripData.driverName) \(tripData.rating) ★")
            textAtt.setColorForText(textToFind: " \(tripData.rating) ★", withColor: .ThemeYellow)
            textAtt.setColorForText(textToFind: "\(tripData.driverName)", withColor: .Title)
            lblRating.attributedText = textAtt
            
        }
        switch tripData.status {
        case .scheduled:
            self.isTripStarted = false
            lblLocation.text = String(format:"%@",tripData.pickupLocation)
        case .beginTrip:
            self.isTripStarted = false
            lblLocation.text = String(format:"%@",tripData.dropLocation)
        case .endTrip,.rating:
            self.isTripStarted = true
            lblLocation.text = String(format:"%@",tripData.dropLocation)
        default:
            self.isTripStarted = false
            lblLocation.text = String(format:"%@",tripData.pickupLocation)
        }
       
        imgDriverThumb.sd_setImage(with: NSURL(string: tripData.driverThumbImage)! as URL)
        lblVehicleName.text = tripData.vehicleName
        lblVehicleNumber.text = tripData.vehicleNumber
        self.otpLabel.text = "OTP " + (!tripData.otp.isEmpty ? tripData.otp : "XXXX")
        if self.otpLabel.text == "" || self.otpLabel.text == nil {
            self.otpView.backgroundColor = .clear
        }
         self.setRouteAccordingToStaus(isJustForMarker: true,skipValidationToHitAPI: false)
        if !isTripStarted {
            sosView.isHidden = true
            sosLabel.isHidden = true
            sosStack.isHidden = true
            map?.settings.myLocationButton = true
            self.etaLbl.isHidden = false
            self.locationImgCenterConstraint.constant = -10
        } else{
            sosView.isHidden = false
            sosLabel.isHidden = false
            sosStack.isHidden = false
            self.etaLbl.isHidden = true
            self.locationImgCenterConstraint.constant = 0
            map?.settings.myLocationButton = false
        }
    }
    
    /*MARK:-******/
    func startObservingPathFromFirebase(){
        let reference = self.ref.child(FireBaseNodeKey.trip.rawValue)
        reference.observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.hasChild(self.tripID.description){
                self.observePathFromFirebase(reference: reference
                                                .child(self.tripID.description)
                    .child(FireBaseNodeKey._polyline_path.rawValue))
                self.observeETAFromFirebase(reference: reference
                                                .child(self.tripID.description)
                    .child(FireBaseNodeKey._eta_min.rawValue))
                
            }else{
                if self.polyline.path == nil{
                    self.setRouteAccordingToStaus(isJustForMarker: true,skipValidationToHitAPI: true)
                }
                DispatchQueue.performAsync(on: .main,
                                           withDelay: .now() + 0.5) {
                                            self.startObservingPathFromFirebase()
                }
            }
        }
    }
    
    /*MARK:-******/
    func observePathFromFirebase(reference: DatabaseReference){
        // yamini hiding it
        reference.observe(.value) { (snapshot) in
            guard let gPAthString = snapshot.value as? String else{
                self.setRouteAccordingToStaus(skipValidationToHitAPI: false)
                return
            }
            //if Driver is in backgroud rider can validate
            self.riderCanValidatePathChanges = gPAthString == "0"
            
            if let gPAthString = snapshot.value as? String,
                gPAthString != "0",
                let gPAth = GMSPath(fromEncodedPath: gPAthString){
                self.path = gPAth
                if self.polyline.path == nil{
                    self.driversPositiionAtPath = 0
                    self.drawRoute(for: gPAth)
                    self.setRouteAccordingToStaus(skipValidationToHitAPI: false)
                }
                if let tripDetail = self.tripDetailModel{
                    _ = self.isPathChanged(byDriver: tripDetail.driverLocation)
                }else{
                    self.setRouteAccordingToStaus(skipValidationToHitAPI: true)
                }
            }else if self.polyline.path == nil{
                self.setRouteAccordingToStaus(skipValidationToHitAPI: true)
            }
        }
        
    }
    
    /*MARK:-******/
    func observeETAFromFirebase(reference: DatabaseReference){
        // yamini hiding it
        reference.observe(.value) { (snapshot) in
          
            if let strETA = snapshot.value as? String,
                let eta = Int(strETA){
                
                self.updateETAView(with: eta)
            }
        }
         
    }
    
    //MARK:- ETA Calculation
       func calculateETA(){
           guard let route = self.currenRouteData,
            self.riderCanValidatePathChanges,
            let driverLocation = tripDetailModel?.driverLocation,
            let steps = route.legs.first?.steps else{return}
           var remainingSecETA : Int? = nil
           for step in steps{
               if let availableETA = remainingSecETA {
                remainingSecETA = availableETA + (step.duration.value )
               }else if (step.startLocation.distance(from: driverLocation) ) < 100{
                remainingSecETA = step.duration.value
               }
           }
           if let secondsETA = remainingSecETA{
               var minutesETA = secondsETA / 60
               if minutesETA < 1{
                   minutesETA = 1
               }
               debug(print: minutesETA.description)
            self.updateETAView(with: minutesETA)
           }
       }
       /*MARK:-******/
    func updateETAView(with minutesETA : Int){
        var etaString = String()
                  let hrs = minutesETA / 60
                  let mins = minutesETA % 60
                  if hrs > 0{
                        
                    etaString.append("\(hrs) \(hrs == 1 ?  self.langugage.hr.lowercased() : self.langugage.hrs.lowercased()) ")
                  }
                  if mins > 1 {
                      etaString.append("\(mins) \(self.langugage.mins.lowercased())")
                  }else{
                    etaString.append("1 \(self.langugage.min.lowercased())")
                  }
                  self.tripDetailModel?.arrivalFromGoogle = etaString
                    
                  self.etaLbl.text = etaString
   
    }
    //MARK: - CALL GOOGLE POLYLINE API
    
    /*
     AND HERE GETTING ROUTE INFORMATION STRING
     */
     /*MARK:-******/
    func createRoute(pickUpLatitude: Double,
                     pickUpLongitude: Double,
                     dropLatitude: Double,
                     dropLongitude: Double,
                     skipValidationToHitAPI : Bool)
    {
        if isZoomed == false {
            let update =  GMSCameraPosition.camera(withLatitude: Double(pickUpLatitude), longitude: Double(pickUpLongitude), zoom: self.cameraDefaultZoom)
                self.map?.animate(to: update)
            isZoomed = true
            var arr = Array(0...100)
        }
        var hitWsToPolyline = false
        if skipValidationToHitAPI {
            hitWsToPolyline = true
        }else if self.polyline.path == nil{
            hitWsToPolyline = true
        }else if let driver = self.tripDetailModel?.driverLocation,
            self.isPathChanged(byDriver: driver){
            hitWsToPolyline = true
        }
        if hitWsToPolyline{
            let timeDifference = Date().timeIntervalSince(self.lastDirectionAPIHitStamp ?? Date())
                   guard self.lastDirectionAPIHitStamp == nil || timeDifference > 15 else{return}
            self.wsToHitAPIForPolyLine(pickUpLatitude: pickUpLatitude,
                                       pickUpLongitude: pickUpLongitude,
                                       dropLatitude: dropLatitude,
                                       dropLongitude: dropLongitude)
        }
        
      
    }
    func wsToHitAPIForPolyLine(pickUpLatitude : Double,
                               pickUpLongitude : Double,
                               dropLatitude : Double,
                               dropLongitude : Double){
        self.lastDirectionAPIHitStamp = Date()
        let count = UserDefaults.value(for: .direction_hit_count) ?? 0
        UserDefaults.set(count + 1, for: .direction_hit_count)
        DispatchQueue.main.async { [weak self] in
           self?.apiInteractor?
            .getRequest(forAPI: "https://maps.googleapis.com/maps/api/directions/json",
                        params: [
                            "origin" : "\(pickUpLatitude),\(pickUpLongitude)",
                            "destination" :"\(dropLatitude),\(dropLongitude)",
                            "mode" : "driving",
                            "units" : "metric",
                            "sensor" : "true",
                            "key" : iApp.instance.GoogleApiKey
                        ], CacheAttribute: .none)
            .responseDecode(to: GoogleGeocode.self, { [weak self] (googleGecode) in
                guard let welf = self,
                    let route = googleGecode.routes.first,
                    let leg = route.legs.first else{return}
                welf.tripDetailModel?.arrivalFromGoogle = leg.duration.text ?? ""
                welf.drawRoute(forRoute: route)
                welf.calculateETA()
            })
            .responseJSON({ (json) in
                debugPrint(json.description)
            })
            .responseFailure({ (error) in
                debug(print: error)
            })
         

        }
    }
 
    // DRAWING ROUTE ON GOOGLE MAP WITH POLYLINE POINTS
    /*MARK:-******/
    func drawRoute(forRoute route: Route)
    {
         self.currenRouteData = route
        let points = route.overviewPolyline.points
        if let newPath = GMSPath(fromEncodedPath: points){
            self.path = newPath
            self.driversPositiionAtPath = 0
            self.drawRoute(for: path)
        }
    }
    func drawRoute(for path : GMSPath){
        let drawingPath = GMSMutablePath()
        if riderCanValidatePathChanges {
            debug(print: self.driversPositiionAtPath.description + ": "+path.count().description)
        }
        for i in self.driversPositiionAtPath..<path.count(){
            drawingPath.add(path.coordinate(at: i))
        }
        self.polyline.path = drawingPath
        self.polyline.strokeColor = UIColor.ThemeYellow
        self.polyline.strokeWidth = 3.0
        self.polyline.map = map
    }
    
    var marker2 : GMSMarker?
    var marker1 : GMSMarker?
    
    //MARK: - Create Map Marker
    func onCreateMapMarker(pickUpLatitude: Double,
                           pickUpLongitude: Double,
                           dropLatitude: Double,
                           dropLongitude: Double)
    {
        if driverMarker?.map == nil || driverMarker?.icon == nil || driverMarker == nil{
            driverMarker?.map = nil
            driverMarker?.icon = nil
            driverMarker?.iconView = nil
            driverMarker = GMSMarker()
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
            imageView.image = UIImage(named: "top view")
            driverMarker?.iconView = imageView
            driverMarker?.isFlat = true
            driverMarker?.map = map
            let newLocation = CLLocationCoordinate2DMake(Double(tripDetailModel?.driverLatitude ?? 0)
                                                         ,
                                                         Double(tripDetailModel?.driverLongitude ?? 0)
            )
            driverMarker?.position = newLocation
        }
        self.marker1?.map = nil
        self.marker1?.icon = nil
        self.marker2?.map = nil
        self.marker2?.icon = nil
        
      
//        if !self.tripDataModel.status.isTripStarted {//!self.isTripStarted
        if !self.tripStatus.isTripStarted {
            marker1 = GMSMarker()
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            imageView.image = UIImage(named: "circle")
            marker1?.iconView = imageView
            marker1?.map = map
            marker1?.position = CLLocationCoordinate2D(latitude: tripDetailModel?.pickupLatitude ?? 0.0, longitude: tripDetailModel?.pickupLongitude ?? 0.0)
            marker1!.userData =  ""
            marker1!.title = ""
            marker1!.snippet = ""
            marker1?.map = map
            self.map?.selectedMarker = marker1
        } else {
            
            marker2 = GMSMarker()
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            imageView.image = UIImage(named: "box")
            marker2?.iconView = imageView
            marker2?.map = map
            marker2?.position = CLLocationCoordinate2D(latitude: Double(dropLatitude), longitude: Double(dropLongitude))
        }
    }
    
    // MARK: When User View Profile Driver
    @IBAction func onContacttapped()
    {
        guard let tripDetail = self.tripDetailModel else{
            self.wsToGetTripDetails()
            return
        }
        if tripDetail.arrivalFromGoogle == nil || tripDetail.arrivalFromGoogle != self.etaLbl.text{
            tripDetail.arrivalFromGoogle = self.etaLbl.text
        }
        let viewLoc = DriverProfileVC.initWithStory(for: tripDetail, isTripStarted: isTripStarted)
        viewLoc.tripDetailModel = tripDetailModel
        viewLoc.isTripStarted = isTripStarted
        self.driver_profile_delegate = viewLoc
        self.navigationController?.pushViewController(viewLoc, animated: true)
        
    }
    
    func sosButtonAction() {
        let sosVC:SOSViewController = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        self.presentInFullScreen(sosVC, animated: true, completion: nil)
    }
    
    @IBAction func goToChatVC(){
       //
        guard self.tripDetailModel != nil else {return}
        guard let data = self.tripDetailModel else {return}
        let chatVC = ChatVC.initWithStory(withTripId: data.id.description,
                                          driverRating: data.getRating,
                                          driver_id: data.driverId)
        
        chatVC.drivername = data.driverName
        chatVC.driverImage = self.imgDriverThumb.image
        self.navigationController?
                    .pushViewController(chatVC,
                                        animated: true)
    }
    // MARK: When User Back
    @IBAction func onBacktapped(_ sender:UIButton!)
    {
        self.deinitObjects()
        self.updateTripHistory?.updateContent()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    //Mark: - Change Map Style
    /*
     Here we are changing the Map style from ub__map_style Json File
     */
    func onChangeMapStyle()
    {
        do {
            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if let styleURL = Bundle.main.url(forResource: "mapStyleChanged", withExtension: "json")
            {
                map?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            }
            else
            {
            }
        } catch {
        }
        
    }
    
}
extension UIViewController {
    func checkMobileNumeber(isDirectCall:Bool = false) {
        
        guard let number : String = UserDefaults.value(for: .admin_mobile_number) else{return}
        let contactNumber = number.split(separator: " ").last ?? ""
        let language = Language.default.object
        if number == "" {
            self.presentAlertWithTitle(title: language.noContactFound,
                                       message: "",
                                       options: language.ok) { (index) in
                                        switch index {
                                            
                                        default:
                                            break
                                        }
            }
        }
        else {
            if isDirectCall {
                if let phoneCallURL = URL(string:"tel://\(contactNumber)") {
                    let application:UIApplication = UIApplication.shared
                    if (application.canOpenURL(phoneCallURL)) {
                        application.openURL(phoneCallURL);
                    }
                }
            }
            else {
                self.presentAlertWithTitle(title: language.dial.capitalized + "\(number)",
                    message: language.contactAdmin,//"Contact admin for manual booking".localize
                    options: language.no.capitalized,language.yes.capitalized) { (index) in
                        switch index{
                        case 1:
                            if let phoneCallURL = URL(string:"tel://\(contactNumber)") {
                                let application:UIApplication = UIApplication.shared
                                if (application.canOpenURL(phoneCallURL)) {
                                    application.openURL(phoneCallURL);
                                }
                            }
                        default:
                            break
                        }
                }
            }
        }
        
    }
}
