/**
 * RatingVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit
import Alamofire
class RatingVC: UIViewController, FloatRatingViewDelegate,UITextViewDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
//        case .RatingGiven:
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: self, userInfo: nil)

//        case .tripDetailData(let response):
//            self.tripDetailData = response
//            self.setDriverData(response)
        default:
            print()
        }
    }
    
    func onFailure(error: String,for API : APIEnums) {
        print(error)
    }
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    lazy var skipBtn = UIButton()
    var tripData : TripDataModel!
    var tripDetailData: TripDetailDataModel?{
        didSet{if let detail = self.tripDetailData{self.tripData = detail}}
    }
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var strTripID = ""
    var strDriverImgUrl = ""
    var isFromTripPage : Bool = false
    lazy var arrTemp1 : NSMutableArray = NSMutableArray()
    lazy var arrTripsData : NSMutableArray = NSMutableArray()
   

    // MARK: - ViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        if ChatInteractor.instance.isInitialized{
            ChatInteractor.instance.deinitialize()
        }
        txtComments.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        txtComments.layer.borderWidth = 2.0
        txtComments.layer.cornerRadius = 3.0
        btnSubmit.layer.cornerRadius = 3.0
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        self.floatRatingView.fullImage = UIImage(named: "StarFull")
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 0
        self.floatRatingView.rating = 0.0
        self.floatRatingView.editable = true
        var lblFrame = lblPlaceHolder.frame
        lblFrame.origin.y = txtComments.frame.origin.y+8
        lblFrame.origin.x = txtComments.frame.origin.x+5
        lblPlaceHolder.frame = lblFrame
        imgUser.layer.cornerRadius = imgUser.frame.size.width / 2
        imgUser.clipsToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide1), name: UIResponder.keyboardWillHideNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initSkipButton()
        }
        if let detail = self.tripDetailData{
            self.setDriverData(detail)
        }else{
            
//            self.apiInteractor?.getResponse(forAPI: .getTripDetail,
//                                            params: ["trip_id" : self.tripData.id])
//                .shouldLoad(true)
            
            UberSupport().showProgressInWindow(showAnimation: true)
            self.apiInteractor?
                .getRequest(for: .getTripDetail,params: ["trip_id" : self.tripData.id])
                .responseJSON({ (json) in
                    if json.isSuccess{
                        UberSupport.shared.removeProgressInWindow()
                        let detail = TripDetailDataModel(json)
                        self.tripDetailData = detail
                        self.setDriverData(detail)
                    }else{
                        AppDelegate.shared.createToastMessage(json.status_message)
                        UberSupport.shared.removeProgressInWindow()

                    }
                }).responseFailure({ (error) in
                    AppDelegate.shared.createToastMessage(error)
                        UberSupport.shared.removeProgressInWindow()
                })
        }
        
        self.txtComments.textAlignment = Language.default.object.getTextAlignment(align: .left)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 150
    }
 
    func initLanguage(){
    }
  
    func setStatusBarStyle()
    {
    }
    // Dissmiss keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHideForView(keyboarHeight: keyboardFrame.size.height, btnView: self.view)
    }
    
    @objc func keyboardWillHide1(notification: NSNotification)
    {
            UberSupport().keyboardWillShowOrHideForView(keyboarHeight: 0, btnView: self.view)
   
    }
    func setDriverData(_ data : TripDetailDataModel){
        
        imgUser.sd_setImage(with: URL(string: data.driverThumbImage), placeholderImage:UIImage(named:""))
    }
    //MARK:- skipButton
    func initSkipButton(){
        self.view.addSubview(self.skipBtn)
        self.view.bringSubviewToFront(self.skipBtn)
        
        self.skipBtn.setTitle("Skip".localize, for: .normal)
        self.skipBtn.titleLabel?.font = self.lblPlaceHolder.font
        self.skipBtn.setTitleColor(.ThemeMain, for: .normal)
        self.skipBtn.backgroundColor = .white
        
        let margin = view.layoutMarginsGuide
        let safeFrame = margin.layoutFrame
        let width : CGFloat = 50
        let height : CGFloat = 48
        let isRTL = Language.default.isRTL
        self.skipBtn.frame = CGRect(x: isRTL ? 0 :safeFrame.maxX - width,
                                    y: safeFrame.minY,
                                    width: width,
                                    height: height)
        self.skipBtn.addAction(for: .tap) {
           
               NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: nil)
        }
    }
    //MARK: - TEXTVIEW DELEGATE METHOD
    func textViewDidChange(_ textView: UITextView)
    {
        lblPlaceHolder.isHidden = (txtComments.text.count > 0) ? true : false
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
    //MARK: TEXTVIEW DELEGATE END
    
    // MARK: - FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        self.view.endEditing(true)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        let strRating = NSString(format: "%.2f", self.floatRatingView.rating) as String
        floatRatingView.rating = Float(strRating)!
    }
    // MARK: FloatRatingViewDelegate

    // MARK: - When User Press Submit Button
    @IBAction func onSubmitTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if Int(self.floatRatingView.rating) == 0
        {
            let settingsActionSheet: UIAlertController = UIAlertController(title:NSLocalizedString("Message!!!", comment: ""), message:NSLocalizedString("Please give rating", comment: ""), preferredStyle:UIAlertController.Style.alert)
            settingsActionSheet.addAction(UIAlertAction(title:NSLocalizedString("OK", comment: ""), style:UIAlertAction.Style.cancel, handler:{ action in
            }))
            present(settingsActionSheet, animated:true, completion:nil)
            
            return
        }
        self.updateRatingToApi()
    }
    
    func updateRatingToApi() {
        var parameters = Parameters()
        parameters["trip_id"] = strTripID
        parameters["rating"] = String(format: "%d", Int(self.floatRatingView.rating))
        parameters["rating_comments"] = txtComments.text ?? String()
//        self.apiInteractor?.getResponse(forAPI: .giveRating, params: parameters).shouldLoad(true)
        UberSupport().showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .giveRating,params: parameters)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let statuscode = json.int("status_code")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.RefreshInCompleteTrips.rawValue), object: self, userInfo: nil)

                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()
            })
        return
      
    }
   
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)

        if isFromTripPage
        {
            self.navigationController!.popViewController(animated: true)
        }
        else
        {
           let propertyView = MainMapView.initWithStory()
            self.navigationController?.pushViewController(propertyView, animated: true)

        }
    }
    
}

