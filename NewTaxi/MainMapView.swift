/**
 * MainMapView.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit
import Foundation
import GoogleMaps
import JavaScriptCore
import Alamofire
import Firebase
import FirebaseAuth
class MainMapView : UIViewController,
                    CLLocationManagerDelegate,
                    GMSMapViewDelegate,
                    CAAnimationDelegate,
                    APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
//        case .essentialDataReceived:
//            self.firebaseAuthentication()
//            self.driverLTManger?.startUpdating()
//        case .RiderModel(let driver):
//            dump(driver)
//        case .tripDetailData(let data):
//
//            if data.status == .payment{
//                AppRouter(self).getPaymentInvoiceAndRoute(data)
//            }else{
//                AppRouter(self).routeInCompleteTrips(data)
//            }
        default:
            print()
        }
    }
    
    func onFailure(error: String,for API : APIEnums) {
//        print(error)
    }
    
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    
    
    @IBOutlet weak var driveText: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var viewSearchHolder: UIView!
    @IBOutlet weak var whereToLbl : UILabel?
    @IBOutlet weak var mapLocation: GMSMapView!
    @IBOutlet weak var btnSideBar: UIButton!
    @IBOutlet weak var roundView: UIView!
    
    // gender
    @IBOutlet weak var preferenceTable: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var preferencePopupView: UIView!
    @IBOutlet weak var savePrefernceBtn: UIButton!
    lazy var profileModel : RiderDataModel? = nil
    @IBOutlet weak var preferenceTableHeight: NSLayoutConstraint!
    lazy var tempProfileModel : RiderDataModel? = nil
    let mainCellHeight : CGFloat = 40
    var isNoHitWillAppear = Bool()
    
    lazy var edgeSwipeView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.view.frame.height))
        view.backgroundColor = .clear
        return view
    }()
    
    
    @IBOutlet weak var cornerView: UIView!
    var PromoModel : PromoCodeModel!
    let arrMenus: [String] = [NSLocalizedString("Payment", comment: "") ,NSLocalizedString("My Trips", comment: ""),NSLocalizedString("Wallet", comment: ""),NSLocalizedString("Settings", comment: ""),NSLocalizedString("Emergency Contacts", comment: "")]
    var locationManager: CLLocationManager!
    fileprivate let cameraDefaultZoom : Float = 16.5
    
    @IBOutlet weak var carButton: UIButton!
    lazy var marker = GMSMarker()
    lazy var marker2 = GMSMarker()
    lazy var polyline = GMSPolyline()
    lazy var animationPolyline = GMSPolyline()
    lazy var path = GMSPath()
    lazy var animationPath = GMSMutablePath()
    lazy var lang = Language.default.object
    var firebaseAuth : Bool = UserDefaults.standard.bool(forKey: USER_FIREBASE_AUTH)
    var i: UInt = 0
    var timer: Timer!
    var isCurrentLocationSet : Bool = false
    var pickUpLocation: CLLocation!
    var isSearchStarted : Bool = false
    var isTripStarted : Bool = false
    var isMainMap : Bool = false
    var isDriverPageCalled : Bool = false
    var isRatingPageCalled : Bool = false
    var isPopEexcuted:Bool = Bool()
    var strTripId = ""
    
    // MARK: - ViewController Methods
    
    var driverLTManger : DriverLiveTrackingManager?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //check
        self.apiInteractor = APIInteractor(self)
        self.driverLTManger = DriverLiveTrackingManager(self.mapLocation,viewController: self)
        self.refreshRiderDetailsFromAPI()
        self.initView()
        self.initGesture()
        self.initNotificaiton()
        self.initLanguage()
        self.preferencePopupView.isHidden = true
        self.preferenceTable.delegate = self
        self.preferenceTable.dataSource = self
        self.driveText.text = self.lang.grapRide
    }
    func initGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = self.lang.isRTLLanguage() ? .right : .left
        self.edgeSwipeView.addGestureRecognizer(edgePan)
    }
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            print("Screen edge swiped!")
            self.view.endEditing(true)
            let menuVc = MenuVC.initWithStory(self)
            menuVc.modalPresentationStyle = .overCurrentContext
            self.present(menuVc, animated: false, completion: nil)
        }
    }
    func firebaseAuthentication()
    {
        let firebaseToken = UserDefaults.standard.value(forKey: USER_FIREBASE_TOKEN) as? String ?? ""
        //        if !firebaseAuth{
        Auth.auth().signIn(withCustomToken: firebaseToken) { (user, error) in
            if (error != nil) {
                UserDefaults.standard.setValue(false, forKey: USER_FIREBASE_AUTH)
            }else{
                if Shared.instance.permissionDenied {
                    self.appDelegate.pushManager.startObservingUser()
                }
                
                UserDefaults.standard.setValue(true, forKey: USER_FIREBASE_AUTH)
            }
        }
        
    }
    func setDesign()
    {
        viewSearchHolder.layer.shadowColor = UIColor.gray.cgColor;
        viewSearchHolder.layer.shadowOffset = CGSize(width:0, height:1.0);
        viewSearchHolder.layer.shadowOpacity = 0.5;
        viewSearchHolder.layer.shadowRadius = 2.0;
        var rectTblView = viewSearchHolder.frame
        rectTblView.size.width = self.viewSearchHolder.frame.size.width-100
        rectTblView.origin.x = (self.view.frame.size.width-rectTblView.size.width)/2
        viewSearchHolder.frame = rectTblView
        viewSearchHolder.cornerRadius = 10
        self.roundView.isRoundCorner = true
        self.roundView.backgroundColor = .ThemeYellow
        self.btnSideBar.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.filterButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.carButton.setImage(#imageLiteral(resourceName: "car"), for: .normal)
        self.carButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.btnSideBar.cornerRadius = 12
        self.btnSideBar.backgroundColor = .ThemeYellow
        self.driverName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.driverName.textColor = .Title
        self.driveText.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.driveText.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.whereToLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.whereToLbl?.textColor = .Title

    }
    func initView(){
        self.setDesign()
        self.cornerView.setSpecificCornersForTop(cornerRadius: 0)
        self.filterView.setSpecificCornersForTop(cornerRadius: 0)
        isMainMap = true
        // Getting User Current Location
        self.updateCurrentLocation()
        startAnimation()
        setupShareAppViewAnimationWithView(viewSearchHolder)  //  animate search holder
        onChangeMapStyle()
        mapLocation.delegate = self
        setprofileInfo()
        self.view.addSubview(self.edgeSwipeView)
        self.view.bringSubviewToFront(self.edgeSwipeView)
        self.edgeSwipeView.anchor(toView: self.view, leading: 0, top: 0, bottom: 0)
        self.edgeSwipeView.widthAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    //initialization with story board
    class func initWithStory() -> MainMapView {
        let view : MainMapView = UIStoryboard.payment.instantiateViewController()
        view.apiInteractor = APIInteractor(view)
        return view
    }
    func initLanguage(){
        self.whereToLbl?.text = self.lang.whereVal
        self.savePrefernceBtn.setTitle(self.lang.save.uppercased(), for: .normal)
        self.savePrefernceBtn.cornerRadius = 10
    }
    func initNotificaiton(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDriverDetails), name: Notification.Name(rawValue: NotificationTypeEnum.GetDriverDetails.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDriverDetails), name: Notification.Name(rawValue: NotificationTypeEnum.KilledStateNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showThisPage), name: Notification.Name(rawValue: NotificationTypeEnum.ShowHomePage.rawValue), object: nil)
        
        // DISPLAY ALERT ONLY WHEN RECEIVING APNS
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.arrivenoworbegintrip), name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.arrivenoworbegintrip), name: Notification.Name(rawValue: NotificationTypeEnum.ArrivedNowOrBeginTrips.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.driverCancelledTrip), name: Notification.Name(rawValue: NotificationTypeEnum.cancel_trip.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.endTrip), name: Notification.Name(rawValue: NotificationTypeEnum.EndTrip.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue),
                                                  object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.getTripDetails),
                                               name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue),
                                               object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: NotificationTypeEnum.RequestAccepted.rawValue),
                                                  object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refreshInCompleteTrip),
                                               name: Notification.Name(rawValue: NotificationTypeEnum.RequestAccepted.rawValue),
                                               object: nil)
    }
    //MARK: - WHEN DRIVER ACCEPTING REQUEST
    /*
     NOTIFICATION TYPE PAYMENT COMPLETED
     */
    func PayMentCompleted()
    {
        let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Success", comment: ""), message:NSLocalizedString("Payment Completed successfully", comment: ""), preferredStyle:UIAlertController.Style.alert)
        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.trip_payments.rawValue), object: self, userInfo: nil)
        }))
    }
    //MARK: - WHEN DRIVER ACCEPTING REQUEST
    /*
     NOTIFICATION TYPE RATING
     */
    @objc
    func refreshInCompleteTrip(){
        self.navigationController?.popToViewController(self, animated: false)
//        if let liveNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
//           liveNav.viewControllers.contains(self){
//            self.getTripDetailsApi()
//            Shared.instance.resumeTripHitCount += 1
//        }
    }
    @objc func getTripDetails()
    {
        self.navigationController?.popToViewController(self, animated: false)
        if Shared.instance.resumeTripHitCount == 0,
           let liveNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
           liveNav.viewControllers.contains(self){
            self.getTripDetailsApi()
            Shared.instance.resumeTripHitCount += 1
        }
    }
    func getTripDetailsApi()
    {
//        self.apiInteractor?.getResponse(for: .getTripDetail).shouldLoad(true)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getTripDetail)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let data = TripDetailDataModel(json)
                    if data.status == .payment{
                        AppRouter(self).getPaymentInvoiceAndRoute(data)
                    }else{
                        AppRouter(self).routeInCompleteTrips(data)
                    }
                }else{
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
            })

    }
    //MARK: - WHILE GETTING DRIVER CANCELLED TRIP PUSH NOTIFICATION FROM DRIVER
    /*
     When driver cancelling trip, that time rider will get apns
     and we have to inform the rider - "trip is cancelled" in alert
     */
    @objc func driverCancelledTrip()
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.cancel_trips.rawValue), object: self, userInfo: nil)
        
        let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString(NSLocalizedString("Message!!!", comment: ""), comment: ""), message:NSLocalizedString(NSLocalizedString("Trip cancelled by driver", comment: ""), comment: ""), preferredStyle:UIAlertController.Style.alert)
        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString(NSLocalizedString("OK", comment: ""), comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
        }))
        if let liveNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
           liveNav.viewControllers.contains(self){
            UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
        }
        
    }
    
    //MARK: - WHILE GETTING PUSH NOTIFICATION FROM DRIVER
    /*
     NOTIFICATION TYPE ARRIVE NOW OR BEGIN TRIP
     */
    @objc func arrivenoworbegintrip(notification: Notification)
    {
        let str2 = notification.userInfo
        let getNotificationType = str2?["type"] as? String ?? String()
        self.isTripStarted = false
        let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message:(getNotificationType == "arrivenow") ? NSLocalizedString("Driver arrived", comment: "") : NSLocalizedString("Trip Started", comment: ""), preferredStyle:UIAlertController.Style.alert)
        settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in            
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
    }
    
    //MARK: - WHILE GETTING END TRIP PUSH NOTIFICATION FROM DRIVER
    /*
     NOTIFICATION TYPE END TRIP
     */
    @objc func endTrip(notification: Notification)
    {/*
         var params = Parameters()
         params["trip_id"] = notification.userInfo?["trip_id"] as? String ?? String()
         self.apiInteractor?.getResponse(forAPI: .getInvoice, params: params).shouldLoad(true)
         */
        if isRatingPageCalled
        {
            return
        }
        isRatingPageCalled = false
        /* self.isTripStarted = true
         viewSearchHolder.isHidden = true
         let str2 = notification.userInfo
         let propertyView = UIStoryboard.main.instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
         propertyView.strDriverImgUrl = str2?["driver_thumb_image"] as? String ?? String()
         propertyView.strTripID = str2?["trip_id"] as? String ?? String()
         self.navigationController?.pushViewController(propertyView, animated: false)*/
        guard let json = notification.userInfo as? JSON else{return}
        let riderJSON : JSON = ["riders": [json]]
        let trip = TripDataModel(riderJSON)
        let rateDriverVC : RateDriverVC = .initWithStory()
        rateDriverVC.tripId = trip.id
        self.navigationController?.pushViewController(rateDriverVC,
                                                      animated: false)
        
    }
    
    
    //here showing this page when driver cancel or rider cancel this trip
    @objc func showThisPage(notification: Notification)
    {
        let propertyView = MainMapView.initWithStory()
        self.navigationController?.pushViewController(propertyView, animated: false)
    }
    
    //MARK: - WHEN DRIVER ACCEPTING REQUEST
    /*
     NOTIFICATION TYPE ACCEPT REQUEST
     */
    @objc func getDriverDetails(notification: Notification)
    {
        if isDriverPageCalled
        {
            return
        }
        isDriverPageCalled = true
        
        if let json = notification.userInfo as? JSON{
            let detail = TripDetailDataModel(json)
            let routeVC = RouteVC.initWithStory()
            routeVC.tripDataModel = detail
            routeVC.tripDetailModel = detail
            routeVC.tripID = detail.id
            routeVC.tripStatus = detail.status
            routeVC.bookingType = detail.bookingType
            self.navigationController?.pushViewController(routeVC, animated: true)
        }
    }
    
    // MARK: CALLING API FOR CREATE FB OR GOOGLE ACC
    func setCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    {
        if isCurrentLocationSet
        {
            return
        }
        isCurrentLocationSet = true
        
        CATransaction.begin()
        CATransaction.setValue(1.5, forKey: kCATransactionAnimationDuration)
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: self.cameraDefaultZoom)
        GMSMapView.map(withFrame: mapLocation.frame, camera: camera)
        mapLocation.camera = camera
        mapLocation.isMyLocationEnabled = true
        mapLocation.settings.myLocationButton = true
        CATransaction.commit()
        let southWest = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let northEast = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        let icon = UIImage(named: "car_40.png")
        
        let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
        overlay.bearing = 0
        overlay.map = mapLocation
    }
    
    
    // Mark the map marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var point: CGPoint = mapLocation.projection.point(for: marker.position)
        point.y -= 100
        mapLocation.animate(toLocation: mapLocation.projection.coordinate(for: point))
        mapLocation.selectedMarker = marker
        return true
    }
    
    //MARK: - Change Map Style
    /*
     Here we are changing the Map style from Json File
     */
    func onChangeMapStyle()
    {
        do {
            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if let styleURL = Bundle.main.url(forResource: "mapStyleChanged", withExtension: "json") {
                mapLocation.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
            }
        } catch {
        }
    }
    
    func DegreeBearing(_ A:CLLocation,_ B:CLLocation)-> Double{
        var dlon = self.ToRad(degrees: B.coordinate.longitude - A.coordinate.longitude)
        let dPhi = log(tan(self.ToRad(degrees: B.coordinate.latitude) / 2 + .pi / 4) / tan(self.ToRad(degrees: A.coordinate.latitude) / 2 + .pi / 4))
        if  abs(dlon) > .pi
        {
            dlon = (dlon > 0) ? (dlon - 2 * .pi) : (2 * .pi + dlon)
        }
        return self.ToBearing(radians: atan2(dlon, dPhi))
    }
    
    func ToRad(degrees:Double) -> Double{
        return degrees * (.pi / 180)
    }
    
    func ToBearing(radians:Double)-> Double{
        return (ToDegrees(radians: radians) + 360).truncatingRemainder(dividingBy: 360)
    }
    
    func ToDegrees(radians:Double)->Double{
        return radians * 180 / .pi
    }
    
    func animatePath(_ layer: CAShapeLayer) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 6
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        pathAnimation.fromValue = Int(1.0)
        pathAnimation.toValue = Int(0.0)
        pathAnimation.repeatCount = 100
        layer.add(pathAnimation, forKey: "strokeEnd")
    }
    
    //MARK: - GOOGLE MAP DELEGATE METHOD
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if(mapView.camera.zoom > 5)
        {
            
        }
        
    }
    //MARK:  **** END ****
    @objc func notificationHandler(_ notification:Notification)  {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if let dict = notification.userInfo as? JSON {
            let tripId : Int = (UserDefaults.value(for: .current_trip_id)) ?? 0
            if tripId.description != ChatVC.currentTripID {
                let json = [NotificationTypeEnum.chat_notification.rawValue] as? JSON
                let driverID : Int = json?.int("user_id") ?? UserDefaults.value(for: .driver_user_id) ?? 0
                let driverRating : Double? = json?.double("rating")
                let chatVC = ChatVC.initWithStory(withTripId: json?.string("trip_id") ?? tripId.description,
                                                  driverRating: driverRating,
                                                  driver_id: driverID)
                if let nav = appdelegate.window?.rootViewController as? UINavigationController{
                    nav.pushViewController(chatVC, animated: true)
                }else if let root = appdelegate.window?.rootViewController{
                    root.navigationController?.pushViewController(chatVC, animated: true)
                }
                
            }
            else{
                
                let custom = dict[NotificationTypeEnum.custom.rawValue] as Any
                let data = appdelegate.pushManager.convertStringToDictionary(text: custom as? String ?? String())
                let dictionary = data! as NSDictionary
                appdelegate.pushManager.handleCommonPushNotification(userInfo: dictionary,generateLocalNotification: false)
                appdelegate.pushManager.handlePushNotificaiton(userInfo: dictionary as! JSON)
            }
        }
        
    }
    //MARK: - **** LOCATION MANAGER DELEGATE METHODS ****
    func updateCurrentLocation()
    {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    locationManager.requestWhenInUseAuthorization()
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.requestAlwaysAuthorization()
                }
            } else {
                
            }
            
            locationManager.delegate = self
            
        }
        
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        locationManager.startUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        //If map is being used
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            mapLocation.isMyLocationEnabled = true
            mapLocation.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            mapLocation.camera = GMSCameraPosition(target: location.coordinate, zoom: self.cameraDefaultZoom, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        Constants().STOREVALUE(value: String(format: "%f", coord.longitude) as String, keyname: USER_LONGITUDE)
        Constants().STOREVALUE(value: String(format: "%f", coord.latitude) as String, keyname: USER_LATITUDE)
        self.pickUpLocation = locationObj
        locationManager.stopUpdatingLocation()
        self.setCurrentLocation(latitude: coord.latitude, longitude: coord.longitude)
        let dicts = [AnyHashable: Any]()
        //self.callUpdateLocationAPI(dicts, latitude: coord.latitude, longitude: coord.longitude)
        
    }
    func refreshRiderDetailsFromAPI(){
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .riderProfile)
            .responseJSON({ (json) in
                let model = RiderDataModel(json)
                model.storeRiderBasicDetail()
                self.profileModel = model
                self.setprofileInfo()
                self.updatefilterIcon()
                
                if json.isSuccess{
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
                UberSupport.shared.removeProgressInWindow()
            }).responseFailure({ (error) in
                if error != ""
                {
                    AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()
                }
            })
        
    }
    //MARK UPDATE LOCATION API
    func callUpdateLocationAPI(_ dicts: [AnyHashable: Any],latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        
        var dicts = JSON()
        
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["latitude"] = Constants().GETVALUE(keyname: USER_LATITUDE)
        dicts["longitude"] = Constants().GETVALUE(keyname: USER_LONGITUDE)
        
        
        self.apiInteractor?
            .getRequest(
                for: APIEnums.updateRiderLocation,
                params: dicts)
            .responseJSON({ (json) in
                UberSupport.shared.removeProgressInWindow()
                if !json.isSuccess{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
            })
        
    }
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    //MARK:  **** END ****
    //MARK: -
    func startAnimation() {
        let animation = CircularRevealAnimation(from: CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2), to: self.view.bounds)
        self.view.layer.mask = animation.shape()
        self.view.alpha = 1
        animation.commit(duration: 0.5, expand: true, completionBlock: {
            self.view.layer.mask = nil
        })
    }
    
    
    //MARK: - ONSCHEDULE ON THE RIDER
    
    @IBAction func onScheduleRiderTapped(_ sender: Any) {
        let scheduleRideVC = ScheduleRiderVC.initWithStory()
        scheduleRideVC.view.backgroundColor = UIColor.clear
        scheduleRideVC.delegate = self
        scheduleRideVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        present(scheduleRideVC, animated: false, completion: nil)
    }
    
    
    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        view.transform = CGAffineTransform(translationX: 0, y: -150)
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
                        {
                            var rectTblView = self.viewSearchHolder.frame
                            rectTblView.size.width = self.viewSearchHolder.frame.size.width+100
                            rectTblView.origin.x = (self.view.frame.size.width-rectTblView.size.width)/2
                            self.viewSearchHolder.frame = rectTblView
                            view.transform = CGAffineTransform.identity
                            view.alpha = 1.0;
                        }, completion: nil)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.driverLTManger?.startUpdating()
//        if !Shared.instance.nonessentialdata {
//            self.apiInteractor?.getResponse(for: .getEssetntials).shouldLoad(false)
            
            self.apiInteractor?
                .getRequest(for: .getEssetntials)
                .responseJSON({ (json) in
                    if json.isSuccess{
                        self.handleEssentials(json)
                        self.firebaseAuthentication()
                        self.driverLTManger?.startUpdating()
                    }else{
                    }
                }).responseFailure({ (error) in
                    print("error")
                })
//        }

        self.getTripDetails()
        self.isNoHitWillAppear = true
        isPopEexcuted = false
        isRatingPageCalled = false
//        self.setStatusBarStyle(.lightContent)
        
    }
    func handleEssentials(_ json : JSON){
        
        let firebase_token = json.string("firebase_token")
        if !firebase_token.isEmpty{
            Constants().STOREVALUE(value: firebase_token, keyname: USER_FIREBASE_TOKEN)
        }
        //Google key
//        let googleKey = json.string("google_map_key")
//        UserDefaults.set(googleKey, for: .google_api_key)
        let driverRadiusKM = json.int("driver_km")
        Shared.instance.driverRadiusKM = driverRadiusKM
        //Sinch key handling
        let sinchKey = json.string("sinch_key")
        let sinchSecret = json.string("sinch_secret_key")
        if !sinchKey.isEmpty{
            UserDefaults.set(sinchKey, for: .sinch_key)
            UserDefaults.set(sinchSecret, for: .sinch_secret_key)
        }
//        let defaultPaymentGateWay = json.string("gateway_type")
        
        let paypalClient = json.string("paypal_client")
//        let paypalMode = json.string("paypal_mode")
        if !paypalClient.isEmpty{
            UserDefaults.set(paypalClient, for: .paypal_client_key)
//            UserDefaults.set(paypalMode, for: .paypal_mode)
//            PayPalHandler.initPaypalModule()
        }
        let isWebPayment = json.bool("is_web_payment")
        Shared.instance.isWebPayment = isWebPayment
        let isCovidEnable = json.bool("covid_future")
        Shared.instance.isCovidEnable = isCovidEnable
        let stripe = json.string("stripe_publish_key")
        if !stripe.isEmpty{
            UserDefaults.set(stripe, for: .stripe_publish_key)
            StripeHandler.initStripeModule()
        }
        let last4 = json.string("last4")
        let brand = json.string("brand")
        if !last4.isEmpty,!brand.isEmpty{
            UserDefaults.set(last4, for: .card_last_4)
            UserDefaults.set(brand, for: .card_brand_name)
        }
        UserDefaults.set(json.string("admin_contact"), for: .admin_mobile_number)
        
        //initializing sinch manager
        if !CallManager.instance.isInitialized,     //(Manger is not initialized)
            !sinchKey.isEmpty,                      //(Key is available to call)
            let accessToken : String = UserDefaults.value(for: .access_token),
            !accessToken.isEmpty,                   //User is Still logged in
            let userID : String = UserDefaults.value(for: .user_id) {
            do{
                try CallManager
                    .instance
                    .initialize(environment: CallManager.Environment.live,//Initialize call manger
                        for: userID)
            }catch let error{debug(print: error.localizedDescription)}
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.driverLTManger?.stopUpdating()
        if self.timer != nil {
            self.timer.invalidate()
        }
        
        if isDriverPageCalled {
            isDriverPageCalled = false
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
    
    // MARK: Navigating to Side Menu View
    @IBAction func onSideMenuTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        let menuVc = MenuVC.initWithStory(self)
        menuVc.modalPresentationStyle = .overCurrentContext
        self.present(menuVc, animated: false, completion: nil)
        return
    }
    // MARK: Navigating to Side Menu View
    @IBAction func onSearchTapped(_ sender:UIButton!)
    {
        let permission = PermissionManager(self,LocationConfig())
        guard permission.isEnabled else{
            permission.forceEnableService()
            return
        }
        mapLocation.clear()
        let viewLoc = SetLocationVC.initWithStory()
        viewLoc.delegate = self
        self.navigationController?.pushViewController(viewLoc, animated: true)
    }
}

//MARK:- MenuResponseProtocol
extension MainMapView : MenuResponseProtocol{
    
    func routeToView(_ view: UIViewController) {
        self.navigationController?.pushViewController(view, animated: true)
    }
    func callAdminForManualBooking() {
        self.checkMobileNumeber()
    }
}
//MARK:- SettingProfileDelegate,EditProfileDelegate
extension MainMapView : SettingProfileDelegate,EditProfileDelegate {
    // Set Driver Profile Delegate method
    internal func setprofileInfo()
    {
        self.driverName.text = self.lang.hey + " " + Constants().GETVALUE(keyname: USER_FULL_NAME)
    }
}
//MARK:- setLocationDelegate
extension MainMapView : setLocationDelegate{
    func onExitSetLocation(from viewController: UIViewController) {
        self.navigationController?.popViewController(animated: false)
    }
    internal func onLocationTapped(pickUpLatitude: CLLocationDegrees, pickUpLongitude: CLLocationDegrees, dropLatitude: CLLocationDegrees, dropLongitude: CLLocationDegrees,dropLocName: String, pickUpLocName: String, scheduledTime:String?) {
        
        let viewLoc : SearchCarVC = .initWithStory()
        viewLoc.delegate = self
        viewLoc.pickUpLatitude = pickUpLatitude
        viewLoc.pickUpLongitude = pickUpLongitude
        viewLoc.dropLatitude = dropLatitude
        viewLoc.dropLongitude = dropLongitude
        viewLoc.dropLocName = dropLocName
        viewLoc.pickUpLocName = pickUpLocName
        viewLoc.scheduledTime = scheduledTime
        viewLoc.profileModel = self.profileModel
        self.navigationController?.pushViewController(viewLoc, animated: false)
    }
}
extension MainMapView : carAvailbleDelegate{
    func onmakeanimation()
    {
        
    }
    
}
//MARK: - SCHEDULE RIDER SELECTED DATE DELEGATE
extension MainMapView : ScheduleRiderDelegate{
    internal func onScheduleRiderTapped(scheduledTime:String)
    {
        mapLocation.clear()
        let viewLoc = SetLocationVC.initWithStory()
        viewLoc.delegate = self
        viewLoc.scheduledTime = scheduledTime
        self.navigationController?.pushViewController(viewLoc, animated: true)
    }
    
}
class PreferenceTableCell : UITableViewCell{
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var preferenceLbl: UILabel!
    @IBOutlet weak var preferenceImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.preferenceLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.preferenceLbl.textColor = .Title
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
extension MainMapView : UITableViewDelegate,UITableViewDataSource{
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
extension UIViewController{
    func cornerRadiusWithShadow(view: UIView){
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true;
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius = 6.0
        view.layer.masksToBounds = false
    }
}
extension UIView{
    func setSpecificCornersForTop(cornerRadius : CGFloat)
    {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively

    }
    func setSpecificCornersForBottom(cornerRadius : CGFloat)
    {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    func setSpecificCorners()
    {
        self.clipsToBounds = true
        self.layer.cornerRadius = 35
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
    }
    
}
