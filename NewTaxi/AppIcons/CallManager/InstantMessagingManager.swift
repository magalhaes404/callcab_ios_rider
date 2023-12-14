//
//  InstantMessagingManager.swift
// NewTaxi
//
//  Created by Seentechs on 14/05/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//
/*
import Foundation
import Sinch

class InstantMessagingManager : NSObject{
    let messageClient : SINMessageClient?
    
    override init() {
        self.messageClient = CallManager.instance.sinchClient?.messageClient()
        super.init()
        self.messageClient?.delegate = self
        
    }
    func sendMessage(_ strMessage : String){
        let message = SINOutgoingMessage(recipient: "10046", text: strMessage)
        self.messageClient?.send(message)
    }
}
extension InstantMessagingManager : SINMessageClientDelegate{
    
    func message(_ message: SINMessage!, shouldSendPushNotifications pushPairs: [Any]!) {
        
    }
    func messageClient(_ messageClient: SINMessageClient!, didReceiveIncomingMessage message: SINMessage!) {
        
    }
    func messageSent(_ message: SINMessage!, recipientId: String!) {
        
    }
    func messageDelivered(_ info: SINMessageDeliveryInfo!) {
        
    }
    func messageFailed(_ message: SINMessage!, info messageFailureInfo: SINMessageFailureInfo!) {
        
    }
    
}
*/
