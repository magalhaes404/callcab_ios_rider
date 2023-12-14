//
//  SelectPaymentMethodVC.swift
// NewTaxi
//
//  Created by Seentechs on 27/11/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit


protocol paymentMethodSelection : UpdateContentProtocol{
    func selectedPayment(method : PaymentOptions)
}


class SelectPaymentMethodVC: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    
    @IBOutlet weak var addPromoView: UIView!
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var promoTxtField: UITextField!
    @IBOutlet weak var promoTitle: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var addPromoChildView: UIView!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var lblPayment: UILabel!
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let preference = UserDefaults.standard
    var isFromWallect:Bool = false
    
    var canShowPaymentMethods = true
    var canShowWallet = true
    var canShowPromotion = true
    var isFromWallet : Bool {
        return self.canShowPaymentMethods && !self.canShowWallet && !canShowPromotion
    }
    var selectedPayment = ""
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var wallectamount = ""
    var arrpayment = [String]()
    var arrpaymentImages = [String]()
    var paymentDataSource = [PaymentTableSection]()
    var paymentSelectionDelegate : paymentMethodSelection?
    var paymentList : PaymentList?
    //MARK: view life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.viewPromoCode()
       self.backButton.setTitle(self.language.getBackBtnText(), for: .normal)
       self.lblPayment.text = self.language.payment
        self.promoTitle.text = self.language.enterPromoCode

        self.addButton.setTitle(self.language.add.uppercased(), for: .normal)
        self.cancelButton.setTitle(self.language.cancel.uppercased(), for: .normal)

        if #available(iOS 10.0, *) {
            promoTxtField.keyboardType = .asciiCapable
        } else {
            // Fallback on earlier versions
            promoTxtField.keyboardType = .default
        }
//        self.updateApi()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide1), name:UIResponder.keyboardWillHideNotification, object: nil)
        
//        self.wsToGetOptionList()
        self.setDesign()
    }
    func setDesign()
    {
        self.backButton.setTitleColor(.Title, for: .normal)
        self.lblPayment.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.lblPayment.textColor = .Title
        self.outerView.setSpecificCornersForTop(cornerRadius: 35)
        self.outerView.elevate(4)
        self.promoTitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.promoTitle.textColor = .Title
        self.promoTxtField.border(1, .Border)
        self.promoTxtField.textColor = .Title
        self.promoTxtField.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 24)
        self.promoTxtField.cornerRadius = 15
        self.addPromoChildView.setSpecificCornersForTop(cornerRadius: 35)
        self.addPromoChildView.elevate(4)
        self.cancelButton.backgroundColor = .ThemeYellow
        self.cancelButton.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.cancelButton.setTitleColor(.Title, for: .normal)
        self.cancelButton.cornerRadius = 15
        self.addButton.backgroundColor = .ThemeYellow
        self.addButton.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.addButton.setTitleColor(.Title, for: .normal)
        self.addButton.cornerRadius = 15
        self.promoTxtField.setLeftPaddingPoints(15)
        self.promoTxtField.setRightPaddingPoints(15)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateApi()
        self.wallectamount = Constants().GETVALUE(keyname: USER_WALLET_AMOUNT)
        self.addButton.isUserInteractionEnabled = true
//        if UserDefaults.isNull(for: .payment_method) {
//            PaymentOptions.cash.setAsDefault()
//        }
        //        arrpayment = [NSLocalizedString("CASH", comment: ""),NSLocalizedString("PAYPAL", comment: "")]
        arrpayment = [self.language.cash.uppercased(),self.language.paypal.uppercased()]
        arrpaymentImages = ["Currency","paypal.png"]
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.wsToGetOptionList()
    }
    //MARK: Generating TableData Source
    func generateTableDataSource(with paymentList : PaymentList){

        self.paymentList = paymentList
        /*
         * if from wallet screen : hide cash,prmotions,wallet
         * if from car list screen : Hide promotions
         */
        self.paymentDataSource = [PaymentTableSection]()
        
        //********** Payment method seciton **************
        let isFromWallet = !canShowWallet && !canShowPromotion
        
        if canShowPaymentMethods{
            
                      var paymentMethodDatas = [PaymentTableData]()
            for option in paymentList.options{
                let data = PaymentTableData(withName: option.value)
                data.isSelected = option.isDefault
                data.imageURL =  URL(string: option.icon)
                paymentMethodDatas.append(data)
            }
            self.paymentDataSource.append(PaymentTableSection(withTitle: self.language.paymentMethod,
                                                              datas: paymentMethodDatas))
         
        }
        
        //********** Wallet seciton *************
        if canShowWallet{
            var use_wallet = ""
//            let val = NSLocalizedString("USE WALLET", comment: "")
            let val = self.language.useWallet.uppercased()
            self.wallectamount = Constants().GETVALUE(keyname: USER_WALLET_AMOUNT)
            if wallectamount == "" {
                use_wallet = "\(val) \(strCurrency) 0.00"
            }
            else{
                use_wallet =  "\(val) \(strCurrency) \(wallectamount)"
            }
            let walletData = PaymentTableData(withName: use_wallet)
            walletData.image = UIImage(named: "walletUpdated")
            walletData.isSelected = Constants().GETVALUE(keyname: USER_SELECT_WALLET) == "Yes"
//            self.paymentDataSource.append(PaymentTableSection(withTitle: "Wallet".localize,
//                                                              datas: [walletData]))
            self.paymentDataSource.append(PaymentTableSection(withTitle: self.language.wallet,
                                                              datas: [walletData]))
        }
        //********** Promotion seciton **************
        if canShowPromotion{
            var promotionDatas = [PaymentTableData]()
            if Constants().GETVALUE(keyname: USER_PROMO_CODE) != "" && Constants().GETVALUE(keyname: USER_PROMO_CODE) != "0" {
               
//                let promotion = PaymentTableData(withName: "Promotions".localize)
                let promotion = PaymentTableData(withName: self.language.promotions)
                promotion.image = UIImage(named: "tag.png")
                
                promotionDatas.append(promotion)
            }
            
//            let addPromotion = PaymentTableData(withName: "Add Promo/Gift code".localize)
              let addPromotion = PaymentTableData(withName: self.language.addPromoGiftCode)
              promotionDatas.append(addPromotion)
            
//            self.paymentDataSource.append(PaymentTableSection(withTitle: "Promotions".localize,
//                                                              datas: promotionDatas))
            self.paymentDataSource.append(PaymentTableSection(withTitle: self.language.promotions,
                                                              datas: promotionDatas))
        }
        self.paymentTableView.reloadData()
    }
    func wsToGetOptionList(){
        let uberLoader = UberSupport()
       // uberLoader.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getPaymentOptions,
                        params: ["is_wallet":self.isFromWallet ? "1" : "0"])
            .responseDecode(to: PaymentList.self,
                            { (paymentList) in
                                uberLoader.removeProgressInWindow()
                                self.generateTableDataSource(with: paymentList)
            }).responseFailure({ (error) in
                uberLoader.removeProgressInWindow()
                self.appDelegate.createToastMessage(error)
                debug(print: error)
            })
    }
    func updateApi(){
        self.viewPromoCode()
        self.apiInteractor?
            .getRequest(for: .riderProfile)
            .responseJSON({ (json) in
                let _ = DriverDetailModel(jsonForRiderProfile: json)
                if json.isSuccess{
                    self.wsToGetOptionList()
                    
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
            }).responseFailure({ (error) in
                if error != ""
                {
                    AppDelegate.shared.createToastMessage(error)
                }
            })
        
    }
    

// KEY BOARD DISSMISS METHODS
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: self.addPromoView)
    }
    
    @objc func keyboardWillHide1(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: self.addPromoView)
        
    }
 
//MARK:  UIBUTTON ACTION
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        self.paymentSelectionDelegate?.updateContent()
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        promoTxtField.resignFirstResponder()
        
        let oldColor = addPromoView.backgroundColor
        UIView.animateKeyframes(withDuration: 0.8, delay: 0.15, options: [.layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.5/3, animations: {
                self.addPromoView.backgroundColor = .clear
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.addPromoView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
            })
        }, completion: { (_) in
            self.addPromoView.transform = .identity
            self.addPromoView.backgroundColor = oldColor
            self.addButton.isUserInteractionEnabled = true
            self.addPromoView.removeFromSuperview()
            self.addPromoView.transform = .identity
        })
      
    }
    @IBAction func addButtonAction(_ sender: Any) {
        if promoTxtField.text != "" {
            promoTxtField.resignFirstResponder()
            self.view.addSubview(self.addPromoView)
            self.view.bringSubviewToFront(self.addPromoView)
            let oldColor = addPromoView.backgroundColor
            UIView.animateKeyframes(withDuration: 0.8, delay: 0.15, options: [.layoutSubviews], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.5/3, animations: {
                    self.addPromoView.backgroundColor = .clear
                })
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    self.addPromoView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
                })
            }, completion: { (_) in
                self.addPromoView.backgroundColor = oldColor
                self.addButton.isUserInteractionEnabled = true
                self.addPromoView.removeFromSuperview()
                self.onPromoCode()
                self.addPromoView.transform = .identity
            })
            
        }
        else{
//            appDelegate.createToastMessage(NSLocalizedString("Please enter the promo code", comment: ""), bgColor: UIColor.black, textColor: UIColor.white)
            appDelegate.createToastMessage(self.language.enterPromoCode, bgColor: UIColor.black, textColor: UIColor.white)
        }
    }
// MARK: CALL API TO VIEW THE PROMO CODE
    func viewPromoCode()
    {
        UberSupport().showProgressInWindow(showAnimation: true)
        self.apiInteractor?.getRequest(for: .getPromoDetails)
            .responseDecode(
                to: PromoContainerModel.self,
                { (container) in
                    UberSupport.shared.removeProgressInWindow()
                    self.wsToGetOptionList()
                    
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
            })

    }
    
// MARK: CALL API TO ADD THE PROMO CODE
    func onPromoCode()
    {
      // UberSupport().showProgressInWindow(showAnimation: true)
        self.addButton.isUserInteractionEnabled = false
        self.apiInteractor?.getRequest(
            for: APIEnums.addPromoCode,
            params: [
                "code" : promoTxtField.text!
            ]
        ).responseJSON({ (json) in                                                                                                                      
            if json.isSuccess{
                print("Sucess")
                self.promoTxtField.text = ""
                self.addPromoView.isHidden = true
                self.viewWillAppear(true)
                self.paymentTableView.reloadData()
            }else{
                AppDelegate.shared.createToastMessage(json.status_message)
            }
            self.addButton.isUserInteractionEnabled = true
            UberSupport.shared.removeProgressInWindow()
        }).responseFailure({ (error) in
            self.addButton.isUserInteractionEnabled = true
            UberSupport.shared.removeProgressInWindow()
            AppDelegate.shared.createToastMessage(error)
        })
        
        
        
    }

// MARK: TABE VIEW DELEGATE AND TABLE VIEW DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.paymentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let header = self.paymentDataSource[section]
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (paymentTableView.frame.size.width) ,height: 40)
        let titleLabel:UILabel = UILabel()
//        titleLabel.frame =  CGRect(x: 10, y:5, width: viewHolder.frame.size.width ,height: 35)
        titleLabel.text = header.title
        titleLabel.font = UIFont (name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
//        viewHolder.backgroundColor = UIColor(hex: "DCDCDC")//self.view.backgroundColor
        viewHolder.backgroundColor = .Background
        titleLabel.textAlignment = NSTextAlignment.natural
        titleLabel.textColor = UIColor.Title
        viewHolder.setSpecificCornersForTop(cornerRadius: 15)
        viewHolder.addSubview(titleLabel)
        titleLabel.anchor(toView: viewHolder, leading: 15, trailing: -15, top: 0, bottom: 0)

        return viewHolder
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentDataSource[section].datas.count
        if section == 0{
            return arrpayment.count != 0 ? arrpayment.count : 0
        }
        else{
            return 1
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let header = self.paymentDataSource[indexPath.section]
        let data = header.datas[indexPath.row]
        switch header.title {
        case self.language.paymentMethod :
            
            let cell = paymentTableView.dequeueReusableCell(withIdentifier: "CellPaymentMethodTVC") as! CellPaymentMethodTVC
            cell.titlePaymentTxt.text = data.name
            cell.paymentImg.sd_setImage(with: data.imageURL, completed: nil)//.image = data.image
            cell.selectedlable.text = data.isSelected ? "3" : ""
            cell.selectionStyle = .none
            return cell
        case self.language.wallet:
            let cell = paymentTableView.dequeueReusableCell(withIdentifier: "CellPaymentMethodTVC") as! CellPaymentMethodTVC
            cell.titlePaymentTxt.text = data.name
            cell.paymentImg.image = data.image
            cell.selectedlable.text = data.isSelected ? "3" : ""
            cell.selectionStyle = .none
            return cell
        case self.language.promotions:
            if indexPath.row == 0 && header.datas.count > 1{
                
                let cell = paymentTableView.dequeueReusableCell(withIdentifier: "CellPromoAppliedTVC") as! CellPromoAppliedTVC
                cell.titleLabel.text = data.name
                //                cell.imageView.image = data.image
                cell.promoCountLabel.text = Constants().GETVALUE(keyname: USER_PROMO_CODE)
                cell.selectionStyle = .none
                return cell
                
            }else{
                fallthrough
            }
        default://ADD PromoCode
            let cell = paymentTableView.dequeueReusableCell(withIdentifier: "CellAddNewPromoTVC") as! CellAddNewPromoTVC
            cell.titleLabel.text = " "+data.name
            cell.selectionStyle = .none
            return cell
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let header = self.paymentDataSource[indexPath.section]
        let data = header.datas[indexPath.row]
     
        let isFromWallet = !self.canShowPromotion && !self.canShowWallet
        switch header.title {
//        case "Payment Methods".localize :
            case self.language.paymentMethod :
            
                let selectedItem = self.paymentList?.didSelect(optionNamed: data.name)
                if selectedItem?.key == "stripe_card"{
                    let vc = AddStripeCardVC.initWithStory(self)
                    self.presentInFullScreen(vc, animated: true, completion: {
                        self.wsToGetOptionList()
                    })
                }else{
                    selectedItem?.option.setAsDefault()
                    self.paymentSelectionDelegate?.updateContent()
                    self.backButton.sendActions(for: .touchUpInside)
                }
            /*switch data.name{
            case self.language.cash.uppercased():
                PaymentOptions.cash.setAsDefault()
                self.backButton.sendActions(for: .touchUpInside)
                self.paymentSelectionDelegate?.selectedPayment(method: .cash)//cash_isSelected()
            case self.language.paypal.uppercased():
                PaymentOptions.paypal.setAsDefault()
                
                self.backButton.sendActions(for: .touchUpInside)
                self.paymentSelectionDelegate?.selectedPayment(method: .paypal)//paypal_isSelected()
            case self.language.addCreditDebit :
                let vc = AddStripeCardVC.initWithStory(self)
                self.presentInFullScreen(vc, animated: true, completion: {
                    self.wsToGetOptionList()
                })
            case self.language.changeCreditDebit:
                let vc = AddStripeCardVC.initWithStory(self)
                vc.isToChangeCard = true
                self.presentInFullScreen(vc, animated: true, completion: {
                    self.wsToGetOptionList()
                })
            case self.language.onlinePay:
                
                PaymentOptions.brainTree.setAsDefault()
                self.backButton.sendActions(for: .touchUpInside)
                self.paymentSelectionDelegate?.selectedPayment(method: .brainTree)
            default:
                
                PaymentOptions.stripe.setAsDefault()
                self.backButton.sendActions(for: .touchUpInside)
                self.paymentSelectionDelegate?.selectedPayment(method: .stripe)//selectedPayment(method: .stripe)//stripe_isSelected()
            }*/
//        case "Wallet".localize:
        case self.language.wallet :
            if Constants().GETVALUE(keyname: USER_SELECT_WALLET) == "Yes"{
                Constants().STOREVALUE(value: "No" , keyname: USER_SELECT_WALLET)
            }
            else{
                Constants().STOREVALUE(value: "Yes" , keyname: USER_SELECT_WALLET)
            }
            if let list = self.paymentList{
                self.generateTableDataSource(with: list)
            }else{
                self.wsToGetOptionList()
            }
       // case "Promotions".localize:
             case self.language.promotions:
            if indexPath.row == 0 && header.datas.count > 1{
                let propertyView = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController(withIdentifier: "PromotionsVC") as! PromotionsVC
                self.navigationController?.pushViewController(propertyView, animated: true)
            }else{
                fallthrough
            }
        default://Add Promo code
            print()
            self.onAddNewPromoTapped()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    

    

 
    
    func onAddNewPromoTapped(){
        addPromoView.frame = CGRect(x: 0, y:0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.addPromoView.isHidden = true
        view.addSubview(addPromoView)
        self.promoTxtField.text = nil
        addPromoView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        let oldColor = addPromoView.backgroundColor
        addPromoView.backgroundColor = .clear
       
        self.addPromoView.isHidden = false
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.addPromoView.transform = .identity
            })
            UIView.addKeyframe(withRelativeStartTime: 2.5/3, relativeDuration: 1, animations: {
                self.addPromoView.backgroundColor = oldColor
            })
        }, completion: nil)
    }
    
// MARK: TEXTFIELD DELIGATE METHODS
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        self.addButton.isUserInteractionEnabled = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.addButton.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
        let cs = CharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
        let filtered: String = string.components(separatedBy: cs).joined(separator: "")
        return string == filtered
        
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == " ") {
            return false
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    //MARK: initWith Story
    class func initWithStory(showingPaymentMethods : Bool = true,
                             wallet : Bool = true,
                             promotions : Bool = true) -> SelectPaymentMethodVC{
        let view : SelectPaymentMethodVC = UIStoryboard.payment.instantiateViewController()
        view.canShowPaymentMethods = showingPaymentMethods
        view.canShowWallet = wallet
        view.canShowPromotion = promotions
        return view
    }
}
extension SelectPaymentMethodVC : UpdateContentProtocol{
    func updateContent() {
        self.wsToGetOptionList()
    }
}
class CellPaymentMethodTVC : UITableViewCell {
    
    @IBOutlet weak var titlePaymentTxt: UILabel!
    @IBOutlet weak var selectedlable: UILabel!
    @IBOutlet weak var paymentImg: UIImageView!
    @IBOutlet weak var selectpaymentbutton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titlePaymentTxt.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.titlePaymentTxt.textColor = .Title
    }
}
class CellPromoAppliedTVC : UITableViewCell{
    
    @IBOutlet weak var promoCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promoButoon: UIButton!
    

    @IBOutlet weak var imgTag: UIImageView!
    
    
    @IBOutlet weak var lblArrowPromo: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.titleLabel.textColor = .Title
        self.promoCountLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.promoCountLabel.textColor = .ThemeYellow

    }

}
class CellAddNewPromoTVC : UITableViewCell {
    
    @IBOutlet weak var addNewPromoButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.titleLabel.textColor = .ThemeYellow
    }
}

