//
//  ChatModel.swift
// NewTaxi
//
//  Created by Seentechs on 08/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import UserNotifications

//MARK: chat protocols
protocol ChatInteractorProtocol {
    var trip_id : String{get set}
    var chatRef : DatabaseReference{get}
    func getAllChats(ForView view : ChatViewProtocol?,AndObserve observe: Bool)
    func observeTripChat(_ val : Bool,view : ChatViewProtocol?)
    func append(message : ChatModel)
}
protocol ChatViewProtocol {
    var chatInteractor : ChatInteractorProtocol?{get set}
    var messages : [ChatModel]{get set}
    func setChats(_ message : [ChatModel])
}



//MARK: ChatModel###########################
enum MessageSenderType : String{
    case driver = "driver"
    case rider = "rider"
    
    static func typeFor(string : String) -> MessageSenderType{
        if string.lowercased() == "driver"{
            return .driver
        }else{
            return .rider
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


class ChatModel: Equatable{
    static func == (lhs: ChatModel, rhs: ChatModel) -> Bool {
        return lhs.message == rhs.message
            && lhs.type == rhs.type
            && lhs.key == rhs.key
    }
    
    var message : String
    var type : MessageSenderType
    var key : String
    init(message : String , type : MessageSenderType){
        self.message = message
        self.type =  type
        self.key = ""
    }
    init(snapShot : DataSnapshot){
        self.message = ""
        self.type = .rider
        self.key = ""
        guard let dict = snapShot.value as? NSDictionary else{return}
        if let message = dict.value(forKey: "message") as? String,
            let sender = dict.value(forKey: "type") as? String{
            self.message = message
            self.type = MessageSenderType.typeFor(string: sender)
            self.key = snapShot.key
        }
        
    }
    var getDict : [String:String]{
        return ["message":self.message,
                "type":type.rawValue]
    }
  
}

//MARK: #################ChatInteractor#########################################################

class ChatInteractor : ChatInteractorProtocol{
   
    
    var trip_id: String
    lazy var lang = Language.default.object

    
    internal var chatRef: DatabaseReference
    
    static var instance = ChatInteractor()
    
    var isInitialized = false
    
    //Messages that should not send notifications
    var noNotificaitonMessages : [ChatModel]?
    var timer : Timer?
    private init(){
        self.trip_id = String()
        self.chatRef = FireBaseNodeKey.trip_chat.ref()
        //let _timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(triggerFirebase), userInfo: nil, repeats: true)
        //self.timer = _timer
    }
    //intializing to firebase node with trip id
    func initialize(withTrip tripId : String){
        guard !tripId.isEmpty else{return}
        self.isInitialized = true
        self.trip_id = tripId
        self.chatRef = FireBaseNodeKey.trip_chat.ref(forID: self.trip_id)
        
    }
    //Stop listening to chat and clear all instance
    func deinitialize(){
        if self.isInitialized{
            self.chatRef.removeAllObservers()
            self.chatRef = FireBaseNodeKey.trip_chat.ref()
            self.isInitialized = false
        }
    }
    
    //Remove all listeners to the chat
    func resetListener(){
        self.chatRef.removeAllObservers()
        self.chatRef = FireBaseNodeKey.trip_chat.ref(forID: self.trip_id)
        self.isInitialized = true
    }
    
    //Gettign all converstaion in firebase
    func getAllChats(ForView view: ChatViewProtocol?, AndObserve observe: Bool) {
        //yamini hiding it
        guard self.isInitialized else {return}
        guard observe else{
            self.observeTripChat(false, view: view)//to stop listeing to chat
            return
        }
        self.chatRef.observeSingleEvent(of: .value, with: { (SnapShot) in
            if !SnapShot.exists(){
                self.observeTripChat(true, view: view)
                return
            }
            var messages = [ChatModel]()
            let enumerator = SnapShot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
               
                messages.append(ChatModel.init(snapShot: rest))
            }
            self.noNotificaitonMessages = messages
            if let chatView = view{
                chatView.setChats(messages)
            }
            
            self.observeTripChat(true, view: view)
            
            
        })
         
    }
    
    //Listeninig to firebase converastaions
    internal func observeTripChat(_ val : Bool, view: ChatViewProtocol?) {
        guard isInitialized else{return}
        guard val else{
            self.chatRef.removeAllObservers()
            self.trip_id = String()
            self.chatRef = FireBaseNodeKey.trip_chat.ref()
            return
        }
        self.resetListener()//Reset so other listener will not work
        var messages = view?.messages ?? [ChatModel]()
        self.chatRef.observe(.childAdded, with: { (Snapshot) in
           
            if !Snapshot.exists(){
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
                    self.observeTripChat(true, view: view)
                })
                return
            }

            let message = ChatModel.init(snapShot: Snapshot)
           
            guard !messages.contains(message) else{return}//If message is already obtained do nothing
            messages.append(message)
            if let listeningView = view,
                Shared.instance.chatVcisActive{//has view so send message to view
                
                self.noNotificaitonMessages?.append(message)
                listeningView.setChats(messages)
            }else{//No view connected so send push notification
                self.postLocalNotification(WithChat: message)
            }
        })
    }
    
    //Appending users message to firebase node
    func append(message: ChatModel) {
        guard self.isInitialized else{return}
        self.chatRef.observeSingleEvent(of: .value, with: { (ss) in
            let autoId = self.chatRef.childByAutoId()
              self.chatRef
                          .child(autoId.key ?? "key")
                          .setValue(message.getDict,
                                    withCompletionBlock: { (error, ref) in
                                      print(error)
                                          
                      })
        })
    }
    
    func postLocalNotification(WithChat chat: ChatModel){
        return 
        guard !(self.noNotificaitonMessages?.contains(chat) ?? false) else {return}
        self.noNotificaitonMessages?.append(chat)
        guard chat.type == .driver else{return}

        let sender_name = UserDefaults.standard.string(forKey: TRIP_DRIVER_NAME) ?? lang.driver
      
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
    @objc func triggerFirebase() {
        guard self.noNotificaitonMessages?.isEmpty ?? true else{return}
        guard (!self.trip_id.isEmpty) else{return}
        guard let root = UIApplication.shared.keyWindow?.rootViewController else{
           // self.getAllChats(ForView: nil, AndObserve: true)
            return
        }
        
        if !(root.children.last is ChatVC) {
           // self.getAllChats(ForView: nil, AndObserve: true)
        }
            
        
    }
}
