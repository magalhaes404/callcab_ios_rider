/**
 * AppDelegate.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit
import FBSDKCoreKit
import GoogleSignIn
import GoogleMaps
import UserNotifications
import Firebase
//import FirebaseInstanceID
import FirebaseMessaging
import GooglePlaces
import CoreData

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,APIViewProtocol
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    var notificationJSOS:JSON?
    var window: UIWindow?
    var isFirstTime : Bool = false
    let userDefaults = UserDefaults.standard
    var isMainMap : Bool = false
    var paymentMethod = ""
    var iswallect = ""
    var option = ""
    var amount = ""
    var nSelectedIndex : Int = 0
    var language = ""
    let center = UNUserNotificationCenter.current()

    //MARK: - PushNotification Manager Declaration
    
    var pushManager : PushNotificationManager!
    
    fileprivate var backGroundThread : UIBackgroundTaskIdentifier = .invalid
    // MARK Create a FBSDK
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        if let scheme = url.scheme,
            scheme
                .localizedCaseInsensitiveCompare(
                    iApp.Rider().appName
                ) == .orderedSame{
            return true
        }
        if ApplicationDelegate.shared.application(
            application,
            open: url as URL,
            sourceApplication: sourceApplication,
            annotation: annotation
            ){
            return true
        }
        return true
    }
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "NewTaxi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                /*var tripCache = TripCache()
                tripCache.removeTripDataFromLocale(UserDefaults.value(for: .cache_location_trip_id) ?? "")*/
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if #available(iOS 13.0, *){
            let view = UIApplication.shared.statusBarView
            view?.backgroundColor = style == .lightContent ? UIColor.ThemeYellow : .white
        }else if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = style == .lightContent ? UIColor.ThemeYellow : .white
        }
}
    //MAKR: When a app is Launch to front in mobile
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        let pre = Locale.preferredLanguages[0]
        let lag = pre.components(separatedBy: "-")
        language = Language.default.rawValue
        Constants().STOREVALUE(value: language, keyname: DEVICE_LANGUAGE)
        //PUSHNOTIFICATION Manager
        DispatchQueue.main.async {
            self.pushManager = PushNotificationManager(application)
            self.initPushNotification()
        }
        if let options = launchOptions,
                       let jsons = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
                       self.notificationJSOS = jsons
                       self.perform(#selector(self.didReceiveNotificationHandler), with: nil, afterDelay: 1)
                   }

        self.window = UIWindow(frame:UIScreen.main.bounds)
        UIApplication.shared.applicationIconBadgeNumber = 0;
        ApplicationDelegate.shared
            .application(
                application,
                didFinishLaunchingWithOptions: launchOptions
        )
        UIApplication.shared.isIdleTimerDisabled = true
        //background notification
        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        application.setMinimumBackgroundFetchInterval(1800)
        self.initModules()
        self.makeSplashView(isFirstTime: true)
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
          (granted, error) in
            if !granted {
              print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
          if settings.authorizationStatus != .authorized {
            // Notifications not allowed
            print("not allowed")
          }
        }
        self.updateLanguage()// Update language and initialize paypal;
        return true
    }
    @objc func didReceiveNotificationHandler() { // MARK: for killed state pushnotification Handler
        if  let nav = self.window?.rootViewController as? UINavigationController {
            if let  dict = self.notificationJSOS {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.KilledStateNotification.rawValue), object: self)
        }
        
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.didReceiveNotificationHandler()
            }
           
        }
    
    }
    func initModules(){
        self.apiInteractor = APIInteractor(self)
        if UserDefaults.isNull(for: .default_language_option){
            Language.default.saveLanguage()
        }
        if let googlePlist = PlistReader<GooglePlistKeys>(){
            if let apiKey : String = googlePlist.value(for: .apiKey){
                GMSServices.provideAPIKey(apiKey)
                GMSPlacesClient.provideAPIKey("AIzaSyCZKWo4oxyTgR7477O5xxAZu0ZadzM0u7M")
            }
            if let clinetId : String = googlePlist.value(for: .clientId){
                GIDSignIn.sharedInstance()?.clientID = clinetId
            }
        }
        NetworkManager.instance.observeReachability(true)
        let userCurrency = userDefaults.value(forKey: USER_CURRENCY_SYMBOL_ORG) as? String
        if (userCurrency == nil || userCurrency == "")
        {
            userDefaults.set("", forKey: USER_CURRENCY_SYMBOL_ORG)
        }
        let userdialcode = userDefaults.value(forKey: USER_DIAL_CODE) as? String
        if (userdialcode == nil || userdialcode == "")
        {
            userDefaults.set("", forKey: USER_DIAL_CODE)
        }
        let userCountryCode = userDefaults.value(forKey: USER_COUNTRY_CODE) as? String
        if (userCountryCode == nil || userCountryCode == "")
        {
            userDefaults.set("", forKey: USER_COUNTRY_CODE)
        }
        
        let userDeviceToken = userDefaults.value(forKey: USER_DEVICE_TOKEN) as? String
        if (userDeviceToken == nil || userDeviceToken == "")
        {
            userDefaults.set("", forKey: USER_DEVICE_TOKEN)
        }
        StripeHandler.initStripeModule()
        userDefaults.synchronize()
    }

    
    
    // [START openurl]
    internal func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        let urlOpen = url.absoluteString
        var version = Bundle.main.infoDictionary?["FacebookAppID"] as? String
        version = String(format:"fb%@",version!)
        if StripeHandler.isStripeHandleURL(url){
            return true
        }else if (urlOpen as NSString).range(of:version!).location != NSNotFound {
            let handled = ApplicationDelegate.shared.application(
                application,
                open: url as URL,
                sourceApplication: sourceApplication,
                annotation: annotation
            )
            return handled
        }else{
            return GIDSignIn.sharedInstance()?.handle(url) ?? false
        }
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch data from internet now
        if let trip_id : Int = UserDefaults.value(for: .current_trip_id){
            ChatInteractor.instance.initialize(withTrip: trip_id.description)
            ChatInteractor.instance.observeTripChat(true, view: nil)
        }
    }
    //MARK: Social login KEYS update
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
     
        let urlOpen = url.absoluteString
        
        var version = Bundle.main.infoDictionary?["FacebookAppID"] as? String
        version = String(format:"fb%@",version!)
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare(iApp.Rider().appName) == .orderedSame{
            return true
        }
        if BrainTreeHandler.isBrainTreeHandleURL(url, options: options){
            return true
        }else if StripeHandler.isStripeHandleURL(url){
            return true
        }else if (urlOpen as NSString).range(of:version!).location != NSNotFound {
            let handled = ApplicationDelegate.shared
                .application(
                    app,
                    open: url,
                    options: options
            )
            return handled
        }
        else if let canHandle = GIDSignIn.sharedInstance()?.handle(url),
            canHandle{
            return true
        }
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                
                if StripeHandler.isStripeHandleURL(url) {
                    return true
                } else {
                    // This was not a Stripe url – handle the URL normally as you would
                }
            }
        }
        return false
    }
    // Display Splash Screen when startup app
    func makeSplashView(isFirstTime:Bool)
    {
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
                
        let splashView = SplashVC.initWithStory()
        splashView.isFirstTimeLaunch = isFirstTime
        window!.rootViewController = splashView
        window!.makeKeyAndVisible()    }
    
    // MARK: Getting Main Storyboard Name
    func getMainStoryboardName() -> String
    {
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        var getStoryBoardName : String = ""
        switch (deviceIdiom)
        {
        case .pad:
            getStoryBoardName = "Main_iPad"
        case .phone:
            getStoryBoardName = "Main"
        default:
            break
        }
        return getStoryBoardName
    }
    
    func initPushNotification() {
           
           DispatchQueue.main.async {
               self.pushManager.registerForRemoteNotification()
           }
       }
    // Setting Main Root ViewController
    func onSetRootViewController(viewCtrl:UIViewController?,caller : String = #function){
        debug(print: caller)
//        viewCtrl?.view.removeFromSuperview()
       
        
        let getMainPage =  userDefaults.object(forKey: "getmainpage") as? NSString
        if Language.default.isRTL{
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else{
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        if getMainPage == "rider"
        {
            
            self.showMapView()
            PushNotificationManager.shared?.startObservingUser()
        }
        else
        {
            self.showAuthenticationScreen()
        }
        
    }
    
    // MARK: Goto Main View after user loggedin
    func showMapView()
    {
        
        let vcMenuVC = MainMapView.initWithStory()

        let navigationController = UINavigationController(rootViewController: vcMenuVC)
        navigationController.isNavigationBarHidden = true
        let newWindow = UIWindow()
        newWindow.rootViewController = navigationController
        self.window = newWindow
        self.window?.makeKeyAndVisible()
//        window?.makeKeyAndVisible()
        
    }
    
    // MARK: Display Login View
    func showAuthenticationScreen()
    {
        let storyBoardMenu : UIStoryboard = UIStoryboard(name: self.getMainStoryboardName(), bundle: nil)
        let authenticationVC  = AuthenticationVC.initWithStory()
        
        let navigationController = UINavigationController(rootViewController: authenticationVC)
        navigationController.isNavigationBarHidden = true
        self.window?.rootViewController = navigationController;
        window?.makeKeyAndVisible()
    }
    func scheduleNotification(title: String,message: String,json: JSON) {
//        let sender_name = UserDefaults.standard.string(forKey: TRIP_DRIVER_NAME) ?? "driver"
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.userInfo = json
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Chat Notification"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }

    }
    // Enable hockey app sdk for tracking crashes

    
    // MARK: Application Life cycle delegate methods
    func applicationWillResignActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
        _ = PipeLine.fireEvent(withKey: PipeLineKey.app_entered_foreground)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let pre = Locale.preferredLanguages[0]
        let lag = pre.components(separatedBy: "-")
        language = lag[0]
        self.updateLanguage()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
        AppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CallManager.instance.deinitialize()
       
        
        self.backGroundThread = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let welf = self,welf.backGroundThread == .invalid else{return}
            CallManager.instance.deinitialize()
            welf.terminateBackgroundThread()
        }
        assert(backGroundThread != .invalid)
        
    }
    
    // MARK: - Remote Notification Methods // <= iOS 9.x
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CallManager.instance.registerForPushNotificaiton(token: deviceToken, forApplicaiton: application)
       
        pushManager.getDeviceID(deviceToken: deviceToken)
    }

    // MARK: Get Token Refersh
    func tokenRefreshNotification() {
    }
    // Get FCM Token
    func connectToFcm() {

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Error = ",error.localizedDescription)
    }
    
 
    //Deiver Token updated to the Server
    func sendDeviceTokenToServer(strToken: String)
    {
        var devicetoken = strToken
        
        if devicetoken.isEmpty {
            devicetoken = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN) ?? ""
        }
        guard !devicetoken.isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.tokenRefreshNotification()
            }
            return
        }
        var dicts = JSON()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        dicts["device_id"] = String(format:"%@",strToken)
        self.apiInteractor?
            .getRequest(
                for: APIEnums.updateDeviceToken,
                params: dicts
        ).responseJSON({ (json) in
            if !json.isSuccess{
                self.tokenRefreshNotification()
            }
        }).responseFailure({ (error) in
            self.tokenRefreshNotification()
        })
 
    }
    func updateLanguage () {
        let token = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        
        guard !token.isEmpty else{return}
        var dicts = JSON()
        
        dicts["token"] = token
        dicts["language"] = Language.default.rawValue
        
        self.apiInteractor?
            .getRequest(
                for: APIEnums.updateLanguage,
                params: dicts
        ).responseJSON({ (response) in
            if response.isSuccess{
            }
        }).responseFailure({ (error) in
        })
     
  
        DispatchQueue.main.async {
            StripeHandler.initStripeModule()
        }
    }
    // MARK: - Display Toast Message
    func createToastMessage(_ strMessage:String, bgColor: UIColor = .ThemeMain, textColor: UIColor = .ThemeBgrnd)
    {
        guard let win = UIApplication.shared.keyWindow else {
            return
        }
        let lblMessage = UILabel(frame: CGRect(x: 0, y: (win.frame.size.height)+70, width: win.frame.size.width, height: 70))
        
        lblMessage.tag = 500
        lblMessage.text = YSSupport.isNetworkRechable() ? strMessage : iApp.NewTaxiError.connection.localizedDescription
        lblMessage.textColor = UIColor.Title
        lblMessage.backgroundColor = UIColor.ThemeYellow
        lblMessage.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(15))
        lblMessage.textAlignment = NSTextAlignment.center
        lblMessage.numberOfLines = 0
        lblMessage.layer.shadowColor = UIColor.ThemeMain.cgColor;
        lblMessage.layer.shadowOffset = CGSize(width:0, height:1.0);
        lblMessage.layer.shadowOpacity = 0.5;
        lblMessage.layer.shadowRadius = 1.0;
        
        moveLabelToYposition(lblMessage)
        UIApplication.shared.keyWindow?.addSubview(lblMessage)
    }
    
    func createToastMessageForAlamofire(_ strMessage:String, bgColor: UIColor=UIColor.ThemeMain, textColor: UIColor=UIColor.ThemeBgrnd, forView:UIView)
    {
        let lblMessage=UILabel(frame: CGRect(x: 0, y: (forView.frame.size.height)+70, width: (forView.frame.size.width), height: 70))
        lblMessage.tag = 500
        lblMessage.text = YSSupport.isNetworkRechable() ? NSLocalizedString(strMessage, comment: "") : NSLocalizedString(iApp.NewTaxiError.connection.localizedDescription, comment: "")
        lblMessage.textColor = .Title
        lblMessage.backgroundColor = .ThemeYellow
        lblMessage.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(15))
        lblMessage.textAlignment = NSTextAlignment.center
        lblMessage.numberOfLines = 0
        lblMessage.layer.shadowColor = UIColor.ThemeYellow.cgColor;
        lblMessage.layer.shadowOffset = CGSize(width:0, height:1.0);
        lblMessage.layer.shadowOpacity = 0.5;
        lblMessage.layer.shadowRadius = 1.0;
        
        downTheToast(lblView: lblMessage, forView: forView)
        UIApplication.shared.keyWindow?.addSubview(lblMessage)
    }
    
    func downTheToast(lblView:UILabel, forView:UIView) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            lblView.frame = CGRect(x: 0, y: (forView.frame.size.height)-70, width: (forView.frame.size.width), height: 70)
        }, completion: { (finished: Bool) -> Void in
            self.closeTheToast(lblView, forView: forView)
        })
    }
    
    func closeTheToast(_ lblView:UILabel, forView:UIView)
    {
        UIView.animate(withDuration: 0.3, delay: 3.5, options: UIView.AnimationOptions(), animations: { () -> Void in
            lblView.frame = CGRect(x: 0, y: (forView.frame.size.height)+70, width: (forView.frame.size.width), height: 70)
        }, completion: { (finished: Bool) -> Void in
            lblView.removeFromSuperview()
        })
    }
    
    // MARK: - Show the Animation
    func moveLabelToYposition(_ lblView:UILabel)
    {
        guard let win = UIApplication.shared.keyWindow else {
            return
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            lblView.frame = CGRect(x: 0, y: (win.frame.size.height)-70, width: win.frame.size.width, height: 70)
        }, completion: { (finished: Bool) -> Void in
            self.onCloseAnimation(lblView)
        })
    }
    // MARK: - close the Animation
    func onCloseAnimation(_ lblView:UILabel)
    {
        guard let win = UIApplication.shared.keyWindow else {
            return
        }
        UIView.animate(withDuration: 0.3, delay: 3.5, options: UIView.AnimationOptions(), animations: { () -> Void in
            lblView.frame = CGRect(x: 0, y: (win.frame.size.height)+70, width: (win.frame.size.width), height: 70)
        }, completion: { (finished: Bool) -> Void in
            lblView.removeFromSuperview()
        })
    }
    func route2DriverInfo(WithInfo infos : NSDictionary){
        let dictTemp = infos["accept_request"] as! NSDictionary
        let tripID = Int(UberSupport()
            .checkParamTypes(params:dictTemp, keys:"trip_id") as String)
            ?? 0
        guard tripID != UserDefaults.value(for: .current_trip_id) else {return}
        let info: [AnyHashable: Any] = [
            "trip_id" : UberSupport().checkParamTypes(params:dictTemp, keys:"trip_id"),
            "arrival_time" : UberSupport().checkParamTypes(params:dictTemp, keys:"arrival_time"),
            "car_name" : UberSupport().checkParamTypes(params:dictTemp, keys:"car_name"),
            "driver_name" : UberSupport().checkParamTypes(params:dictTemp, keys:"driver_name"),
            "drop_location" : UberSupport().checkParamTypes(params:dictTemp, keys:"drop_location"),
            "pickup_location" : UberSupport().checkParamTypes(params:dictTemp, keys:"pickup_location"),
            "rating" : UberSupport().checkParamTypes(params:dictTemp, keys:"rating"),
            "vehicle_name" : UberSupport().checkParamTypes(params:dictTemp, keys:"vehicle_name"),
            "vehicle_number" : UberSupport().checkParamTypes(params:dictTemp, keys:"vehicle_number"),
            "trip_status" : UberSupport().checkParamTypes(params:dictTemp, keys:"trip_status"),
            "mobile_number" : UberSupport().checkParamTypes(params:dictTemp, keys:"mobile_number"),
            "driver_thumb_image" : UberSupport().checkParamTypes(params:dictTemp, keys:"driver_thumb_image"),
            "driver_latitude" : UberSupport().checkParamTypes(params:dictTemp, keys:"driver_latitude"),
            "driver_longitude" : UberSupport().checkParamTypes(params:dictTemp, keys:"driver_longitude"),
            "drop_latitude" : UberSupport().checkParamTypes(params:dictTemp, keys:"drop_latitude"),
            "drop_longitude" : UberSupport().checkParamTypes(params:dictTemp, keys:"drop_longitude"),
            "pickup_latitude" : UberSupport().checkParamTypes(params:dictTemp, keys:"pickup_latitude"),
            "pickup_longitude" : UberSupport().checkParamTypes(params:dictTemp, keys:"pickup_longitude"),
            "type" : "accept_request"
        ]
        //Trying to fetch navigation controller
           if let window = UIApplication.shared.keyWindow,
                let root = window.rootViewController,
                let nav = root as? UINavigationController,
                let dictTemp = infos["accept_request"] as? JSON{
            
            
            let routeVC = RouteVC.initWithStory()
            let tripDetail = TripDetailDataModel(dictTemp)
            routeVC.tripDetailModel = tripDetail
            routeVC.tripID = tripDetail.id
            routeVC.tripStatus = tripDetail.status
            routeVC.bookingType = tripDetail.bookingType
            nav.popToRootViewController(animated: false)
            nav.pushViewController(routeVC, animated: true)
           }else{//Can't fetch navigation, so send push notification to main screen
      
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.RequestAccepted.rawValue), object: self, userInfo: info)
        }
    }
    
    var isDriverInfoPresent: Bool{
        
        if let window = UIApplication.shared.keyWindow,
            let root = window.rootViewController,
            let nav = root as? UINavigationController{
            for child in nav.children{
                if child is RouteVC{
                    return true
                }
            }
        }
        return false
    }
    
//    func route2DriverInfo(withId id : String){
//        
//        let routeVC = RouteVC.initWithStory()
//        routeVC.tripDetailModel = TripDetailDataModel(tripID: Int(id) ?? 0)
//        if let window = UIApplication.shared.keyWindow,
//            let root = window.rootViewController,
//            let nav = root as? UINavigationController{
//            nav.popToRootViewController(animated: false)
//            nav.pushViewController(routeVC, animated: true)
//            
//        }else{
//            self.showMapView()
//            self.route2DriverInfo(withId: id)
//        }
//    }
}


//MARK:- Background task
extension AppDelegate{
    
    fileprivate func terminateBackgroundThread() {
        print("Background task ended.")
        guard backGroundThread != .invalid else{return}
        UIApplication.shared.endBackgroundTask(backGroundThread)
        self.backGroundThread = .invalid
    }
    
}
extension AppDelegate{
    static var shared : AppDelegate{
        return UIApplication.shared.delegate as! AppDelegate
    }
}
