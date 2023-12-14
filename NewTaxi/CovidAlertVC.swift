//
//  CovidAlertVC.swift
// NewTaxi
//
//  Created by Seentechs on 21/04/21.
//  Copyright © 2021 Vignesh Palanivel. All rights reserved.
//

import UIKit
import GoogleMaps

class CovidAlertVC: UIViewController{
   
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var pointThreeView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var pointOneView: UIView!
    @IBOutlet weak var pointTwoView: UIView!
    @IBOutlet weak var pointOneDot: UILabel!
    @IBOutlet weak var pointOneLbl: UILabel!
    @IBOutlet weak var pointTwoDot: UILabel!
    @IBOutlet weak var pointTwoLbl: UILabel!
    @IBOutlet weak var imageOuterView: UIView!
    @IBOutlet weak var pointThreeLbl: UILabel!
    
    @IBOutlet weak var bottomlbl: UILabel!
    @IBOutlet weak var pointThreeDot: UILabel!
    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var alertImg: UIImageView!
    private var carModel : SearchCarsModel!
    var scheduledTime:String?

    lazy var dictParams = JSON()
    var isSchedule = false
    var navigationControllerObj = UINavigationController()

    class func initWithStory(params : JSON,navigationCtrl: UINavigationController,isSchedule: Bool) -> CovidAlertVC{
        let covid : CovidAlertVC = UIStoryboard.payment.instantiateViewController()
        covid.navigationControllerObj = navigationCtrl
        covid.dictParams = params
        covid.isSchedule = isSchedule
        return covid
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFonts()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        
    }
    func setFonts()
    {
        self.popupView.setSpecificCornersForTop(cornerRadius: 35)
        
//        self.titleLbl.text = "Travel Only If You Are Asymptomatic."
        self.titleLbl.text = self.language.covidTitle
        self.titleLbl.textColor = .Title
        self.titleLbl.font = iApp.NewTaxiFont.centuryBold.font(size: 15)
        
        self.subTitleLbl.text = self.language.covidSubTitle //"Make The Ride Comfortable By Following The Safety Regulations To Keep You and Your Driver Safe!!".localize
        self.subTitleLbl.textColor = UIColor.Title.withAlphaComponent(0.75)
        self.subTitleLbl.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        
        self.pointOneLbl.text = self.language.covidPointOne //"Always wear a mask and maintain social distance.".localize
        self.pointOneLbl.textColor = UIColor.Title.withAlphaComponent(0.50)
        self.pointOneLbl.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        
        self.pointTwoLbl.text = self.language.covidPointTwo//"Regularly Wear Face Covering and Sanitise your Hands Before And After the Rides.".localize
        self.pointTwoLbl.textColor = UIColor.Title.withAlphaComponent(0.50)
        self.pointTwoLbl.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)

        self.pointThreeLbl.text = self.language.covidPointThree//"Don’t take a ride if you have Covid-19 or related symptoms.".localize
        self.pointThreeLbl.textColor = UIColor.Title.withAlphaComponent(0.50)
        self.pointThreeLbl.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)
        
        self.bottomlbl.text = self.language.covidBottom//"Be Safe and Stay Healthy!!!".localize
        self.bottomlbl.textColor = UIColor.Title.withAlphaComponent(0.75)
        self.bottomlbl.font = iApp.NewTaxiFont.centuryRegular.font(size: 14)

        self.cancelBtn.backgroundColor = .Background
        self.cancelBtn.titleLabel?.font = iApp.NewTaxiFont.centuryBold.font(size: 17)
        self.cancelBtn.setTitleColor(.Title, for: .normal)
        self.cancelBtn.setTitle(self.language.cancel.capitalized, for: .normal)
        self.proceedBtn.setTitle(self.language.proceed.lowercased().capitalized, for: .normal)
        self.cancelBtn.cornerRadius = 10
        self.proceedBtn.backgroundColor = .Title
        self.proceedBtn.titleLabel?.font = iApp.NewTaxiFont.centuryBold.font(size: 17)
        self.proceedBtn.setTitleColor(.white, for: .normal)
        self.proceedBtn.cornerRadius = 10
        self.alertImg.image = UIImage(named: "covid")
        self.alertImg.cornerRadius = 5
        self.pointOneDot.isRoundCorner = true
        self.pointTwoDot.isRoundCorner = true
        self.pointThreeDot.isRoundCorner = true

//        let attributedText = NSMutableAttributedString().underlined("Wear a mask".localize).normal(" and sanitise your hands before and after each ride.".localize)
//        self.pointOneLbl.attributedText = attributedText
//        let attributedText2 = NSMutableAttributedString().normal("Travel only if you are ".localize).underlined("completely symptom - free".localize).normal(" and have no fever, cough, or other respiratory problems.".localize)
//        self.pointTwoLbl.attributedText = attributedText2
        
    }
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceedBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if isSchedule{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Schedule_covid"), object: self, userInfo: ["params": dictParams,"time": self.scheduledTime])

        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Request_covid"), object: self, userInfo: ["params": dictParams])
        }
       
    }
    
}
