/**
 * AddLocationVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */



import UIKit
import Foundation
import MapKit
import AGPullView
import GoogleMaps
import GooglePlaces

protocol addLocationDelegate
{
    func onLocationAdded(latitude: CLLocationDegrees, longitude: CLLocationDegrees, locationName: String)
}


class AddLocationVC : UIViewController,UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource, AGConfiguratorDelegate,GMSMapViewDelegate,CLLocationManagerDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var viewTopHolder: UIView!
    @IBOutlet weak var txtPickUpLoc: UITextField!
    @IBOutlet weak var tblLocations: UITableView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickupView: UIView!
    @IBOutlet weak var pinLocationImage: UIImageView!

    var usingPinToGetLocation : Bool = false {
        didSet{
            if self.usingPinToGetLocation{
                self.btnDone.isHidden = false
                self.pinLocationImage.isHidden = false
            }else{
                self.btnDone.isHidden = true
                self.pinLocationImage.isHidden = true
            }
            self.tblLocations.reloadData()
        }
    }
    lazy var language:LanguageProtocol = Language.default.object
    var selectedLocation: LocationModel!
    var currentLocation: CLLocation!
    lazy var autocompletePredictions = [GooglePlacesModel]()
    weak var locationAnnotation: MKAnnotation?
    var selectedCell : CellLocations!
    var pickUpLatitude: CLLocationDegrees = 0.0
    var pickUpLongitude: CLLocationDegrees = 0.0
    var searchCountdownTimer: Timer?
    var searchMapCountdownTimer: Timer?
    var locationManager: CLLocationManager!
//    let configurator = AGPullViewConfigurator()
    var delegate: addLocationDelegate?
    var isReadyToDrag: Bool = false
    var isCurrentLocationGot: Bool = false
    var isFromHomeLocation: Bool = false
    var isKeyBoardShown: Bool = false
//    let arrMenus: [String] = ["Set pin location"]
    let arrMenus: [String] = [Language.default.object.setPin]
    let arrImgs: [String] = ["map location"]
    
    var isCurrentLocationSet : Bool = false
    let userDefaults = UserDefaults.standard
    var strCurrentLocName = ""
    var firstlocation = ""
    var simval = ""
    var animateView = UIView()
//    var googleMapView = GMSMapView()

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        if language.isRTLLanguage(){
            btnDone.setTitle(self.language.done, for: .normal)
        }
        self.initView()
    }
    func initView(){
        if #available(iOS 10.0, *) {
            txtPickUpLoc.keyboardType = .asciiCapable
            
        } else {
            // Fallback on earlier versions
            txtPickUpLoc.keyboardType = .default
        }
        txtPickUpLoc.setLeftPaddingPoints(10)
        txtPickUpLoc.setRightPaddingPoints(10)
        self.initGooglePlaceSearch()
        self.onChangeMapStyle()
        updateCurrentLocation()
        googleMapView.delegate = self
        pinLocationImage.center = googleMapView.center
        self.view.bringSubviewToFront(viewTopHolder)
        self.outerView.isHidden = false
        self.tblLocations.isHidden = false

        //self.startAnimation(whereTo: viewTopHolder.frame.height, animationView: animateView)
//        self.configurator.setupPullView(forSuperview: viewDummy, colorScheme:ColorSchemeTypeDarkTransparent)
//        self.configurator.percentOfFilling = 96
//        self.configurator.delegate = self
//        self.configurator.needBounceEffect = true
//        self.configurator.animationDuration = 0.3
//        self.configurator.enableShowingWithTouch = true;
//        self.configurator.enableHidingWithTouch = false;
//        self.configurator.enableBlurEffect(withBlurStyle: .dark)
//        //configurator.show(animated: true)
//        self.configurator.fullfillContentView(with: tblLocations)
//        viewDummy.backgroundColor = UIColor.clear
//        self.view.bringSubviewToFront(viewDummy)
        txtPickUpLoc.placeholder = isFromHomeLocation ? self.language.enterHome :  self.language.enterWork
        txtPickUpLoc.delegate = self
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.onReadyToSearchMap), userInfo: nil, repeats: false)
        // Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.onShowKeyboard), userInfo: nil, repeats: false)
        
        //        self.applyTopMargin(forView: self.viewTopHolder)
        //        self.viewTopHolder.elevate(0)
        //        self.tblLocations.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        //        self.applyTopMargin(forView: self.tblLocations)
        //        self.applyTopMargin(toViews: self.view.subviews)
        txtPickUpLoc.textAlignment = self.language.getTextAlignment(align: .left)
        self.setDesign()
        self.pinLocationImage.isHidden = true
        self.btnDone.isHidden = true
        self.usingPinToGetLocation = true
        self.initial(ishide: true)

    }
    func initial(ishide: Bool){
        self.googleMapView.isHidden = ishide
        self.tblLocations.isHidden = !ishide
        self.pinLocationImage.isHidden = ishide
        self.btnDone.isHidden = ishide

    }
    func setDesign()
    {
        self.backBtn.setTitleColor(.Title, for: .normal)
        self.titleLabel.text = self.isFromHomeLocation ? self.language.addHomeLoc : self.language.addWorkLoc
        self.titleLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.titleLabel.textColor = .Title
        self.pickupView.cornerRadius = 15
        self.pickupView.border(1, .Border)
        self.outerView.setSpecificCornersForTop(cornerRadius: 45)
        self.outerView.elevate(4)
        self.btnDone.cornerRadius = 15
        self.btnDone.backgroundColor = .ThemeYellow
        self.btnDone.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.btnDone.setTitleColor(.Title, for: .normal)
        self.txtPickUpLoc.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtPickUpLoc.textColor = UIColor.Title

    }
    func onShowKeyboard()
    {
        guard !self.isReadyToDrag else {return}
        txtPickUpLoc.becomeFirstResponder()
        isKeyBoardShown = true
    }
    //MARK:- Actions
    @objc func onReadyToSearchMap()
    {
        //isReadyToDrag = true
    }
    
    @IBAction func onDummyViewTapped()
    {
        simval = "1"
        self.searchMapCountdownTimerFired()
//        viewDummy.isHidden = true
        btnDone.backgroundColor = UIColor.ThemeInactive
        btnDone.isUserInteractionEnabled = false
    }
    
    @IBAction func onDummyPickupTapped()
    {
//        self.configurator.hide(animated: true)
    }
    //MARK:- initWithStory
    class func initWithStory(_ delegate : addLocationDelegate) -> AddLocationVC{
        let addLocationVC : AddLocationVC = UIStoryboard.payment.instantiateViewController()
        addLocationVC.delegate = delegate
        return addLocationVC
    }
    //MARK:- initilaizers
    func initGooglePlaceSearch()
    {
        let longitude = userDefaults.value(forKey: USER_LONGITUDE) as? String
        let latitude = userDefaults.value(forKey: USER_LATITUDE) as? String
        if ((longitude != nil && longitude != "") && (latitude != nil && latitude != ""))
        {
            let longitude1 :CLLocationDegrees = Double(longitude!)!
            let latitude1 :CLLocationDegrees = Double(latitude!)!
            let location = CLLocation(latitude: latitude1, longitude: longitude1)
            pickUpLatitude = latitude1
            pickUpLongitude = longitude1
            self.currentLocation = location
        }
//        dataLoader = GooglePlacesDataLoader.init(delegate: self)
        selectedLocation = LocationModel()
    }
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        viewTopHolder.removeFromSuperview()
    }
    
//    //For correct working of layout in early versions of iOS 10
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        self.configurator.layoutPullView()
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.configurator.handleTouchesBegan(touches)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.configurator.handleTouchesMoved(touches)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.configurator.handleTouchesEnded(touches)
//    }
//
    func didDrag(_ pullView: AGPullView!, withOpeningPercent openingPercent: Float) {
    }
    
    func didShow(_ pullView: AGPullView!) {
        if isKeyBoardShown && !self.isReadyToDrag
        {
            txtPickUpLoc.becomeFirstResponder()
        }
//        viewDummy.isHidden = false
    }
    
    func didHide(_ pullView: AGPullView!) {
        txtPickUpLoc.resignFirstResponder()
//        viewDummy.isHidden = true
    }
    func didTouch(toShow pullView: AGPullView!) {
    }
    
    func didTouch(toHide pullView: AGPullView!) {
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.isNavigationBarHidden = true
        if self.locationManager == nil{
            self.locationManager = CLLocationManager()
        }
        
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    func deinitObjects(){
        self.autocompletePredictions.removeAll()
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
        self.locationManager = nil
        self.googleMapView.delegate = nil
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: NotificationTypeEnum.EndTrip.rawValue), object: nil)
        LoadingManager.instance.showUBL(self, show: false)
        self.animateView.layer.removeAllAnimations()
        self.searchCountdownTimer?.invalidate()
        self.searchMapCountdownTimer?.invalidate()
        self.searchCountdownTimer = nil
        self.searchMapCountdownTimer = nil
    }
    // MARK: TextField Delegate Method
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        if (textField.text?.count)! > 0
        {
            self.animateView.isHidden = false
            self.startCountdownTimer(forSearch: textField.text!)
        }
        else
        {
            self.autocompletePredictions = [GooglePlacesModel]()
            tblLocations.reloadData()
        }
    }
    
    func startCountdownTimer(forSearch searchString: String) {
        //stop the current countdown
        let fireDate : Date
        if self.searchCountdownTimer == nil || !self.searchCountdownTimer!.isValid{
            fireDate = Date(timeIntervalSinceNow: 1.0)
        }else{
            fireDate = Date(timeIntervalSinceNow: 1.35)
        }
        self.searchCountdownTimer?.invalidate()
    
        //cancel all pending requests
//        self.dataLoader?.cancelAllRequests()
        // add search data to the userinfo dictionary so it can be retrieved when the timer fires
        let info: [AnyHashable: Any] = [
            "searchString" : searchString,
        ]
        
        self.searchCountdownTimer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(self.startAutoComplete), userInfo: info, repeats: false)
        
        RunLoop.main.add(self.searchCountdownTimer!, forMode: RunLoop.Mode.default)
        
    }
    var hitCount = 0
    @objc func startAutoComplete(_ countdownTimer: Timer) {
        let searchString = countdownTimer.userInfo as! NSDictionary
        let newsearchString: String? = searchString["searchString"] as? String
        
       
        guard let newSearch = newsearchString,
            !newSearch.isEmpty else {return}
        guard (self.txtPickUpLoc.text?.count ?? -1) == newSearch.count else{
            self.autocompletePredictions = [GooglePlacesModel]()
            tblLocations.reloadData()
            return
        }
        self.hitCount += 1
        print("∂HitCount : \(self.hitCount)")
//        self.dataLoader?.sendAutocompleteRequest(withSearch: newSearch, andLocation: nil)
        let placesClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        placesClient.findAutocompletePredictions(fromQuery: newSearch,bounds: nil, boundsMode: .bias, filter: nil, sessionToken: nil) { (results, error) in
            if results == nil {
                print("Error",error as Any)
                return
            }
            if let autoComplete = results {
                self.autocompletePredictions.removeAll()
                autoComplete.forEach { (model) in
                    let placeModel = GooglePlacesModel(title: model.attributedPrimaryText.string, address: model.attributedSecondaryText?.string ?? "", placeId: model.placeID, fullAddress: model.attributedFullText.string)
                    self.autocompletePredictions.append(placeModel)
                }
            }
            self.tblLocations.reloadData()
        }
    }
    
    //text field delegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if textField.text?.count == 1 && string == "" {
            self.autocompletePredictions.removeAll()
            self.tblLocations.reloadData()
            return true
        }
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == txtPickUpLoc
        {
            if txtPickUpLoc.text == self.language.currentLocation
            {
                txtPickUpLoc.text = ""
            }
        }
        else
        {
            if txtPickUpLoc.text?.count == 0
            {
                txtPickUpLoc.text = self.language.currentLocation
            }
            
        }
        usingPinToGetLocation = false
        self.initial(ishide: true)
    }
    
    
    // MARK: Navigating to Side Menu View
    @IBAction func onSearchTapped(_ sender:UIButton!)
    {
    }
    
    // MARK: Navigating to Side Menu View
    @IBAction func onProfileTapped(_ sender:UIButton!)
    {
        let propertyView = UIStoryboard.jeba.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: - **** Table View Delegate End ****
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if self.autocompletePredictions.count == 0
        {
            return 60
        }
        else
        {
            return 85
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.autocompletePredictions.count == 0
        {
            return 85
        }
        else
        {
            return 85
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if self.usingPinToGetLocation{
//            tableView.backgroundView = self.googleMapView
//            return 0
//        }
//        tableView.backgroundView = nil
         self.animateView.isHidden = true
        return (self.autocompletePredictions.count == 0) ? arrMenus.count : self.autocompletePredictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        self.isReadyToDrag = false
        if self.autocompletePredictions.count == 0
        {
            let cell:CellItems = tblLocations.dequeueReusableCell(withIdentifier: "CellItems") as! CellItems
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblName?.text = arrMenus[indexPath.row]
            cell.lblIconName?.image = UIImage(named: arrImgs[indexPath.row])
            cell.lblName?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
            cell.lblName?.textColor = .Title
//            if arrMenus.count > 1 {
//                if indexPath.row == 0 {
//                    cell.contentView.setSpecificCornersForTop(cornerRadius: 25)
//                }else if indexPath.row == arrMenus.count - 1 {
//                    cell.contentView.setSpecificCornersForBottom(cornerRadius: 25)
//                }
//                else{
//                    cell.contentView.cornerRadius = 0
//                }
//            }else{
//                cell.contentView.cornerRadius = 10
//            }
            cell.outerView.backgroundColor = .clear
            return cell
        }
        else
        {
            let titleString = self.autocompletePredictions.value(atSafe: indexPath.row)?.fullAddress
            let addresArray  = titleString?.components(separatedBy: ",")
            let finalTitle: String? = ((addresArray?.count)! > 0) ? addresArray?[0] : ""
            var finalSubTitle: String = ""
            let count = (addresArray?.count)! as Int
            for i in 1 ..< count
            {
                finalSubTitle = finalSubTitle + (addresArray?[i])!
                if i < (addresArray?.count)! - 1 {
                    if i == 1
                    {
                        finalSubTitle = finalSubTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    
                    finalSubTitle = finalSubTitle + ","
                }
            }
            
            let cell:CellLocations = tblLocations.dequeueReusableCell(withIdentifier: "CellLocations") as! CellLocations
            cell.lblTitle?.text = finalTitle
            let trimmedString = finalSubTitle.trimmingCharacters(in: .whitespaces)
            cell.lblSubTitle?.text = trimmedString
            cell.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
            cell.lblTitle?.textColor = .Title
            cell.lblSubTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 11)
            cell.lblSubTitle?.textColor = .Title

//            cell.lblIcon.image = UIImage(named: "map location")
            if autocompletePredictions.count > 1 {
                if indexPath.row == 0 {
                    cell.outerView.setSpecificCornersForTop(cornerRadius: 25)
                }else if indexPath.row == autocompletePredictions.count - 1 {
                    cell.outerView.setSpecificCornersForBottom(cornerRadius: 25)
                }
                else{
                    cell.outerView.cornerRadius = 0
                }
            }else{
                cell.outerView.cornerRadius = 10
            }
          
            cell.outerView.backgroundColor = .Background
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.autocompletePredictions.count == 0
        {
            let longitude = userDefaults.value(forKey: USER_LONGITUDE) as? String
            let latitude = userDefaults.value(forKey: USER_LATITUDE) as? String
            if ((longitude != nil && longitude != "") && (latitude != nil && latitude != ""))
            {
                self.selectedLocation.longitude = String(format: "%2f", self.currentLocation.coordinate.longitude)
                self.selectedLocation.latitude = String(format: "%2f", self.currentLocation.coordinate.latitude)
            }
            else
            {
                selectedLocation.searchedAddress = ""
                self.selectedLocation.longitude = ""
                self.selectedLocation.latitude = ""
            }
            
            if indexPath.row == 0
            {
//                guard self.locationManager != nil,
//                    LocationManager.instance.isAuthorized else {return}
//                self.usingPinToGetLocation = true
//                self.isReadyToDrag = true
//                txtPickUpLoc.resignFirstResponder()
//                self.onDummyViewTapped()
//                simval = "1"
                self.initial(ishide: false)
                self.onDummyViewTapped()

                simval = "1"
                self.isReadyToDrag = true
                txtPickUpLoc.resignFirstResponder()


            }
        }
        else
        {
            selectedCell = tableView.cellForRow(at: indexPath) as! CellLocations
            
//            let adict = self.locationDescription(at: indexPath.row) as NSDictionary
//            let title  = adict[RESPONSE_KEY_DESCRIPTION] as? String
            guard let title = self.autocompletePredictions.value(atSafe: indexPath.row)?.fullAddress else{return}

            let addresArray  = title.components(separatedBy: ",")
            let finalTitle: String? = ((addresArray.count) > 0) ? addresArray[0] : ""
            var finalSubTitle: String = ""
            let count = (addresArray.count) as Int
            for i in 1 ..< count
            {
                finalSubTitle = finalSubTitle + (addresArray[i])
                if i < (addresArray.count) - 1 {
                    if i == 1
                    {
                        finalSubTitle = finalSubTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    
                    finalSubTitle = finalSubTitle + ","
                }
            }
            let trimmedString = finalSubTitle.trimmingCharacters(in: .whitespaces)
            
            txtPickUpLoc.text = String(format:"%@ %@",finalTitle!,trimmedString)
            
            if txtPickUpLoc.text?.count == 0
            {
//                self.configurator.show(animated: true)
                self.outerView.isHidden = false
                self.tblLocations.isHidden = false
            }
            
            let selPrediction = self.autocompletePredictions[indexPath.row].placeId
//            let referenceID: String? = (selPrediction[RESPONSE_KEY_REFERENCE] as? String)
//            self.dataLoader?.cancelAllRequests()
            self.getLocationCoordinates(withReferenceID: selPrediction)
        }
    }
    // MARK:  **** Table View Delegate End ****
    
    // MARK: - **** Getting Latitude & Longitude from Google Place Search ****
    func getLocationCoordinates(withReferenceID referenceID: String)
    {
        var dicts = [AnyHashable: Any]()
        
        dicts["token"]   = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        let paramsComponent: String = "\(iApp.GOOGLE_MAP_DETAILS_URL)?key=\(iApp.instance.GoogleApiKey)&reference=\(referenceID)&sensor=\("true")"
        WebServiceHandler.sharedInstance.getThridPartyWebService(wsMethod: paramsComponent, paramDict: dicts as! [String : Any], viewController: self, isToShowProgress: false, isToStopInteraction: false) { (responseDict) in
            let gModel =  GoogleLocationModel.generateModel(from: responseDict)
            
            if gModel.status_code == "1"
            {
                let dictsTempsss = gModel.dictTemp[iApp.RESPONSE_KEY_RESULT] as! NSDictionary
                self.googleData(didLoadPlaceDetails: dictsTempsss)

            }else {
                
            }
        }
    
    }
    
    func googleData(didLoadPlaceDetails placeDetails: NSDictionary) {
        self.searchDidComplete(withPlaceDetails: placeDetails)
    }
    
    
    func searchDidComplete(withPlaceDetails placeDetails: NSDictionary)
    {
        let placeGeometry =  (placeDetails[iApp.RESPONSE_KEY_GEOMETRY]) as? NSDictionary
        let locationDetails  = (placeGeometry?[iApp.RESPONSE_KEY_LOCATION]) as? NSDictionary
        let lat = (locationDetails?[iApp.RESPONSE_KEY_LATITUDE] as? Double)
        let lng = (locationDetails?[iApp.RESPONSE_KEY_LONGITUDE] as? Double)
        
        selectedLocation.searchedAddress = (((placeDetails as Any) as AnyObject).value(forKey: "formatted_address") as? String ?? "")
        let longitude :CLLocationDegrees = Double(String(format: "%2f", lng!))!
        let latitude :CLLocationDegrees = Double(String(format: "%2f", lat!))!
        
        pickUpLatitude = latitude
        pickUpLongitude = longitude
        
        gotoMainMapView()
    }
    
    
    
   
    
    
    func gotoMainMapView()
    {
        self.autocompletePredictions = [GooglePlacesModel]()
        tblLocations.reloadData()
        if (txtPickUpLoc.text?.count)! > 0
        {
            self.gotoCarAvailblePage()
        }
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: false)
        
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
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 16.5, bearing: 0, viewingAngle: 0)
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
        locationManager.stopUpdatingLocation()
        if (!isCurrentLocationGot)
        {
            isCurrentLocationGot = true
            self.gettingLocationName(lat: coord.latitude, long: coord.longitude, isFromCurrentLocation: true)
        }
        self.setCurrentLocation(latitude: coord.latitude, longitude: coord.longitude)
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
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.5)
        GMSMapView.map(withFrame: googleMapView.frame, camera: camera)
        googleMapView.camera = camera
        googleMapView.isMyLocationEnabled = true
        CATransaction.commit()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    //MARK: **** END ****
    
    //MARK: - Change Map Style
    /*
     Here we are changing the Map style from Json File
     */
    func onChangeMapStyle()
    {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate at zoom level 6.
        
        //        googleMapView.setMinZoom(15.0, maxZoom: 55.0)
        let camera = GMSCameraPosition.camera(withLatitude: 9.917703, longitude: 78.138299, zoom: 4.0)
        GMSMapView.map(withFrame: googleMapView.frame, camera: camera)
        
        do {
            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
            if let styleURL = Bundle.main.url(forResource: "mapStyleChanged", withExtension: "json") {
                googleMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                //                print("Unable to find style.json")
            }
        } catch {
            //            print("The style definition could not be loaded: \(error)")
        }
    }
    
    @IBAction func onDoneTapped(_ sender: UIButton!)
    {
        gotoCarAvailblePage()
    }
    
    func gotoCarAvailblePage()
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.delegate?.onLocationAdded(latitude: self.pickUpLatitude, longitude: self.pickUpLongitude, locationName: self.txtPickUpLoc.text! ==  self.language.enterUrLocation ? self.strCurrentLocName : self.txtPickUpLoc.text!)
        })
        self.navigationController?.popViewController(animated: false)
        CATransaction.commit()
    }
    
    //MARK: - GOOGLE MAP DELEGATE METHOD
    var map_view_is_idle = true
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard !self.map_view_is_idle else{return}//Return if already in idle state
        self.map_view_is_idle = true
        defer {
            if isReadyToDrag{
                self.searchMapCountdownTimerFired()
            }
        }
        if(mapView.camera.zoom > 5)
        {
            //do your code here
        }
        //        print(position.target.latitude)
        //        print(position.target.longitude)
        pickUpLatitude = position.target.latitude
        pickUpLongitude = position.target.longitude
       
        
//        if (self.searchMapCountdownTimer != nil) {
//            self.searchMapCountdownTimer?.invalidate()
//        }
        
//        let fireDate = Date(timeIntervalSinceNow: 1.0)
//        self.searchMapCountdownTimer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(self.searchMapCountdownTimerFired), userInfo: nil, repeats: false)
//        RunLoop.main.add(self.searchMapCountdownTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.map_view_is_idle = false
        return
      /*  if(mapView.camera.zoom > 5)
        {
            //do your code here
        }
        //        print(position.target.latitude)
        //        print(position.target.longitude)
        if !isReadyToDrag
        {
            return
        }
        
        if (self.searchMapCountdownTimer != nil) {
            self.searchMapCountdownTimer?.invalidate()
        }
        
        pickUpLatitude = position.target.latitude
        pickUpLongitude = position.target.longitude
        
        let fireDate = Date(timeIntervalSinceNow: 1.0)
        self.searchMapCountdownTimer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(self.searchMapCountdownTimerFired), userInfo: nil, repeats: false)
        RunLoop.main.add(self.searchMapCountdownTimer!, forMode: RunLoopMode.defaultRunLoopMode)*/
    }
    
    //MARK:  **** END ****
    func searchMapCountdownTimerFired()
    {
        self.gettingLocationName(lat: pickUpLatitude, long: pickUpLongitude, isFromCurrentLocation: false)
    }
    
    var last_loc : CLLocation?
    func gettingLocationName(lat: CLLocationDegrees, long: CLLocationDegrees, isFromCurrentLocation: Bool)
    {
        
        var location = CLLocation(latitude: lat, longitude: long)
        if (lat == 0.0 && long == 0.0) || self.last_loc == location{
            self.map_view_is_idle = false
            let center = self.googleMapView.center
            let center_coords =  self.googleMapView.projection.coordinate(for: center)
            location = CLLocation(latitude: center_coords.latitude, longitude: center_coords.longitude)
            
        }
        self.last_loc = location
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if placemarks == nil
            {
                self.btnDone.backgroundColor = UIColor.ThemeYellow
                self.btnDone.isUserInteractionEnabled = true
                return
            }
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])
                if pm != nil
                {
                    let strLoc = self.stringPlaceMark(placemark: pm!)
                    if strLoc.count>0
                    {
                        if isFromCurrentLocation
                        {
                            self.strCurrentLocName = strLoc
                             print("strLochome \(strLoc)")
                            self.txtPickUpLoc.text = ""
                            if(self.txtPickUpLoc.placeholder == self.language.enterHome){
                                
                                self.txtPickUpLoc.text = ""
                                self.firstlocation = self.strCurrentLocName
                                
                                if(self.simval == "1"){
                                    self.txtPickUpLoc.text = strLoc
                                    self.btnDone.backgroundColor = UIColor.ThemeYellow
                                    self.btnDone.isUserInteractionEnabled = true
                                }
                            }
                            else if(self.txtPickUpLoc.placeholder == self.language.enterWork){
                                
                                self.txtPickUpLoc.text = ""
                                self.firstlocation = self.strCurrentLocName
                                
                                if(self.simval == "1"){
                                    self.txtPickUpLoc.text = strLoc
                                    self.btnDone.backgroundColor = UIColor.ThemeYellow
                                    self.btnDone.isUserInteractionEnabled = true
                                }
                            }
                        }
                        else
                        {
                            self.btnDone.backgroundColor = UIColor.ThemeYellow
                            self.btnDone.isUserInteractionEnabled = true
                            
                            self.txtPickUpLoc.text = strLoc
                        }
                    }
                }
                else{
                    
                    if(self.txtPickUpLoc.placeholder == self.language.enterHome){
                        
                        self.txtPickUpLoc.text = ""
                        
                        if(self.simval == "1"){
                            self.txtPickUpLoc.text = self.firstlocation
                            self.btnDone.backgroundColor = UIColor.ThemeYellow
                            self.btnDone.isUserInteractionEnabled = true
                        }
                    }
                    else if(self.txtPickUpLoc.placeholder == self.language.enterWork){
                        
                        self.txtPickUpLoc.text = ""
                        if(self.simval == "1"){
                            
                            self.txtPickUpLoc.text = self.firstlocation
                            self.btnDone.backgroundColor = UIColor.ThemeYellow
                            self.btnDone.isUserInteractionEnabled = true
                            
                        }
                    }
                    
                }
            }
        })
    }
    
    func stringPlaceMark(placemark: CLPlacemark) -> String {
        var string = String()
        
        
        if (placemark.thoroughfare != nil) {
            string += placemark.thoroughfare!
        }else if let subLocality = placemark.subLocality{
            string += subLocality
        }
        
        if (placemark.locality != nil)
        {
            if (string.count ) > 0 {
                string += ", "
            }
            string += placemark.locality!
        }
        
        if (placemark.administrativeArea != nil) {
            if (string.count ) > 0 {
                string += ", "
            }
            string += placemark.administrativeArea!
        }
        
        if (placemark.country != nil) {
            if (string.count ) > 0 {
                string += ", "
            }
            string += placemark.country!
        }
        
        return string
    }
}
