///**
//* TripsVC.swift
//*
//* @package NewTaxi
//* @author Seentechs Product Team
//*
//* @link http://seentechs.com
//*/
//
//import UIKit
//import MessageUI
//import Social
//
//class ScheduledTripsTVC: UITableViewCell {
//
//    @IBOutlet weak var statusLabel: UILabel!
//    @IBOutlet weak var timeAndVehicleNameView: UIView!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var vehicleNameLabel: UILabel!
//    @IBOutlet weak var sourceLocLabel: UILabel!
//    @IBOutlet weak var destiLocLabel: UILabel!
//    @IBOutlet weak var editTimeButtonOutlet: UIButton!
//    @IBOutlet weak var cancelRideButtonOutlet: UIButton!
//}
//
//class TripsVC : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, ScheduleRiderDelegate,UICollectionViewDelegateFlowLayout,APIViewProtocol
//{
//    var apiInteractor: APIInteractorProtocol?
//    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
//        switch response {
//        default:
//            print()
//        }
//    }
//    func onFailure(error: String,for API : APIEnums) {
//        print(error)
//    }
//    @IBOutlet weak var collectionTrips: UICollectionView!
//    @IBOutlet weak var viewNavHeader: UIView!
//    @IBOutlet weak var viewTapper: UIView!
//    @IBOutlet weak var lblNoTrips: UILabel!
//    @IBOutlet weak var menuView: UIView!
//    @IBOutlet weak var indicatorView: UIView!
//    @IBOutlet weak var pastButtonOutlet: UIButton!
//    @IBOutlet weak var upcomingButtonOutlet: UIButton!
//    @IBOutlet weak var scheduledRideTableView: UITableView!
//
//
//    var selectedCell : CustomTripsCell!
//    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
//    lazy var arrTemp1 : NSMutableArray = NSMutableArray()
//    var model : DriverDetailModel!
//
//    // For API Calls
//    var nPageNumber : Int = 1
//    var isDataFinishedFromServer : Bool = false
//    var isApiCalling : Bool = false
//    var isCurrentTripApiCalled : Bool = false
//    var isCurrentTripTapped : Bool = false
//    lazy var arrCurrentTripsData : NSMutableArray = NSMutableArray()
//    lazy var arrTripsData : NSMutableArray = NSMutableArray()
//    lazy var normalTripsDict = [[String:Any]]()
//    lazy var scheduledTripsDict = [[String:Any]]()
//    var isfromschdule:Bool = false
//    var strTripID = ""
//    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
//    var selectedTripDict = [String:Any]()
//
//
//    // MARK: - ViewController Methods
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        self.apiInteractor = APIInteractor(self)
//        lblNoTrips.isHidden = true
//        view.addSubview(collectionTrips)
//        view.addSubview(scheduledRideTableView)
//        collectionTrips.frame = CGRect(x: 0,
//                                       y:menuView.frame.origin.y + menuView.frame.size.height,
//                                       width: self.view.frame.size.width,
//                                       height: self.view.frame.size.height - (menuView.frame.origin.y + menuView.frame.size.height))
//        scheduledRideTableView.frame = CGRect(x: 0,
//                                              y:menuView.frame.origin.y + menuView.frame.size.height,
//                                              width: self.view.frame.width,
//                                              height: self.view.frame.height - (menuView.frame.origin.y + menuView.frame.height))
//        self.callGetTripsApi()
//        collectionTrips.dataSource = self
//        collectionTrips.delegate = self
//        scheduledRideTableView.tableFooterView = UIView()
//        scheduledRideTableView.isHidden = true
//    }
//
//    override func viewWillAppear(_ animated: Bool){
//        super.viewWillAppear(animated)
//    }
//
//    override func viewDidDisappear(_ animated: Bool)
//    {
//        super.viewDidDisappear(animated)
//    }
//
//    override func viewDidAppear(_ animated: Bool)
//    {
//        super.viewDidAppear(animated)
//    }
//
//    //MARK: - CALL TRIPS API
//    func callGetTripsApi() {
//        let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
//                         "user_type" : "rider"] as JSON
//        WebServiceHandler.sharedInstance.getWebService(wsMethod:"get_rider_trips",
//                                                       paramDict: paramDict,
//                                                       viewController:self,
//                                                       isToShowProgress:true,
//                                                       isToStopInteraction:false,
//                                                       complete:  { (response) in
//            let responseJson = response
//            DispatchQueue.main.async {
//                if responseJson["status_code"] as? String == "1" {
//                    self.scheduledTripsDict = responseJson["schedule_ride"] as! [[String:Any]]
//                    self.normalTripsDict = responseJson["trip_details"] as! [[String:Any]]
//                    self.lblNoTrips.isHidden = (self.scheduledTripsDict.count != 0) ? true : false
//                    self.lblNoTrips.text = NSLocalizedString("You have no trips", comment: "")
//                    self.scheduledRideTableView.reloadData()
//                    self.collectionTrips.reloadData()
//                }
//                else {
//                    self.appDelegate.createToastMessageForAlamofire(responseJson["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
//                }
//
//            }
//        }){(error) in
//
//        }
//
//
//    }
//
//
//    func checkStatus()
//    {
//        guard self.isViewLoaded else {return}
//            collectionTrips.isHidden = (arrTripsData.count > 0) ? false : true
//            lblNoTrips.isHidden = (arrTripsData.count == 0) ? false : true
//            lblNoTrips.text = NSLocalizedString("You have no trips", comment: "")
//
//    }
//
//
//    // MARK: COLLECTION VIEW DATA SOURCE & DELEGATE METHODS
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
//    {
//        if normalTripsDict.count != 0{
//            self.view.bringSubviewToFront(collectionTrips)
//            return normalTripsDict.count
//        }else{
//            self.view.bringSubviewToFront(lblNoTrips)
//            return 0
//        }
//    }
//
//     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionat section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: self.view.frame.width, height: 260)
//    }
//     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionTrips.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! CustomTripsCell
//        let cell = collectionTrips.generate(CustomTripsCell(), forIndex: indexPath)
//        let rideJSON = self.normalTripsDict[indexPath.item] as JSON
//        let rideModel = DriverDetailModel.init(withJson: rideJSON)
//        let msg1 = NSLocalizedString("Trip ID:", comment: "")
//        cell.lblTripTime?.text = "\(msg1)\(rideModel.id)"
//        cell.lblCarType?.text = rideModel.vehicle_name
//        cell.lblCost?.text = "\(Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)) \(rideModel.total_fare)"
//        cell.lblTripStatus?.text = NSLocalizedString("\(rideModel.status)", comment: "")
//        if !rideModel.map_image.isEmpty {
//            cell.imgMapView?.sd_setImage(with: URL(string: rideModel.map_image), placeholderImage:UIImage(named:""))
//        }
//        else {
//            cell.imgMapView?.sd_setImage(with:  rideModel.getGooglStaticMap, placeholderImage:UIImage(named:""))
//
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
//            cell.attachRatingButton(rideModel.tripStatus == .rating)
//        }
//        cell.rateYourRiderButton.addAction(for: .tap) {
//            self.goToRating(withTrip: rideModel)
//        }
//
//        return cell
//    }
//
//    // MARK: CollectionView Delegate
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//    {
//        let ridemodel = DriverDetailModel(withJson: self.normalTripsDict[indexPath.row] as JSON)
//
////        if ridemodel.tripStatus == .rating{
////            AppRouter(self).routeToDetailTripHistory(forTrip: ridemodel)
////        }else{
////            AppRouter(self).routeInCompleteTrips(ridemodel)
////        }
//
//    }
//
//
//    func goToRating(withTrip trip : DriverDetailModel){
//        /*
//        let propertyView = UIStoryboard.main.instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
//        let id = trip.trip_id
//        propertyView.strDriverImgUrl = trip.driver_thumb_image
//        propertyView.strTripID = String(id)
//        propertyView.isFromTripPage = true
//        self.navigationController?.pushViewController(propertyView, animated: true)*/
////        let rateDriverVC : RateDriverVC = .initWithStory(trip)
////        self.navigationController?.pushViewController(rateDriverVC,
////                                                      animated: true)
//    }
//// MARK:  ACCEPT RIDER TRIP REQUEST
//    // MARK:- Button Actions
//    @IBAction func onBackTapped(_ sender:UIButton!)
//    {
//        if isfromschdule == true {
//            let propertyView = MainMapView.initWithStory()
//            self.navigationController?.pushViewController(propertyView, animated: true)
//        }
//        else{
//            self.navigationController!.popViewController(animated: true)
//        }
//    }
//
//    @available(iOS 12.0, *)
//    @IBAction func pastButtonAction(_ sender: Any) {
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
//            self.indicatorView.frame = CGRect(x:  (sender as AnyObject).frame.origin.x, y:self.indicatorView.frame.origin.y , width: self.indicatorView.frame.size.width,height: self.indicatorView.frame.size.height);
//        }, completion: { (finished: Bool) -> Void in
//            self.collectionTrips.isHidden = false
//            self.scheduledRideTableView.isHidden = true
//        })
//        self.checkStatus()
//        self.collectionTrips.reloadData()
//    }
//
//    @available(iOS 12.0, *)
//    @IBAction func upcomingButtonAction(_ sender: Any) {
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
//            self.indicatorView.frame = CGRect(x:  (sender as AnyObject).frame.origin.x, y:self.indicatorView.frame.origin.y , width: self.indicatorView.frame.size.width,height: self.indicatorView.frame.size.height);
//        }, completion: { (finished: Bool) -> Void in
//            self.scheduledRideTableView.isHidden = false
//            self.collectionTrips.isHidden = true
//        })
//        self.checkStatus()
//        self.scheduledRideTableView.reloadData()
//
//    }
//
//    @objc func editTimeSelected(_ sender: UIButton) {
//        let cell: ScheduledTripsTVC = sender.superview!.superview as! ScheduledTripsTVC
//        let table: UITableView = cell.superview as! UITableView
//        let selectedIndexPath = table.indexPath(for: cell)!.row
//        print(selectedIndexPath)
//        selectedTripDict = scheduledTripsDict[selectedIndexPath]
//        let scheduleRideVC = ScheduleRiderVC.initWithStory()
//        scheduleRideVC.view.backgroundColor = UIColor.clear
//        scheduleRideVC.delegate = self
//        scheduleRideVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
//        present(scheduleRideVC, animated: false, completion: nil)
//    }
//
//    @objc func cancelRideSelected(_ sender: UIButton) {
//        let cell: ScheduledTripsTVC = sender.superview!.superview as! ScheduledTripsTVC
//        let table: UITableView = cell.superview as! UITableView
//        let selectedIndexPath = table.indexPath(for: cell)!.row
//        print(selectedIndexPath)
//        let cancelRiderVC = CancelRideVC.initWithStory()
//        cancelRiderVC.isToCancelSchedule = true
//        cancelRiderVC.strTripId = "\(String(describing: scheduledTripsDict[selectedIndexPath]["id"]!))"
//        self.navigationController?.pushViewController(cancelRiderVC, animated: false)
//    }
//
//    // MARK:- TableView Delegates
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        if scheduledTripsDict.count != 0{
//            self.view.bringSubviewToFront(scheduledRideTableView)
//            return scheduledTripsDict.count
//        }else{
//            self.view.bringSubviewToFront(lblNoTrips)
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduledTripsTVC") as! ScheduledTripsTVC
//        cell.statusLabel!.text = NSLocalizedString("\((scheduledTripsDict[indexPath.row]["status"] as? String ?? String()))", comment: "")
//        cell.timeLabel!.text = (scheduledTripsDict[indexPath.row]["schedule_display_date"] as? String ?? String())
//        cell.vehicleNameLabel!.text = "\(scheduledTripsDict[indexPath.row]["car_name"] as? String ?? String())|\(Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)) \(scheduledTripsDict[indexPath.row]["fare_estimation"] as? String ?? String())"
//        cell.sourceLocLabel!.text = (scheduledTripsDict[indexPath.row]["pickup_location"] as? String ?? String())
//        cell.destiLocLabel!.text = (scheduledTripsDict[indexPath.row]["drop_location"] as? String ?? String())
//        cell.editTimeButtonOutlet.addTarget(self, action: #selector(self.editTimeSelected(_:)), for: .touchUpInside)
//        cell.cancelRideButtonOutlet.addTarget(self, action: #selector(self.cancelRideSelected(_:)), for: .touchUpInside)
//        return cell
//    }
//
//    func onScheduleRiderTapped(scheduledTime: String) {
//        var receivedDateString = String((scheduledTime.split(separator: "-"))[0])
//        let myDateFormatter: DateFormatter = DateFormatter()
//        myDateFormatter.locale = Locale(identifier: "en_US")
//        receivedDateString = String(format:"%@",receivedDateString.replacingOccurrences(of: "at", with: "\(myDateFormatter.string(from: Date())) ~"))
//        receivedDateString.removeLast()
//        myDateFormatter.dateFormat = "EEE, dd MMM yyyy ~ hh:mm a"
//        myDateFormatter.locale = Locale(identifier: "en_US")
//        guard let mySelectedDate = myDateFormatter.date(from: "\(receivedDateString)") else{
//            self.appDelegate.createToastMessage(DisplayErrors.somethingWentWrong.rawValue)
//            return
//        }
//        myDateFormatter.dateFormat = "HH:mm"
//        myDateFormatter.locale = Locale(identifier: "en_US")
//        let scheduledTimeAloneString = myDateFormatter.string(from: mySelectedDate)
//        myDateFormatter.dateFormat = "dd-MM-yyyy"
//        let scheduledDateAloneString = myDateFormatter.string(from: mySelectedDate)
//        let paramDict = ["schedule_date":scheduledDateAloneString, "schedule_time":scheduledTimeAloneString, "schedule_id":"\(String(describing: selectedTripDict["id"]!))", "token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)] as [String : Any]
//        WebServiceHandler.sharedInstance.getWebService(wsMethod:"save_schedule_ride", paramDict: paramDict, viewController:self, isToShowProgress:true, isToStopInteraction:true,complete:  { (response) in
//            let responseJson = response
//            DispatchQueue.main.async {
//                if responseJson["status_code"] as? String == "1" {
//                    self.callGetTripsApi()
//                }
//                else {
//                self.appDelegate.createToastMessageForAlamofire(responseJson["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
//                }
//
//            }
//        }){(error) in
//
//        }
//
//    }
//
//}
//
