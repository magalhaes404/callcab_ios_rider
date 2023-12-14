//
//  PeakDetailVC.swift
// NewTaxi
//
//  Created by Seentechs on 22/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import GoogleMaps

class PeakDetailVC: UIViewController {

    private var carModel : SearchCarsModel!
    var carCount: Int = 0
    var pickUp : CLLocationCoordinate2D!
    var drop : CLLocationCoordinate2D!
    var strCarType = ""
    var path : GMSPath!
    var request_Params = JSON()
   
    
    //MARK: Outlets
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageDescription: UILabel!
    
    @IBOutlet weak var peakValue: UILabel!
    @IBOutlet weak var normalFareLbl: UILabel!
    @IBOutlet weak var minimumFareLbl: UILabel!
    @IBOutlet weak var minLeftLbl: UILabel!
    @IBOutlet weak var minKMLbl: UILabel!
    @IBOutlet weak var minKMValueLbl: UILabel!
    @IBOutlet weak var minLeftValueLbl: UILabel!
    @IBOutlet weak var minFareValueLbl: UILabel!
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var blackCircleV: UIView!
    
    @IBOutlet weak var peak_car: UIImageView!
    
    @IBOutlet weak var acceptFareBtn: UIButton!
    @IBOutlet weak var tryLaterBtn: UIButton!
    @IBOutlet weak var orBtn: UIButton!
    @IBOutlet weak var bar: UIView!
    
    // Design
    
    func setDesign() {
        self.containerView.backgroundColor = .white
        self.containerView.setSpecificCornersForTop(cornerRadius: 35)
        self.containerView.elevate(4)
        
        self.pageTitle.textColor = .Title
        self.pageTitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        
        self.pageDescription.textColor = .Title
        self.pageDescription.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.blackCircleV.isRoundCorner = true
        self.blackCircleV.elevate(0.8)
        self.blackCircleV.backgroundColor = .ThemeYellow
        
        
        self.peakValue.textColor = .Title
        self.peakValue.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 50)
        
        
        self.normalFareLbl.textColor = .Title
        self.normalFareLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.minFareValueLbl.textColor = .Title
        self.minFareValueLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        
        
        self.minimumFareLbl.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.minimumFareLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        
        
        self.bar.backgroundColor = .Border
        
        self.minLeftValueLbl.textColor = .Title
        self.minLeftValueLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        
        
        self.minLeftLbl.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.minLeftLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        
        
        self.minKMValueLbl.textColor = .Title
        self.minKMValueLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        
        
        self.minKMLbl.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.minKMLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        
        
        self.acceptFareBtn.setTitleColor(.Title, for: .normal)
        self.acceptFareBtn.backgroundColor = .ThemeYellow
        self.acceptFareBtn.cornerRadius = 15
        self.acceptFareBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.tryLaterBtn.setTitleColor(.white, for: .normal)
        self.tryLaterBtn.backgroundColor = .Title
        self.tryLaterBtn.cornerRadius = 15
        self.tryLaterBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.orBtn.setTitleColor(.Title, for: .normal)
        self.orBtn.backgroundColor = .white
        self.orBtn.isRoundCorner = true
        self.orBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
    }
    
    //MARK: Actions
    @IBAction func BackAction(_ sender: UIButton) {
   
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func requsetCarAPIAction(_ sender: Any) {
        self.animateToMakeRequest()
    }
    var isForSchedule = false
    var paramDict = [String:Any]()
    var estimatedFareString = String()
    var scheduledTimeString = String()
    lazy var language = Language.default.object
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.setDesign()
        // Do any additional setup after loading the view.
    }
    
    //MARK: initializers
    
    func initView(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
//            self.orBtn.isRoundCorner = true
//            self.blackCircleV.isRoundCorner = true
//            self.blackCircleV.elevate(0.8)
            self.addBubleLayer()
        }
//        self.peakValue.setResponisveFont(withSize: 50)
//        self.normalFareLbl.setResponisveFont(withSize: 15)
//        self.minFareValueLbl.setResponisveFont(withSize: 18)
//        self.minimumFareLbl.setResponisveFont(withSize: 17)
//        self.minLeftValueLbl.setResponisveFont(withSize: 17)
//        self.minLeftLbl.setResponisveFont(withSize: 16)
//        self.minKMValueLbl.setResponisveFont(withSize: 17)
//        self.minKMLbl.setResponisveFont(withSize: 16)
        
        let currency = UserDefaults.standard.string(forKey: USER_CURRENCY_SYMBOL_ORG) ?? "$"
        
        self.peakValue.text = self.carModel.peak_price+"x"
        self.minFareValueLbl.text = currency+self.carModel.min_fare
        self.minKMValueLbl.text = currency+self.carModel.per_km
        self.minLeftValueLbl.text = currency+self.carModel.per_min
        
        
        
        self.pageTitle.text = self.language.peakTimePricing
        let _description = self.language.demandIsOff
        self.pageDescription.text = _description.replacingOccurrences(of: "UBER", with: iApp.appName)
        self.normalFareLbl.text = self.language.normalFare
        self.minimumFareLbl.text = self.language.minFare
        self.minLeftLbl.text = self.language.minLeft
        self.minKMLbl.text = self.language.minKm
        self.orBtn.setTitle(self.language.or.uppercased(), for: .normal)
        self.acceptFareBtn.setTitle(self.language.acceptHigherFare, for: .normal)
        self.tryLaterBtn.setTitle(self.language.tryLater, for: .normal)
        
    }
    //MARK: animations and effects
    
    func animateToMakeRequest(){
        /*
        let dot = CALayer()
        dot.opacity = 0.5
        dot.frame = self.view.frame
        dot.cornerRadius = self.view.frame.size.height / 2
        dot.backgroundColor = UIColor.black.cgColor
        dot.transform = CATransform3DMakeScale(0, 0, 0)
        
        view.layer.addSublayer(dot)
        
        UIView.animate(withDuration: 1.3, animations: {
            dot.opacity = 1
            dot.transform = CATransform3DMakeScale(1, 1, 1)
        }) { (_) in
            dot.removeFromSuperlayer()
         
            
        }
         */
//        let storyBoard = Stories.Main.instance
        if isForSchedule{
            let scheduleDetailVC = ScheduleRideDetailViewController
                .initWithStory(params: self.paramDict,
                               car: self.carModel,
                               estimatedFareString: self.estimatedFareString,
                               scheduledTimeString: self.scheduledTimeString,
                               path: self.path)
            self.navigationController?.pushViewController(scheduleDetailVC, animated: true)
        }else{
         
            let peak_id = String(self.carModel.peak_id)
            self.request_Params["peak_id"] = String(format:"%@",peak_id)
            self.request_Params["location_id"] = String(format:"%@",self.carModel.location_id)
            
                let viewRequest = MakeRequestVC
                    .initWithStory(params: self.request_Params,
                                   carType: self.strCarType,
                                   carCount: self.carCount,
                                   path: self.path,
                                   pickUp: self.pickUp,
                                   drop: self.drop)
                self.navigationController?.pushViewController(viewRequest, animated: false)
          
        }
    }
    func addBubleLayer(){
        let bezierPath = UIBezierPath()
        let arrowHeight : CGFloat = 15
        let arrowWidth : CGFloat = 15
        let curve : CGFloat = 5
        let elevation : CGFloat = 1
        /*
         * Ignore the beizer coding
         * Alter above values for changing the appearance
         * and for color go down and edit buble layer shadow color
         */
        bezierPath.move(to: CGPoint(x: 0 + curve * 2,
                                    y: 0 + arrowHeight))
        
        bezierPath.addLine(to: CGPoint(x: (self.bubbleView.frame.width / 2) - arrowWidth ,
                                       y: 0 + arrowHeight))
        bezierPath.addLine(to: CGPoint(x: (self.bubbleView.frame.width / 2)  ,
                                       y: 0))
        bezierPath.addLine(to: CGPoint(x: (self.bubbleView.frame.width / 2) + arrowWidth ,
                                       y: 0 + arrowHeight))
        
        bezierPath.addLine(to: CGPoint(x: (self.bubbleView.frame.width - curve * 2),
                                       y: 0 + arrowHeight))
        bezierPath.addCurve(to: CGPoint(x: self.bubbleView.frame.width,
                                        y: 0 + arrowHeight + curve * 2),
                            controlPoint1: CGPoint(x: self.bubbleView.frame.width - curve,
                                                   y: 0 + arrowHeight),
                            controlPoint2: CGPoint(x: self.bubbleView.frame.width  ,
                                                   y: 0 + arrowHeight))
        
        bezierPath.addLine(to: CGPoint(x: self.bubbleView.frame.width,
                                       y: self.bubbleView.frame.height - curve * 2))
        bezierPath.addCurve(to: CGPoint(x: self.bubbleView.frame.width - curve * 2,
                                        y: self.bubbleView.frame.height),
                            controlPoint1: CGPoint(x: self.bubbleView.frame.width,
                                                   y: self.bubbleView.frame.height - curve),
                            controlPoint2: CGPoint(x: self.bubbleView.frame.width  ,
                                                   y: self.bubbleView.frame.height))
        
        bezierPath.addLine(to: CGPoint(x: 0 + curve * 2,
                                       y: self.bubbleView.frame.height))
        bezierPath.addCurve(to: CGPoint(x: 0,
                                        y: self.bubbleView.frame.height - curve * 2),
                            controlPoint1: CGPoint(x: 0 + curve,
                                                   y: self.bubbleView.frame.height),
                            controlPoint2: CGPoint(x: 0  ,
                                                   y: self.bubbleView.frame.height))
        
        bezierPath.addLine(to: CGPoint(x: 0,
                                       y: 0 + arrowHeight + curve * 2 ))
        bezierPath.addCurve(to: CGPoint(x: 0 + curve * 2,
                                        y: 0 + arrowHeight),
                            controlPoint1: CGPoint(x: 0,
                                                   y: 0 + arrowHeight + curve),
                            controlPoint2: CGPoint(x: 0  ,
                                                   y: 0 + arrowHeight))
        
        bezierPath.close()
        
        let bubleLayer = CAShapeLayer()
        bubleLayer.path = bezierPath.cgPath
        bubleLayer.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.frame.width,
                                  height: self.view.frame.height)
        
        bubleLayer.fillColor = UIColor.white.cgColor
        bubleLayer.masksToBounds = false
        bubleLayer.shadowColor = UIColor.ThemeMain.cgColor
        bubleLayer.shadowOffset = CGSize(width: 0, height: elevation)
        bubleLayer.shadowRadius = elevation
        bubleLayer.shadowOpacity = 1
        self.bubbleView.layer.addSublayer(bubleLayer)
        
    }
 
    class func initWithStory(forCar car : SearchCarsModel,
                             params : JSON,
                             carType : String,
                             carCount : Int,
                             path : GMSPath,
                             pickUp : CLLocationCoordinate2D,
                             drop : CLLocationCoordinate2D) -> PeakDetailVC{
        let view : PeakDetailVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        view.carModel = car
        view.request_Params = params
        view.path = path
        view.carCount = carCount
        view.strCarType = carType
        view.pickUp = pickUp
        view.drop = drop
        view.isForSchedule = false
        return view
    }
    class func initWithStory(forCar car : SearchCarsModel,
                              scheduleParams params : JSON,
                              estimatedFareString : String,
                              scheduledTimeString : String,
                              path : GMSPath) -> PeakDetailVC{
         let viewRequest : PeakDetailVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
         viewRequest.carModel = car
        viewRequest.path = path
        viewRequest.paramDict = params
        viewRequest.estimatedFareString = estimatedFareString
        viewRequest.scheduledTimeString = scheduledTimeString
        viewRequest.isForSchedule = true
         return viewRequest
     }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
