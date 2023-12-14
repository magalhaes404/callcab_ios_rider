//
//  CallManager.swift
// NewTaxi
//
//  Created by Seentechs on 27/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//


import Foundation
import Sinch
import AVFoundation
import AudioToolbox
import MediaPlayer


class CallManager : NSObject {
    lazy var language : LanguageProtocol = {
           return Language.default.object
       }()
    //MARK:- Globals
    enum Environment : String{
        case live = "clientapi.sinch.com"
        case sandbox = "sandbox.sinch.com"
    }
    enum SinchErrors: Error {
        case clientNotInitialized
        case clientNotReadyForCall
        case clientNotReadyForListening
        case keyNotAvailable
        case noCall
    }
    enum CallState {
        case inComming
        case outGoing
        case inCall
        case ringing
        case none
    }
    static let instance : CallManagerDelegate = CallManager()
    //MARK:- SinchVaraibles
    var sinchClient : SINClient?{
        didSet{
            
        }
    }
    var callMaker : SINCallClient?{
        didSet{self.callMaker?.delegate = self}
    }
    var activeCall : SINCall?{
        didSet{self.activeCall?.delegate = self}
    }
    var audioController : SINAudioController?
    
    var pushManager : SINManagedPush?
    
    //MARK:- Varaibles
    var ringTimer : Timer?
    var player: AVAudioPlayer?
    lazy var callVC : CallViewController = .initWithStory(self)
    
    var callEstablishTime : Date?
    
    var pushApplicationData : UIApplication?
    var pushNotiToken : Data?
    var lastNotification : [AnyHashable : Any]?
    
    
    private override init(){
        super.init()
        
    }
}
extension CallManager : CallManagerDelegate {
    
   
    
    
    
    //MARK:- CallManagerDelegate
    
    var isInitialized : Bool{
        return self.sinchClient?.isStarted() ?? false
    }
    func initialize(environment: CallManager.Environment,for user : String) throws{
        //        UserDefaults.set("c9ea329a-d57f-4cb3-b640-a183799ba839", for: .sinch_key)
        //        UserDefaults.set("muqN5Q/zuEeZV9ZqrTTmHg==", for: .sinch_secret_key)
        
        guard self.sinchClient == nil || !(self.sinchClient?.isStarted() ?? false) else{return}
        guard let key : String = UserDefaults.value(for: .sinch_key),
            let secret : String = UserDefaults.value(for: .sinch_secret_key) else{
                throw SinchErrors.keyNotAvailable
        }
        
        self.sinchClient = Sinch.client(withApplicationKey: key,
                                        applicationSecret: secret,
                                        environmentHost: environment.rawValue,
                                        userId: user)
       
        guard self.sinchClient != nil else {throw SinchErrors.clientNotInitialized}
        
        self.audioController = sinchClient?.audioController()
        
        //Call
        self.callMaker = self.sinchClient?.call()
        self.callMaker?.delegate = self
        self.sinchClient?.delegate = self
        self.sinchClient?.setSupportCalling(true)
        
        //Push notification
        self.sinchClient?.unregisterPushNotificationData()
        self.sinchClient?.setSupportPushNotifications(iApp.CanRequestSinchNotification)
        if iApp.CanRequestSinchNotification{
            if let app = self.pushApplicationData,let data = self.pushNotiToken{
                let pushEnvironment : SINAPSEnvironment = iApp.deploymentEnvironment == .live ? .production : .development
                self.sinchClient?.registerPushNotificationDeviceToken(data,
                                                                  type: SINPushTypeRemote,
                                                                  apsEnvironment: pushEnvironment)
                self.pushManager?.application(app,
                                          didRegisterForRemoteNotificationsWithDeviceToken: data)
            }
            self.pushManager = Sinch.managedPush(with: .development)
            self.sinchClient?.enableManagedPushNotifications()
            self.pushManager?.delegate = self
            
        }
        
        self.sinchClient?.start()
    }
    
    
    func wipeUserData() {
        self.activeCall?.hangup()
        self.sinchClient?.terminate()
        
        self.sinchClient?.setSupportCalling(false)
        self.sinchClient?.unregisterPushNotificationData()
        self.sinchClient?.unregisterPushNotificationDeviceToken()
        self.sinchClient?.setSupportPushNotifications(false)
    }
    func deinitialize(){
        self.activeCall?.hangup()
        self.audioController?.stopPlayingSoundFile()
        self.audioController = nil
        self.sinchClient?.terminate()
        self.sinchClient?.setSupportCalling(false)
        self.sinchClient?.delegate = nil
        self.sinchClient = nil
    }
    func should(waitForCall listent : Bool) throws{
        guard let client = self.sinchClient else{throw SinchErrors.clientNotInitialized}
        guard client.isStarted() else{throw SinchErrors.clientNotReadyForListening}
        if listent{
            client.startListeningOnActiveConnection()
            
        }else{
            client.stopListeningOnActiveConnection()
        }
    }
    func callUser(withID id: String) throws {
        debug(print: "Id -> \(id)")
        guard let _ = self.sinchClient else{throw SinchErrors.clientNotReadyForCall}
        guard let call = self.callMaker?.callUser(withId: id) else{throw SinchErrors.noCall}
        
        
        self.activeCall = call
        self.activeCall?.delegate = self//SINCallDelegate
        self.callVC.attach(with: .fullScreen)
        
        self.ringTimer =  Timer.scheduledTimer(timeInterval: 3,
                                               target: self,
                                               selector: #selector(self.doCallAlertSounds),
                                               userInfo: nil,
                                               repeats: true)
        self.ringTimer?.fire()
    }
    func registerForPushNotificaiton(token: Data, forApplicaiton app: UIApplication) {
        self.pushApplicationData = app
        self.pushNotiToken = token
    }
    
    
    func didReceivePush(notification data: [AnyHashable : Any]) {
        debug(print: data.description)
        
        if !self.isInitialized{
            self.lastNotification = data
        }
        self.pushManager?.application(self.pushApplicationData,
                                      didReceiveRemoteNotification: data)
        
    }
    
}
//MARK:- Sinch Client Delegate
extension CallManager : SINClientDelegate{
    func clientDidStart(_ client: SINClient!) {
        debug(print: client.userId)
        if let lastNotificationData = self.lastNotification{
            self.pushManager?.application(self.pushApplicationData,
                                          didReceiveRemoteNotification: lastNotificationData)
            self.lastNotification = nil
        }
        
        do{ try CallManager.instance.should(waitForCall: true)
        }catch let error{debug(print: error.localizedDescription)}
        
        if let firstName : String = UserDefaults.value(for: .first_name){
            self.sinchClient?.setPushNotificationDisplayName(firstName)
        }else{
            self.sinchClient?.setPushNotificationDisplayName("Driver".localize)
        }
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        debug(print: client.userId)
        
    }
    
    func clientDidStop(_ client: SINClient!) {
        debug(print: client.userId)
        
    }
    func client(_ client: SINClient!, requiresRegistrationCredentials registrationCallback: SINClientRegistration!) {
        debug(print: client.userId)
    }
}

//MARK:- OutGoing
extension CallManager : SINCallDelegate{
    /**
     delegate show if the other user is available (Ringing State)
     */
    func callDidProgress(_ call: SINCall!) {
        
        self.callVC.refreshView()
        debug(print: call.callId)
        self.activeCall = call
    }
    
    func callDidEstablish(_ call: SINCall!) {
        let audioPermission = PermissionManager(self.callVC,
                                                MicrophoneConfig())
           
        if !audioPermission.isEnabled {
            audioPermission.forceEnableService()
        }
        AudioServicesPlaySystemSound(1150)//call waiting1257
        self.disableLoudSpeaker(true)
        MPVolumeView.setVolume(1)
        debug(print: call.callId)
        self.callVC.refreshView()
        self.activeCall = call
        self.callEstablishTime = Date()
        self.stopCallAlertSounds()
    }
    func callDidEnd(_ call: SINCall!) {
        AudioServicesPlaySystemSound(1256)//call waiting1257
        self.callEstablishTime = nil
        debug(print: call.callId)
        self.stopCallAlertSounds()

        self.callVC.detach()
        self.activeCall = nil

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        switch call.details.endCause{
        case .denied:
            if call.direction == .outgoing{
                appDelegate?.createToastMessage(self.language.driverBusy)
            }else{
                fallthrough
            }
        default:
            appDelegate?.createToastMessage(self.language.callEnded.capitalized)
        }

        
    }
    
    
    
}
//MARK:- inComming
extension CallManager : SINCallClientDelegate{
    
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        debug(print: call.callId)
        //        self.activeCall = call
        
    }
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        debug(print: call.callId)
        self.activeCall = call
        self.callMaker = client
        
        
        self.ringTimer =  Timer.scheduledTimer(timeInterval: 3,
                                               target: self,
                                               selector: #selector(self.doCallAlertSounds),
                                               userInfo: nil,
                                               repeats: true)
        self.ringTimer?.fire()
        self.callVC.attach(with: .fullScreen)//.toast)
        
        
        
    }
//    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
//        debug(print: call.callId)
//        
//        self.activeCall = call
//        let notification = SINLocalNotification()
//        notification.alertAction = "Answer"
//        notification.alertBody = "Incoming call from Rider"
//        return notification
//    }
    
}
extension CallManager : UICallHandlingDelegate{
    var callerID: String? {
        return self.activeCall?.remoteUserId
    }
    
    var callDuration: String? {
        guard let time = self.callEstablishTime else{return nil}
        var durationStr = String()
        let interval = abs(Int(time.timeIntervalSinceNow))
        let timeStamp : (Int,Int,Int) = (interval / 3600,
                                         (interval % 3600) / 60,
                                         (interval % 3600) % 60)//hr,min,sec
        
        let numberFormatter = NumberFormatter()
        numberFormatter.allowsFloats = false
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.maximumIntegerDigits = 2
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        
        if timeStamp.0 > 0{
            durationStr.append("\(numberFormatter.string(from: NSNumber(value: timeStamp.0)) ?? "00" ) : ")
        }
        durationStr.append("\(numberFormatter.string(from: NSNumber(value: timeStamp.1)) ?? "00" ) : ")
        durationStr.append("\(numberFormatter.string(from: NSNumber(value: timeStamp.2)) ?? "00" )")
        
        return durationStr
    }
    
    
    func accept() {
        self.activeCall?.answer()
        
        self.stopCallAlertSounds()
    }
    func decline() {
        self.stopCallAlertSounds()
        if self.activeCall?.direction == SINCallDirection.incoming {
            self.activeCall?.hangup()
        }else{
            self.activeCall?.hangup()
        }
    }
    var callState: CallManager.CallState{
        guard let call = self.activeCall else {
            debug(print: "cant Determin")
            return .none
        }
        if [SINCallState.progressing].contains(call.state){//progressing
            debug(print: "incall")
            return .ringing
        }else if [SINCallState.established].contains(call.state){//progressing
            debug(print: "incall")
            return .inCall
        }else if call.direction == .incoming{
            debug(print: "incomming")
            return .inComming
        }else{
            debug(print: "Outgoing")
            return .outGoing
        }
        
    }
    
    
}
//MARK:- Push notification
extension CallManager : SINManagedPushDelegate{
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        self.sinchClient?.relayRemotePushNotification(payload)
    }
    
    
}
extension CallManager {
    //MARK:- UDF
    private func playSound(_ fileName: String) {
        let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
            debug(print: fileName)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    @objc func doCallAlertSounds(){
        debug(print: "\(self.activeCall?.direction == SINCallDirection.incoming)")
        guard ![CallManager.CallState.none,.inCall].contains(self.callState) else {return}
        guard self.ringTimer?.isValid ?? false else{return}
//        self.playSound("requestaccept")
        DispatchQueue.main.async {
            if self.activeCall?.direction == SINCallDirection.incoming{
                AudioServicesPlaySystemSound(1304)// call ringing
                AudioServicesPlaySystemSound(1520) // Actuate "Pop" feedback (strong boom) booms)
            }else{
                AudioServicesPlaySystemSound(1154)//call waiting
//                AudioServicesPlaySystemSound(1521) // Actuate "Nope" feedback (series of three weak
            }
        }
    }
    func stopCallAlertSounds(){
        debug(print: "")
        self.player?.stop()
        self.ringTimer?.invalidate()
        self.ringTimer = nil
    }
    func muteMic(_ mute : Bool){
        guard let audioCtrlr = self.audioController else{return}
        if mute{
            audioCtrlr.mute()
        }else{
            audioCtrlr.unmute()
        }
    }
    
    func disableLoudSpeaker(_ disable : Bool){
        let session = AVAudioSession.sharedInstance()
        do{
            if !disable{
//                try session.setCategory(AVAudioSession.Category.playback)
                try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            }else{
//                try session.setCategory(.playAndRecord)
                try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            }
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            
        }catch(let error){
            
            debug(print: error.localizedDescription)
        }
    }
}
/*
 if let call = dict["CALL"] as? [AnyHashable : Any]{
 CallManager.instance.didReceivePush(notification: call)
 return
 }else
 let sender_name = UserDefaults.standard.string(forKey: TRIP_DRIVER_NAME) ?? "Driver".localize
 let customNotification = UILocalNotification()
 customNotification.fireDate = Date(timeIntervalSinceNow: 0)
 customNotification.soundName = UILocalNotificationDefaultSoundName
 customNotification.timeZone = NSTimeZone.default
 customNotification.alertTitle = "\(sender_name) is Calling"
 customNotification.alertBody = "Answer"
 
 customNotification.alertAction = "open"
 customNotification.hasAction = true
 customNotification.userInfo = ["CALL" : notification.request.content.userInfo]
 UIApplication.shared.scheduleLocalNotification(customNotification)
 */
extension MPVolumeView {
  static func setVolume(_ volume: Float) {
    let volumeView = MPVolumeView()
    let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
        slider?.setValue(volume, animated: true)
//      slider?.value = volume
    }
  }
}
