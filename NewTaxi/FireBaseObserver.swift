//
//  FireBaseObserver.swift
// NewTaxi
//
//  Created by Seentechs on 04/06/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

enum FireBaseEnvironment : String{
    case live
    case demo
}



enum FireBaseNodeKey : String{
    case rider
    case driver
    case trip
    case trip_chat = "driver_rider_trip_chats"
    case live_tracking
    
    case refresh_payment = "refresh_payment_screen"
    case _polyline_path = "path"
    case _eta_min = "eta_min"
    
    
    func ref() -> DatabaseReference{
        return Database.database()
            .reference()
            .child(iApp.firebaseEnvironment.rawValue)
            .child(self.rawValue)
    }
    func ref(forID : String) -> DatabaseReference{
        return self.ref()
            .child(forID)
    }
    func setValue(_ json : JSON){
        self.ref().setValue(json) { (error, dataRef) in
            
        }
    }
    func getReference(for keyPath : String...) -> DatabaseReference{
        var reference = self.ref()
        for path in keyPath{
            guard path != nil && path != "" else { return reference}
            reference = reference.child(path)
        }
        return reference
    }
    func setValue(_ value : Any,for keyPath : String...){
        var reference = self.ref()
        for path in keyPath{
            reference = reference.child(path)
        }
        reference.setValue(value)
    }
    func removeObject(for keyPath : String...){
        var reference = self.ref()
        for path in keyPath{
            reference = reference.child(path)
        }
        reference.removeValue()
    }
    func addObserver(_ event : DataEventType,for keyPath : String...,response :@escaping (DataSnapshot)->()){
        
        var reference = self.ref()
        for path in keyPath{
            reference = reference.child(path)
        }
        
        reference.observe(event) { (snapshot) in
            response(snapshot)
        }
    }
}

