//
//  RateDriverVC.swift
// NewTaxi
//
//  Created by Seentechs on 23/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseDatabase
import Foundation
import SDWebImage
import IQKeyboardManagerSwift

class RateDriverVC: UIViewController,APIViewProtocol {
    
    //MARK:- APIHandlers
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
        default:
            print()
        }
    }
   func onFailure(error: String,for API : APIEnums) {
    }
    //MARK:- Outlets
    @IBOutlet weak var pageTitlelbl : UILabel!
    @IBOutlet weak var backBtn : UIButton!
    
    @IBOutlet weak var contentHolderView : UIView!
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var commentView : UIView!
    @IBOutlet weak var commentTitleLbl : UILabel!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!

    @IBOutlet weak var covidFeatureNote: UILabel!
    @IBOutlet weak var tipView : UIView!
    @IBOutlet weak var tipSideIconIV : UIImageView!
    @IBOutlet weak var tipTitleLbl : UILabel!
    
    @IBOutlet weak var tipAmountView : UIView!
    @IBOutlet weak var tipBackgroundView : UIView!
    @IBOutlet weak var tipCurrencyLbl : UILabel!
    @IBOutlet weak var tipAmountTF : UITextField!
    @IBOutlet weak var tipAmountBtn : UIButton!
    @IBOutlet weak var cancelTipBtn : UIButton!
    
    //MARK:- Variables
    let curr_sym = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var tripId : Int = 0
    var tripDetailData: TripDetailDataModel?
    var riderGivenTripAmount : Double?{
        didSet{
            self.updateTipAmountView()
        }
    }
    var tipTextFieldObserver : TextFieldUtil?
    lazy var language = Language.default.object
    //MARK:- Viewcontroller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.getTripDetails()
        btnSubmit.addTarget(self, action: #selector(onSubmitTapped(_:)), for: .touchUpInside)
    
        self.initView()
        self.initLanguage()
        self.initGestures()
        self.initTextFieldObservers()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self] in
            self?.initLayers()
        }
        self.covidFeatureNote.isHidden = !Shared.instance.isCovidEnable
        self.covidFeatureNote.textColor = .Title
        self.covidFeatureNote.font = iApp.NewTaxiFont.centuryBold.font(size: 15)
        self.covidFeatureNote.text = self.language.ratingCovidContent
        self.setStatusBarStyle(.lightContent)
    }
    var isDark = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDark ? .lightContent : .default
    }

    func toggleAppearance() {
       isDark.toggle()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.setStatusBarStyle(.default)
    }
    func getTripDetails()
    {
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getTripDetail,params: ["trip_id" : self.tripId])
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let detail = TripDetailDataModel(json)
                    self.tripId = detail.id
                    self.tripDetailData = detail
                    self.setRiderProfileImage()

                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    func setRiderProfileImage(){
        if self.tripDetailData?.driverThumbImage != ""{
            self.imgUser.sd_setImage(with: URL(string: self.tripDetailData?.driverThumbImage ?? ""))
        }else{
            self.imgUser.image = UIImage(named: "user_dummy.png")
             
        }
        
        
    
    }
    //MARK:- initializers
    
    func initView(){

        self.floatRatingView.minRating = 0
        self.floatRatingView.maxRating = 5
        
        self.floatRatingView.rating = 0
        self.riderGivenTripAmount = nil
        
        self.txtComments.delegate = self
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShowns), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHiddens), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func initLanguage(){
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        self.pageTitlelbl.text = self.language.rateYourRide.capitalized
        self.lblPlaceHolder.text = self.language.smoothOrSloppy
        self.commentTitleLbl.text = self.language.writeYourComment.capitalized
       self.tipTitleLbl.text = self.language.addTip.capitalized
        self.btnSubmit.setTitle(self.language.submit.uppercased(), for: .normal)
        self.tipAmountBtn.setTitle(self.language.setTip.uppercased(), for: .normal)
       self.tipAmountTF.placeholder = self.language.enterTipAmount.capitalized
        self.txtComments.textAlignment = self.language.getTextAlignment(align: .left)

    }
    func initTextFieldObservers(){
        self.tipTextFieldObserver = TextFieldUtil(self.tipAmountTF)
        self.tipTextFieldObserver?.addValidation({$0.count <= 6})
        self.tipTextFieldObserver?.listen({ ( event,  textField) in
            if textField.text?.isEmpty ?? true{
                self.tipAmountBtn.isUserInteractionEnabled = false
                self.tipAmountBtn.backgroundColor = .ThemeInactive
            }else{
                self.tipAmountBtn.isUserInteractionEnabled = true
                self.tipAmountBtn.backgroundColor = .ThemeYellow
            }
        })
      
    }
    
    func setDesign() {
        
        
        self.pageTitlelbl.textColor = .Title
        self.pageTitlelbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.contentHolderView.setSpecificCornersForTop(cornerRadius: 35)
        self.contentHolderView.elevate(4)
        
        self.imgUser.cornerRadius = 30
        
        self.lblPlaceHolder.textColor = .Title
        self.lblPlaceHolder.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
        
        self.floatRatingView.imageTintColor = .ThemeYellow
        
        self.commentView.cornerRadius = 15
        self.commentView.elevate(1)
        
        self.txtComments.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.checkForTextColor()
        
        self.tipView.cornerRadius = 10
        self.tipView.elevate(1)
        self.tipView.backgroundColor = .Title
        
        self.tipTitleLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.tipTitleLbl.textColor = .white
        
       
        self.btnSubmit.cornerRadius = 15
        self.btnSubmit.setTitleColor(.Title, for: .normal)
        self.btnSubmit.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.btnSubmit.elevate(1)
        
        self.tipBackgroundView.setSpecificCornersForTop(cornerRadius: 35)
        self.tipBackgroundView.elevate(1)
        self.tipBackgroundView.backgroundColor = .Background
        
        self.tipAmountTF.backgroundColor = .white
        self.tipAmountTF.cornerRadius = 10
        self.tipAmountTF.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.tipAmountTF.textColor = .Title
        self.tipAmountTF.textAlignment = .left
        self.tipAmountTF.setLeftPaddingPoints(15)
        self.tipAmountTF.setRightPaddingPoints(15)
        
        self.tipCurrencyLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.tipCurrencyLbl.textColor = .Title
        
        self.tipAmountTF.cornerRadius = 15
        
        self.tipAmountBtn.cornerRadius = 15
        self.tipAmountBtn.backgroundColor = .ThemeYellow
        self.tipAmountBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.tipAmountBtn.setTitleColor(.Title, for: .normal)
        
    }
    func initLayers(){
        self.tipCurrencyLbl.text = self.curr_sym
        self.setDesign()
        self.view.addSubview(self.tipAmountView)
        self.view.bringSubviewToFront(self.tipAmountView)
        self.tipAmountView.backgroundColor = .clear
        self.tipAmountView.frame = CGRect(x: 0,
                                          y: 0,
                                          width: self.view.frame.width,
                                          height: self.view.frame.height)
        self.tipAmountTF.text = ""
        self.tipAmountView.transform = CGAffineTransform(translationX: 0,
                                                         y: self.view.frame.height)
        self.view.layoutIfNeeded()
        
        
        self.tipAmountView.layoutIfNeeded()
        
         
    }
    func initGestures(){
        self.tipView.addAction(for: .tap) { [weak self] in
            guard let welf = self,welf.riderGivenTripAmount == nil else{return}
            
            
            UIView.animate(withDuration: 0.6,
                           animations: {
                            welf.tipAmountView.transform = .identity
            }, completion: { (completed) in
                if completed{
                    welf.tipAmountTF.becomeFirstResponder()
                }
            })
        }
        self.contentHolderView.addAction(for: .tap) { [weak self] in
            self?.view.endEditing(true)
        }
        self.tipSideIconIV.addAction(for: .tap) { [weak self] in
            guard let welf = self,welf.riderGivenTripAmount != nil else{return}
            welf.riderGivenTripAmount =  nil
        }
        self.tipAmountView.addAction(for: .tap) { [weak self] in
            guard let welf = self else{return}
            UIView.animate(withDuration: 0.6, animations: {
                welf.tipAmountTF.resignFirstResponder()
                welf.tipAmountView.transform = .identity
            })
            
            
        }
        
        self.tipBackgroundView.addAction(for: .tap) {
            
        }
    }
    //MARK:- initWithStory
    class func initWithStory() -> RateDriverVC{
        let driverRatingVC : RateDriverVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateIDViewController()
        return driverRatingVC
    }
    //MARK:- UDF
    @objc func KeyboardShowns(notification: NSNotification) {
        
    }
    //hide the keyboard
    @objc func KeyboardHiddens(notification: NSNotification)
    {
    }
    func updateTipAmountView(){
        
        if let tip = self.riderGivenTripAmount{
            self.tipSideIconIV.image = UIImage(named:"cancel")?.withRenderingMode(.alwaysTemplate)
            self.tipTitleLbl.text = "\(self.language.tip) \(self.curr_sym)\(tip) \(self.language.toDriver)"
            self.tipView.backgroundColor = .Title
        }else{
            self.tipSideIconIV.image = UIImage(named:"tip")?.withRenderingMode(.alwaysTemplate)
            self.tipTitleLbl.text = self.language.add.capitalized + " " + self.language.tip
            self.tipView.backgroundColor = .Title
        }
        self.tipSideIconIV.tintColor = .white
    }
    func pushToPaymentVC(){
        let paymentVc : MakePaymentVC = UIStoryboard.payment.instantiateViewController()
        paymentVc.tripID = self.tripId
        self.navigationController?.pushViewController(paymentVc, animated: true)
    }
    //MARK:- Actions
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        
        if self.navigationController?.viewControllers.contains(where: {$0 is RouteVC}) ?? false
        {
                           NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
        }
        else
        {
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func setTipAmount(_ sender : UIButton?){
        guard let amount = Double(self.tipAmountTF.text ?? ""),
            !amount.isZero else{
                
                self.appDelegate.createToastMessage(self.language.pleaseEnterValidAmount)//"Please enter valid amount"
                return
        }
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let welf = self else {return}
            welf.tipAmountTF.text = ""
            welf.tipAmountView.resignFirstResponder()
            welf.view.endEditing(true)
            welf.tipAmountView.transform = CGAffineTransform(translationX: 0,
                                                              y: welf.view.frame.height)
        }
        self.riderGivenTripAmount = amount
        
    }
    @IBAction func cancelTipAction(_ sender : UIButton){
        UIView.animate(withDuration: 0.6) {
            self.view.endEditing(true)
            self.tipAmountTF.text = ""
            self.tipAmountView.transform = CGAffineTransform(translationX: 0,
                                                             y: self.view.frame.height)
        }
    }
    
    
    //MARK:- set Refresh Payment in Firebase
    func setRefreshPayment(){
        let strTripID = self.tripId.description
        var node = [String:Any]()
        node[FireBaseNodeKey.refresh_payment.rawValue] = PaymentOptions.tips.rawValue
        FireBaseNodeKey.trip.ref(forID: strTripID).setValue(node)
    }
    
    
    @IBAction func onSubmitTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if Int(self.floatRatingView.rating) == 0
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:self.language.message+"!!!", message:self.language.pleaseGiveRating.capitalized, preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:self.language.ok.uppercased(), style:UIAlertAction.Style.cancel, handler:{ action in
            }))
            present(settingsActionSheet, animated:true, completion:nil)
            
            return
        }
        var parameters = Parameters()
         parameters["trip_id"] = self.tripId
        parameters["rating"] = String(format: "%d", Int(self.floatRatingView.rating))
        if txtComments.text == self.language.writeYourComment{
            parameters["rating_comments"] = ""
        }
        else{
            parameters["rating_comments"] = txtComments.text ?? String()
        }
        parameters["user_type"] = Constants().GETVALUE(keyname: USER_TYPE)
        if let tip = self.riderGivenTripAmount?.description{
        parameters["tips"] = tip
        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .giveRating,params: parameters)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let statuscode = json.int("status_code")
                    if statuscode == 1{
                        if self.riderGivenTripAmount != nil {
                                          self.setRefreshPayment()
                                      }
                        AppRouter(self).routeToPayment(tripId: self.tripId)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
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

}
extension RateDriverVC : UITextViewDelegate{
    //MARK: - TEXTVIEW DELEGATE METHOD
    func textViewDidChange(_ textView: UITextView)
    {
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if range.location == 0 && (text == " ") {
            return false
        }
        if (text == "") {
            return true
        }
        else if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func checkForTextColor() {
        if txtComments.text == self.language.writeYourComment {
            txtComments.text = ""
            txtComments.textColor = .Title
        } else if txtComments.text == "" {
            txtComments.text = self.language.writeYourComment
            txtComments.textColor = UIColor.Title.withAlphaComponent(0.29)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.checkForTextColor()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.checkForTextColor()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
extension RateDriverVC : FloatRatingViewDelegate{
    
    // MARK: - FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        self.view.endEditing(true)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        let strRating = NSString(format: "%.2f", self.floatRatingView.rating) as String
        floatRatingView.rating = Float(strRating)!
    }
}

