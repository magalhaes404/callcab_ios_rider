/**
* MakePaymentVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import AVFoundation
import Alamofire
import FirebaseDatabase

class MakePaymentVC : UIViewController, UITableViewDelegate, UITableViewDataSource,APIViewProtocol
{
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var pageTitleLblb : UILabel!
    
    @IBOutlet weak var lblPaymentDetails: UILabel!
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch (response,API) {

        default:
            print()
        }
    }
    
    
    func onFailure(error: String,for API : APIEnums) {
//        print(error)
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - ViewController Methods
    
    @IBOutlet var tblPaymentDetails:UITableView!
    @IBOutlet var viewTblFooter:UIView!
    @IBOutlet var btnPayPal : UIButton!
    @IBOutlet weak var contentHolderView: UIView!
    var contentView = ChangePaymentMethod.initViewFromXib()
    var brainTree : BrainTreeProtocol?
    var stripeHandler : StripeHandler?
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var arrInfoKey : NSMutableArray = NSMutableArray()
    var isFromTripPage : Bool = false
    var PaymentMethod = ""
    var payableAmount = ""
//    var tripData : TripDataModel!
    var tripID : Int = 0
    var paymentStatus : BtnPymtStatus = .proceed
    var paymentstatus = ""
    var resultText = ""
    var proceed = ""
    var currency = ""
    var payAmount = ""
    var params = Parameters()
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    let preference = UserDefaults.standard

    func setDesign() {
        self.pageTitleLblb.textColor = .Title
        self.pageTitleLblb.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.holderView.setSpecificCornersForTop(cornerRadius: 35)
        self.holderView.elevate(4)
        self.btnPayPal.cornerRadius = 15
        self.btnPayPal.setTitleColor(.Title, for: .normal)
        self.btnPayPal.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.contentView.cashLbl.textColor = .Title
        self.contentView.cashLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.tblPaymentDetails.backgroundColor = .white
        self.bottomView.backgroundColor = .Background
        self.bottomView.setSpecificCornersForTop(cornerRadius: 35)
        self.contentView.backgroundColor = .Background
        self.contentView.changeBtn.isCurvedCorner = true
        self.contentView.promolbl.isCurvedCorner = true
        self.contentView.promolbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.contentView.promolbl.textColor = .Title
        self.contentView.changeBtn.setTitleColor(.white, for: .normal)
        self.contentView.changeBtn.backgroundColor = .Title
        self.contentView.changeBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    }
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.btnBack.setTitle(self.language.getBackBtnText(), for: .normal)
        self.onPromoCode()
        var params = Parameters()
        params["trip_id"] = tripID
        self.getInvoice(params: params)
        self.contentView.frame = self.contentView.setFrame(self.contentHolderView.frame)
        self.contentHolderView.addSubview(self.contentView)
        self.contentHolderView.bringSubviewToFront(self.contentView)
        self.initView()
        self.initPaymentView()
        self.addListeneners()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.checkPaymentStatus()
        }
        self.pageTitleLblb.text = self.language.paymentDetails.capitalized
        self.stripeHandler = StripeHandler(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePayment(_:)), name: NSNotification.Name(rawValue: "TripApi"), object: nil)
        self.setDesign()
    }
    func getInvoice(params: JSON)
    {
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getInvoice,params: params)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    var customizedJSON = JSON()
                    customizedJSON["riders"] = [json]
                    let detail = TripDetailDataModel(customizedJSON)
                    self.arrInfoKey = NSMutableArray(array: detail.invoice.compactMap({$0 as Any}))
                    self.payableAmount = detail.getPayableAmount
                    self.PaymentMethod = detail.getPaymentMethod
                    print("get invoice sucess")
                    self.checkPaymentStatus()
                    self.tblPaymentDetails.reloadData()
                    self.setRefreshPayment()
                    self.btnPayPal.isHidden = false
                }else{
                    UberSupport.shared.removeProgressInWindow()
                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
            })
    }
    @objc func updatePayment(_ notification: NSNotification) {
        if let message = notification.userInfo?["status"] as? String,let tripId = notification.userInfo?["tripId"] as? String {
        // do something with your image
            self.presentAlertWithTitle(title: "", message: message, options: self.language.ok.capitalized) { (option) in
                FireBaseNodeKey.trip.getReference(for: "\(tripId)").removeValue()
                self.appDelegate.onSetRootViewController(viewCtrl: self)
            }
        }
       }
    func initPaymentView(){
         contentView.changeBtn.addTarget(self, action: #selector(changeAction(_:)), for: .touchUpInside)
         self.contentView.changeBtn.setTitle(self.language.change.uppercased() , for: .normal)
         if Constants().GETVALUE(keyname: USER_PROMO_CODE) != "0" && Constants().GETVALUE(keyname: USER_PROMO_CODE) != ""{
                contentView.cashLbl.isHidden = true
                contentView.promolbl.isHidden = false
             contentView.promolbl.text = self.language.promoApplied
         }else{
                contentView.cashLbl.isHidden = false
                contentView.promolbl.isHidden = true
               }
            
            switch PaymentOptions.default {
            case .cash:
                contentView.payPalImg.image = UIImage(named:"Currency")!
                contentView.cashLbl.text = self.language.cash.uppercased()
            case .paypal:
                contentView.payPalImg.image = UIImage(named:"paypal.png")!
                contentView.cashLbl.text = self.language.paypal.uppercased()
            case .brainTree:
                contentView.payPalImg.image = UIImage(named:"braintree")!
                contentView.cashLbl.text = UserDefaults.value(for: .brain_tree_display_name) ?? self.language.onlinePay
            case .onlinepayment:
                contentView.payPalImg.image = UIImage(named:"onlinePay")!
                contentView.cashLbl.text = self.language.onlinePayment

            case .stripe:
                contentView.payPalImg.image = UIImage(named:"card")!.withRenderingMode(.alwaysTemplate)
                self.contentView.tintColor = .ThemeYellow
                 contentView.cashLbl.text = self.language.card.uppercased()
                if let last4 : String = UserDefaults.value(for: .card_last_4),
                    let brand : String = UserDefaults.value(for: .card_brand_name),!last4.isEmpty{
                    contentView.cashLbl.text  = "**** "+last4
                    contentView.payPalImg.image = self.getCardImage(forBrand: brand)
                    self.contentView.tintColor = .ThemeYellow
                }
            default:
                contentView.payPalImg.image = UIImage(named:"Currency")!
                contentView.cashLbl.text = self.language.cash.uppercased()
            }
            
            if Constants().GETVALUE(keyname: USER_SELECT_WALLET) == "Yes"{
                contentView.walletImg.image = UIImage(named:"walletUpdated")!
                contentView.walletImg.isHidden = false
                contentView.walletHolder.isHidden = false
                
            }
            else{
                contentView.walletHolder.isHidden = true
                contentView.walletImg.isHidden = true
            }
           print("isWallet",Constants().GETVALUE(keyname: USER_SELECT_WALLET))
        
        self.view.layoutIfNeeded()
    }
    
    //MARK:- api to getInvoice for change Payment
    func updateChangedInvoice(){
        var walletSelected = Constants().GETVALUE(keyname: USER_SELECT_WALLET)
        if walletSelected.isEmpty{walletSelected = "No"}
        params["trip_id"] = self.tripID
        params["payment_mode"] = PaymentOptions.default?.paramValue ?? "cash"
        params["is_wallet"] = walletSelected
        self.getInvoice(params: params)
    }
    
    //MARK:- set refresh payment status in firebase
    func setRefreshPayment(){
        var node = [String:Any]()
        let value = PaymentOptions.default ?? .cash
        let walletSelected = Constants().GETVALUE(keyname: USER_SELECT_WALLET) == "Yes"
        let promoApplied =  Constants().GETVALUE(keyname: USER_PROMO_CODE) != "0" &&
                            Constants().GETVALUE(keyname: USER_PROMO_CODE) != ""
        node[FireBaseNodeKey.refresh_payment.rawValue] = value.with(wallet: walletSelected,
                                                                    promo: promoApplied)
        FireBaseNodeKey.trip
            .ref(forID: tripID.description).setValue(node)
        self.view.layoutIfNeeded()
    }
    @IBAction func changeAction(_ sender : UIButton){
        let tripView = SelectPaymentMethodVC.initWithStory(showingPaymentMethods: true, wallet: true, promotions: true)
        tripView.paymentSelectionDelegate = self as? paymentMethodSelection
        self.navigationController?.pushViewController(tripView, animated: true)
    }
    func initView(){

    }
    func addListeneners(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.PayMentCompleted), name: Notification.Name(rawValue: NotificationTypeEnum.trip_payment.rawValue), object: nil)
        PipeLine.createDataEvent(withName: "trip_payment") { (data) in
            if let paymentData = data as? JSON{
                self.presentAlertWithTitle(title: "", message: paymentData.string("status"), options: self.language.ok.capitalized) { (option) in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)

                }
            }
        }
    }
 
    //MARK: Paymetn Status
    func checkPaymentStatus()
    {
        switch self.PaymentMethod{
        case let x where x.lowercased().contains("cash")://Cash
            if self.payableAmount.isEmpty || Double(payableAmount) == 0.0{
                self.setBtnState(to: .proceed)
            }else{
                self.setBtnState(to: .waitingForConfirmation)
            }
        case let x where x.lowercased().first == "b"://Braintree
            if self.payableAmount.isEmpty || Double(payableAmount) == 0.0{
                self.setBtnState(to: .proceed)
            }else{
                self.setBtnState(to: .pay)
            }
        case let x where x.lowercased().first == "p"://Pay Pal
            if self.payableAmount.isEmpty || Double(payableAmount) == 0.0{
                self.setBtnState(to: .proceed)
            }else{
                self.setBtnState(to: .pay)
            }
        case let x where x.lowercased().first == "s"://Stripe
            if self.payableAmount.isEmpty || Double(payableAmount) == 0.0{
                self.setBtnState(to: .proceed)
            }else{
                self.setBtnState(to: .pay)
            }
        case let x where x.lowercased().first == "o"://Stripe
            if self.payableAmount.isEmpty || Double(payableAmount) == 0.0{
                self.setBtnState(to: .proceed)
            }else{
                self.setBtnState(to: .pay)
            }
        default:
            self.setBtnState(to: .proceed)
        }
        
    }
    
    func setBtnState(to state : BtnPymtStatus){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.paymentStatus = state
            self.proceed = ""
            switch state {
            case .pay:
                  self.btnPayPal.setTitle(self.language.pay.uppercased(), for: .normal)
                self.btnPayPal.backgroundColor = UIColor.ThemeYellow
                self.btnPayPal.isUserInteractionEnabled = true
            case .waitingForConfirmation:
                 self.btnPayPal.setTitle(self.language.waitDriverConfirm.uppercased(), for: .normal)
                self.btnPayPal.backgroundColor = UIColor.ThemeInactive
                self.btnPayPal.isUserInteractionEnabled = false
            case .proceed:
                self.proceed = "1"
                 self.btnPayPal.setTitle(self.language.proceed.uppercased(), for: UIControl.State.normal)
                self.btnPayPal.backgroundColor = .ThemeYellow
                self.btnPayPal.isUserInteractionEnabled = true
            case .continueToRequest:
                self.btnPayPal.setTitle(self.language.continueRequest.uppercased(), for: .normal)
                self.btnPayPal.backgroundColor = UIColor.ThemeInactive
                self.btnPayPal.isUserInteractionEnabled = true
            }
        }
        
    }
    //MARK: - WHEN DRIVER ACCEPTING REQUEST
    /*
     NOTIFICATION TYPE PAYMENT COMPLETED
     */
    @objc func PayMentCompleted()
    {
        var json = JSON()
        json["trip_id"] = self.tripID.description
        self.goToRating(for: TripDataModel(json))
 
       
    }
    @objc func removeProgress()
    {
        UberSupport().removeProgress(viewCtrl: self)
    }

    //MARK: - ****** Adaptive PayPal SDK Integration ******
   
    func onPromoCode()
    {
        self.apiInteractor?
            .getRequest(for: .getPromoDetails)
            .responseDecode(
                to: PromoContainerModel.self,
                { (container) in
                    if Constants().GETVALUE(keyname: USER_PROMO_CODE) != "0"
                        && Constants().GETVALUE(keyname: USER_PROMO_CODE) != ""{
                        self.contentView.cashLbl.isHidden = true
                        self.contentView.promolbl.isHidden = false
                        self.contentView.promolbl.text = self.language.promoApplied
                    }else{
                        self.contentView.cashLbl.isHidden = false
                        self.contentView.promolbl.isHidden = true
                    }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
            })
        
        
    }
   
    // MARK: When User Press Pay Button

    @IBAction func onPayTapped(_ sender:UIButton!)
    {
        if proceed == "1"{
            if Shared.instance.isWebPayment {
                self.wsMethodWebPaymentAmount(using: nil)
            } else{
                self.btnPayPal.isHidden = true
                var dicts = Parameters()
                dicts["trip_id"] = self.tripID
                dicts["payment_type"] = PaymentOptions.default?.paramValue.lowercased() ?? "cash"
                self.afterPayment(params: dicts)

            }
        }else{
            if Shared.instance.isWebPayment {
                self.wsMethodWebPaymentAmount(using: nil)
            } else{
                if PaymentOptions.default == .stripe{
                    self.wsMethodForAfterPayment(using: nil)
                }else{
                    self.wsMethodConvetCurrency(for: Double(self.payableAmount) ?? 0.0)
                }
            }
           
        }
  
  
    }

    func wsMethodWebPaymentAmount(using payKey : String?){
       
        var params : [String : Any] = [
                                        "trip_id":self.tripID,
                                        "amount":self.payableAmount,
                                        "payment_type": PaymentOptions.default?.paramValue.lowercased() ?? "cash"
        ]
        if let key = payKey{
            params["pay_key"] = key
        }
        let paymentType =  PaymentOptions.default?.paramValue.lowercased() ?? "cash"
        let token = preference.string(forKey: USER_ACCESS_TOKEN)!
        let UrlString = "\(iApp.APIBaseUrl + APIEnums.webPayment.rawValue)?amount=\(self.payableAmount)&payment_type=\(paymentType)&token=\(token)&trip_id=\(self.tripID)&pay_for=trip"
        let webVC = LoadWebKitView.initWithStory()
        webVC.strWebUrl = UrlString
        webVC.isFromTrip = true
        self.navigationController?.pushViewController(webVC, animated: true)

    }
    
    //MARK:- BrainTreePaymetn
    func wsMethodConvetCurrency(for amount : Double){

        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .currencyConversion,params: ["amount": self.payableAmount,
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
            self.authenticatePaypalPayment(for: amount, currency: currency ?? "USD", using: key)
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
                self.wsMethodForAfterPayment(using: token.nonce)
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
                self.wsMethodForAfterPayment(using: token.nonce)
            case .failure(let error):
                self.appDelegate.createToastMessage(error.localizedDescription)
            }
        }
    }
    func afterPayment(params: JSON){
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .afterPayment,params: params)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    if json.status_code == 2{
                        let intent = json.string("two_step_id")
                        self.initiate3DSecureValidaiton(for: intent)
                    }else{
                        self.presentAlertWithTitle(title: "", message: json.status_message, options: "Ok".localize) { (option) in
                            let detail = TripDetailDataModel(json)
                            FireBaseNodeKey.trip.getReference(for: "\(self.tripID.description)").removeValue()
                               NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)

                        }
                    }
                    self.btnPayPal.isHidden = false

                }else{
                    UberSupport.shared.removeProgressInWindow()
                    self.appDelegate.createToastMessage(json.status_message)

                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
                    self.appDelegate.createToastMessage(error)
            })
    }
    func wsMethodForAfterPayment(using payKey : String?){
        var params : JSON = [
            "trip_id":self.tripID.description,
                                        "amount":self.payableAmount,
                                        "payment_type": PaymentOptions.default?.paramValue.lowercased() ?? "cash"
        ]
        if let key = payKey{
            params["pay_key"] = key
        }

        self.afterPayment(params: params)
    }
    func initiate3DSecureValidaiton(for intent : String){
          self.stripeHandler?.confirmPayment(for: intent, completion: { (stResult) in
              switch stResult{
              case .success(let token):
                  self.wsMethodForAfterPayment(using: token)
              case .failure(let error):
                  self.appDelegate.createToastMessage(error.localizedDescription)
              }
          })
      }
    
    func wsToCallAfterPayment(using nonce : String){
       

        self.afterPayment(params: ["trip_id":self.tripID.description,
                                   "amount":self.payableAmount,
                                   "payment_type": PaymentOptions.default?.paramValue.lowercased() ?? "cash",
                                   "nonce": nonce])
        
        
    }
    
    //MARK: - ****** Adaptive PayPal SDK Delegate Methods ******
    func paymentLibraryExit()
    {
        var strTitle = ""
        var strMessage = ""
        
        if paymentstatus == "success"
        {
            return
        }
        else if paymentstatus == "failed"
        {
            strTitle = self.language.orderFailed
            strMessage = self.language.yourOrderfailed + self.language.pay.uppercased() + self.language.totryAgain
        }
        else if paymentstatus == "cancelled"
        {
            strTitle = self.language.orderCancelled
             strMessage = self.language.yourOrderfailed + self.language.pay.uppercased() + self.language.totryAgain
        }
        
        if paymentstatus == "failed" || paymentstatus == "cancelled"
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:strTitle, message:NSLocalizedString(strMessage, comment: "") , preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:self.language.ok, style:UIAlertAction.Style.cancel, handler:{ action in
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(settingsActionSheet, animated:true, completion:nil)
        }
    }
  //payment calcel
    func paymentCanceled() {
        paymentstatus = "cancelled"
    }
    //show error message
    func paymentFailed(withCorrelationID correlationID: String!) {
        paymentstatus = "failed"
    }
   
    // MARK: Once user pay the amount will redirect to home page, when click alert ok button
    func gotoHomePage()
    {
       
         let settingsActionSheet: UIAlertController = UIAlertController(title:self.language.success, message:self.language.paymentPaidSuccess, preferredStyle:UIAlertController.Style.alert)
        settingsActionSheet.addAction(UIAlertAction(title: self.language.ok, style:UIAlertAction.Style.cancel, handler:{ action in
            let info: [AnyHashable: Any] = [
                "cancelled_by" : "NO",
            ]
            let propertyView = MainMapView.initWithStory()
            self.navigationController?.pushViewController(propertyView, animated: true)
        }))
        present(settingsActionSheet, animated:true, completion:nil)
    }
  
    func goToRating(for trip : TripDataModel){
        let rateDriverVC : RateDriverVC = .initWithStory()
        rateDriverVC.tripId = trip.id
        self.navigationController?.pushViewController(rateDriverVC,
                                                      animated: true)
    }
    // MARK: - ViewController Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initPaymentView()
        self.updateChangedInvoice()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func showSuccess() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelay(2.0)
        UIView.commitAnimations()
    }
    //MARK: update the payment to the server
    func updateTransactionIdToServer(transactionID: String)
    {
        self.btnPayPal.isHidden = true
        var dicts = Parameters()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["trip_id"] = tripID.description
        if proceed == "1" || transactionID == "Stripe"{
            dicts["paykey"] = ""
        }
        else{
            dicts["paykey"] = transactionID
        }
        dicts["payment_type"] = PaymentOptions.default?.paramValue.lowercased() ?? "cash"
//        self.apiInteractor?.getResponse(forAPI: .afterPayment, params: dicts).shouldLoad(true)
        self.afterPayment(params: dicts)
     
    }
    
    //MARK: Make payment Table Datasource & Delegates
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  60
    }
    class func initWithStory() -> MakePaymentVC {
        
        return UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrInfoKey.count != 0 ? arrInfoKey.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {        
        let cell:CellTripsInfo = tblPaymentDetails.dequeueReusableCell(withIdentifier: "CellTripsInfo")! as! CellTripsInfo
        let tripModel = arrInfoKey[indexPath.row] as? InvoiceModel
        cell.lblTitle?.text = "\(NSLocalizedString((tripModel?.invoiceKey)!, comment: ""))"
        cell.lblCostInfo.text = "\(NSLocalizedString((tripModel?.invoiceValue)!, comment: ""))"
        cell.setBar(tripModel?.bar == 1)
        if let colorStr = tripModel?.color,
            !colorStr.isEmpty {
            var color = colorStr == "black" ? UIColor(hex: "000000") : .ThemeYellow
            cell.lblCostInfo.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(18))
            cell.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(18))
//            if (tripModel?.invoiceKey)?.capitalized.localize == "Total Trip Fare".localize {
            if tripModel?.color == "yellow" {

                color = .ThemeYellow
            } else {
                color = .Title
            }
            cell.lblCostInfo.textColor = color
            cell.lblTitle?.textColor = color
            
        }else{
            cell.lblCostInfo.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(16))
            cell.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(16))
            let color : UIColor = .Title
            cell.lblCostInfo.textColor = color
            cell.lblTitle?.textColor = color
        }
        
        if let comment = tripModel?.comment{
            cell.lblTitle?.text = cell.lblTitle!.text! + " ⓘ"
            cell.lblTitle!.addAction(for: .tap) { [unowned self] in
                self.showPopOver(withComment: comment,on : cell.lblTitle!)
            }
        }else{
            cell.lblTitle?.addAction(for: .tap) {}
        }
        return cell
    }
    
   
    // MARK: When User Press Back Button

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
    
    }
    
  
}

extension MakePaymentVC {//PayPalHandlerDelegate
    func paypalHandler(didComplete paymentID: String) {
        self.wsMethodForAfterPayment(using: paymentID)
    }
    
    func paypalHandler(didFail error: String) {
        self.appDelegate.createToastMessage(error)
    }
    
    
}
