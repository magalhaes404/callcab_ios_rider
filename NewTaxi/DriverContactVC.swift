/**
* DriverContactVC.swift
*
* @package UberDriver
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import Foundation
import MapKit

class DriverContactVC : UIViewController
{
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var callHolderView: UIView!
    @IBOutlet weak var messageHolderView: UIView!
    
    
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPhoneNo: UILabel!
    
    @IBOutlet weak var messageView : UIView?
    @IBOutlet weak var callView : UIView?
    
    @IBOutlet weak var lblContacts : UILabel!
    @IBOutlet weak var lblCall : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var heightLblPhone : NSLayoutConstraint!
    static var currentTripID : String? = nil
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var driverimage  =  UIImage(named: "user_dummy.png")!
    private (set) var tripDetailModel : TripDetailDataModel!
    var window: UIWindow? {
        return AppDelegate.shared.window
    }
    lazy var language : LanguageProtocol = {Language.default.object}()
    // MARK: - ViewController Methods
    
    func setDesign() {
        self.view.backgroundColor = .white
        
        self.containerView.setSpecificCornersForTop(cornerRadius: 35)
        self.containerView.elevate(4)
        
        self.lblContacts.textColor = .Title
        self.lblContacts.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.lblUserName.textColor = .Title
        self.lblUserName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
        
        self.lblPhoneNo.textColor = .Title
        self.lblPhoneNo.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 19)
        
        self.callView?.backgroundColor = .ThemeYellow
        self.callView?.isCurvedCorner = true
        self.callView?.elevate(3)
        
        self.lblCall.textColor = .Title
        self.lblCall.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        
        self.messageView?.backgroundColor = .ThemeYellow
        self.messageView?.isCurvedCorner = true
        self.messageView?.elevate(3)
        
        self.lblMessage.textColor = .Title
        self.lblMessage.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initView()
        self.initLanguage()
        self.setDesign()
    }
    override func viewWillAppear(_ animated: Bool) {

    }
    //MARK:- initializers
    func initView(){
        
        if self.tripDetailModel?.bookingType == BookingEnum.manualBooking {
//            self.messageHolderView?.isHidden = true
            lblPhoneNo.text = tripDetailModel?.mobileNumber
            lblPhoneNo.isHidden = false
            self.heightLblPhone.constant = 50
        }else{
            lblPhoneNo.isHidden = true
            self.messageHolderView?.isHidden = false
            lblPhoneNo.text = ""//strContactNo
            self.heightLblPhone.constant = 0
            
        }
        lblUserName.text = tripDetailModel.driverName.capitalized
        
    }
    func initLanguage(){
        self.btnBack.setTitle(self.language.getBackBtnText(), for: .normal)
        self.lblContacts.text = self.language.contacts
        self.lblCall.text = self.language.call
        self.lblMessage.text = self.language.message
    }
    //MARK:- initWithStory
    class func initWithStory(tripDetail : TripDetailDataModel) -> DriverContactVC{
        let view : DriverContactVC =  UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        view.tripDetailModel = tripDetail
        return view
    }
    //MARK:- aCtions
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: false)

    }

    //MARK: - WHEN PRESS CALL BUTTON
    /*
        WE HAVE TO MAKE 
     */
    @IBAction func onCallTapped()
    {
        

        if self.tripDetailModel.bookingType != BookingEnum.manualBooking{
            guard let driverId : Int = UserDefaults.value(for: .driver_user_id),
                driverId != 0
                else {return}
            self.callView?.freeze()
            do {
                try CallManager.instance.callUser(withID: driverId.description)
            }catch let error{
                debug(print: error.localizedDescription)
            }
        }else{
            if let phoneCallURL:NSURL = NSURL(string:"tel://\(self.tripDetailModel?.mobileNumber ?? "")") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL as URL)) {
//                    application.openURL(phoneCallURL as URL);
                    application.open(phoneCallURL as URL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    @IBAction func onMessageTapped(){
        let chatVC = ChatVC.initWithStory(withTripId: self.tripDetailModel.description,
                                          driverRating: Double(self.tripDetailModel.rating),
                                          driver_id: self.tripDetailModel.driverId)
        chatVC.driverImage = self.driverimage
        if let nav = self.window?.rootViewController as? UINavigationController{
            nav.pushViewController(chatVC, animated: true)
        }else if let root = self.window?.rootViewController{
            root.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
