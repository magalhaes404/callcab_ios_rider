//
//  CallManagerProtocol.swift
// NewTaxi
//
//  Created by Seentechs on 13/12/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Sinch

protocol CallManagerDelegate {
    /**
     variable to return sinch client is initialized or not
     - Author: Abishek Robin
     */
    var isInitialized : Bool{get}
    /**
     initialize sinch clien for specific client
     - Author: Abishek Robin
     - Parameters:
     - environment: sandbox or live
     - user:  client's user id
     - Warning: throsws reason if can't initialize client
     */
    
    func initialize(environment: CallManager.Environment,for user : String) throws
    /**
     Remove user data from sinch server
     - Author: Abishek Robin
     - Warning: call on logout or the user will not receive calls
     */
    func wipeUserData()
    
    /**
       Stop all call tasks
       - Author: Abishek Robin
       */
    func deinitialize()
    
    /**
        configure weather to receive calls or not
       - Author: Abishek Robin
       - Parameters:
       - waitForCall: should receive call or not
       - Warning: call after initializing client
       */
    func should(waitForCall listent : Bool) throws
    
    /**
        call sinch client with user ID
       - Author: Abishek Robin
       - Parameters:
       - withID: end client userID
       - Warning: call after initializing client
       */
    func callUser(withID id: String) throws
    
    /**
        register to receive push notification if application is not available
       - Author: Abishek Robin
       - Parameters:
       - token: push token
       - app: application
       */
    func registerForPushNotificaiton(token : Data,forApplicaiton app : UIApplication)
    /**
        didReceive push notificaiton fron sinch server for call
       - Author: Abishek Robin
       - Parameters:
       - data: push data
       */
    func didReceivePush(notification data : [AnyHashable : Any])
    /**
     Curren call's state
     - Author: Abishek Robin
     - Returns: active call's state
     */
    var callState : CallManager.CallState {get}
    
    
    var sinchClient : SINClient? {get set}
}
