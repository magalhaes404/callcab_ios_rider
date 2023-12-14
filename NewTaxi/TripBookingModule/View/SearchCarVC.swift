/**
 * CarAvailableVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit
import Foundation
import GoogleMaps
import Network

protocol carAvailbleDelegate
{
    func onmakeanimation()
}

class SearchCarVC : UIViewController,UIGestureRecognizerDelegate, GMSMapViewDelegate, setLocationDelegate,UICollectionViewDelegate, UICollectionViewDataSource,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    @IBOutlet weak var changeLocation: UIButton!
    weak var appDelegate  = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var viewObjectHolder: UIView!
    @IBOutlet weak var googleMapView: UIView!
    @IBOutlet weak var collectionCarDetails: UICollectionView!
    @IBOutlet weak var viewEditLocHolder: UIView!
    @IBOutlet weak var promolab: UILabel!
    @IBOutlet weak var cashlab: UILabel!
    @IBOutlet weak var paymentimg: UIImageView!
    @IBOutlet weak var walletimg: UIImageView!
    @IBOutlet weak var btnRequestNewTaxi: UIButton!
    @IBOutlet weak var viewRefresh: UIView!
    @IBOutlet weak var viewSpinnerHolder: UIView!
    @IBOutlet weak var lblNoCarsMsg: UILabel!
    @IBOutlet weak var cashView: UIView!
    @IBOutlet weak var waitingChargeLbl : UILabel!
    @IBOutlet weak var changePaymentBtn : UIButton!
    @IBOutlet weak var gettingCablbl : UILabel!
    
    //gender
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var preferenceTable: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var preferencePopupView: UIView!
    @IBOutlet weak var savePrefernceBtn: UIButton!
    var profileModel : RiderDataModel? = nil
    @IBOutlet weak var preferenceTableHeight: NSLayoutConstraint!
    var tempProfileModel : RiderDataModel? = nil
    let mainCellHeight : CGFloat = 40

    
 
    @IBOutlet weak var refreshBtn: UIButton!
    var driverLTManger : DriverLiveTrackingManager?
     var locationManager = CLLocationManager()
     var currentLocation: CLLocation!

    
    var imgCarThumbRect:CGRect = CGRect.zero
    var isRouteDraw:Bool = false
    lazy var lang = Language.default.object
    var pickUpLatitude: CLLocationDegrees = 0.0
    var pickUpLongitude: CLLocationDegrees = 0.0
    var dropLatitude: CLLocationDegrees = 0.0
    var dropLongitude: CLLocationDegrees = 0.0
    
    
    lazy var polyline = GMSPolyline()
    lazy var animationPolyline = GMSPolyline()
    lazy var path : GMSPath? = nil
    lazy var animationPath = GMSMutablePath()
    var delegate: carAvailbleDelegate?
    lazy var spinnerView = JTMaterialSpinner()
//    var polyLineRoute : NSDictionary = NSDictionary()
   // var dictSearchCarList : NSMutableDictionary = NSMutableDictionary()
    lazy var availableCars = [SearchCarsModel]()
    
    @IBOutlet weak var editLocImg: UIImageView!
    var viewNewTaxiLoader = NewTaxiLoader()
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var showingSeatsView = true
    var carTag: Int = 0
    var carCount: Int = 0
    var i: UInt = 0
    var timer: Timer?
    var orgCarID = ""
    var strPoints = ""
    var strCarType = ""
    var promo = ""
    var dropLocName = ""
    var pickUpLocName = ""
    var scheduledTime:String?
    var estimatedFareString = String()

    lazy var pickupMarker = GMSMarker()
    lazy var dropMarker = GMSMarker()
    
    var pushManager: PushNotificationManager!
    
    lazy var seatSelectionView : SeatSelectionView = {
        let selectionView = SeatSelectionView.getView(self)
        let refFrame = self.viewObjectHolder.frame
        selectionView.frame = CGRect(x: refFrame.minX,
                                     y: refFrame.minY - self.view.safeAreaInsets.bottom,
                                     width: refFrame.width,
                                     height: refFrame.height + self.view.safeAreaInsets.bottom)
        return selectionView
    }()
    
    var map : GMSMapView?
    
    func createMap() {
        
        //Display Current location while loading:
        self.apiInteractor = APIInteractor(self)
        
        self.map = GMSMapView()
        guard let map = self.map else { return }
        self.driverLTManger = DriverLiveTrackingManager(map,
                                                        viewController: self,
                                                        focusLocation: CLLocation(latitude: self.pickUpLatitude,
                                                                                  longitude: self.pickUpLongitude))
        self.googleMapView.addSubview(map)
        map.anchor(toView: self.googleMapView,
                   leading: 0,
                   trailing: 0,
                   top: 0,
                   bottom: 0)
        self.onChangeMapStyle()
        self.startLoader()
        
        self.callAPIForSearchNearestCars()
        self.updatePaymentData()
        self.preferenceTable.delegate = self
        self.preferenceTable.dataSource = self
        self.updatefilterIcon()
        self.initView()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.initLayer()
        }
        self.setFonts()
        self.viewObjectHolder.setSpecificCornersForTop(cornerRadius: 35)
        
    }
    
    func removeMap() {
        self.map?.removeFromSuperview()
        self.map = nil
    }
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "Schedule_covid"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "Request_covid"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoScheduleScreen(_:)), name: NSNotification.Name(rawValue: "Schedule_covid"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoRequestView(_:)), name: NSNotification.Name(rawValue: "Request_covid"), object: nil)


        self.initLanguage()
        self.createMap()
        self.updateApi()
    }
    @objc func gotoScheduleScreen(_ notification: NSNotification) {
        
        if let params = notification.userInfo?["params"] as? JSON,let time = notification.userInfo?["time"] as? String {
            self.goToScheduleScreen(dicts: params, scheduletime: time)
        }
       }
    @objc func gotoRequestView(_ notification: NSNotification) {
        
        if let params = notification.userInfo?["params"] as? JSON {
            self.gotoGettingNearCarView(params)
        }
       }
    func setFonts()
    {
        self.googleMapView.setSpecificCornersForTop(cornerRadius: 35)
        self.filterView.setSpecificCornersForTop(cornerRadius: 35)
        self.editLocImg.image = #imageLiteral(resourceName: "arrow right")
        self.editLocImg.transform = self.lang.isRTLLanguage() ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
        self.waitingChargeLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.waitingChargeLbl.textColor = .Title
        self.changeLocation.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.changeLocation.titleLabel?.textColor = .DarkTitle
        self.changeLocation.setTitle(self.lang.changeLocation, for: .normal)
        self.changePaymentBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.changePaymentBtn.setTitleColor(.Title, for: .normal)
        self.cashlab.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.cashlab.textColor = .Title
        self.promolab.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.promolab.textColor = .Title
        self.btnRequestNewTaxi.cornerRadius = 15
        self.btnRequestNewTaxi.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.btnRequestNewTaxi.setTitleColor(.Title, for: .normal) 
        self.refreshBtn.backgroundColor = .Title
        self.refreshBtn.setImage(#imageLiteral(resourceName: "re-load"), for: .normal)
        self.refreshBtn.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.refreshBtn.cornerRadius = 15
        self.filterButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.savePrefernceBtn.cornerRadius = 15
        self.savePrefernceBtn.backgroundColor = .ThemeYellow
        self.savePrefernceBtn.setTitleColor(.Title, for: .normal)
        self.savePrefernceBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.savePrefernceBtn.setTitle(self.lang.save.uppercased(), for: .normal)
        self.promolab.cornerRadius = 8
    }
    deinit{
        self.deinitObjects()
       debug(print: "Called")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
//        self.deinitObjects()
        debug(print: "Called")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.removeMap()
    }
    func initView(){
        locationManager.requestWhenInUseAuthorization()
        currentLocation = locationManager.location
        if currentLocation != nil {
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 16.5)
            map?.camera = camera
        }
        promolab.isHidden = true
        cashlab.isHidden = true
        viewSpinnerHolder.isHidden = true
//        viewRefresh.layer.borderWidth = 1.0
//        viewRefresh.layer.borderColor = UIColor.black.cgColor
        googleMapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - viewObjectHolder.frame.size.height)
//        viewEditLocHolder.layer.cornerRadius = viewEditLocHolder.frame.size.height / 2
//        viewEditLocHolder.clipsToBounds = true
//        viewEditLocHolder.backgroundColor = UIColor.white
//        var rectView = viewEditLocHolder.frame
//        rectView.origin.y = viewObjectHolder.frame.origin.y - 70
//        viewEditLocHolder.frame = rectView
        
        self.waitingChargeLbl.text = ""
        
    }
    func deinitObjects(){
        self.timer?.invalidate()
        if self.map != nil{
            self.map?.clear()
            self.map?.delegate = nil
        }
    }
    func updatePaymentData(){
        self.apiInteractor?
            .getRequest(for: APIEnums.getPaymentOptions,
                        params: ["is_wallet":"0"])
            .responseDecode(to: PaymentList.self,
                            { (list) in
                                self.payView()
            })
    }
    func initLayer(){
        

        self.view.addSubview(self.seatSelectionView)
        self.view.bringSubviewToFront(self.seatSelectionView)
        self.viewObjectHolder.frame = self.seatSelectionView.frame
        self.showSeatSelectionView(false, duration: 0)
    }
    class func initWithStory() -> SearchCarVC{
        return UIStoryboard.payment.instantiateViewController()
    }
    func showSeatSelectionView(_ show : Bool,duration : TimeInterval = 0.6){
        guard show != (self.seatSelectionView.transform == .identity) else{return}
        let safeHeight = self.view.safeAreaInsets.bottom
        self.collectionCarDetails.isHidden = show
        UIView.animate(withDuration: duration) {
            if show{
                if let car = self.selectedCar{
                    self.seatSelectionView.setData(forCar: car)
                }
                self.seatSelectionView.transform = .identity
            }else{
                self.seatSelectionView.transform = CGAffineTransform(translationX: 0,
                                                                     y: self.seatSelectionView.frame.height + self.view.safeAreaInsets.bottom)
            }
            self.seatSelectionView.seatCollectionView.reloadData()
            self.seatSelectionView.layoutIfNeeded()
        }
    }
    //Get Promo code status
    func updateApi()
    {
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getPromoDetails)
            .responseDecode(
                to: PromoContainerModel.self,
                { (container) in
                    UberSupport.shared.removeProgressInWindow()
                    self.payView()
                    
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
            })
        
        
    }
    func initLanguage(){
        self.changePaymentBtn.setTitle(self.lang.change, for: .normal)
        self.gettingCablbl.text = self.lang.gettingCabs
        self.btnRequestNewTaxi.setTitle(self.lang.request + " ...", for: .normal)
        self.backBtn.setTitle(self.lang.getBackBtnText(), for: .normal)
    }
    // Show the Payment method View
    func payView(){
        if Constants().GETVALUE(keyname: USER_PROMO_CODE) != "0" && Constants().GETVALUE(keyname: USER_PROMO_CODE) != ""{
            cashlab.isHidden = true
            promolab.isHidden = false
            promolab.text = self.lang.promoApplied
        }
        else{
            cashlab.isHidden = false
            promolab.isHidden = true
        }
        print("payment method \(PaymentOptions.default)")
     
        switch PaymentOptions.default {
        case .cash:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"Currency")!
            cashlab.text = self.lang.cash
        case .paypal:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"paypal.png")!
            cashlab.text = self.lang.paypal
        case .stripe:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"card")!.withRenderingMode(.alwaysTemplate)
            paymentimg.tintColor = .ThemeYellow
            cashlab.text = self.lang.card
            
            if let last4 : String = UserDefaults.value(for: .card_last_4),
                !last4.isEmpty,
                let brand : String = UserDefaults.value(for: .card_brand_name){
                cashlab.text  = "**** "+last4
              
                paymentimg.image = self.getCardImage(forBrand: brand)
                paymentimg.tintColor = .ThemeYellow
            }
        case .brainTree:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"braintree")!
            cashlab.text = UserDefaults.value(for: .brain_tree_display_name) ?? self.lang.onlinePay
        case .onlinepayment:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"onlinePay")!
            cashlab.text = self.lang.onlinePayment

        default:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"Currency")!
            cashlab.text = self.lang.cash
        }

        if Constants().GETVALUE(keyname: USER_SELECT_WALLET) == "Yes"{
            walletimg.image = UIImage(named:"walletUpdated")!
           walletimg.isHidden = false
        }
        else{
            walletimg.isHidden = true
        }
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if self.timer != nil
        {
            self.timer?.invalidate()
        }
    }
    // Preferences functionality
    func updatefilterIcon()
    {
       
        if let request =  self.profileModel?.requestOptions.filter({$0.isSelected}).compactMap({$0.id.description}){
            if request.count == 0{
                self.filterButton.setImage(#imageLiteral(resourceName: "Filter"), for: .normal)
                self.filterButton.tintColor = .Title
            }else{
//                self.filterButton.setImage(#imageLiteral(resourceName: "filter-on"), for: .normal)
                self.filterButton.setImage(#imageLiteral(resourceName: "Filter"), for: .normal)
                self.filterButton.tintColor = .ThemeYellow
            }
        }
    }
    @IBAction func savePreferencesBtnAction(_ sender: Any) {
        dump(self.profileModel)
        if self.tempProfileModel !=  nil{
            self.profileModel?.update(fromData: self.tempProfileModel!)
        }
        dump(self.profileModel)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        
        var dicts = JSON()
        if let requests = self.tempProfileModel?.requestOptions
            .filter({$0.isSelected})
            .compactMap({$0.id.description}){
            dicts["options"] = requests.joined(separator: ",")
        }
        
        self.apiInteractor?
            .getRequest(
                for: APIEnums.riderProfile,
                params: dicts)
            .responseJSON({ (json) in
                UberSupport.shared.removeProgressInWindow()
                if !json.isSuccess{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }else{
                    self.preferencePopupView.isHidden = true
                    self.updatefilterIcon()
                    self.refreshMap()
                }
            }).responseFailure({ (error) in
                if error != ""
                {
                    UberSupport.shared.removeProgressInWindow()
                    AppDelegate.shared.createToastMessage(error)
                }
            })
    }
    @objc func dismissOnTapOutside(){
        self.preferencePopupView.isHidden = true
    }
  
    @IBAction func filterBtnAction(_ sender: Any) {
        guard let model = self.profileModel else {return}
        self.tempProfileModel = RiderDataModel(copy: model)
        self.preferencePopupView.isHidden = false
        self.filterView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        let oldColor = self.preferencePopupView.backgroundColor
        self.preferencePopupView.backgroundColor = .clear
        self.preferenceTableHeight.constant = CGFloat(self.tempProfileModel?.requestOptions.count ?? 0) * self.mainCellHeight
        self.filterView.frame = CGRect(x: 0, y: self.preferencePopupView.frame.size.height - self.filterView.frame.size.height, width: self.preferencePopupView.frame.width, height: self.filterView.frame.size.height)
        self.preferencePopupView.addSubview(self.filterView)
        self.preferencePopupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        self.view.addSubview(self.preferencePopupView)
        self.preferenceTable.reloadData()
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.filterView.transform = .identity
            })
            UIView.addKeyframe(withRelativeStartTime: 2.5/3, relativeDuration: 1, animations: {
                self.preferencePopupView.backgroundColor = oldColor
            })
        }, completion: { (completed) in
            guard completed else {return}
        })
    }
    // MARK - WHEN USER PRESS EDIT LOCAITON BUTTON
    @IBAction func goToEditLocation()
    {
        let viewRequest : SetLocationVC = .initWithStory()
        viewRequest.isFromCarAvailablePage = true
        viewRequest.delegate = self
        viewRequest.strPickUpLocation = pickUpLocName
        viewRequest.strDropLocation = dropLocName
        viewRequest.pickUpLatitude = pickUpLatitude
        viewRequest.pickUpLongitude = pickUpLongitude
        viewRequest.dropLatitude = dropLatitude
        viewRequest.dropLongitude = dropLongitude
        viewRequest.scheduledTime = self.scheduledTime
        self.navigationController?.pushViewController(viewRequest, animated: true)
    }
    
    // MARK - SETLOCATION DELEGATE
    // EDIT LOCATION (SETLOCAITONVC) DELEGATE AFTER EDITED LOCAITON
    func onExitSetLocation(from viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
    internal func onLocationTapped(pickUpLatitude: CLLocationDegrees, pickUpLongitude: CLLocationDegrees, dropLatitude: CLLocationDegrees, dropLongitude: CLLocationDegrees,dropLocName: String, pickUpLocName: String, scheduledTime:String?)
    {
        self.path = nil
        if self.timer != nil
        {
            self.timer?.invalidate()
        }
        self.pickUpLatitude = pickUpLatitude
        self.pickUpLongitude = pickUpLongitude
        self.dropLatitude = dropLatitude
        self.dropLongitude = dropLongitude
        self.dropLocName = dropLocName
        self.pickUpLocName = pickUpLocName
        self.scheduledTime = scheduledTime
        self.startLoader()
        map?.clear()
        self.callAPIForSearchNearestCars()
    }
    
    // start the Loader
    func startLoader()
    {
        self.map?.clear()
        let tempMarker = GMSMarker()
        tempMarker.map = map
        
        viewObjectHolder.addSubview(viewNewTaxiLoader)
        viewNewTaxiLoader.frame = CGRect(x: 0, y: 0, width: viewObjectHolder.frame.size.width, height: 2)
        viewNewTaxiLoader.beginRefreshing()
    }
    
    
    // MARK: When User Press Cash Button
    
    @IBAction func CashAction(_ sender: Any) {
        
        let tripView = SelectPaymentMethodVC.initWithStory(showingPaymentMethods: true, wallet: true, promotions: true)
        tripView.paymentSelectionDelegate = self
        self.navigationController?.pushViewController(tripView, animated: true)
    }
    
    // MARK: CALLING API - SEARCHING NEAREST CARS
    /*
     HERE PASSING PICKUP AND DROP LATITUDE, LONGITUDE FROM SETLOCATION PAGE
     */
    func callAPIForSearchNearestCars()
    {
        self.lblNoCarsMsg.text = ""
        self.lblNoCarsMsg.isHidden = true
        btnRequestNewTaxi.isUserInteractionEnabled = false
        btnRequestNewTaxi.backgroundColor = UIColor.ThemeYellow
        viewRefresh.isUserInteractionEnabled = false
        var localTimeZoneName: String { return TimeZone.current.identifier }
        var dicts = JSON()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["user_id"] = Constants().GETVALUE(keyname: USER_ID)
        dicts["pickup_latitude"] = String(format:"%f",pickUpLatitude)
        dicts["pickup_longitude"] = String(format:"%f",pickUpLongitude)
        dicts["drop_latitude"] = String(format:"%f",dropLatitude)
        dicts["drop_longitude"] = String(format:"%f",dropLongitude)
        dicts["car_id"] = "1"
        if let _scheduleTime = self.scheduledTime{
            let (date,time) = getDate_Time(fromString: _scheduleTime)
            dicts["schedule_date"] = date
            dicts["schedule_time"] = time
            dicts["is_schedule"] = 1
        }else{
            dicts["is_schedule"] = 0
        }
        dicts["payment_method"] = PaymentOptions.default?.paramValue ?? "cash"
        dicts["timezone"] = localTimeZoneName
        dicts["is_wallet"] = Constants().GETVALUE(keyname: USER_SELECT_WALLET)
        self.apiInteractor?
            .getRequest(
                for: APIEnums.searchCars,
                params: dicts
        ).responseJSON({ (json) in
            self.handleSearchCarResponse(json)
        }).responseFailure({ (error) in
        self.removeSpinnerProgress()
        self.viewNewTaxiLoader.endRefreshing()
        self.viewRefresh.isUserInteractionEnabled = true
        self.btnRequestNewTaxi.isUserInteractionEnabled = false
        self.btnRequestNewTaxi.backgroundColor = UIColor.ThemeInactive
        self.appDelegate?.createToastMessage(iApp.NewTaxiError.server.localizedDescription, bgColor: UIColor.ThemeYellow, textColor: UIColor.white)
        })
       
    }
    func handleSearchCarResponse(_ json : JSON){
        let nearestCars = json.json("nearest_car")
        let dumKeys = nearestCars.keys
        let cars = dumKeys.compactMap({SearchCarsModel(nearestCars.json($0))})
        
        let sortedCars = cars.sorted { (car1, car2) -> Bool in
            guard let car1_min_time = Int(car1.min_time)else{
                return false
            }
            guard let car2_min_time = Int(car2.min_time) else{
                return true
            }
            return car1_min_time <= car2_min_time
        }
        
        self.addSubviewContactAdmin(isRemove: true)
        if self.availableCars.count > 0
        {
            //  self.dictSearchCarList.removeAllObjects()
            self.availableCars.removeAll()
        }
        
        if json.status_code == 2
        {
            self.addSubviewContactAdmin()
            
            
            self.map?.clear()
            self.btnRequestNewTaxi.isUserInteractionEnabled = false
            self.btnRequestNewTaxi.backgroundColor = UIColor.ThemeInactive
            self.lblNoCarsMsg.text = json.status_message
            self.lblNoCarsMsg.isHidden = false
        }
        else if json.status_code == 1
        {
          
            // self.dictSearchCarList = tempCars
            self.availableCars = sortedCars
            self.setCarInfoAndShowRoute()
            if self.availableCars.first?.driverIDS.count ?? 0 > 0 {
                self.btnRequestNewTaxi.isUserInteractionEnabled = true
                self.btnRequestNewTaxi.backgroundColor = UIColor.ThemeYellow
            }else{
                self.btnRequestNewTaxi.isUserInteractionEnabled = false
                self.btnRequestNewTaxi.backgroundColor = UIColor.ThemeInactive
            }
            
        }
        else
        {
            
            self.btnRequestNewTaxi.isUserInteractionEnabled = false
            self.btnRequestNewTaxi.backgroundColor = UIColor.ThemeInactive
            self.lblNoCarsMsg.text = self.lang.noCarAvailable
            self.lblNoCarsMsg.isHidden = false
            self.cashView.isHidden = true
        
                if json.status_message != "No cars found"
                {
                    self.appDelegate?.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.white)
                }
            
            
            
        }
        self.collectionCarDetails.reloadData()
        self.viewNewTaxiLoader.endRefreshing()
        self.removeSpinnerProgress()
        self.viewRefresh.isUserInteractionEnabled = true
    }
    func addSubviewContactAdmin(isRemove:Bool = false) {
        let imageview = UIImageView()
        imageview.frame = CGRect(x: self.view.frame.width-60, y: self.map!.frame.height - 69, width: 50, height: 50)
        

        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.callAdmin))
        imageview.addGestureRecognizer(gesture)
        imageview.isUserInteractionEnabled = true
        imageview.backgroundColor = .white
        imageview.isRoundCorner = true
        imageview.image = UIImage(named: "contact_admin")
        if !isRemove {
            if !self.view.subviews.contains(imageview) {
                self.view.addSubview(imageview)
                self.view.bringSubviewToFront(imageview)
            }
        }
        else if isRemove {
            if self.view.subviews.contains(imageview) {
                imageview.removeFromSuperview()
            }
        }
        
    }
   @objc func callAdmin() {
        self.checkMobileNumeber(isDirectCall: false)
    }
    
    // set the aviable car
    func setCarInfoAndShowRoute()
    {
        self.collectionCarDetails.reloadData()
        
        if let firstCar = self.availableCars.first{
            carTag = Int(firstCar.car_id) ?? Int()
            strCarType = firstCar.car_name
            estimatedFareString = firstCar.fare_estimation
            self.gotoCarDetailPage(selectedCar: firstCar)
            let nextIndex = IndexPath(row: 0, section: 0)
            collectionCarDetails.scrollToItem(at: nextIndex, at: .right, animated: true)
        }
  
        self.showRoute()
    }
    
    func showRoute()
    {
        if let gPath = self.path {
            self.drawRoute(with: gPath)
        }else{
            self.animatePolyLine(pickUpLatitude: pickUpLatitude, pickUpLongitude: pickUpLongitude, dropLatitude: dropLatitude, dropLongitude: dropLongitude)
        }
    }
    
    func gotoCarDetailPage(selectedCar: SearchCarsModel,seatCount : Int? = nil)
    {
        
        if scheduledTime == nil {
            btnRequestNewTaxi.setTitle(String(format:"\(self.lang.request) %@",strCarType.uppercased()), for: .normal)
            btnRequestNewTaxi.titleLabel?.text = String(format:"\(self.lang.request) %@",strCarType.uppercased())
        }
        else {
            
            for view in btnRequestNewTaxi.subviews {
                view.removeFromSuperview()
            }
            
            btnRequestNewTaxi.setTitle("", for: .normal)
            let title = UILabel(frame: CGRect(x: 1, y: 0, width: btnRequestNewTaxi.frame.size.width, height: (btnRequestNewTaxi.frame.size.height / 2) - 1))
            title.backgroundColor = UIColor.clear
            if let aSize = UIFont(name: "Chalkboard", size: 14) {
                title.font = aSize
            }
            title.font = UIFont(name: iApp.NewTaxiFont.medium.rawValue, size: CGFloat(14))
            title.text = String(format:"\(self.lang.request) %@",strCarType.uppercased())
            title.textColor = UIColor.white
            title.textAlignment = .center
            btnRequestNewTaxi.addSubview(title)
            let subtitle = UILabel(frame: CGRect(x: 0, y: title.frame.size.height + 1, width: btnRequestNewTaxi.frame.size.width, height: (btnRequestNewTaxi.frame.size.height / 2) - 1))
            subtitle.backgroundColor = UIColor.clear
            if let aSize = UIFont(name: "Helvetica", size: 14) {
                subtitle.font = aSize
            }
            subtitle.font = UIFont(name: iApp.NewTaxiFont.medium.rawValue, size: CGFloat(10))
            subtitle.text = scheduledTime
            subtitle.textColor = UIColor.white
            subtitle.textAlignment = .center
            btnRequestNewTaxi.addSubview(subtitle)
        }
        
        let car = selectedCar
        
        
        orgCarID = car.car_id
        carCount = car.arrcCarLocations.count
        
        
        
        self.waitingChargeLbl.text = car.appliedWaitingChargeDescription
        if let gPath = self.path{
            self.map?.clear()
            self.drawRoute(with: gPath)
        }
        if car.driverIDS.count == 0
        {
            
            
            
            btnRequestNewTaxi.isUserInteractionEnabled = false
            btnRequestNewTaxi.backgroundColor = UIColor.ThemeInactive
            self.waitingChargeLbl.text = nil
            let tit = self.lang.noCabs
            appDelegate?.createToastMessage(tit, bgColor: UIColor.ThemeYellow, textColor: UIColor.white)
            self.driverLTManger?.stopUpdating()
        }
        else
        {
            btnRequestNewTaxi.isUserInteractionEnabled = true
            btnRequestNewTaxi.backgroundColor = UIColor.ThemeYellow
            self.driverLTManger?.startUpdating(withFilter: car.driverIDS)
            
            
//            self.displayNearestCarsInMapView(car.arrcCarLocations, car_id: car.car_id)
        }

        
          if selectedCar.shareRideEnabled{
              self.btnRequestNewTaxi.setTitle(self.lang.confirmSeats.capitalized,
                                            for: .normal)
          }
        
    }
    
    func zoomCarImage(_ sender: UIImageView!, frame:CGRect)
    {
        UIView.animate(withDuration:  0.9, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            sender.frame = frame
        }, completion: { (finished: Bool) -> Void in
        })
    }
    
    func zoomOutCarImage(_ sender: UIImageView!, frame:CGRect)
    {
        UIView.animate(withDuration:  0.4, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            sender.frame = frame
        }, completion:  { (finished: Bool) -> Void in
        })
    }
    
    //MARK: Adding Cars to Google MapView
    func displayNearestCarsInMapView(_ carList: NSMutableArray, car_id: String)
    {
        
        for i in 0..<carList.count
        {
            let modelData = carList[i] as! NSDictionary
            guard let json = modelData as? JSON else{continue}
            let tempMarker = GMSMarker()
            
            tempMarker.position = CLLocationCoordinate2D(latitude: json.double("latitude"),
                                                         longitude: json.double("longitude"))
            if car_id == "1"
            {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
                imageView.image = UIImage(named: "top view")
                tempMarker.iconView = imageView

//                tempMarker.icon = UIImage(named: "top view")//"newtaxigo.png")
            }
            else if car_id == "2"
            {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                imageView.image = UIImage(named: "topView2")
                tempMarker.iconView = imageView
                
//                tempMarker.icon = UIImage(named: "topView2")//"newtaxix.png")
            }
            else
            {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                imageView.image = UIImage(named: "topView3")
                tempMarker.iconView = imageView
                
//                tempMarker.icon = UIImage(named: "topView3")//"newtaxixl.png")
            }
            tempMarker.map = map
        
        }
    }
    
    func animatePolyLine(pickUpLatitude: CLLocationDegrees, pickUpLongitude: CLLocationDegrees, dropLatitude: CLLocationDegrees, dropLongitude: CLLocationDegrees)
    {
        let vancouver = CLLocationCoordinate2DMake(pickUpLatitude, pickUpLongitude)
        let calgary = CLLocationCoordinate2DMake(dropLatitude, dropLongitude)
        let bounds = GMSCoordinateBounds(coordinate: vancouver, coordinate: calgary)
        let camera1 = map?.camera(for: bounds, insets:UIEdgeInsets.zero)
        map?.camera = camera1!
        
        let service = "https://maps.googleapis.com/maps/api/directions/json"
        let urlString = "\(service)?origin=\(pickUpLatitude),\(pickUpLongitude)&destination=\(dropLatitude),\(dropLongitude)&mode=driving&units=metric&sensor=true&key=\(iApp.instance.GoogleApiKey)"
        //UserDefaults.value(for: .google_api_key) ?? ""
        
        WebServiceHandler.sharedInstance.getThridPartyWebService(wsMethod: urlString, paramDict: [String:Any](), viewController: self, isToShowProgress: true, isToStopInteraction: false) { (responseDict) in
            
                if responseDict.count > 0 {
                    OperationQueue.main.addOperation {
                        self.drawRoute(routeDict: responseDict as NSDictionary)
                    }
                }
        }

        
    }
    // to drow the route from user location to currect car location
    func drawRoute(routeDict: NSDictionary)
    {
        let routesArray = routeDict ["routes"] as? NSArray ?? NSArray()
        if (routesArray.count > 0)
        {
            let routeDict = routesArray[0] as! Dictionary<String, Any>
            let routeOverviewPolyline = routeDict["overview_polyline"] as! Dictionary<String, Any>
            let points = routeOverviewPolyline["points"]
            let gPath = GMSPath.init(fromEncodedPath: points as? String ?? String())!
            strPoints = points as? String ?? String()
            self.path = gPath
            self.drawRoute(with: gPath)
           
        }
    }
    func drawRoute(with gPath : GMSPath){
        self.polyline.map = nil
        
        onCreateMapMarker()
        self.polyline.path = path
//        self.polyline.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.polyline.strokeColor = .ThemeYellow
        self.polyline.strokeWidth = 3.0
        self.polyline.map = map
        
        let bounds = GMSCoordinateBounds(path: gPath)
        map?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: (map!.frame.size.height * 0.25)))
                   if self.timer != nil
                   {
                    self.timer?.invalidate()
                   }
                   self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
    }
    
    @objc func animatePolylinePath()
    {
        guard let gPath = self.path else{return}
        if self.timer == nil
        {
            self.animationPolyline.strokeColor = UIColor.clear
            self.animationPolyline.strokeWidth = 0
            return
        }
        
        if (self.i < gPath.count()) {
            self.animationPath.add(gPath.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.systemOrange
            self.animationPolyline.strokeWidth = 3
            self.animationPolyline.map = map
            self.i += 1
        }
        else
        {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }
    
    // MARK: - ****** CollectionView Data Source ******
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let rect = UberSupport().getScreenSize()
//        return CGSize(width: (rect.size.width/3)-20, height: 145.0)
        return CGSize(width: (rect.size.width/3)-20, height: rect.size.height/4)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availableCars.count//dictSearchCarList.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarDetailCell", for: indexPath as IndexPath) as! CarDetailCell
        let modelData1 = self.availableCars[indexPath.row]
        cell.lblCarName.text = modelData1.car_name
        let currentTag = Int(modelData1.car_id) ?? Int()
        if (carTag == currentTag)
        {
            cell.imgCarThumb.sd_setImage(with: URL(string: modelData1.car_active_image))
            self.selectedCar = modelData1
            self.zoomCarImage(cell.imgCarThumb, frame: CGRect(x: (cell.frame.size.width - 80) / 2, y: 21, width: 80, height: 80))
            cell.carPoolLbl.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
        else
        {
            cell.imgCarThumb.frame = CGRect(x: (cell.frame.size.width - 70) / 2, y: 28, width: 70, height: 70)
            cell.imgCarThumb.sd_setImage(with: URL(string: modelData1.car_image))
            cell.carPoolLbl.transform = .identity
        }
        cell.setCarInfo(carModel: modelData1)
        cell.layoutIfNeeded()
        return cell
    }
    var selectedCar : SearchCarsModel?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
  
        guard let car = self.availableCars.value(atSafe: indexPath.row) else{return}
        
        
        
        strCarType = car.car_name
        estimatedFareString = car.fare_estimation
        
        let currentTag = Int(car.car_id) ?? Int()
        if carTag == currentTag
        {
            let viewFare : FareEstimationVC = .initWithStory(for: car)
            present(viewFare, animated: false, completion: nil)
            return
        }
        else
        {
            self.gotoCarDetailPage(selectedCar: car)
            
        }
        
        
        self.selectedCar = car
        carTag = currentTag
        collectionView.reloadData()
    }
    // MARK: ****** CollectionView Delegate End ******
    
    //MARK: - Refresh Icon onScheduleRiderTapped
    @IBAction func onRefreshTapped(_ sender: UIButton)
    {
        self.refreshMap()
    }
    func refreshMap()
    {
        if self.timer != nil
        {
            self.timer?.invalidate()
        }
        map?.clear()
        self.cashView.isHidden = false
        self.animationPolyline.map = nil
        self.polyline.map = nil
        
        lblNoCarsMsg.isHidden = true
        lblNoCarsMsg.text = ""
        viewSpinnerHolder.isHidden = false
        addProgress()
        self.callAPIForSearchNearestCars()
    }
    func addProgress()
    {
        spinnerView.frame = CGRect(x: (viewSpinnerHolder.frame.size.width - 40)/2, y: 65, width: 40, height: 40)
        spinnerView.circleLayer.lineWidth = 3.0
        spinnerView.circleLayer.strokeColor =  UIColor.ThemeYellow.cgColor
        viewSpinnerHolder.addSubview(spinnerView)
        spinnerView.beginRefreshing()
        
        
    }
    
    func removeSpinnerProgress()
    {
        viewSpinnerHolder.isHidden = true
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
        
        
    }
    
    @IBAction func onScheduleRiderTapped(_sender : UIButton!)
    {
        
    }
    
    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        },  completion: { (finished: Bool) -> Void in
        })
    }
    // MARK: When User Press Back Button
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.path = nil
        self.deinitObjects()
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: SETTING PICKUP TIME TO DELEGATE
    /*
     */
    @IBAction func onRequestNewTaxiTapped(_ sender:UIButton!)
    {
        if self.availableCars.count == 0
        {
            return
        }
        
        if YSSupport.checkDeviceType()
        {
            if !(UIApplication.shared.isRegisteredForRemoteNotifications)
            {
                let settingsActionSheet: UIAlertController = UIAlertController(title:self.lang.message, message:self.lang.enPushNotifyLogin, preferredStyle:UIAlertController.Style.alert)
                settingsActionSheet.addAction(UIAlertAction(title:self.lang.ok, style:UIAlertAction.Style.cancel, handler:{ action in
                   // self.appDelegate?.registerForRemoteNotification()
                    self.appDelegate?.pushManager.registerForRemoteNotification()
                }))
                present(settingsActionSheet, animated:true, completion:nil)
                return
            }
        }
        
        if self.selectedCar?.shareRideEnabled ?? false{
            self.showSeatSelectionView(true)
        }else{
            self.makeRequest()
        }
       
        
        
    }
    func makeRequest(wiht seats : Int? = nil){
        
        if scheduledTime == nil {//For normal trips
            var dicts = JSON()
            
            dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
            dicts["pickup_latitude"] = String(format:"%f",pickUpLatitude)
            dicts["pickup_longitude"] = String(format:"%f",pickUpLongitude)
            dicts["drop_latitude"] = String(format:"%f",dropLatitude)
            dicts["drop_longitude"] = String(format:"%f",dropLongitude)
            dicts["pickup_location"] = String(format:"%@",pickUpLocName)
            dicts["drop_location"] = String(format:"%@",dropLocName)
            dicts["car_id"] =  String(format:"%@",orgCarID)
            if let location_id = self.selectedCar?.location_id{
                dicts["location_id"] = String(format:"%@",location_id)
            }
            if let _seat = seats{
                dicts["seat_count"] = _seat.description
            }
            
            if Shared.instance.isCovidEnable {
                let view : CovidAlertVC = CovidAlertVC.initWithStory(params: dicts,navigationCtrl: self.navigationController ?? UINavigationController(), isSchedule: false)
                view.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(view, animated: true, completion: nil)
            }else{
            self.gotoGettingNearCarView(dicts)
            }
        }
        else {// for scheduled trip
            var dict = [String: Any]()
            dict["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
            dict["pickup_latitude"] = String(format:"%f",pickUpLatitude)
            dict["pickup_longitude"] = String(format:"%f",pickUpLongitude)
            dict["drop_latitude"] = String(format:"%f",dropLatitude)
            dict["drop_longitude"] = String(format:"%f",dropLongitude)
            dict["pickup_location"] = String(format:"%@",pickUpLocName)
            dict["drop_location"] = String(format:"%@",dropLocName)
            dict["car_id"] =  String(format:"%@",orgCarID)
            if let location_id = self.selectedCar?.location_id{
                dict["location_id"] = String(format:"%@",location_id)
            }
            if let _seat = seats{
                dict["seat_count"] = _seat.description
            }
            if Shared.instance.isCovidEnable {
                let view : CovidAlertVC = CovidAlertVC.initWithStory(params: dict,navigationCtrl: self.navigationController ?? UINavigationController(), isSchedule: true)
                view.modalPresentationStyle = .overCurrentContext
                view.scheduledTime = self.scheduledTime
                self.navigationController?.present(view, animated: true, completion: nil)
            }else{
                self.goToScheduleScreen(dicts: dict, scheduletime: self.scheduledTime ?? "")
            }
          
        }
    }
   
    func gotoGettingNearCarView(_ dicts: JSON)
    {
        guard let selected = self.selectedCar,
            let gPath = self.path else{return}
        let pickUp = CLLocationCoordinate2D(latitude: self.pickUpLatitude,
                                            longitude: self.pickUpLongitude)
        
        let drop = CLLocationCoordinate2D(latitude: self.dropLatitude,
                                            longitude: self.dropLongitude)
        if selected.apply_peak{//Go to peak approval screen
                let viewRequest = PeakDetailVC
                    .initWithStory(forCar: selected,
                                   params: dicts,
                                   carType: strCarType,
                                   carCount: carCount,
                                   path: gPath,
                                   pickUp: pickUp,
                                   drop: drop)
               
                self.navigationController?.pushViewController(viewRequest, animated: true)
        }else{// go to request
                let viewRequest : MakeRequestVC = .initWithStory(params: dicts,
                                                                 carType: strCarType,
                                                                 carCount: carCount,
                                                                 path: gPath,
                                                                 pickUp: pickUp,
                                                                 drop: drop)
                self.navigationController?.pushViewController(viewRequest, animated: true)
        }
       
    }
    
    func goToScheduleScreen(dicts : [String:Any],scheduletime: String){
        guard let gPath = self.path else {
            return
        }
        guard let selected = self.selectedCar else{return}
        if selected.apply_peak{
            let viewRequest = PeakDetailVC.initWithStory(forCar: selected,
                                                         scheduleParams: dicts,
                                                         estimatedFareString: estimatedFareString,
                                                         scheduledTimeString: scheduletime,
                                                         path: gPath)
            self.navigationController?.pushViewController(viewRequest, animated: true)
        }else{
            let scheduleDetailVC = ScheduleRideDetailViewController
                .initWithStory(params: dicts,
                               car: selected,
                               estimatedFareString: estimatedFareString,
                               scheduledTimeString: scheduletime,
                               path: gPath)
            self.navigationController?.pushViewController(scheduleDetailVC, animated: true)
        }
    }
    func getDate_Time(fromString str : String)->(String,String){
        var receivedDateString = String((str.split(separator: "-"))[0])
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "en_US")
        receivedDateString = String(format:"%@",receivedDateString.replacingOccurrences(of: " at ", with: "\(myDateFormatter.string(from: Date())) ~ "))
        receivedDateString.removeLast()
        myDateFormatter.dateFormat = "EEE, dd MMM yyyy ~ hh:mm a"
        //        myDateFormatter.locale = Locale(identifier: "en_US")
        let mySelectedDate = myDateFormatter.date(from: "\(receivedDateString)")
        myDateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        myDateFormatter.dateFormat = "HH:mm"
        let scheduledTimeAloneString = myDateFormatter.string(from: mySelectedDate!)
        myDateFormatter.dateFormat = "dd-MM-yyyy"
        let scheduledDateAloneString = myDateFormatter.string(from: mySelectedDate!)
        return (scheduledDateAloneString,scheduledTimeAloneString)
    }
    //MARK: - Create Map Marker
    func onCreateMapMarker()
    {
        pickupMarker.map = nil
        dropMarker.map = nil
        pickupMarker = GMSMarker()
        dropMarker = GMSMarker()
        
        // Creates a marker in the center of the map.
        pickupMarker.position = CLLocationCoordinate2D(latitude: pickUpLatitude, longitude: pickUpLongitude)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView.image = UIImage(named: "circle")
        pickupMarker.iconView = imageView
//        pickupMarker.icon = UIImage(named: "circle")
        pickupMarker.map = map
        
        dropMarker.position = CLLocationCoordinate2D(latitude: dropLatitude, longitude: dropLongitude)
        let imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView2.image = UIImage(named: "box")
        dropMarker.iconView = imageView2

//        dropMarker.icon = UIImage(named: "box")
        dropMarker.map = map
        
        let vancouver = CLLocationCoordinate2DMake(pickUpLatitude, pickUpLongitude)
        let calgary = CLLocationCoordinate2DMake(dropLatitude, dropLongitude)
        let bounds = GMSCoordinateBounds(coordinate: vancouver, coordinate: calgary)
        let camera1 = map?.camera(for: bounds, insets:UIEdgeInsets.zero)
        map?.camera = camera1!
        
        pickupMarker.tracksInfoWindowChanges = true
    }
    
    func createCustomMarkerImageWithMarker(marker: GMSMarker) -> UIImage
    {
        let priceLabelRect: CGRect = marker.title!.boundingRect(with: CGSize(width: CGFloat(500), height: CGFloat(50)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(10))], context: nil)
        let priceLabel = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(priceLabelRect.size.width + 25), height: CGFloat(priceLabelRect.size.height + 12)))
        priceLabel.text = " \(strCurrency) \(marker.title!) "
        priceLabel.textAlignment = .center
        priceLabel.textColor = UIColor.black
        priceLabel.backgroundColor = UIColor.red
        priceLabel.font = UIFont.systemFont(ofSize: CGFloat(11))
        
        let numberOfPropertiesLabelRect: CGRect = marker.snippet!.boundingRect(with: CGSize(width: CGFloat(300), height: CGFloat(50)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(10))], context: nil)
        let numberOfPropertiesLabel = UILabel(frame: CGRect(x: CGFloat(priceLabel.frame.size.width), y: CGFloat(0), width: CGFloat(numberOfPropertiesLabelRect.size.width + 10), height: CGFloat(numberOfPropertiesLabelRect.size.height + 12)))
        numberOfPropertiesLabel.text = marker.snippet
        numberOfPropertiesLabel.textAlignment = .center
        numberOfPropertiesLabel.textColor = UIColor.white
        numberOfPropertiesLabel.backgroundColor = UIColor.red
        numberOfPropertiesLabel.font = UIFont.systemFont(ofSize: CGFloat(11))
        
        _ = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(priceLabel.frame.size.width + numberOfPropertiesLabel.frame.size.width), height: CGFloat(priceLabel.frame.size.height + 20))
        map?.addSubview(priceLabel)
        map?.addSubview(numberOfPropertiesLabel)
        map?.addSubview(cashView)
        
        let icon: UIImage? = UIImage(named: "box")
        return icon!
    }
    
    //MARK: - Change Map Style
    /*
     Here we are changing the Map style from "ub__map_style" Json File
     */
    func onChangeMapStyle()
    {
        do
        {
            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if let styleURL = Bundle.main.url(forResource: "mapStyleChanged", withExtension: "json") {
                map?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                
            }
            else
            {
            }
        }
        catch
        {
        }
    }
}
extension SearchCarVC : paymentMethodSelection{
    func updateContent() {
        self.selectedPayment(method: PaymentOptions.default ?? .cash)
    }
    
    func selectedPayment(method: PaymentOptions) {
        switch method {
        case .stripe:
            cashView.isHidden = false
//            paymentimg.image = UIImage(named:"card")!.withRenderingMode(.alwaysTemplate)
//            paymentimg.tintColor = .ThemeYellow
            cashlab.text = self.lang.card
            let preference = UserDefaults.standard
            if let brand : String = UserDefaults.value(for: .card_brand_name),
                let last4 : String = UserDefaults.value(for: .card_last_4){
                cashlab.text  = "**** "+last4
                paymentimg.image = self.getCardImage(forBrand: brand)
                paymentimg.tintColor = .ThemeYellow
            }
        case .paypal:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"paypal.png")!
            cashlab.text = self.lang.paypal
        case .onlinepayment:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"onlinePay")!
            cashlab.text = self.lang.onlinePayment
        case .brainTree:
            cashView.isHidden = false
            self.paymentimg.image = UIImage(named: "braintree")
            self.cashlab.text = UserDefaults.value(for: .brain_tree_display_name) ?? self.lang.onlinePay
        case .cash:
            cashView.isHidden = false
            paymentimg.image = UIImage(named:"Currency")!
            cashlab.text = self.lang.cash
        default:
            break
        }
      }

    
}

extension SearchCarVC : SeatSelectionDelegate{
    func seatsSelected(_ selected: Int) {
        
        self.showSeatSelectionView(false)
        self.makeRequest(wiht: selected)
    }
    
    func seatsSelectionCancelled() {
        self.showSeatSelectionView(false)
    }
    
    
}
extension SearchCarVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.tempProfileModel?.requestOptions.count ?? 0
        return  count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.tempProfileModel?.requestOptions[indexPath.row]

        let cell : PreferenceTableCell = preferenceTable.dequeueReusableCell(for: indexPath)
        cell.preferenceLbl.text = model?.name
        cell.preferenceLbl.textAlignment = self.lang.isRTLLanguage() ? .right : .left
//        cell.preferenceImg.image = model?.isSelected ?? false ? #imageLiteral(resourceName: "check-mark") : #imageLiteral(resourceName: "unchecked")
        cell.preferenceImg.image = model?.isSelected ?? false ? #imageLiteral(resourceName: "checkbox") : #imageLiteral(resourceName: "checkbox-Outline")
        cell.contentView.addAction(for: .tap) {
            model?.isSelected = !(model?.isSelected ?? true)
//            cell.preferenceImg.image = model?.isSelected ?? false ? #imageLiteral(resourceName: "check-mark") : #imageLiteral(resourceName: "unchecked")
            cell.preferenceImg.image = model?.isSelected ?? false ? #imageLiteral(resourceName: "checkbox") : #imageLiteral(resourceName: "checkbox-Outline")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.mainCellHeight
    }
}

