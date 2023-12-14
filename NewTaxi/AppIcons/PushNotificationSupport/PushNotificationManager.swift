//
//  PushNotificationManager.swift
// NewTaxi
//
//  Created by Apple on 03/06/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//


import Foundation
import Firebase
//import FirebaseInstanceID
import FirebaseMessaging
import UIKit
import UserNotifications
import AVFoundation

import FirebaseCore
import FirebaseDatabase

enum NotificationTypeEnum: String, CaseIterable{
    
    
    case EndTrip
    case ArrivedNowOrBeginTrip
    case ArrivedNowOrBeginTrips
    case cancel_trips
    case GotoHomePage1
    case RequestAccepted
    case no_cars
    case GetDriverDetails
    case KilledStateNotification
    case cancel_trip
    case trip_payment
    case ShowHomePage
    case trip_payments
    case phonenochanged
    case GotoHomePage
    
    case accept_request
    case chat_notification
    case arrivenow
    case begintrip
    case end_trip
    case arrive_now
    case custom_message
    case custom
    case sin
    case begin_trip
    case none
    case RefreshInCompleteTrips
    
    init?(fromKeys keys: [String]){
        let cases = NotificationTypeEnum.allCases.compactMap({$0.rawValue})
        guard let key = Array(Set(cases).intersection(Set(keys))).first,
            let enumValue = NotificationTypeEnum(rawValue: key) else{
            return nil
        }
        self = enumValue
        
    }
}


class PushNotificationManager: NSObject,MessagingDelegate{
   //MARK: Remote Notification
//    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
//        print(remoteMessage.appData)
//    }
    

    var application:UIApplication
    static var shared : PushNotificationManager?
    var notificationType:NotificationTypeEnum = .none
    var receivedNotificationIDs = [Int]()
    var receivedLocalNotificationIDs = [Int]()

    var window: UIWindow? {
        return AppDelegate.shared.window
    }
    fileprivate var firebaseReference : DatabaseReference? = nil

    init(_ application:UIApplication) {

        self.application = application
        super.init()
        Messaging.messaging().delegate = self
        FirebaseApp.configure()

//       if #available(iOS 10.0, *) {
//           // For iOS 10 display notification (sent via APNS)
//           UNUserNotificationCenter.current().delegate = self
//           let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//           UNUserNotificationCenter.current().requestAuthorization(
//               options: authOptions,
//               completionHandler: {_, _ in })
//           // For iOS 10 data message (sent via FCM
//
//
//       } else {
//           let settings: UIUserNotificationSettings =
//               UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//           application.registerUserNotificationSettings(settings)
//       }
//       application.registerForRemoteNotifications()
//        self.messaging.delegate = self
        
        Self.shared = self
    }
    fileprivate func updatetoken(_ refreshedToken: String) {
        Constants().STOREVALUE(value: refreshedToken, keyname: USER_DEVICE_TOKEN)
        let userStatus = appDelegate.userDefaults.value(forKey: USER_ACCESS_TOKEN) as? String
        if (userStatus != nil && userStatus != "")
        {
            appDelegate.sendDeviceTokenToServer(strToken: refreshedToken)   // UPDATING DEVICE TOKEN FOR LOGGED IN USER
        }
        else{
            self.tokenRefreshNotification()
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let refreshedToken = fcmToken else {
            return
        }
        
        print("Remote instance ID token: \(refreshedToken)")
        print("InstanceID token: \(String(describing: refreshedToken))")
        updatetoken(refreshedToken)
    }

    // MARK: Register Push notification Class Methods
    func registerForRemoteNotification() {
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: Get Token Refersh
    func tokenRefreshNotification() {
        // NOTE: It can be nil here
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instange ID: \(error)")
//            } else if let result = result {
//                let refreshedToken = result.token
//                print("Remote instance ID token: \(refreshedToken)")
//                print("InstanceID token: \(String(describing: refreshedToken))")
//                Constants().STOREVALUE(value: refreshedToken, keyname: USER_DEVICE_TOKEN)
//                if  !refreshedToken.isEmpty {
//                    AppDelegate.shared.sendDeviceTokenToServer(strToken: refreshedToken)   // UPDATING DEVICE TOKEN FOR LOGGED IN USER
//                }
//                else{
//                    self.tokenRefreshNotification()
//                }
//                self.connectToFcm()
//            }
//        }
        
    }
    // Get FCM Token
    func connectToFcm() {
        
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instange ID: \(error)")
//                return
//            } else if let result = result {
//                print("Remote instance ID token: \(result.token)")
//            }
//        }
//        if Messaging.messaging().isDirectChannelEstablished{
//            print("Connected to FCM.")
//        } else {
//            print("Disconnected from FCM.")
//        }
//
    }
    func getDeviceID(deviceToken: Data){
        Messaging.messaging().apnsToken = deviceToken
        
        
        
        // 1. Convert device token to string
               let tokenParts = deviceToken.map { data -> String in
                   return String(format: "%02.2hhx", data)
               }
               let device = tokenParts.joined()
               // 2. Print device token to use for PNs payloads
               print("Device Token: \(device)")
        
        print("FCM Token \(Messaging.messaging().fcmToken)")
        self.updatetoken(Messaging.messaging().fcmToken ?? "")
    }

    
    func onFetchToken(_ onFetch : @escaping (String?)->Void) {
      
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instange ID: \(error)")
//                return
//            } else if let result = result {
//                onFetch(result.token)
//                print("Remote instance ID token: \(result.token)")
//            }
//        }
    }
    

}

extension PushNotificationManager : UNUserNotificationCenterDelegate {
    // MARK: Converted a String to dictionary format
    
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
// MARK: UNUserNotificationCenter Delegate // >= iOS 10
@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //sinch
    let dict = notification.request.content.userInfo as NSDictionary
    if dict["sin"] != nil {
        debug(print: dict.description)
        completionHandler([])
        return
    }
    if notification.request.identifier == "Local Notification" {
        print("Handling notifications with the Local Notification Identifier")
        completionHandler([.alert,.sound])
        return
    }
//    if let uniqId = dict.value(forKey: "UUID") as? String,
//        uniqId == "CURRENT_CHAT_TRIP_ID"{
    if notification.request.identifier == "Chat Notification" {
        if Shared.instance.chatVcisActive{
            completionHandler([])
        }else{
            completionHandler([.alert,.sound])
        }
        return
    }
    
    let custom = dict[NotificationTypeEnum.custom.rawValue] as Any
    let data = convertStringToDictionary(text: custom as? String ?? String())
    let keys = data?.compactMap({$0.key}) ?? []
    if keys.contains(NotificationTypeEnum.accept_request.rawValue){
        completionHandler([])
    }else if keys.contains(NotificationTypeEnum.custom_message.rawValue){
        //Admin custom_message
        completionHandler([.alert,.sound])
    
    }else if keys.contains(NotificationTypeEnum.chat_notification.rawValue){
        //chat notification
        let subJSON = data?[NotificationTypeEnum.chat_notification.rawValue] as? JSON ?? JSON()
       // completionHandler([.alert,.sound])
        if Shared.instance.chatVcisActive{
            if subJSON.string("trip_id") == ChatVC.currentTripID{
                completionHandler([])
            }else{
                completionHandler([.alert,.sound])
            }
        }else{
            completionHandler([.alert,.sound])
        }
        return
    }else {
        completionHandler([.sound])
    }
    guard let dictionary = data as NSDictionary? else{return}
    self.handlePushNotificaiton(userInfo: dictionary as! JSON)
    
}

@available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let dict = response.notification.request.content.userInfo as NSDictionary
    
    //sinch
    if dict[NotificationTypeEnum.sin.rawValue] != nil{
        CallManager.instance.didReceivePush(notification: response.notification.request.content.userInfo)
        return
    }
        if response.notification.request.identifier == "Local Notification" {
            
            return
        }
//    if let uniqId = dict.value(forKey: "UUID") as? String,
//        uniqId == "CURRENT_CHAT_TRIP_ID"{
        if response.notification.request.identifier == "Chat Notification" {
        //Click action handling
        let tripId : Int = UserDefaults.value(for: .current_trip_id) ?? 0
        let driverID : Int = UserDefaults.value(for: .driver_user_id) ?? 0
//        if ChatInteractor.instance.isInitialized{
            let rating = Double(response.notification.request.content.userInfo["rating"] as? String ?? "0.0")
            let chatVC = ChatVC.initWithStory(withTripId: tripId.description,
                                              driverRating: rating,
                                              driver_id: driverID)
            if let nav = self.window?.rootViewController as? UINavigationController{
                nav.pushViewController(chatVC, animated: true)
            }else if let root = self.window?.rootViewController{
                root.navigationController?.pushViewController(chatVC, animated: true)
            }
//        }else{
//            Shared.instance.needToShowChatVC = true
//        }
        return
    }
    let custom = dict[NotificationTypeEnum.custom.rawValue] as Any
    let data = convertStringToDictionary(text: custom as? String ?? String())
    let dictionary = data! as NSDictionary
        self.handleCommonPushNotification(userInfo: dictionary, generateLocalNotification: false)
    self.handlePushNotificaiton(userInfo: dictionary as! JSON)
    
    completionHandler()
    
    }
    //MARK: HANDLE PUSH NOTIFICATION
    
    func canIHandleThisNotification(userInfo : JSON)-> Bool{
        print("ð Last Notification ID : \(String(describing: self.receivedNotificationIDs))")
        let notificationID = userInfo.int("id")
        print("ð New Notification ID : \(notificationID)")
        guard !self.receivedNotificationIDs.contains(notificationID) else{
            print("Notification \(notificationID) already handled")
            return false
        }
        self.receivedNotificationIDs.append(notificationID)
        return true
    }
    func canIHandleThisLocalNotification(userInfo : JSON)-> Bool{
        print("ð Last Notification ID : \(String(describing: self.receivedLocalNotificationIDs))")
        let notificationID = userInfo.int("id")
        print("ð New Notification ID : \(notificationID)")
        guard !self.receivedLocalNotificationIDs.contains(notificationID) else{
            print("Notification \(notificationID) already handled")
            return false
        }
        self.receivedLocalNotificationIDs.append(notificationID)
        return true
    }
    //MARK: HANDLE PUSH NOTIFICATION
    func handlePushNotificaiton(userInfo: JSON)
    {
//        guard self.canIHandleThisNotification(userInfo: userInfo as! JSON) else{return}
        guard let notification = NotificationTypeEnum(fromKeys: userInfo.compactMap({$0.key})) else{return}
        let valueJSON = userInfo.json(notification.rawValue)
        let notificationTitle = userInfo.string("title")
        let preference = UserDefaults.standard
        print("notification data",userInfo)

        switch notification{
        case .accept_request:
            let jobID = valueJSON.int("job_id")
            UserDefaults.set(jobID, for: .current_job_id)
            Shared.instance.resumeTripHitCount = 0
            Shared.instance.nonessentialdata = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.RequestAccepted.rawValue), object: self, userInfo: nil)

        case .arrive_now:
            let dictTemp = userInfo[NotificationTypeEnum.arrive_now.rawValue] as! NSDictionary
            let info: [AnyHashable: Any] = [
                "trip_id" : UberSupport().checkParamTypes(params:dictTemp, keys:"trip_id"),
                "type" : NotificationTypeEnum.arrivenow.rawValue,
                ]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.ArrivedNowOrBeginTrip.rawValue), object: self, userInfo: info)
        case .begin_trip:
            let dictTemp = userInfo[NotificationTypeEnum.begin_trip.rawValue] as! NSDictionary
            let info: [AnyHashable: Any] = [
                "type" : NotificationTypeEnum.begintrip,
                "trip_id" : UberSupport().checkParamTypes(params:dictTemp, keys:"trip_id"),
                ]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.ArrivedNowOrBeginTrips.rawValue), object: self, userInfo: info)
        case .KilledStateNotification:
            let KilledStateNotification = Notification.Name(rawValue: "KilledStateNotification")
        case .end_trip:
            let dictTemp = userInfo[NotificationTypeEnum.end_trip.rawValue] as! NSDictionary
            let info: [AnyHashable: Any] = [
                "driver_thumb_image" : UberSupport().checkParamTypes(params:dictTemp, keys:"driver_thumb_image"),
                "trip_id" : UberSupport().checkParamTypes(params:dictTemp, keys:"trip_id"),
                ]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationTypeEnum.EndTrip.rawValue), object: self, userInfo: info)
            preference.removeObject(forKey: TRIP_DRIVER_RATING)
            preference.removeObject(forKey: TRIP_DRIVER_NAME)
            preference.removeObject(forKey: TRIP_DRIVER_THUMB_URL)
        case .no_cars:
            let dictTemp = userInfo[NotificationTypeEnum.no_cars.rawValue] as! NSDictionary
            print("No Cars Available",userInfo)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.no_cars.rawValue), object: self, userInfo: nil)
        case .cancel_trip:
            print("cancel_trip data",userInfo)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotificationTypeEnum.cancel_trip.rawValue), object: self, userInfo: nil)
            preference.removeObject(forKey: TRIP_DRIVER_RATING)
            preference.removeObject(forKey: TRIP_DRIVER_NAME)
            preference.removeObject(forKey: TRIP_DRIVER_THUMB_URL)
        case .trip_payment:
            if let paymentData = userInfo[NotificationTypeEnum.trip_payment.rawValue] as? JSON{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationTypeEnum.trip_payment.rawValue), object: self, userInfo: nil)
                PipeLine.fireDataEvent(withName: NotificationTypeEnum.trip_payment.rawValue, data: paymentData)
           
                paymentData.string("driver_thumb_image")
                //status
                //trip_id
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationTypeEnum.trip_payment.rawValue), object: self, userInfo: nil)
                print("Cash Collected",userInfo)
            }
        default:
            print("Not handled \(notification) With value \(valueJSON)")
        }
    }

    /**
     handles only chat notifcaition
     - warning: Dont use this method inside firebase listener
     */
    func handleCommonPushNotification(userInfo: NSDictionary,generateLocalNotification: Bool){
        guard userInfo[NotificationTypeEnum.chat_notification.rawValue] != nil else{return}
        let tripId : Int = (UserDefaults.value(for: .current_trip_id)) ?? 0
        let valueJSON = userInfo[NotificationTypeEnum.chat_notification.rawValue]
        if tripId.description != ChatVC.currentTripID{
            if generateLocalNotification {
                guard self.canIHandleThisNotification(userInfo: userInfo as! JSON) else {return}
                guard self.canIHandleThisLocalNotification(userInfo: userInfo as! JSON) else{return}

                let message = UberSupport().checkParamTypes(params:valueJSON as! NSDictionary, keys:"message_data")
                let title =  UberSupport().checkParamTypes(params:valueJSON as! NSDictionary, keys:"user_name")

                appDelegate.scheduleNotification(title: title as String, message: message as String,json: valueJSON as! JSON)
//                let messageModel = ChatModel.init(message: message as String, type: .rider)
//                self.postLocalNotification(WithChat: messageModel)
            }
            else{
                let json = userInfo[NotificationTypeEnum.chat_notification.rawValue] as? JSON
                let driverID : Int = json?.int("user_id") ?? UserDefaults.value(for: .driver_user_id) ?? 0
                let driverRating : Double? = json?.double("rating")
                let chatVC = ChatVC.initWithStory(withTripId: json?.string("trip_id") ?? tripId.description,
                                                  driverRating: driverRating,
                                                  driver_id: driverID)
                if let nav = self.window?.rootViewController as? UINavigationController{
                    nav.pushViewController(chatVC, animated: true)
                }else if let root = self.window?.rootViewController{
                    root.navigationController?.pushViewController(chatVC, animated: true)
                }
            }
        }else if userInfo[NotificationTypeEnum.custom_message.rawValue] != nil{
            print("custom_message",userInfo)
        }
    }
    func postLocalNotification(WithChat chat: ChatModel,title: String){
//        guard chat.type == .driver else{return}

        let sender_name = UserDefaults.standard.string(forKey: TRIP_DRIVER_NAME) ?? "driver"
      
            let notification = UILocalNotification()
            notification.fireDate = Date(timeIntervalSinceNow: 0)
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.timeZone = NSTimeZone.default
            notification.alertBody = "\(sender_name) :\(chat.message)"
        
            notification.alertAction = "open"
            notification.hasAction = true
            notification.userInfo = ["UUID": "CURRENT_CHAT_TRIP_ID" ]
            UIApplication.shared.scheduleLocalNotification(notification)

//        self.timer?.invalidate()
//        self.timer = nil
    }
}
//MARK:- firebase notification handler
extension PushNotificationManager {
    func startObservingUser(){
        
        self.stopObservingUser()
        guard let userID : String = UserDefaults.value(for: .user_id) else{
            print("userId is missing")
            return
        }
        if let fireListeningKey = self.firebaseReference?.key,
            fireListeningKey == userID{
            print("Already listeneing to \(fireListeningKey)")
            return
        }
        print("Listening to firebase user id \(userID)")
        self.firebaseReference = Database.database().reference()
            .child(iApp.firebaseEnvironment.rawValue)
            .child("Notification")
        .child("\(userID)")
        self.firebaseReference?.observe(.value, with: { (snapShot) in
            guard snapShot.exists() else{return}
            Shared.instance.permissionDenied = false
            //Reomve from firebase after reading the data
            self.firebaseReference?.removeValue()
            let dataStr = snapShot.value as? String
            let dict = self.convertStringToDictionary(text: dataStr  ?? String())
            let custom = dict?[NotificationTypeEnum.custom.rawValue] as Any
            var valueDict = custom as! JSON
            if valueDict["title"] == nil{
                valueDict["title"] = dict?["title"] as? String
            }
            self.handlePushNotificaiton(userInfo: valueDict)
            self.handleCommonPushNotification(userInfo: valueDict as NSDictionary, generateLocalNotification: true)
        }, withCancel: { (Error:Any) in
            Shared.instance.permissionDenied = true
            print("Error is \(Error)") //prints Error is Error Domain=com.firebase Code=1 "Permission Denied"
        })
        
    }
    func stopObservingUser(){
        self.firebaseReference?.removeAllObservers()
        self.firebaseReference = nil
     //   let jeba = Jeba(hhhh: 10, name: 5)
    }
}



class Jeba {
    var name = 0
    var hhhh : Int?
    
//    init(name:Int) {
//        self.name = name
//    }
}

