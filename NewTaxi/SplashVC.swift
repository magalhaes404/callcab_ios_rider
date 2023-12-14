/**
 * SplashVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit
import Alamofire
import FirebaseCrashlytics
enum ForceUpdate : String {
    case skipUpdate = "skip_update"
    case noUpdate = "no_update"
    case forceUpdate = "force_update"
}
class SplashVC: UIViewController ,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
            //        case .forceUpdate(let update):
            //            self.shouldForceUpdate(update)
            
        default:
            print()
        }
    }
    
    func onFailure(error: String,for API : APIEnums) {
        //        print(error)
    }
    var hasLaunchedAlready : Bool = false
    
    lazy var window = UIWindow()
    @IBOutlet var lblMenuTitle: UILabel!
    @IBOutlet var imgAppIcon: UIImageView!
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var isFirstTimeLaunch : Bool = false
    
    var transitionDelegate: UIViewControllerTransitioningDelegate?
    var pushManager: PushNotificationManager!
    @IBOutlet var button: UIButton!
    var timer : Timer?
    // MARK: - Splashscreen launch
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.initView()
        }
        if iApp.crashApplicationOnSplash{
            Crashlytics.crashlytics()
        }
    }
    func initView() {
        
        if YSSupport.checkDeviceType()
        {
            if !(UIApplication.shared.isRegisteredForRemoteNotifications)
            {
                let settingsActionSheet:UIAlertController = UIAlertController(title: self.language.message, message: self.language.enPushNotifyLogin, preferredStyle:UIAlertController.Style.alert)
                settingsActionSheet.addAction(UIAlertAction(title: self.language.ok, style:UIAlertAction.Style.cancel, handler:{ action in
                    self.appDelegate.pushManager.registerForRemoteNotification()
                }))
                present(settingsActionSheet, animated:true, completion:nil)
                
            }
        }
        self.timer = Timer.scheduledTimer(timeInterval:1.0, target: self, selector: #selector(self.onSetRootViewController), userInfo: nil, repeats: true)
        self.apiInteractor = APIInteractor(self)
        
        _ = PipeLine.createEvent(key: PipeLineKey.app_entered_foreground) {
            self.onStart()
        }
    }
    //MARK:- initWithStory
    class func initWithStory() -> SplashVC{
        let splash : SplashVC = UIStoryboard.account.instantiateViewController()
        splash.apiInteractor = APIInteractor(splash)
        return splash
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    // Setting root view controller after splash showed
    @objc func onSetRootViewController()
    {
        if !iApp.isSimulator {
            guard let fcmToken = UserDefaults.standard.string(forKey: USER_DEVICE_TOKEN),
                  !fcmToken.isEmpty,
                  fcmToken != " " || iApp.isSimulator else{
                //MARK: - Push Notification Call
                self.appDelegate.pushManager.registerForRemoteNotification()
                
                
                return
            }
        }
        
        self.timer?.invalidate()
        self.onStart()
    }
    //Onapplicaiton start
    func onStart()
    {
        guard let appVersion = iApp.instance.version else {return}
        var params = Parameters()
        params["version"] = appVersion
        //        _ = self.apiInteractor?.getResponse(forAPI: APIEnums.force_update, params: params)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .force_update,params: params)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let shouldForceUpdate = json.string("force_update")
                    let should = ForceUpdate(rawValue: shouldForceUpdate) ?? .noUpdate
                    let enableReferral = json.bool("enable_referral")
                    let appleLogin = json.bool("apple_login")
                    let facebookLogin = json.bool("facebook_login")
                    let googleLogin = json.bool("google_login")
                    let otpEnabled = json.bool("otp_enabled")
                    let supportArray = json.array("support")
                    let support = supportArray.compactMap({Support.init($0)})
                    Shared.instance.socialLoginSupport(appleLogin: appleLogin, facebookLogin: facebookLogin, googleLogin: googleLogin, otpEnabled: otpEnabled, supportArr: support )
                    Shared.instance.enableReferral(enableReferral)
                    self.shouldForceUpdate(should)
                    
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()
                    
                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                UberSupport.shared.removeProgressInWindow()
                
            })
        
        
    }
    func shouldForceUpdate(_ should : ForceUpdate){
        
        switch should {
        case .forceUpdate:
            self.presentAlertWithTitle(title: self.language.newVersAvail,
                                       message: self.language.updateOurApp,
                                       options: self.language.update) { (option) in
                self.goToAppStore()
            }
        case .noUpdate:
            moveOn()
        case .skipUpdate:
            self.showAlert(title: self.language.newVersAvail, message: self.language.forceUpdate)
        default:
            break
        }
    }
    func showAlert(title:String,message:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: self.language.skip, style: .default, handler: { (action) in
            self.moveOn()
        }))
        alertController.addAction(UIAlertAction.init(title: self.language.update, style: .default, handler: { (action) in
            self.goToAppStore()
        }))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            if let top = topController.presentedViewController{
                top.present(alertController, animated: true, completion: nil)
            }else{
                topController.present(alertController, animated: true, completion: nil)
            }
            
        }else{
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func moveOn()
    {
        guard !self.hasLaunchedAlready else {return}
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.onSetRootViewController(viewCtrl:self)
        self.hasLaunchedAlready = true
    }
    //Redirect to App Store
    func goToAppStore(){
        
        if let url = iApp.Rider().appStoreLink{
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
                // Fallback on earlier versions
            }
        }
    }
}
