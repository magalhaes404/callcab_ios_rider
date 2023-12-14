/**
 * MakeRequestVC.swift
 *
 * @package UberDriver
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit
import AVFoundation
import GoogleMaps
import Firebase
import FirebaseDatabase
import Lottie

typealias GifLoaderValue = (loader:UIView,count : Int)

class MakeRequestVC : UIViewController, ProgressViewHandlerDelegate,GMSMapViewDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var player: AVAudioPlayer?
    
    // MARK: - ViewController Methods
//    @IBOutlet var viewDetailHoder: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblCarType: UILabel!
    @IBOutlet weak var viewCircular: UIView!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var viewNoRideAvailble: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var sryNoRideLbl: UILabel!
    @IBOutlet weak var contactAdminLbl: UILabel!
    @IBOutlet weak var rippleEffect : LNBRippleEffect!
    lazy var lang = Language.default.object
    var reference: DatabaseReference?
    var isCalled : Bool = false
    var timerAni = Timer()
    var timerBack = Timer()
    var carCount: Int = 0
    var pickUpLatitude: CLLocationDegrees = 0.0
    var pickUpLongitude: CLLocationDegrees = 0.0
    var drop_latitude : CLLocationDegrees = 0.0
    var drop_longitude : CLLocationDegrees = 0.0
    var strCarType = ""
    var isDriverAcceptedMyRequest : Bool = false
    lazy var spinnerView = JTMaterialSpinner()
    lazy var dictParams = JSON()
    var path : GMSPath!
    var timerDriverLocation = Timer()
    lazy var animationView : AnimationView? = nil
    lazy var gif = UIView()
    
    var mapView : GMSMapView?
    var bgRipple : UIView?
    var circular : BIZCircularProgressView?
    // MARK: - ViewController Methods
    
    func addReqViews() {
        
        // MapView Setup
        self.mapView = GMSMapView()
        self.view.addSubview(mapView!)
        self.mapView?.anchor(toView: self.view,
                             leading: 0,
                             trailing: 0,
                             top: 0,
                             bottom: 0)
        self.onChangeMapStyle()
        self.configureMap()
        self.setPickUpLocation()
        // Ripple Setup
        self.bgRipple = self.getLoaderGif(forFrame: self.mapView!.frame)
        self.mapView?.addSubview(self.bgRipple!)
        self.bgRipple?.anchor(toView: self.mapView!,
                              leading: 0,
                              trailing: 0,
                              top: 0,
                              bottom: 0)
        
        // Circular View Setup
        self.circular = BIZCircularProgressView()
        self.bgRipple?.addSubview(self.circular!)
        self.circular?.anchor(toView: self.bgRipple!)
        self.circular?.centerXAnchor.constraint(equalTo: self.bgRipple!.centerXAnchor).isActive = true
        self.circular?.centerYAnchor.constraint(equalTo: self.bgRipple!.centerYAnchor).isActive = true
        self.circular?.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.circular?.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.circular?.isRoundCorner = true
            self.circular?.progressLineWidth = 8
        }
        
        let progressView = BIZProgressViewHandler.init(progressView: circular, minValue: 0, maxValue: 9)
        progressView?.liveProgress = true
        progressView?.delegate = self
        progressView?.start()
        
        // Label Setup
        self.circular?.addSubview(self.lblCarType)
        self.lblCarType.anchor(toView: self.circular!,
                               leading: 10,
                               trailing: -10,
                               top: 10,
                               bottom: -10)
        self.lblCarType.transform = CGAffineTransform(rotationAngle: .pi/2)
        
        // accept Btn
        self.btnAccept.setTitle("", for: .normal)
        self.lblCarType.addSubview(self.btnAccept)
        self.btnAccept.anchor(toView: self.lblCarType,
                              leading: 0,
                              trailing: 0,
                              top: 0,
                              bottom: 0)
    }
    
    func removeReqViews() {
        self.mapView?.removeFromSuperview()
        self.mapView = nil
        self.bgRipple = nil
        self.circular = nil
        self.view.addSubview(self.viewNoRideAvailble)
        self.viewNoRideAvailble.anchor(toView: self.view,
                                       leading: 0,
                                       trailing: 0,
                                       top: 0,
                                       bottom: 0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        lblCarType.text = self.lang.contacting + " " + "\(strCarType)" + " " + self.lang.nearYou
        self.tryAgainBtn.setTitle(self.lang.tryAgain, for: .normal)
        self.callBtn.setTitle(self.lang.call, for: .normal)
        self.sryNoRideLbl.text = self.lang.sorryNoRides
        self.contactAdminLbl.text = self.lang.contactAdmin
        viewNoRideAvailble.isHidden = true
        btnBack.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.initLayer()
        }
       
        
        
        btnAccept.backgroundColor = UIColor.clear
        onCallTimer()
//        self.addReqViews()
//        setPickUpLocation()
        callRequestNewTaxiAPI()
        
//        self.configureMap()
        
//yamini hiding it
//        NotificationCenter.default.addObserver(self, selector: #selector(self.gotoMainView), name: Notification.Name(rawValue: NotificationTypeEnum.RequestAccepted.rawValue), object: nil)
           
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNoCarsPage), name: Notification.Name(rawValue: NotificationTypeEnum.no_cars.rawValue), object: nil)
    }
    func configureMap() {
        self.mapView?.clear()
        let pickup  = CLLocationCoordinate2D(
            latitude: self.pickUpLatitude,
            longitude: self.pickUpLongitude
        )
        let drop = CLLocationCoordinate2D(
            latitude: self.drop_latitude,
            longitude: self.drop_longitude
        )
        let pickUpMarker = GMSMarker()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView.image = UIImage(named: "circle")
        pickUpMarker.iconView = imageView

//        pickUpMarker.icon = UIImage(named: "pickup_icon_pin.png")
        pickUpMarker.position = pickup
        pickUpMarker.map = self.mapView
        
        let dropMarker = GMSMarker()
        let imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView2.image = UIImage(named: "box")
        dropMarker.iconView = imageView2

//        dropMarker.icon = UIImage(named: "dropoff_icon_pin.png")
        dropMarker.position = drop
        dropMarker.map = self.mapView
        
        let polyline = GMSPolyline(path: self.path)
        polyline.strokeColor = .ThemeYellow
        polyline.strokeWidth = 2
        polyline.geodesic = true
        polyline.map = self.mapView
        
        let bounds = GMSCoordinateBounds()
        bounds.includingPath(self.path)
        
        bounds.includingCoordinate(pickup)
        bounds.includingCoordinate(drop)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 15)
        self.mapView?.moveCamera(update)
        self.mapView?.animate(toZoom: 13)
        self.mapView?.isUserInteractionEnabled = false
        self.setDesign()
    }
    func setDesign()
    {
        self.lblCarType.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.lblCarType.textColor = .Title
        self.callBtn.backgroundColor = .ThemeYellow
        self.callBtn.cornerRadius = 15
        self.callBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.callBtn.setTitleColor(.Title, for: .normal)
        self.callBtn.tintColor = .Title
        self.contactAdminLbl.textColor = .Title
        self.contactAdminLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.sryNoRideLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.sryNoRideLbl.textColor = .Title
        self.tryAgainBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.tryAgainBtn.setTitleColor(.Title, for: .normal)

    }
    func initLayer(){
        self.viewNoRideAvailble.frame = self.view.bounds
        self.googleMapView.removeFromSuperview()
        self.googleMapView = nil
        self.rippleEffect.isHidden = true
        /*
         btnAccept.frame = CGRect(x: 0, y: (self.view.frame.size.height - (self.view.frame.size.height + 80 - viewDetailHoder.frame.size.height)) / 2, width: self.view.frame.size.width, height: self.view.frame.size.width)
         
         viewCircular.frame = CGRect(x: (self.view.frame.size.width - (self.view.frame.size.width-70)) / 2, y: (self.view.frame.size.height - (self.view.frame.size.height + 10 - viewDetailHoder.frame.size.height)) / 2, width: self.view.frame.size.width-70, height: self.view.frame.size.width-70)*/
        
        /*
         googleMapView.frame = frame*/
//        googleMapView.isRoundCorner = true
//        googleMapView.layer.borderColor = UIColor.lightGray.cgColor
//        googleMapView.layer.borderWidth = 1.0
//        let rippleAnimation = self.createLottieView()
//        self.animationView = rippleAnimation
//        self.animationView?.center = self.view.center
//         rippleEffect = LNBRippleEffect(image: UIImage(named: ""), frame: self.rippleEffect.frame, color: UIColor(red: CGFloat((28.0 / 255.0)), green: CGFloat((212.0 / 255.0)), blue: CGFloat((255.0 / 255.0)), alpha: CGFloat(1)), target: #selector(self.onCallTimer), id: self)
//        rippleEffect.setRippleColor(UIColor.clear)
//        rippleEffect.setRippleTrailColor(UIColor(red: CGFloat((28.0 / 255.0)), green: CGFloat((212.0 / 255.0)), blue: CGFloat((255.0 / 255.0)), alpha: CGFloat(0.5)))
//        self.view.addSubview(rippleEffect)
//        self.view.insertSubview(rippleAnimation, at: 0)
//        gif = self.getLoaderGif(forFrame: self.view.frame)
//        self.view.addSubview(viewNoRideAvailble)
//        view.addSubview(gif)
//        gif.frame = view.frame
//        gif.center = view.center

//        self.view.bringSubviewToFront(self.googleMapView)
//        self.view.bringSubviewToFront(self.btnAccept)
//        self.view.bringSubviewToFront(gif)
//        self.viewCircular.addSubview(self.lblCarType)
//        self.view.bringSubviewToFront(self.viewCircular)
//        self.view.bringSubviewToFront(self.lblCarType)
            self.addReqViews()

//        self.view.bringSubviewToFront(self.animationView!)


        /*
         self.view.addSubview(googleMapView)
         self.view.addSubview(btnAccept)
         self.view.addSubview(btnBack)
         */

    }
    func createLottieView() -> AnimationView{

        let animationView = AnimationView.init(name: "rab")

//        animationView.frame = CGRect(x: self.rippleEffect.frame.origin.x - 35 , y: self.rippleEffect.frame.origin.y - 70, width: self.rippleEffect.frame.width + 70, height: self.rippleEffect.frame.height + 140)
        animationView.frame = self.view.bounds
        // 3. Set animation content mode

        animationView.contentMode = .scaleAspectFill

        // 4. Set animation loop mode

        animationView.loopMode = .loop

        // 5. Adjust animation speed

        animationView.animationSpeed = 0.5


        // 6. Play animation

        animationView.play()
        return animationView
    }
    func setUpFirebaseObservers(){
         // yamini hiding it
        if let userID : String = UserDefaults.value(for: .user_id){
            self.reference = FireBaseNodeKey
                .rider
                .getReference(for: "\(userID)","trip_id")
            self.reference?.setValue("0")
            self.reference?.observe(.value) { (data) in
                let currentTrip : Int = UserDefaults.value(for: .current_trip_id) ?? 0
                guard let newTripID = data.value as? String,
                !["0",currentTrip.description].contains(newTripID) else {return}
                UserDefaults.set(Int(newTripID), for: .current_trip_id)
                /*
                 * 2.3
                     let appDelegate = UIApplication.shared.delegate as! AppDelegate
                     appDelegate.onSetRootViewController(viewCtrl: nil)
                 */
                 Shared.instance.resumeTripHitCount = 0
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
                FireBaseNodeKey.rider.getReference(for: "\(userID)").removeValue()
            }
            
            
        } 
    }
    //SHOW NO CAR PAGE
    //MARK:- initWithStory
    class func initWithStory(params : JSON,
                             carType : String,
                             carCount : Int,
                             path : GMSPath,
                             pickUp : CLLocationCoordinate2D,
                             drop : CLLocationCoordinate2D) -> MakeRequestVC{
        let makeRequest : MakeRequestVC = UIStoryboard.tripBooking.instantiateViewController()
        makeRequest.dictParams = params
        makeRequest.strCarType = carType
        makeRequest.carCount = carCount
        makeRequest.path = path
        makeRequest.pickUpLatitude = pickUp.latitude
        makeRequest.pickUpLongitude = pickUp.longitude
        makeRequest.drop_latitude = drop.latitude
        makeRequest.drop_longitude = drop.longitude
        return makeRequest
        
    }
    
    @objc func showNoCarsPage()
    {
        timerDriverLocation.invalidate()
//        self.gif.isHidden = true
        self.lblCarType.isHidden = true
        if viewNoRideAvailble.isHidden
        {
            
            viewNoRideAvailble.isHidden = false
            btnBack.isHidden = false
            self.removeReqViews()
//            self.viewCircular.isHidden = true
//            self.googleMapView.isHidden = true
//            self.btnAccept.isHidden = true
//            self.rippleEffect.isHidden = true
            return
          
        }
    }
    
    
    // MARK: API CALL - Request To Book
    /*
     */
    func callRequestNewTaxiAPI()
    {
        self.setUpFirebaseObservers()
        let wallet = Constants().GETVALUE(keyname: USER_SELECT_WALLET)
        print("wallet\(wallet)")
        PaymentOptions.default?.setAsDefault()
              
        if wallet == "Yes"{            
            let wallectamount = Constants().GETVALUE(keyname: USER_WALLET_AMOUNT)
            let amount:Double = (wallectamount as NSString).doubleValue
            let wall_amt = String(format: "%.2f", amount)
            print("aaa\(wall_amt)")
            if wallectamount == "0.00" {
                let wallet = "No"
                Constants().STOREVALUE(value: wallet , keyname: USER_SELECT_WALLET)
            }
            else{
                
                let wallet = "Yes"
                Constants().STOREVALUE(value: wallet , keyname: USER_SELECT_WALLET)
            }
        }
        else{
            let wallet = "No"
            Constants().STOREVALUE(value: wallet , keyname: USER_SELECT_WALLET)
            
        }
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + 10.0 + (self.carCount == 0 ? 120.0 : Double(self.carCount * 5))) {
                if !self.isDriverAcceptedMyRequest{
                    //self.timerDriverLocation.isValid &&
                    self.showNoCarsPage()
                }
        }
        dictParams["polyline"] = self.path.encodedPath()
        self.wsToMakeRequest(params: dictParams)
        /*UberAPICalls().GetRequest(dictParams,methodName: METHOD_SENDING_REQUEST_TO_CAR as NSString, forSuccessionBlock:{(_ response: Any) -> Void in
            let gModel = response as! GeneralModel
            
            OperationQueue.main.addOperation {
                UberSupport().removeProgress(viewCtrl: self)
               
              
                if gModel.status_code == "1"
                {
                    
                }
                else
                {
                    if gModel.status_message == "user_not_found" || gModel.status_message == "token_invalid" || gModel.status_message == "Invalid credentials" || gModel.status_message == "Authentication Failed"
                    {
                        let userDefaults = UserDefaults.standard
                        userDefaults.set("", forKey:"getmainpage")
                        userDefaults.synchronize()
                        self.appDelegate.onSetRootViewController(viewCtrl:self)
                    }
                    else
                    {
                        
                    }
                }
                
            }
        }, andFailureBlock: {(_ error: Error) -> Void in
            OperationQueue.main.addOperation {
                
            }
        })*/
    }
    func wsToMakeRequest(params requestJSON : JSON){
        var params = requestJSON
        let paymode = PaymentOptions.default
        let wallet = Constants().GETVALUE(keyname: USER_SELECT_WALLET)
        var localTimeZoneName: String { return TimeZone.current.identifier }
        params["timezone"] = localTimeZoneName

        params["user_type"] = "Rider"
        params["payment_method"] = paymode?.paramValue ?? "cash"
        params["is_wallet"] = wallet
        
        self.apiInteractor?
            .getRequest(for: .requestCars,
                        params: params)
            .responseJSON({ (response) in   
                print(response.status_code.description)
            }).responseFailure({ (error) in
//                self.appDelegate.createToastMessage(error)
            })
        
        
    }
    //MARK: - WHEN DRIVER ACCEPTING REQUEST
    /*
     NOTIFICATION TYPE GET DRIVER DETAIL
     */
    @objc func gotoMainView(notification: Notification)
     {
        self.isDriverAcceptedMyRequest = true
        timerDriverLocation.invalidate()
        let str2 = notification.userInfo
        let info: [AnyHashable: Any] = [
            "trip_id" : str2?["trip_id"] as? String ?? String(),
            "arrival_time" : str2?["arrival_time"] as? String ?? String(),
            "car_name" : str2?["car_name"] as? String ?? String(),
            "pickup_location" : str2?["pickup_location"] as? String ?? String(),
            "driver_name" : str2?["driver_name"] as? String ?? String(),
            "drop_location" : str2?["drop_location"] as? String ?? String(),
            "rating" : str2?["rating"] as? String ?? String(),
            "vehicle_name" : str2?["vehicle_name"] as? String ?? String(),
            "vehicle_number" : str2?["vehicle_number"] as? String ?? String(),
            "trip_status" : str2?["trip_status"] as? String ?? String(),
            "mobile_number" : str2?["mobile_number"] as? String ?? String(),
            "driver_thumb_image" : str2?["driver_thumb_image"] as? String ?? String(),
            "driver_latitude" : str2?["driver_latitude"] as? String ?? String(),
            "driver_longitude": str2?["driver_longitude"] as? String ?? String(),
            "drop_latitude" : str2?["drop_latitude"] as? String ?? String(),
            "drop_longitude" : str2?["drop_longitude"] as? String ?? String(),
            "pickup_latitude" : str2?["pickup_latitude"] as? String ?? String(),
            "pickup_longitude" : str2?["pickup_longitude"] as? String ?? String(),
            "type" : "accept_request"
        ]
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.GetDriverDetails.rawValue), object: self, userInfo: info)
    }
    //SET THE PICKUP LOCCATION TO  MAP
    func setPickUpLocation()
    {
        let camera = GMSCameraPosition.camera(withLatitude: pickUpLatitude, longitude: pickUpLongitude, zoom: 15.0)
        GMSMapView.map(withFrame: mapView!.frame, camera: camera)
        mapView?.camera = camera
        
    }
    
    func onGoBack()
    {
        timerAni.invalidate()
        self.gif.removeFromSuperview()
        rippleEffect.stopRippleAnimation()
        self.navigationController?.popViewController(animated: true)
    }
    
    internal func progressViewHandler(_ progressViewHandler: BIZProgressViewHandler!, didFinishProgressFor progressView: BIZCircularProgressView!) {
        timerAni.invalidate()
        rippleEffect.stopRippleAnimation()
        btnAccept.layer.borderWidth = 0.0
    }
    
    @objc func onCallTimer()
    {
        playSound("ub__reminder")
    }
    
    // set the request sound
    func playSound(_ fileName: String) {
        let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    // MARK: When User Press try again Button
    
    @IBAction func onTryAgainTapped()
    {
        
        viewNoRideAvailble.isHidden = true
        btnBack.isHidden = true
        gif.isHidden = false
        lblCarType.isHidden = false
        self.viewCircular.isHidden = false
        self.addReqViews()
//        self.googleMapView.isHidden = false
        self.btnAccept.isHidden = false
        self.rippleEffect.isHidden = false
        self.isDriverAcceptedMyRequest = false
//        self.configureMap()
        btnBack.isHidden = true
        viewNoRideAvailble.isHidden = true
        self.callRequestNewTaxiAPI()
    }
    // MARK: When User Press accept Button
    
    @IBAction func onAcceptTapped()
    {
    }
    @IBAction func onContactDriverAction(_ sender : UIButton?){
        self.callAdminForManualBooking()
    }
    func gotoToRouteView()
    {
        playSound("requestaccept")
    }
    
    func animateBorderWidth(view: UIButton, from: CGFloat, to: CGFloat, duration: Double) {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        view.layer.add(animation, forKey: "Width")
        view.layer.borderWidth = to
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func createLottieView(view: UIView) -> AnimationView{
        
        let animationView = AnimationView.init(name: "request")
        
        animationView.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView.loopMode = .loop
        
        // 5. Adjust animation speed
        
        animationView.animationSpeed = 1.5
        
        // 6. Play animation
        
        animationView.play()
        return animationView
    }
    
    func getLoaderGif(forFrame parentFrame: CGRect) -> UIView {
        // Creatting a Background View
        let view = UIView()
        view.backgroundColor = .clear
        view.frame = parentFrame
        
        // Creatting a Lottie Loader View
        let loader = self.createLottieView(view: view)
        view.addSubview(loader)
        
        // Setting Loader For Loader View
        loader.anchor(toView: view)
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loader.heightAnchor.constraint(equalToConstant: 500).isActive = true
        loader.widthAnchor.constraint(equalToConstant: 500).isActive = true
        
        // Setting Tag For The Loader
        view.tag = 100
        
        return view
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController!.popViewController(animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
    internal func RetryTapped()
    {
        
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
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                //                print("Unable to find style.json")
            }
        } catch {
            //            print("The style definition could not be loaded: \(error)")
        }
        
    }
    
    
}



extension MakeRequestVC:MenuResponseProtocol {
    func routeToView(_ view: UIViewController) {
        
    }
    
    func callAdminForManualBooking() {
        self.checkMobileNumeber(isDirectCall: true)
    }
}

extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 3750)
        
        return animation
    }
}
