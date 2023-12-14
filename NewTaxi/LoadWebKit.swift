/**
* LoadWebKitView.swift
*
* @package NewTaxiDriver
* @author Seentechs Product Team
* @version - Stable 1.0
* @link http://seentechs.com
*/

import UIKit
import MessageUI
import Social
import WebKit

class LoadWebKitView : UIViewController{
//    @IBOutlet var scrollMenus: UIScrollView!
    @IBOutlet var webCommon: WKWebView?
    @IBOutlet var lblTitle: UILabel!
    var strPageTitle = ""
    var strWebUrl = ""
    var strCancellationFlexible = ""
    var isFromTrip = Bool()
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var cornerView: UIView!

    @IBOutlet weak var backBtn: UIButton!
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        webCommon?.backgroundColor = UIColor.white
        webCommon?.scrollView.backgroundColor = UIColor.white
        self.webCommon?.navigationDelegate = self
        self.webCommon?.uiDelegate = self
        self.navigationController?.isNavigationBarHidden = true
        lblTitle.text = strPageTitle
        let request = URLRequest(url: URL(string: strWebUrl)!)
        lblTitle.text = "Payment Details".localize
        self.lblTitle.textColor = .Title
        self.lblTitle.font = iApp.NewTaxiFont.centuryBold.font(size: 15)
        self.cornerView.setSpecificCornersForTop(cornerRadius: 35)
        self.cornerView.elevate(4)
        webCommon?.load(request)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)

    }
    
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //MARK:- initWithStory
    class func initWithStory() -> LoadWebKitView{
        let view : LoadWebKitView = UIStoryboard.payment.instantiateViewController()
        
//        view.apiInteractor = APIInteractor(view)
        return view
    }
    func goBack()
    {
//        OperationQueue.main.addOperation {
            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onAddTitleTapped(_ sender:UIButton!)
    {
        
    }

    @IBAction func onAddSummaryTapped(_ sender:UIButton!)
    {
        
    }

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onAddListTapped(){
        
    }
}

extension LoadWebKitView: WKNavigationDelegate,WKUIDelegate {

    
    // 1. Decides whether to allow or cancel a navigation.
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {

        print("*********************************************************navigationAction load:\(String(describing: navigationAction.request.url))")
        let str = String(describing: navigationAction.request.url)
        if str.contains("/challenge/complete"){
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "subcription_complete"), object: self, userInfo: nil)
               self.goBack()
        }
        }
        decisionHandler(.allow)
    }
    
    // 2. Start loading web address
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start load:\(String(describing: webView.url))")
       UberSupport().showProgress(viewCtrl: self, showAnimation: true)
    }
    
    // 3. Fail while loading with an error
    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        print("fail with error: \(error.localizedDescription)")
    }
    
    // 4. WKWebView finish loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish loading")
        UberSupport().removeProgress(viewCtrl: self)
        webView.evaluateJavaScript("document.getElementById('data').innerHTML", completionHandler: { result, error in
            if let userAgent = result as? String {

                if let resFinal = self.convertStringToDictionary(text: userAgent) as? JSON{
                    print("*****************")
                    print(resFinal)
                    let statCode = resFinal["status_code"] as! String
                    let statMessage = resFinal["status_message"] as! String
                    var tripId = ""
                    var walletAmount = ""
                    if self.isFromTrip{
                        tripId = resFinal.string("trip_id")
                    }
                    else {
                        walletAmount = resFinal.string("wallet_amount")
                    }
                    if statCode == "1"{
                        self.goBack()
                        if self.isFromTrip{
                            tripId = resFinal.string("trip_id")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TripApi"), object: self, userInfo: ["status": statMessage,"tripId":tripId])
                        }
                        else {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WalletApi"), object: self, userInfo: ["wallet": walletAmount])
                            self.appDelegate.createToastMessage(statMessage)
                        }
//                        if self.isFromTrip{
//                            FireBaseNodeKey.trip.getReference(for: "\(tripId)").removeValue()
//                            self.appDelegate.onSetRootViewController(viewCtrl: self)
//                        }
                    }else{
                        self.appDelegate.createToastMessage(statMessage)
                        self.goBack()
                    }
                    
                   
                }
                
            }
        })

        print("didFinish")
    }
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}


//"{\"status_code\":\"1\",\"status_message\":\"Paid Successfully\",\"currency_code\":\"INR\",\"trip_id\":67,\"total_time\":\"0.00\",\"total_km\":\"0.00\",\"total_time_fare\":\"0.00\",\"total_km_fare\":\"0.00\",\"base_fare\":\"7312.80\",\"total_fare\":\"8044.08\",\"access_fee\":\"731.28\",\"pickup_location\":\"12\\/9, Ranan Nagar, Madurai, Tamil Nadu 625020, India\",\"drop_location\":\"12\\/9, Ranan Nagar, Madurai, Tamil Nadu 625020, India\",\"driver_payout\":\"6581.52\",\"trip_status\":\"Completed\",\"driver_thumb_image\":\"http:\\/\\/<a href=\"http://seentechsdemo.com\" dir=\"ltr\" x-apple-data-detectors=\"true\" x-apple-data-detectors-type=\"link\" x-apple-data-detectors-result=\"0\">seentechsdemo.com</a>\\/kirawouya\\/public\\/images\\/user.jpeg\"}"
