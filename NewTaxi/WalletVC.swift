//
//  WalletVC.swift
// NewTaxi
//
//  Created by Seentechs Technologies on 16/11/17.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class WalletVC: UIViewController,UITextFieldDelegate,APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    
    @IBOutlet weak var imgWallet: UIImageView!
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch response {
//        case .amountAddedToWallet:
//            self.hideView("")
//            self.updateApi()
        default:
            break
        }
    }
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
 

    @IBOutlet weak var AmountView: UIView!
    @IBOutlet weak var separateview: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lbltext: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var addAmountView: UIView!
    @IBOutlet weak var addbuttn: UIButton!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var scrollHolder: UIScrollView!
    @IBOutlet weak var viewNextHolder: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var PaymentTypeImage: UIImageView!
    @IBOutlet weak var PaymentTypeName: UILabel!
    @IBOutlet weak var ChangeButton: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var hideViewBtn: UIButton!
    @IBOutlet weak var EnterTheAmountLbl: UILabel!
    @IBOutlet weak var AddAmountBtn: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var changePaymentView: UIView!
    
    
    var resultText = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var currency = ""
    var walletAmount = ""
        
    var selectedPaymentOption : PaymentOptions? = nil
    let preference = UserDefaults.standard
    var brainTree : BrainTreeProtocol?
    var stripeHandler : StripeHandler?
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        self.initLocalization()
        self.initAddAmountView()
        self.updateApi()
        self.setfont()
        self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.elevate(10)
        self.viewNextHolder.setSpecificCornersForTop(cornerRadius: 35)
        self.AddAmountBtn.backgroundColor = .ThemeYellow
        self.AddAmountBtn.cornerRadius = 8
        self.AmountView.cornerRadius = 11
        self.AmountView.border(2, .Border)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WalletVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.stripeHandler = StripeHandler(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide1), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateWallet(_:)), name: NSNotification.Name(rawValue: "WalletApi"), object: nil)

        self.changePaymentView.isHidden = Shared.instance.isWebPayment
    }
    //MARK: initializers
    func initLocalization(){
        self.addbuttn.setTitle(self.language.addMoneytoWallet.uppercased(), for: .normal)
        self.AddAmountBtn.setTitle(self.language.addAmount.uppercased(), for: .normal)
        self.ChangeButton.setTitle(self.language.change.uppercased(), for: .normal)
        ChangeButton.titleLabel!.textColor = .Title
        self.EnterTheAmountLbl.text = self.language.enterAmount
        self.EnterTheAmountLbl.textColor = .Title
    }
    func initAddAmountView(){
        self.addAmountView.frame = self.view.frame
        self.view.addSubview(self.addAmountView)
        self.view.bringSubviewToFront(self.topView)
        self.addAmountView.addAction(for: .tap) {
            self.addAmountView.isHidden = true
            self.amountField.text = ""
            self.addbuttn.isUserInteractionEnabled = true
            self.amountField.resignFirstResponder()
        }
        self.viewNextHolder.addAction(for: .tap) {
            
        }
        addAmountView.isHidden = true
    }
    //MARK: init with story
    class func initWithStory()-> WalletVC{
        let walletVC : WalletVC = UIStoryboard.jeba.instantiateViewController()
        return walletVC
    }
    @objc func updateWallet(_ notification: NSNotification) {
        
        if let amount = notification.userInfo?["wallet"] as? String {
        // do something with your image
            Constants().STOREVALUE(value: amount, keyname: USER_WALLET_AMOUNT)
        }
       }
    @objc func updateApi(){
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .riderProfile)
            .responseJSON({ (json) in
                let _ = DriverDetailModel(jsonForRiderProfile: json)
                if json.isSuccess{
                    self.viewWillAppear(true)
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
                UberSupport.shared.removeProgressInWindow()
            }).responseFailure({ (error) in
                if error != ""
                {
                    AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()
                }
            })
        
    }
    
    
    //TEXT FIELD DELEGATE METHODS
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newLength = string.utf16.count - range.length
        
        if let text = amountField.text {
            newLength = text.utf16.count + string.utf16.count - range.length
        }
        
        let characterSet = NSMutableCharacterSet()
        characterSet.addCharacters(in: "1234567890")
        
        if string.rangeOfCharacter(from: characterSet.inverted) != nil || newLength > 4 {
            return false
        }
        return true
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        self.addbuttn.isUserInteractionEnabled = true
        self.checkNextButtonStatus()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        
        if (text == "") {
            return true
        }
        else if (text != "") {
            self.checkNextButtonStatus()
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func checkNextButtonStatus()
    {
        addbuttn.backgroundColor = ((amountField.text?.count)! > 0) ? UIColor.ThemeYellow : UIColor.ThemeInactive
        addbuttn.isUserInteractionEnabled = ((amountField.text?.count)!>0) ? true : false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        if #available(iOS 10.0, *) {
            amountField.keyboardType = .asciiCapableNumberPad
            
        } else {
            // Fallback on earlier versions
            amountField.keyboardType = .numberPad
        }
        amountField.delegate = self
        amountField.addTarget(self, action: #selector(self.textFieldDidChange(_ :)), for: .editingChanged)
        currencyLabel.text = strCurrency
        lblTitle.text = self.language.wallet
        lblTitle.textColor = .Title
        lbltext.text = self.language.walletAmountIs
        lbltext.textColor = .Title
        lblAmount.textColor = .Title
        let wallectamount = Constants().GETVALUE(keyname: USER_WALLET_AMOUNT)
        let amount:Double = (wallectamount as NSString).doubleValue
        let wall_amt = String(format: "%.2f", amount)
        print("aaa\(wall_amt)")
        if wallectamount == "" {
            lblAmount.text = "\(strCurrency)0"
        }
        else{
            lblAmount.text = "\(strCurrency)\(wall_amt)"
        }
    }
    func setfont(){      // MARK: commmon font function
        self.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.lbltext?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 14)
        self.lblAmount?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 26)
        self.AddAmountBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.EnterTheAmountLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.currencyLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 24)
        self.amountField?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 24)
        self.ChangeButton?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.PaymentTypeName?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedPayment(method: PaymentOptions.default ?? .cash)
    }
    
    //WHEN DISS MISS THE KEYBOARD
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        amountField.resignFirstResponder()
    }
    //Show the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: self.addAmountView)
    }
    //Hide the keyboard
    
    @objc func keyboardWillHide1(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: self.addAmountView)
    }
    
    // MARK: When User Press Add Button
    @IBAction func AddbuttonTapped(_ sender: Any) {
        addAmountView.isHidden = false
        addAmountView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        let oldColor = addAmountView.backgroundColor
        addAmountView.backgroundColor = .clear
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.addAmountView.transform = .identity
            })
            UIView.addKeyframe(withRelativeStartTime: 2.5/3, relativeDuration: 1, animations: {
                self.addAmountView.backgroundColor = oldColor
            })
        }, completion: nil)
        self.amountField.becomeFirstResponder()
    }
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: When User Press AddWallect amount button
    @IBAction func AddMonenytoWallet(_ sender: Any) {
        self.view.endEditing(true)
        if PaymentOptions.default == nil || self.ChangeButton.titleLabel?.text == self.language.choosePaymentMethod
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:self.language.message+"!!!", message:self.language.choosePaymentMethod.capitalized, preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:self.language.ok.uppercased(), style:UIAlertAction.Style.cancel, handler:{ action in
            }))
            present(settingsActionSheet, animated:true, completion:nil)
            
            return
        }
        if let text = self.amountField.text,
            let amount = Double(text){
            if Shared.instance.isWebPayment{
                self.wsMethodWalletAmount(using: nil)

            }else{
                if PaymentOptions.default == .stripe{
                    self.wsMethodToUpdateWalletAmount(using: nil)
                }
                else{
                    self.methodConvetCurrency(for: amount)
                }
            }
        }
        else{
             appDelegate.createToastMessage(self.language.amountFldReq, bgColor: UIColor.black, textColor: UIColor.white)
        }
        
    }
    func wsMethodWalletAmount(using payKey : String?){
        var params : [String : Any] = [
                                        "amount":self.amountField.text ?? "",
                                        "payment_type": PaymentOptions.default?.paramValue.lowercased() ?? "cash"
        ]
        if let key = payKey{
            params["pay_key"] = key
        }
        let amount = self.amountField.text ?? ""
        let paymentType =  PaymentOptions.default?.paramValue.lowercased() ?? "cash"
        let token = preference.string(forKey: USER_ACCESS_TOKEN)!
        let UrlString = "\(iApp.APIBaseUrl + APIEnums.webPayment.rawValue)?amount=\(amount)&payment_type=\(paymentType)&token=\(token)&pay_for=wallet"
        let webVC = LoadWebKitView.initWithStory()
        webVC.strWebUrl = UrlString
        webVC.isFromTrip = false
        self.navigationController?.pushViewController(webVC, animated: true)
        self.hideView("")

    }
    @IBAction func ChangeAction(_ sender: UIButton) {
        let paymentPickingVC = SelectPaymentMethodVC.initWithStory(showingPaymentMethods: true, wallet: false, promotions: false)
        paymentPickingVC.paymentSelectionDelegate = self
        self.presentInFullScreen(paymentPickingVC, animated: true, completion: nil)
    }
    
    //SHOW ON SUCCESS ON PAYPAL
    func showSuccess() {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelay(2.0)
        UIView.commitAnimations()
    }

    //MARK:- BrainTreePaymetn
    func methodConvetCurrency(for amount : Double){
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .currencyConversion,params: ["amount": amount,
                                                          "payment_type": PaymentOptions.default?.paramValue.lowercased() ?? "cash"])
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let amount = json.double("amount")
                    let brainTreeClientID = json.string("braintree_clientToken")
                    let currency = json.string("currency_code")
                    self.handleCurrencyConversion(response: amount,
                                                  currency: currency,
                                                  key: brainTreeClientID)
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()
                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

    }
    func handleCurrencyConversion(response amount: Double,currency : String?, key : String ){
        switch PaymentOptions.default {
        case .brainTree:
            self.authenticateBrainTreePayment(for: amount, using: key)
        case .paypal:
            self.authenticatePaypalPayment(for: amount,currency: currency ?? "USD", using: key)
        default:
            break
        }
    }
    func authenticateBrainTreePayment(for amount : Double,using clientId : String){
        self.brainTree = BrainTreeHandler.default
        self.brainTree?.initalizeClient(with: clientId)
        self.view.isUserInteractionEnabled = false
        self.brainTree?.authenticatePaymentUsing(self, for: amount) { (result) in
            self.view.isUserInteractionEnabled = true
            switch result{
            case .success(let token):
                self.wsMethodToUpdateWalletAmount(using: token.nonce)
            case .failure(let error):
                self.appDelegate.createToastMessage(error.localizedDescription)
            }
        }
    }
    func authenticatePaypalPayment(for amount : Double,currency: String,using clientId : String){
        self.brainTree = BrainTreeHandler.default
        self.brainTree?.initalizeClient(with: clientId)
        self.view.isUserInteractionEnabled = false
        self.brainTree?.authenticatePaypalUsing(self, for: amount, currency: currency) { (result) in
            self.view.isUserInteractionEnabled = true
            switch result{
            case .success(let token):
                self.wsMethodToUpdateWalletAmount(using: token.nonce)
            case .failure(let error):
                self.appDelegate.createToastMessage(error.localizedDescription)
            }
        }
    }
    func wsMethodToUpdateWalletAmount(using payKey : String?){
        var params : [String : Any] = [
                                        "amount":self.amountField.text ?? "",
                                        "payment_type": PaymentOptions.default?.paramValue.lowercased() ?? "cash"
        ]
        if let key = payKey{
            params["pay_key"] = key
        }

        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .addAmountToWallet,params: params)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    if json.status_code == 2{
                        let intent = json.string("two_step_id")
                        self.initiate3DSecureValidaiton(for: intent)
                    }else{
                        self.hideView("")
                        self.appDelegate.createToastMessage(json.status_message)
                        self.updateApi()
                    }

                }else{
                    UberSupport.shared.removeProgressInWindow()
                    self.presentAlertWithTitle(title: iApp.appName.capitalized,
                                               message: json.status_message,
                                               options: self.language.ok) { (_) in
                    }
                    self.hideView("")
                    self.updateApi()
                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
                self.presentAlertWithTitle(title: iApp.appName.capitalized,
                                           message: error,
                                           options: self.language.ok) { (_) in
                                            
                }
                self.hideView("")
                self.updateApi()
            })

    }
    func initiate3DSecureValidaiton(for intent : String){
        self.stripeHandler?.confirmPayment(for: intent, completion: { (stResult) in
            switch stResult{
            case .success(let token):
                self.wsMethodToUpdateWalletAmount(using: token)
            case .failure(let error):
                self.appDelegate.createToastMessage(error.localizedDescription)
            }
        })
    }
    
    //GOTO WALLECT PAGE
    func gotoWalletPage()
    {
        let propertyView = WalletVC.initWithStory()
        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // HIDE THE ADDWALLECT AMOUNT
    @IBAction func hideView(_ sender: Any) {
        let oldColor = addAmountView.backgroundColor
        UIView.animateKeyframes(withDuration: 0.8, delay: 0.15, options: [.layoutSubviews], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5/3, animations: {
                self.addAmountView.backgroundColor = .clear
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.addAmountView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
            })
        }, completion: { (_) in
            self.addAmountView.transform = .identity
            self.addAmountView.backgroundColor = oldColor
            self.addbuttn.isUserInteractionEnabled = true
            self.addAmountView.isHidden = true
            self.amountField.text = ""
        })
    }
    
    
}
extension WalletVC : paymentMethodSelection{
    func selectedPayment(method: PaymentOptions) {

        self.ChangeButton.setTitle(self.language.change.uppercased(), for: .normal)
        self.addbuttn.isUserInteractionEnabled = true
        self.addbuttn.backgroundColor = .ThemeYellow
        switch method {
        case .stripe:
            preference.set(true, forKey: STRIPE_WALLET_PAYMENT)
            if let brand : String = UserDefaults.value(for: .card_brand_name),
                let last4 : String = UserDefaults.value(for: .card_last_4){
                self.PaymentTypeImage.image = self.getCardImage(forBrand: brand)
                self.PaymentTypeImage.tintColor = .ThemeYellow
                self.PaymentTypeName.text = "**** "+last4
            }else{
                fallthrough
            }
        case .paypal:
            preference.set(false, forKey: STRIPE_WALLET_PAYMENT)
            self.PaymentTypeImage.image = UIImage(named: "paypal.png")
            self.PaymentTypeName.text = self.language.paypal
        case .onlinepayment:
            preference.set(false, forKey: STRIPE_WALLET_PAYMENT)
            self.PaymentTypeImage.image = UIImage(named: "onlinePay")
            self.PaymentTypeName.text = self.language.onlinePayment
        case .brainTree:
            preference.set(true, forKey: STRIPE_WALLET_PAYMENT)
            self.PaymentTypeImage.image = UIImage(named: "braintree")
            self.PaymentTypeName.text = UserDefaults.value(for: .brain_tree_display_name) ?? self.language.onlinePay
        default:
            self.PaymentTypeImage.image = nil
            self.PaymentTypeName.text = ""
            self.ChangeButton
                .setTitle(self.language.choosePaymentMethod,for: .normal)
            self.addbuttn.isUserInteractionEnabled = false
            self.addbuttn.backgroundColor = . ThemeInactive
        }
    }
    
    func updateContent() {
        self.ChangeButton.setTitle(self.language.change.uppercased(), for: .normal)
        self.selectedPaymentOption = PaymentOptions.default
        if selectedPaymentOption == .cash{
            selectedPaymentOption = nil
        }
        self.selectedPayment(method: selectedPaymentOption ?? .cash)
    }
    
 
}
extension WalletVC {//PayPalHandlerDelegate
    func paypalHandler(didComplete paymentID: String) {
        self.wsMethodToUpdateWalletAmount(using: paymentID)
    }
    
    func paypalHandler(didFail error: String) {
        self.appDelegate.createToastMessage(error)
    }
    
    
}
