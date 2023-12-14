/**
 * SetLocationVC.swift
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
import Alamofire
import GooglePlaces

struct GooglePlacesModel {
    var title: String
    var address:String
    var placeId:String
    var fullAddress:String
}
class LocationModel {
    var searchedAddress = String()
    var longitude = String()
    var latitude = String()
    var currentLocation = CLLocation()
    init(){}
}
protocol setLocationDelegate : class
{
    func onExitSetLocation(from viewController : UIViewController)
    func onLocationTapped(pickUpLatitude: CLLocationDegrees, pickUpLongitude: CLLocationDegrees, dropLatitude: CLLocationDegrees, dropLongitude: CLLocationDegrees,dropLocName: String, pickUpLocName: String, scheduledTime:String?)
}
class SetLocationVC : UIViewController,UITableViewDelegate, UITableViewDataSource, AGConfiguratorDelegate,CLLocationManagerDelegate,addLocationDelegate,APIViewProtocol,UITextFieldDelegate
{
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
        case .RiderModel(let driver):
            dump(driver)
        default:
            print()
        }
    }
    func onFailure(error: String,for API : APIEnums) {
        print(error)
    }
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
    @IBOutlet weak var scheduledTimeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinLocationImage: UIImageView!
    @IBOutlet weak var tableOuterView: UIView!
    @IBOutlet weak var viewTopHolder: UIView!
    @IBOutlet weak var txtPickUpLoc: UITextField!
    @IBOutlet weak var txtDropLoc: UITextField!
    @IBOutlet weak var tblLocations: UITableView!
    @IBOutlet weak var btnPickUp: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var scheduledTimeLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    var selectedLocation = LocationModel()
    var currentLocation: CLLocation!
    var autocompletePredictions = [GooglePlacesModel]()
    weak var locationAnnotation: MKAnnotation?
    weak var appDelegate  = UIApplication.shared.delegate as? AppDelegate
    var pickUpLatitude: CLLocationDegrees = 0.0
    var pickUpLongitude: CLLocationDegrees = 0.0
    var dropLatitude: CLLocationDegrees = 0.0
    var dropLongitude: CLLocationDegrees = 0.0
    var searchCountdownTimer: Timer?
    var searchMapCountdownTimer: Timer?
    var locationManager: CLLocationManager?
    @IBOutlet weak var verticalBar: UIView!
    @IBOutlet weak var bottomCircleView: UIView!
    @IBOutlet weak var topCircleView: UIView!
    weak var delegate: setLocationDelegate?
    var isPickUpTapped: Bool = false
    var isDropTapped: Bool = true //false
    var isReadyToDrag: Bool = false
    var isCurrentLocationGot: Bool = false
    var isFromCarAvailablePage: Bool = false
    var isHomeTapped: Bool = false
    var isGoingAddLocaitonView: Bool = false
    var isRatingPageCalled : Bool = false
    var arrMenus = [String]()
    let arrImgs: [String] = ["home", "work", "map location"]
    var isCurrentLocationSet : Bool = false
    let userDefaults = UserDefaults.standard
    var strCurrentLocName = ""
    var firstlocation = ""
    var strPickUpCountry = ""
    var strDropCountry = ""
    var strPickUpLocation = ""
    var strDropLocation = ""
    var simval = ""
    var emptyloc = ""
    var scheduledTime:String?
    @IBOutlet weak var separatorLbl: UILabel!
    lazy var lang = Language.default.object
    //Loader
     var viewNewTaxiLoader = NewTaxiLoader()
    var searchtext = String()
    var isToStopAnimation = Bool()
    var animateView = UIView()
    var googleMapView : GMSMapView?
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.arrMenus.append(self.lang.addHomeLoc)
        self.arrMenus.append(self.lang.addWorkLoc)
        self.arrMenus.append(self.lang.setPin)
        self.txtDropLoc.placeholder = self.lang.whereTo
        self.btnDone.setTitle(self.lang.done.uppercased(), for: .normal)
        if #available(iOS 10.0, *) {
            txtPickUpLoc.keyboardType = .asciiCapable
            txtDropLoc.keyboardType = .asciiCapable
        } else {
            // Fallback on earlier versions
            txtPickUpLoc.keyboardType = .default
            txtDropLoc.keyboardType = .default
        }
        self.txtPickUpLoc.textAlignment = self.lang.getTextAlignment(align: .left)
        self.txtDropLoc.textAlignment = self.lang.getTextAlignment(align: .left)
        if scheduledTime != nil {
            self.scheduledTimeLabel.text! = self.scheduledTime!
            self.scheduledTimeLabel.isHidden = false
//            self.scheduledTimeHeightConstraint.constant = 40.0
        }else{
            self.scheduledTimeLabel.isHidden = true
//            self.scheduledTimeHeightConstraint.constant = 0.0
        }
        self.view.bringSubviewToFront(viewTopHolder)
        self.tableOuterView.isHidden = false
        self.tblLocations.isHidden = false
        txtDropLoc.delegate = self
        txtPickUpLoc.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.endTrip), name: Notification.Name(rawValue: NotificationTypeEnum.EndTrip.rawValue), object: nil)
        isDropTapped = true
        txtDropLoc.becomeFirstResponder()
      
        self.setDesign()
        self.usingPinToGetLocation = true
    }
    func setDesign()
    {
//        self.backBtn.backgroundColor = .Title
//        self.backBtn.setImage(#imageLiteral(resourceName: "back arrow bottom"), for: .normal)
//        self.backBtn.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
//        self.backBtn.cornerRadius = 15
        self.backBtn.setTitle(self.lang.getBackBtnText(), for: .normal)

        self.btnDone.cornerRadius = 15
        self.btnDone.backgroundColor = .ThemeYellow
        self.btnDone.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.btnDone.setTitleColor(.Title, for: .normal)
        self.tableOuterView.cornerRadius = 20
        self.tableOuterView.clipsToBounds = true
        self.tblLocations.cornerRadius = 20
        self.tblLocations.clipsToBounds = true
        self.topCircleView.backgroundColor = .Title
        self.topCircleView.isRoundCorner = true
        self.bottomCircleView.backgroundColor = .ThemeYellow
        self.bottomCircleView.isRoundCorner = true
        self.drawDottedLine(start: CGPoint(x: self.verticalBar.bounds.minX, y: self.verticalBar.bounds.minY), end: CGPoint(x: self.verticalBar.bounds.maxX, y: self.verticalBar.bounds.maxY), view: self.verticalBar)
        self.txtPickUpLoc.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 17)
        self.txtPickUpLoc.textColor = UIColor.DarkTitle
        self.txtDropLoc.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.txtDropLoc.textColor = .DarkTitle
        self.scheduledTimeLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.scheduledTimeLabel.textColor = .DarkTitle
        self.separatorLbl.backgroundColor = .Background
    }
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.DarkTitle.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3]
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        self.apiInteractor = APIInteractor(self)
        
        self.googleMapView = GMSMapView()
        self.initGooglePlaceSearch()
        self.onChangeMapStyle()
        updateCurrentLocation()
        googleMapView!.delegate = self
        pinLocationImage.center = googleMapView!.center
        
        if isFromCarAvailablePage {
            txtPickUpLoc.text = strPickUpLocation.count == 0 ? self.lang.currentLocation : strPickUpLocation
            txtDropLoc.text = strDropLocation
        }
//        LoadingManager.instance.prepareULB(self, frameView: self.viewTopHolder,onTop: false)
//        LoadingManager.instance.showUBL(self,show:true)
        self.btnDone.isHidden = true
        self.pinLocationImage.isHidden = true
        
        if self.locationManager == nil{
            self.locationManager = CLLocationManager()
        }
        
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //MARK:- deinitializers
    deinit{
        self.deinitObjects()
        debug(print: "Called")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        debug(print: "Called")
    }
    func deinitObjects(){
        self.autocompletePredictions.removeAll()
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
        self.locationManager = nil
        self.googleMapView?.delegate = nil
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: NotificationTypeEnum.EndTrip.rawValue), object: nil)
//        LoadingManager.instance.showUBL(self, show: false)
        self.animateView.layer.removeAllAnimations()
        self.searchCountdownTimer?.invalidate()
        self.searchMapCountdownTimer?.invalidate()
        self.searchCountdownTimer = nil
        self.searchMapCountdownTimer = nil
    }
    //MARK:- initWithStory
    class func initWithStory() -> SetLocationVC{
        return UIStoryboard.payment.instantiateViewController()
    }
    //MARK: - WHEN DRIVER ACCEPTING REQUEST
    /*
     NOTIFICATION TYPE END TRIP
     */
    @objc func endTrip(notification: Notification)
    {
        if isRatingPageCalled
        {
            return
        }
        isRatingPageCalled = false
        guard let json = notification.userInfo as? JSON else{return}
        let trip = TripDataModel(json)
        let rateDriverVC : RateDriverVC = .initWithStory()
        rateDriverVC.tripId = trip.id
        self.navigationController?.pushViewController(rateDriverVC,
                                                      animated: false)
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.deinitObjects()
        self.delegate?.onExitSetLocation(from: self)
    }
    
    func onReadyToSearchMap()
    {
        isReadyToDrag = true
    }
    
    @IBAction func onDummyViewTapped()
    {
        simval = "1"
        self.searchMapCountdownTimerFired()
        btnPickUp.center = googleMapView!.center
    }
    
    @IBAction func onDummyPickupTapped()
    {
        btnPickUp.isHidden = true
       self.isReadyToDrag = true
    }
    
    func initGooglePlaceSearch()
    {
        if !isFromCarAvailablePage
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
        }
        selectedLocation = LocationModel()
    }
    
    
    // MARK: - ******* TextField Delegate Method *******
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        if (textField.text?.count)! > 0
        {
            self.animateView.isHidden = false
            self.startCountdownTimer(in : textField,forSearch: textField.text!)
        }
        else
        {
            self.autocompletePredictions.removeAll()
            tblLocations.reloadData()
        }
    }
    func startCountdownTimer(in textField : UITextField,forSearch searchString: String) {
        //stop the current countdown
        let fireDate : Date
        if self.searchCountdownTimer == nil || !self.searchCountdownTimer!.isValid{
            fireDate = Date(timeIntervalSinceNow: 1.0)
        }else{
            fireDate = Date(timeIntervalSinceNow: 1.35)
        }
        self.searchCountdownTimer?.invalidate()
        let info: [AnyHashable: Any] = [
            "searchString" : searchString,
            "textField": textField
        ]
        self.searchCountdownTimer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(self.startAutoComplete), userInfo: info, repeats: false)
        RunLoop.main.add(self.searchCountdownTimer!, forMode: RunLoop.Mode.default)
    }
    
    @objc func startAutoComplete(_ countdownTimer: Timer) {
        let infoDictionary = countdownTimer.userInfo as! NSDictionary
        let newsearchString: String? = infoDictionary["searchString"] as? String
        guard let newSearch = newsearchString,
            let textField = infoDictionary["textField"] as? UITextField,
            !newSearch.isEmpty else {return}
        guard (textField.text?.count ?? -1) == newSearch.count else{
            self.autocompletePredictions = [GooglePlacesModel]()
            tblLocations.reloadData()
            return
        }
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
    
    //TEXT FIELD DELEGATE METHOD
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
            if txtPickUpLoc.text == "Current Location" {
                txtPickUpLoc.text = ""
            }
            isPickUpTapped = true
            isDropTapped = false
        } else {
            if txtPickUpLoc.text?.count == 0 {
                txtPickUpLoc.text = self.lang.currentLocation
            }
            isPickUpTapped = false
            isDropTapped = true
        }
        usingPinToGetLocation = false
        
    }
    // MARK: ***************************
    
    // MARK: - Navigating to Side Menu View
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
            return 85
        }
        else
        {
            return 85
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.usingPinToGetLocation{
            tableView.backgroundView = self.googleMapView
            return 0
        }
        tableView.backgroundView = nil
        self.animateView.isHidden = true
        return (self.autocompletePredictions.count == 0) ? arrMenus.count : self.autocompletePredictions.count
    }
    
    func createItemCell(indexPath: IndexPath) -> CellItems
    {
        let cell:CellItems = tblLocations.dequeueReusableCell(withIdentifier: "CellItems") as! CellItems
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lblName?.text = arrMenus[indexPath.row]
        cell.lblIconName?.image = UIImage(named: arrImgs[indexPath.row])
        cell.lblName?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        cell.lblName?.textColor = .Title

        if indexPath.row == 0 {
            cell.contentView.setSpecificCornersForTop(cornerRadius: 25)
        }else if indexPath.row == arrMenus.count - 1 {
            cell.contentView.setSpecificCornersForBottom(cornerRadius: 25)
        }
        else{
            cell.contentView.cornerRadius = 0
        }
        cell.contentView.backgroundColor = .Background
        return cell
    }
    
    func createLocationCell(indexPath: IndexPath) -> CellLocations
    {
        let cell:CellLocations = tblLocations.dequeueReusableCell(withIdentifier: "CellLocations") as! CellLocations
        cell.lblTitle?.text = (indexPath.row == 0) ? self.lang.home : self.lang.work
        cell.lblSubTitle?.text = (indexPath.row == 0) ? Constants().GETVALUE(keyname: USER_HOME_LOCATION) : Constants().GETVALUE(keyname: USER_WORK_LOCATION)
        cell.lblIcon.image = (indexPath.row == 0) ? UIImage(named: "home") : UIImage(named: "work")
        cell.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        cell.lblTitle?.textColor = .Title
        cell.lblSubTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 11)
        cell.lblSubTitle?.textColor = .Title

        if indexPath.row == 0 {
            cell.contentView.setSpecificCornersForTop(cornerRadius: 25)
        }else if indexPath.row == arrMenus.count - 1 {
            cell.contentView.setSpecificCornersForBottom(cornerRadius: 25)
        }
        else{
            cell.contentView.cornerRadius = 0
        }
        cell.contentView.backgroundColor = .Background
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        self.isReadyToDrag = false
        if self.autocompletePredictions.count == 0
        {
            if indexPath.row == 0 && Constants().GETVALUE(keyname: USER_HOME_LOCATION).count > 0
            {
                return createLocationCell(indexPath: indexPath)
            }
            else if indexPath.row == 0
            {
                return createItemCell(indexPath: indexPath)
            }
            
            if indexPath.row == 1 && Constants().GETVALUE(keyname: USER_WORK_LOCATION).count > 0
            {
                return createLocationCell(indexPath: indexPath)
            }
            else if (indexPath.row == 1)
            {
                return createItemCell(indexPath: indexPath)
            }
            return createItemCell(indexPath: indexPath)
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

            cell.lblIcon.image = UIImage(named: "map location")
            if indexPath.row == 0 {
                cell.contentView.setSpecificCornersForTop(cornerRadius: 25)
            }else if indexPath.row == autocompletePredictions.count - 1 {
                cell.contentView.setSpecificCornersForBottom(cornerRadius: 25)
            }
            else{
                cell.contentView.cornerRadius = 0
            }
            cell.contentView.backgroundColor = .Background
            return cell
        }
    }
    // MARK:  **** Table View Delegate End ****
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.autocompletePredictions.count == 0
        {
            if indexPath.row == 0 && Constants().GETVALUE(keyname: USER_HOME_LOCATION).count > 0
            {
                if isPickUpTapped
                {
                    txtPickUpLoc.text = String(format:"%@", Constants().GETVALUE(keyname: USER_HOME_LOCATION))
                }
                
                if isDropTapped
                {
                    txtDropLoc.text = String(format:"%@", Constants().GETVALUE(keyname: USER_HOME_LOCATION))
                }
                
                self.AddHomeOrWorkTapped(lat: Constants().GETVALUE(keyname: USER_HOME_LATITUDE), lng: Constants().GETVALUE(keyname: USER_HOME_LONGITUDE),isPickUp: isPickUpTapped)
            }
            else if indexPath.row == 0
            {
                gotoAddLocationPage(indexPath: indexPath)
            }
            
            if indexPath.row == 1 && Constants().GETVALUE(keyname: USER_WORK_LOCATION).count > 0
            {
                if isPickUpTapped
                {
                    txtPickUpLoc.text = String(format:"%@", Constants().GETVALUE(keyname: USER_WORK_LOCATION))
                }
                
                if isDropTapped
                {
                    txtDropLoc.text = String(format:"%@", Constants().GETVALUE(keyname: USER_WORK_LOCATION))
                }
                
                self.AddHomeOrWorkTapped(lat: Constants().GETVALUE(keyname: USER_WORK_LATITUDE), lng: Constants().GETVALUE(keyname: USER_WORK_LONGITUDE),isPickUp: isPickUpTapped)
            }
            else if (indexPath.row == 1)
            {
                gotoAddLocationPage(indexPath: indexPath)
            }
            else if indexPath.row == 2
            {
                self.usingPinToGetLocation = true
                self.isReadyToDrag = true
                simval = "1"
                txtDropLoc.resignFirstResponder()
                txtPickUpLoc.resignFirstResponder()
                self.onDummyViewTapped()
            }
        }
        else
        {
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
            
            if isPickUpTapped
            {
                txtPickUpLoc.text = String(format:"%@ %@",finalTitle!,trimmedString)
            }
            
            if isDropTapped
            {
                txtDropLoc.text = String(format:"%@ %@",finalTitle!,trimmedString)
            }
            
            if txtPickUpLoc.text?.count == 0
            {
                isPickUpTapped = true
                isDropTapped = false
                txtDropLoc.becomeFirstResponder()
                self.tableOuterView.isHidden = false
                self.tblLocations.isHidden = false

            }
            
            let selPrediction = self.autocompletePredictions[indexPath.row].placeId
            self.getLocationCoordinates(withReferenceID: selPrediction, isPickUpTapped: isPickUpTapped)
        }
    }
    //ADD HOME LOCATION
    func AddHomeOrWorkTapped(lat: String, lng: String,isPickUp: Bool)
    {
        let longitude :CLLocationDegrees = Double(lng)!
        let latitude :CLLocationDegrees = Double(lat)!
        
        if isPickUpTapped
        {
            pickUpLatitude = latitude
            pickUpLongitude = longitude
        }
        
        if isDropTapped
        {
            dropLatitude = latitude
            dropLongitude = longitude
        }
        
        gotoMainMapView(isPickTapped: isPickUp)
    }
    
    func gotoAddLocationPage(indexPath: IndexPath)
    {
        isGoingAddLocaitonView = true
        let locationView = AddLocationVC.initWithStory(self)
        locationView.isFromHomeLocation = (indexPath.row == 0) ? true : false
        isHomeTapped = (indexPath.row == 0) ? true : false
        self.navigationController?.pushViewController(locationView, animated: true)
    }
    
    
    // MARK: - **** Getting Latitude & Longitude from Google Place Search ****
    func getLocationCoordinates(withReferenceID referenceID: String, isPickUpTapped: Bool)
    {
        var dicts = [AnyHashable: Any]()
        dicts["token"]   = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        let paramsComponent: String = "\(iApp.GOOGLE_MAP_DETAILS_URL)?key=\(iApp.instance.GoogleApiKey)&reference=\(referenceID)&sensor=\("true")"
        
        WebServiceHandler
            .sharedInstance
            .getThridPartyWebService(wsMethod: paramsComponent,
                                     paramDict: dicts as! [String : Any],
                                     viewController: self,
                                     isToShowProgress: false,
                                     isToStopInteraction: false)
            { [weak self] (responseDict)  in
                guard let welf = self else{return}
            let gModel =  GoogleLocationModel.generateModel(from: responseDict)
            if gModel.status_code == "1"
            {
                let dictsTempsss = gModel.dictTemp[iApp.RESPONSE_KEY_RESULT] as! NSDictionary
                if welf.isPickUpTapped
                {
                    welf.strPickUpCountry = gModel.country_name
                }
                
                if welf.isDropTapped
                {
                    welf.strDropCountry = gModel.country_name
                }
                
                welf.googleData(didLoadPlaceDetails: dictsTempsss,isPickUpTapped: isPickUpTapped)
            }
            else
            {
                welf.appDelegate?.createToastMessage(responseDict.status_message)
            }

        }

    }
    
    // AUTO COMPLETE DELEGATE METHODS
    func googleData(didLoadPlaceDetails placeDetails: NSDictionary,isPickUpTapped: Bool) {
        self.searchDidComplete(withPlaceDetails: placeDetails,isPickTapped: isPickUpTapped)
    }

    func searchDidComplete(withPlaceDetails placeDetails: NSDictionary,isPickTapped: Bool)
    {
        let placeGeometry =  (placeDetails[iApp.RESPONSE_KEY_GEOMETRY]) as? NSDictionary
        let locationDetails  = (placeGeometry?[iApp.RESPONSE_KEY_LOCATION]) as? NSDictionary
        let lat = (locationDetails?[iApp.RESPONSE_KEY_LATITUDE] as? Double)
        let lng = (locationDetails?[iApp.RESPONSE_KEY_LONGITUDE] as? Double)
        selectedLocation.searchedAddress = (((placeDetails as Any) as AnyObject).value(forKey: "formatted_address") as? String ?? "")
        let longitude :CLLocationDegrees = Double(String(format: "%2f", lng!))!
        let latitude :CLLocationDegrees = Double(String(format: "%2f", lat!))!
        if isPickTapped
        {
            pickUpLatitude = latitude
            pickUpLongitude = longitude
        }

        if isDropTapped
        {
            dropLatitude = latitude
            dropLongitude = longitude
        }

        gotoMainMapView(isPickTapped: isPickTapped)

    }
    
    
    func gotoMainMapView(isPickTapped: Bool)
    {
        self.autocompletePredictions = [GooglePlacesModel]()
        tblLocations.reloadData()
        if isPickTapped
        {
            if (txtPickUpLoc.text?.count)! > 0 && (txtDropLoc.text?.count)! > 0
            {
                if(emptyloc == ""){
                    
                    txtDropLoc.text = ""
                }
                else{
                    
                    self.gotoCarAvailblePage()
                }
            }
            else
            {
                txtDropLoc.becomeFirstResponder()
            }
        }
        else if isDropTapped
        {
            print(txtPickUpLoc.text!)
            if (txtPickUpLoc.text?.count)! > 0 && (txtDropLoc.text?.count)! > 0
            {
                if(emptyloc == ""){
                    
                    txtDropLoc.text = ""
                }
                else{
                    self.gotoCarAvailblePage()
                }
            }
            else
            {
                txtPickUpLoc.becomeFirstResponder()
            }
        }
    }
  
    //MARK: - **** LOCATION MANAGER DELEGATE METHODS ****
    func updateCurrentLocation()
    {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    locationManager!.requestWhenInUseAuthorization()
                    break
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager?.requestAlwaysAuthorization()
                @unknown default:
                locationManager?.requestAlwaysAuthorization()
                }
            } else {
                //                self.showAlert()
            }
            locationManager?.delegate = self
            
        }
        
        if #available(iOS 8.0, *) {
            locationManager?.requestWhenInUseAuthorization()
        }
        
        locationManager?.startUpdatingLocation()
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            googleMapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 16.5, bearing: 0, viewingAngle: 0)
            locationManager?.stopUpdatingLocation()
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
        locationManager?.stopUpdatingLocation()
        if (!isCurrentLocationGot)
        {
            isCurrentLocationGot = true
            self.gettingLocationName(lat: coord.latitude, long: coord.longitude, isFromCurrentLocation: true)
        }
        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.delegate = nil
        self.locationManager = nil
        self.setCurrentLocation(latitude: coord.latitude, longitude: coord.longitude)
    }
    
    // MOVING MAP ON CURRENT LOCATION
    func setCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    {
        if isCurrentLocationSet
        {
            return
        }
        isCurrentLocationSet = true
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.5)
        googleMapView?.animate(to: camera)
        googleMapView?.camera = camera
        googleMapView?.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    //MARK: **** END ****
    // MARK: When User Press Done Button

    @IBAction func onDoneTapped(_ sender: UIButton!)
    {
       
        if isDropTapped
        {
            if txtPickUpLoc.text?.count == 0
            {
                isPickUpTapped = true
                isDropTapped = false
                txtDropLoc.becomeFirstResponder()
                self.tableOuterView.isHidden = false
                self.tblLocations.isHidden = false

            }
            else
            {
                gotoCarAvailblePage()
            }
            
            return
        }
        
        if isPickUpTapped
        {
            if txtDropLoc.text?.count == 0
            {
                isDropTapped = true
                isPickUpTapped = false
                txtDropLoc.becomeFirstResponder()
                self.tableOuterView.isHidden = false
                self.tblLocations.isHidden = false

            }
            else
            {
                gotoCarAvailblePage()
            }
        }
    }
    
    func setDefaultLocation()
    {
        let longitude = userDefaults.value(forKey: USER_LONGITUDE) as? String
        let latitude = userDefaults.value(forKey: USER_LATITUDE) as? String
        if ((longitude != nil && longitude != "") && (latitude != nil && latitude != ""))
        {
            let longitude1 :CLLocationDegrees = Double(longitude!)!
            let latitude1 :CLLocationDegrees = Double(latitude!)!
            pickUpLatitude = latitude1
            pickUpLongitude = longitude1
        }
    }
    //Goto Car Avaiable page
    func gotoCarAvailblePage()
    {
        self.view.endEditing(true)
        print(txtPickUpLoc.text!)
        if(
            (self.txtPickUpLoc.text! == self.txtDropLoc.text!) ||
                (self.strCurrentLocName == self.txtDropLoc.text! &&
                self.txtPickUpLoc.text! == self.lang.currentLocation)
            ){
            
            let status_message = self.lang.samePickupDrop
            self.appDelegate?.createToastMessage(status_message, bgColor: UIColor.black, textColor: UIColor.white)
            
        }else{
                if self.txtPickUpLoc.text! == self.strPickUpCountry
                {
                    self.setDefaultLocation()
                }
                
                if self.strCurrentLocName == ""{
                    if self.emptyloc == ""{
                        self.emptyloc = self.lang.currentLocation
                    }
                    self.strCurrentLocName = self.emptyloc
                }
                
                _ = self.txtPickUpLoc.text! == self.strPickUpCountry ? self.strCurrentLocName : self.txtPickUpLoc.text!
            
                self.deinitObjects()
                self.delegate?.onExitSetLocation(from: self)
                self.delegate?.onLocationTapped(pickUpLatitude: self.pickUpLatitude,
                                                pickUpLongitude: self.pickUpLongitude,
                                                dropLatitude: self.dropLatitude,
                                                dropLongitude: self.dropLongitude,
                                                dropLocName: self.txtDropLoc.text!,
                                                pickUpLocName: self.txtPickUpLoc.text! == self.lang.currentLocation ? self.strCurrentLocName : self.txtPickUpLoc.text!,
                                                scheduledTime:self.scheduledTime)
        }
    }
    
    //MARK: - GOOGLE MAP DELEGATE METHOD
    var map_view_is_idle = true
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !self.map_view_is_idle{
            UIView.animate(withDuration: 0.3) {
                self.pinLocationImage.transform = .identity
            }
        }
        guard !self.map_view_is_idle,(position.target.latitude != 0.0 && position.target.longitude != 0.0) else{return}//Return if already in idle state or empty value obtained
        self.map_view_is_idle = true
        defer {
            if isReadyToDrag{
                self.searchMapCountdownTimerFired()
            }
        }
        if(mapView.camera.zoom > 5)
        {
            if self.isPickUpTapped
            {
                pickUpLatitude = position.target.latitude
                pickUpLongitude = position.target.longitude
            }
            
            if self.isDropTapped
            {
                
                dropLatitude = position.target.latitude
                dropLongitude = position.target.longitude
//                self.btnDone.backgroundColor = UIColor.gray
//                self.btnDone.isUserInteractionEnabled = false
                
            }
        }
        
       
        
        if (self.searchMapCountdownTimer != nil) {
            self.searchMapCountdownTimer?.invalidate()
        }
        
        if self.isPickUpTapped
        {
            pickUpLatitude = position.target.latitude
            pickUpLongitude = position.target.longitude
        }
        
        if self.isDropTapped
        {
//            self.btnDone.backgroundColor = UIColor.gray
//            self.btnDone.isUserInteractionEnabled = false
            dropLatitude = position.target.latitude
            dropLongitude = position.target.longitude
            
        }
        
//        let fireDate = Date(timeIntervalSinceNow: 1.0)
//        self.searchMapCountdownTimer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(self.searchMapCountdownTimerFired), userInfo: nil, repeats: false)
//        RunLoop.main.add(self.searchMapCountdownTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if self.map_view_is_idle{
            UIView.animate(withDuration: 0.3) {
                self.pinLocationImage.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    .concatenating(CGAffineTransform(translationX: 0, y: -13))
            }
        }
        self.map_view_is_idle = false
        
        return
    }
    
    //MARK:  **** END ****
    func searchMapCountdownTimerFired()
    {
        if self.isPickUpTapped
        {
            self.gettingLocationName(lat: pickUpLatitude, long: pickUpLongitude, isFromCurrentLocation: false)
        }
        
        if self.isDropTapped
        {
            guard dropLatitude != 0.0 && dropLongitude != 0.0 else {return}
            self.gettingLocationName(lat: dropLatitude, long: dropLongitude, isFromCurrentLocation: false)
        }
    }
    var last_loc : CLLocation?
    func gettingLocationName(lat: CLLocationDegrees, long: CLLocationDegrees, isFromCurrentLocation: Bool)
    {
        
        var location = CLLocation(latitude: lat, longitude: long)
        if !isFromCurrentLocation && ( (lat == 0.0 && long == 0.0) || (self.last_loc == location) ){
            self.map_view_is_idle = false
            let center_coords = self.googleMapView?.camera.target
                //self.googleMapView.projection.coordinate(for: center)
            location = CLLocation(latitude: center_coords!.latitude, longitude: center_coords!.longitude)
        }
        self.last_loc = location
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {[weak self] (placemarks, error) -> Void in
            guard let welf = self else{return}
            if placemarks == nil
            {
                welf.btnDone.backgroundColor = UIColor.ThemeYellow
                welf.btnDone.isUserInteractionEnabled = true
                welf.map_view_is_idle = false
                return
            }
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])
                if pm != nil
                {
                    let strLoc = welf.stringPlaceMark(placemark: pm!, isFromCurrentLocation: isFromCurrentLocation)
                    print(strLoc.count)
                    if strLoc.count>0
                    {
                        if isFromCurrentLocation
                        {
                            welf.strCurrentLocName = strLoc
                            welf.emptyloc = strLoc
                            print("strLoc \(strLoc)")
                            welf.txtDropLoc.text = ""
                            if(welf.txtDropLoc.placeholder == welf.lang.whereTo){
                                
                                welf.txtDropLoc.text = ""
                                welf.firstlocation = welf.strCurrentLocName
                                
                                if(welf.simval == "1"){
                                    welf.txtDropLoc.text = strLoc
                                    welf.btnDone.backgroundColor = UIColor.ThemeYellow
                                    welf.btnDone.isUserInteractionEnabled = true
                                }
                                
                                if welf.isFromCarAvailablePage {
                                    welf.txtDropLoc.text = welf.strDropLocation
                                }
                            }
                        }
                        else if welf.isPickUpTapped
                        {
                            welf.btnDone.backgroundColor = UIColor.ThemeYellow
                            welf.btnDone.isUserInteractionEnabled = true
                            
                            welf.txtPickUpLoc.text = strLoc
                        }
                        else if welf.isDropTapped
                        {
                            welf.btnDone.backgroundColor = UIColor.ThemeYellow
                            welf.btnDone.isUserInteractionEnabled = true
                            welf.txtDropLoc.text = strLoc
                        }else{
                            print("ƒfailed")
                        }
                    }
                    else{
                        
                        if(welf.txtDropLoc.placeholder == welf.lang.whereTo){
                            
                            welf.txtDropLoc.text = ""
                            
                            if(welf.simval == "1"){
                                welf.txtDropLoc.text = welf.firstlocation
                                welf.btnDone.backgroundColor = UIColor.ThemeYellow
                                welf.btnDone.isUserInteractionEnabled = true
                            }
                        }else{
                            print("ƒfailed")
                        }
                        
                    }
                }else{
                    welf.btnDone.backgroundColor = UIColor.ThemeYellow
                    welf.btnDone.isUserInteractionEnabled = true
                    welf.map_view_is_idle = false
                }
            }
        })
    }
    
    func stringPlaceMark(placemark: CLPlacemark, isFromCurrentLocation: Bool) -> String {
        var string = String()
        if (placemark.subThoroughfare != nil) {
            string += placemark.subThoroughfare!
        }
        
        if (placemark.thoroughfare != nil) {
            if (string.count ) > 0 {
                string += ", "
            }
            string += placemark.thoroughfare!
        }
//        else if let subLocality = placemark.subLocality{
//            string += subLocality
//        }
        if let subLocality = placemark.subLocality{
            if (string.count ) > 0 {
                string += ", "
            }
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
        
        if isFromCurrentLocation || self.isPickUpTapped
        {
            if (placemark.country != nil)
            {
                strPickUpCountry = placemark.country!
            }
        }
        else if self.isDropTapped
        {
            if (placemark.country != nil)
            {
                strDropCountry = placemark.country!
            }
        }
        
        return string
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
        
        isGoingAddLocaitonView = false
    }
    
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
    
    // MARK: LOGOUT API CALL
    /*
     */
    func callUpdateLocationAPI(_ dicts: [AnyHashable: Any],latitude: CLLocationDegrees, longitude: CLLocationDegrees, locationName: String)
    {
        guard let parameter = dicts as? JSON else{
            AppDelegate.shared.createToastMessage(self.lang.internalServerError)
            return
        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?.getRequest(
            for: .updateRiderLocation,
            params: parameter
        ).responseJSON({ (json) in
            if json.isSuccess{
                self.setLocationName(latitude: latitude, longitude: longitude, locationName: locationName)
                self.tblLocations.reloadData()
            }else{
                AppDelegate.shared.createToastMessage(json.status_message)
            }
            UberSupport.shared.removeProgressInWindow()
        }).responseFailure({ (error) in
        UberSupport.shared.removeProgressInWindow()
        AppDelegate.shared.createToastMessage(error)
            
        })
    }
    
    func resetUserLocations()
    {
        Constants().STOREVALUE(value: "", keyname: USER_HOME_LOCATION)
        Constants().STOREVALUE(value: "", keyname: USER_HOME_LATITUDE)
        Constants().STOREVALUE(value: "", keyname: USER_HOME_LONGITUDE)
        
        Constants().STOREVALUE(value: "", keyname: USER_WORK_LOCATION)
        Constants().STOREVALUE(value: "", keyname: USER_WORK_LATITUDE)
        Constants().STOREVALUE(value: "", keyname: USER_WORK_LONGITUDE)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.googleMapView?.removeFromSuperview()
        self.googleMapView = nil
        self.tblLocations.backgroundView = nil
    }
    //MARK: - Change Map Style
    /*
     Here we are changing the Map style from Json File
     */
    func onChangeMapStyle()
    {
        
        do {
            if let styleURL = Bundle.main.url(forResource: "mapStyleChanged", withExtension: "json") {
                googleMapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                //       print("Unable to find style.json")
            }
        } catch {
            //     print("The style definition could not be loaded: \(error)")
        }
    }
}

class CellItems: UITableViewCell
{
    @IBOutlet weak var outerView: UIView!
    @IBOutlet var lblName: UILabel?
    @IBOutlet var lblIconName: UIImageView!
}

class CellLocations: UITableViewCell
{
    @IBOutlet weak var outerView: UIView!
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblSubTitle: UILabel?
    @IBOutlet weak var lblIcon: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.lblIcon != nil{
            self.lblIcon.image = UIImage(named: "map location")
        }
    }
}

// MARK - UITEXTFIELD PADDING EXTENSION
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
extension SetLocationVC :GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        
    }
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
}
