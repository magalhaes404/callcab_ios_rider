//
//  SOSViewController.swift
//  MyRideCiti
//
//  Created by Seentechs Technologies on 03/04/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class SOSViewController: UIViewController,APIViewProtocol{
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var useInCaseLabel: UILabel!
    @IBOutlet weak var alertIndicatingView: UIView!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var descriptionLabel : UILabel!

    @IBOutlet weak var closeBtn: UIButton!
    var apiInteractor: APIInteractorProtocol?

    func setDesign() {
        self.closeBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        self.titleLbl.textColor = .Title
        self.titleLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.titleLbl.text = "SOS".localize
        
        self.contentView.setSpecificCornersForTop(cornerRadius: 35)
        self.contentView.elevate(3)
        
        self.alertIndicatingView.isCurvedCorner = true
        self.alertIndicatingView.backgroundColor = .white
        self.alertIndicatingView.elevate(2)
        
        self.useInCaseLabel.textColor = .Title
        self.useInCaseLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
        
        self.alertLabel.textColor = .systemRed
        self.alertLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.descriptionLabel.textColor = .Title
        self.descriptionLabel.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 12)
    }
    
    var appDelegate = AppDelegate()
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.useInCaseLabel.text = self.language.useEmergency
        self.alertLabel.text = self.language.AlertEmergencyContact
        self.descriptionLabel.text = self.language.newtaxiCollectLocData
        self.setDesign()
        let tapOnAlert = UITapGestureRecognizer(target: self, action: #selector(SOSViewController.alertSelected))
        alertIndicatingView.addGestureRecognizer(tapOnAlert)
        let url = Bundle.main.url(forResource: "loading", withExtension: "gif")
        DispatchQueue.main.async {
            self.loadingImageView.sd_setImage(with: url!)
        }
        
        loadingImageView.isHidden = true

        if let desc = self.descriptionLabel.text{
            self.descriptionLabel.text = desc.replacingOccurrences(of: "NewTaxi", with: iApp.appName)
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func alertSelected(_sender:UITapGestureRecognizer) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message: self.language.continueSendAlert, preferredStyle:UIAlertController.Style.alert)
        let okAction = UIAlertAction(title:self.language.continue_, style:UIAlertAction.Style.default, handler:{ action in
            self.alertImageView.image = UIImage(named:"warning (4)")
            self.alertLabel.text = self.language.sendingAlert
            self.alertLabel.textColor = UIColor.gray
            self.loadingImageView.isHidden = false
            self.wsToCallSOS()
        })
        let cancelAction = UIAlertAction(title: self.language.cancel, style:UIAlertAction.Style.cancel, handler:{ action in
        })
        okAction.setValue(UIColor.red, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.gray, forKey: "titleTextColor")
        settingsActionSheet.addAction(okAction)
        settingsActionSheet.addAction(cancelAction)
        present(settingsActionSheet, animated:true, completion:nil)
        
    }

    @IBAction func closeButtonAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    func wsToCallSOS() {
        
        let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
                         "latitude" : Constants().GETVALUE(keyname: USER_LATITUDE),
                         "longitude" : Constants().GETVALUE(keyname: USER_LONGITUDE)] as JSON
        
//        WebServiceHandler.sharedInstance.getWebService(wsMethod:"sosalert", paramDict: paramDict, viewController:self, isToShowProgress:false, isToStopInteraction:true,complete:  { (response) in
//            let responseJson = response
//            DispatchQueue.main.async {
//                if (responseJson["status_code"] as? String == "1") || (responseJson["status_code"] as? String == "2") {
////                    self.alertLabel.text = NSLocalizedString("Alert Sent", comment: "")
//                    self.alertLabel.text = self.language.alertSent
//                    self.alertLabel.textColor = UIColor.black
//                    self.loadingImageView.isHidden = true
//                    self.alertImageView.image = UIImage(named:"check-symbol")
//                }
//                else {
//                    self.appDelegate.createToastMessageForAlamofire(responseJson["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
//                }
//                
//            }
//        }){(error) in
//            
//        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .sosalert,params: paramDict)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    if (json["status_code"] as? String == "1") || (json["status_code"] as? String == "2") {
                        self.alertLabel.text = self.language.alertSent
                        self.alertLabel.textColor = UIColor.black
                        self.loadingImageView.isHidden = true
                        self.alertImageView.image = UIImage(named:"check-symbol")
                    }
                    else{
                        UberSupport.shared.removeProgressInWindow()
                        self.appDelegate.createToastMessageForAlamofire(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title, forView:self.view)
                    }
                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
                self.appDelegate.createToastMessageForAlamofire(error, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title, forView:self.view)
            })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
