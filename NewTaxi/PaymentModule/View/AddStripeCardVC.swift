//
//  AddStripeCardVC.swift
// NewTaxi
//
//  Created by Seentechs on 03/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Stripe

class AddStripeCardVC: UIViewController,APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    

    //MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var doneBtn : UIButton!
    @IBOutlet weak var pageTitle : UILabel!
    @IBOutlet weak var stripeCardTextField: STPPaymentCardTextField!
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    
    let appDelegate = AppDelegate()
    var updateDelegate : UpdateContentProtocol?
    let preference = UserDefaults.standard
    var isToChangeCard = false
    var stripeHandler : StripeHandler?
    //MARK: View life cycles
    
    func setDesign() {
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)

        self.pageTitle.textColor = .Title
        self.pageTitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.view.backgroundColor = .white
        self.containerView.backgroundColor = .white
        self.containerView.setSpecificCornersForTop(cornerRadius: 35)
        self.containerView.elevate(4)
        
        
        self.stripeCardTextField.isCurvedCorner = true
        self.stripeCardTextField.border(1, .Border)
        
        self.doneBtn.backgroundColor = .ThemeYellow
        self.doneBtn.setTitleColor(.Title, for: .normal)
        self.doneBtn.cornerRadius = 15
        self.doneBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.stripeHandler = StripeHandler(self)
        self.initView()
        self.initStripeCardTextField()
        self.listen2Keyboard(withView: self.doneBtn)
        self.setDesign()
        // Do any additional setup after loading the view.
        
    }
    func initView(){
        self.doneBtn.isClippedCorner = true
        self.doneBtn.elevate(0.2)
        self.view.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        if isToChangeCard{
                self.pageTitle.text = self.language.changeCreditDebit
        }else{
             self.pageTitle.text = self.language.addCreditDebit
        }
    }
    func initStripeCardTextField(){
        stripeCardTextField.postalCodeEntryEnabled = false
    }
    

    //MARK: initialize VC
    class func initWithStory(_ delegate : UpdateContentProtocol) -> AddStripeCardVC{
        let view : AddStripeCardVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        view.updateDelegate = delegate
        return view
    }
    //MARK; Actions
    @IBAction func backAct(){
        self.view.endEditing(true)
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func doneAct(_ sender: UIButton) {
       
        self.view.endEditing(true)
        guard NetworkManager.instance.isNetworkReachable else { return}
        guard let cardTF = stripeCardTextField else{return}
        dump(cardTF)
        guard cardTF.isValid else{
            let enter_valid_details = "Please enter valid card details".localize
            self.appDelegate.createToastMessage(enter_valid_details, bgColor: .black, textColor: .white)
            return
        }
        
        print(cardTF.cardNumber!)
            print(cardTF.cvc!)
        print(cardTF.expirationYear)
        print(cardTF.expirationMonth)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getStripeCard)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let stripeClientKey = json.string("intent_client_secret")
                    self.createIntent(using: cardTF, forClient: stripeClientKey)

                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

  
      
    }
    func createIntent(using card : STPPaymentCardTextField,forClient secret : String){
        UberSupport().showProgressInWindow(showAnimation: true)
        self.stripeHandler?
            .setUpCard(textField: card,
                       secret: secret,
                       completion: { (result) in
                        UberSupport().showProgressInWindow(showAnimation: false)
                        UberSupport().removeProgressInWindow()
                        switch result{
                        case .success(let token):
                            UberSupport().removeProgress(viewCtrl: self)
                            UberSupport().removeProgressInWindow()
//                            self.wsToUpdateCard(token: token)
                            self.updateCard(token: token)
                        case .failure(let error):
                            UberSupport().removeProgress(viewCtrl: self)
                            UberSupport().removeProgressInWindow()
                            self.appDelegate.createToastMessage(error.localizedDescription)
                        }
            })
    }
    
    @IBAction func cardEditing(_ sender: STPPaymentCardTextField) {
        
        if sender.isValid{
            self.doneBtn.isUserInteractionEnabled = true
            self.doneBtn.backgroundColor = .ThemeMain
        }else{
            self.doneBtn.isUserInteractionEnabled = false
            self.doneBtn.backgroundColor = .ThemeInactive
        }
    }
    func updateCard(token: String)
    {
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .addStripeCard,params: ["intent_id": token])
            .responseJSON({ (json) in
                if json.isSuccess{
                    if json.status_code == 0 {
                        AppDelegate.shared.createToastMessage(json.status_message)
                        UberSupport.shared.removeProgressInWindow()
                    }else{
                    UberSupport.shared.removeProgressInWindow()
                    let data = NSKeyedArchiver.archivedData(withRootObject: json)
                    self.preference.set(json["last4"], forKey: USER_CARD_LAST4)
                    self.preference.set(json["brand"], forKey: USER_CARD_BRAND)
                    
                    UserDefaults.set(json["last4"] as? String, for: .card_last_4)
                    UserDefaults.set(json["brand"] as? String, for: .card_brand_name)
                    UserDefaults.standard.set(data, forKey: "CardDetails")
                    let outData = UserDefaults.standard.data(forKey: "CardDetails")
                    let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! [String:Any]
                    print(dict)
                    UberSupport().removeProgressInWindow()
                    self.updateDelegate?.updateContent()
                    self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

    }
//    func wsToUpdateCard(token : String){
//
//        let device_token = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) ?? ""
//        WebServiceHandler
//            .sharedInstance
//            .getWebService(wsMethod: APIEnums.addStripeCard.rawValue,
//                           paramDict: ["token" : device_token,
//                                       "intent_id" : token],
//                           viewController: self,
//                           isToShowProgress: false,
//                           isToStopInteraction: false,
//                           complete: { (responseDict) in
//                            UberSupport.init().removeProgressInWindow()
//
//
//                            if responseDict["status_code"] as? String == "0" {
//                                print("∂",responseDict["status_message"] as? String ?? String())
//                                UberSupport().removeProgress(viewCtrl: self)
//                                UberSupport().removeProgressInWindow()
//                                self.appDelegate.createToastMessage(responseDict["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white)
//                            } else {
//                                let data = NSKeyedArchiver.archivedData(withRootObject: responseDict)
//                                self.preference.set(responseDict["last4"], forKey: USER_CARD_LAST4)
//                                self.preference.set(responseDict["brand"], forKey: USER_CARD_BRAND)
//
//                                UserDefaults.set(responseDict["last4"] as? String, for: .card_last_4)
//                                UserDefaults.set(responseDict["brand"] as? String, for: .card_brand_name)
//                                UserDefaults.standard.set(data, forKey: "CardDetails")
//
//                                //                UserDefaults.standard.set(responseDict, forKey: "CardDetails")
//
//                                let outData = UserDefaults.standard.data(forKey: "CardDetails")
//                                let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! [String:Any]
//                                print(dict)
//                                //                                                                SharedVariables.sharedInstance.cardDetailsDict = dict
//                                UberSupport().removeProgress(viewCtrl: self)
//                                UberSupport().removeProgressInWindow()
//                                self.updateDelegate?.updateContent()
//                                self.dismiss(animated: true, completion: nil)
//                            }
//            }){(error) in
//                UberSupport().removeProgress(viewCtrl: self)
//                UberSupport().removeProgressInWindow()
//        }
//        UberSupport().removeProgress(viewCtrl: self)
//        UberSupport().removeProgressInWindow()
//    }
}

extension UIViewController{
    func getCardImage(forBrand brand : String) -> UIImage{
        switch brand.capitalized {
        case "Visa":
            return UIImage(named: "card_visa.png") ?? #imageLiteral(resourceName: "card_basic.png")
        case "MasterCard":
            return UIImage(named: "card_master.png") ?? #imageLiteral(resourceName: "card_basic.png")
        case "Discover":
            return UIImage(named: "card_discover.png") ?? #imageLiteral(resourceName: "card_basic.png")
        case "Amex","American Express":
            return UIImage(named: "card_amex.png") ?? #imageLiteral(resourceName: "card_basic.png")
        case "JCB","JCP":
            return UIImage(named: "card_jcp.png") ?? #imageLiteral(resourceName: "card_basic.png")
        case "Diner","Diners","Diners Club":
            return UIImage(named: "card_diner.png") ?? #imageLiteral(resourceName: "card_basic.png")
        case "Union","UnionPay":
            return UIImage(named: "card_unionpay.png") ?? #imageLiteral(resourceName: "card_basic.png")
        default:
            return UIImage(named: "card_basic.png")?.withRenderingMode(.alwaysTemplate) ?? #imageLiteral(resourceName: "card_basic.png").withRenderingMode(.alwaysTemplate)
        }
}
}
