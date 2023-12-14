//
//  ScheduleRideDetailViewController.swift
// NewTaxi
//
//  Created by Seentechs on 12/07/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import GoogleMaps

class ScheduleRideDetailViewController: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var upcomingRideLabel: UILabel!
    @IBOutlet weak var scheduledTimeLabel: UILabel!
    @IBOutlet weak var scheduleImage: UIImageView!
    @IBOutlet weak var schedulingRideLabel: UILabel!
    @IBOutlet weak var fareTitleLabel: UILabel!
    @IBOutlet weak var estimatedFareLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    
    func setDesign() {
        self.view.backgroundColor = .white
        
        self.holderView.backgroundColor = .white
        self.holderView.setSpecificCornersForTop(cornerRadius: 35)
        self.holderView.elevate(4)
        
        self.upcomingRideLabel.textColor = .Title
        self.upcomingRideLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.scheduledTimeLabel.textColor = .Title
        self.scheduledTimeLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.scheduleImage.cornerRadius = 15
        
        self.schedulingRideLabel.textColor = .Title
        self.schedulingRideLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.fareTitleLabel.textColor = .Title
        self.fareTitleLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        
        
        self.estimatedFareLabel.textColor = .Title
        self.estimatedFareLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 13)
        
        self.descriptionLabel.textColor = .Title
        self.descriptionLabel.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 12)
        
        self.doneButtonOutlet.setTitleColor(.Title, for: .normal)
        self.doneButtonOutlet.backgroundColor = .ThemeYellow
        self.doneButtonOutlet.cornerRadius = 15
        self.doneButtonOutlet.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
    }
    
    var appDelegate = AppDelegate()
    var selectedCar : SearchCarsModel?
    var viewNewTaxiLoader = NewTaxiLoader()
    var paramDict = [String:Any]()
    var estimatedFareString = String()
    var scheduledTimeString = String()
    var scheduledTimeAloneString = String()
    var scheduledDateAloneString = String()
    var receivedDateString = String()
    var isfromschdule: Bool = false
    var path : GMSPath!
    lazy var lang = Language.default.object
    
    func hideOrShowViews(status:Bool) {
        upcomingRideLabel.isHidden = status
        scheduledTimeLabel.isHidden = status
        fareTitleLabel.isHidden = status
        estimatedFareLabel.isHidden = status
        descriptionLabel.isHidden = status
        doneButtonOutlet.isHidden = status
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.upcomingRideLabel.text = self.lang.upComingRide
        self.schedulingRideLabel.text = self.lang.sheduleUrRide
        self.fareTitleLabel.text = self.lang.currentFareEstimate
        self.doneButtonOutlet.setTitle(self.lang.done, for: .normal)
        self.backBtn.setTitle(self.lang.getBackBtnText(), for: .normal)
        var receivedDateString = String((scheduledTimeString.split(separator: "-"))[0])
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "en_US")
        receivedDateString = String(format:"%@",receivedDateString.replacingOccurrences(of: " at ", with: "\(myDateFormatter.string(from: Date())) ~ "))
        receivedDateString.removeLast()
        myDateFormatter.dateFormat = "EEE, dd MMM yyyy ~ hh:mm a"
//        myDateFormatter.locale = Locale(identifier: "en_US")
        let mySelectedDate = myDateFormatter.date(from: "\(receivedDateString)")
        myDateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        myDateFormatter.dateFormat = "HH:mm"
        scheduledTimeAloneString = myDateFormatter.string(from: mySelectedDate!)
        myDateFormatter.dateFormat = "dd-MM-yyyy"
        scheduledDateAloneString = myDateFormatter.string(from: mySelectedDate!)
        estimatedFareLabel.text = "\(Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)) \(estimatedFareString)"
        scheduledTimeLabel.text = scheduledTimeString
        descriptionLabel.text = "\(self.lang.actualString) \(iApp.appName) \(self.lang.doesNotGuaranteeStr)"
        hideOrShowViews(status: false)
        schedulingRideLabel.isHidden = true
        self.setDesign()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- initWithStory
    class func initWithStory(params : JSON,
                             car : SearchCarsModel,
                             estimatedFareString : String,
                             scheduledTimeString : String,
                             path : GMSPath) -> ScheduleRideDetailViewController{
        let scheduleDetailVC : ScheduleRideDetailViewController = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        scheduleDetailVC.paramDict = params
        scheduleDetailVC.selectedCar = car
        scheduleDetailVC.estimatedFareString = estimatedFareString
        scheduleDetailVC.scheduledTimeString = scheduledTimeString
        scheduleDetailVC.path = path
        return scheduleDetailVC
    }
    //MARK:- actions
    @IBAction func backbtnTapped(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        var localTimeZoneName: String { return TimeZone.current.identifier }
        var paramDict = [
            "token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
            "schedule_date" : scheduledDateAloneString,
            "schedule_time" : scheduledTimeAloneString,
            "pickup_latitude" : self.paramDict["pickup_latitude"]!,
            "pickup_longitude" : self.paramDict["pickup_longitude"]!,
            "drop_latitude" : self.paramDict["drop_latitude"]!,
            "drop_longitude" : self.paramDict["drop_longitude"]!,
            "car_id" : self.paramDict["car_id"]!,
            "pickup_location" : self.paramDict["pickup_location"]!,
            "drop_location" : self.paramDict["drop_location"]!,
            "timezone" : localTimeZoneName,
            "&device_type" : "2",
            "is_wallet" : Constants().GETVALUE(keyname: USER_SELECT_WALLET),
            "user_type" : "rider",
            "device_id" : Constants().GETVALUE(keyname: USER_DEVICE_TOKEN),
            "payment_method" : PaymentOptions.default?.paramValue ?? "cash",
            "polyline" : self.path.encodedPath()
            ] as [String : Any]
        if let car = self.selectedCar{
            paramDict["location_id"] = car.location_id
            if car.apply_peak{
                paramDict["peak_id"] = car.peak_id
            }
        }
        print("∂",paramDict)
        let loader = UberSupport()
        loader.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .scheduleRide,
                        params: paramDict)
            .responseJSON({ (response) in
                loader.removeProgressInWindow()
                if response.isSuccess {
                    
                    let tripVC : TripHistoryVC = TripHistoryVC.initWithStory()
                    tripVC.isFromSchdule = true
                    self.navigationController?.pushViewController(tripVC, animated: true)
                    
                }else {
                    self.appDelegate
                        .createToastMessageForAlamofire(response.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.white, forView:self.view)
                }
                
            })
            .responseFailure({ (error) in
                loader.removeProgressInWindow()
                self.appDelegate.createToastMessage(error)
            })
        
    }

}
