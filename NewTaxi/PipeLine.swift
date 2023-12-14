//
//  PipeLine.swift
// NewTaxi
//
//  Created by Seentechs on 31/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

class PipeLine{
    
    private init(){}
    struct Event {
        var id : Int?
        var name : String?
        var action : ()->()
    }
    struct DataEvent {
        var id : Int?
        var name : String?
        var dataAction : (Any?)->()
    }
    private static var events = [Event]()
    private static var dataEvents = [DataEvent]()
    
    static func createEvent(key : PipeLineKey,action : @escaping ()->())->Int{
        return PipeLine.createEvent(withName: key.rawValue, action: action)
    }
    static func createEvent(withName name : String ,action : @escaping ()->()) -> Int{
        PipeLine.events.append(Event(id : PipeLine.events.count,name: name, action: action))
        return PipeLine.events.last?.id ?? -1
    }
    static func fireEvent(withKey key : PipeLineKey) -> Bool{
        return PipeLine.fireEvent(withName: key.rawValue)
    }
    static func fireEvent(withName name : String)-> Bool{
        let _events = PipeLine.events.filter({$0.name == name})
        for event in _events{
            guard event.name != nil else {return false}
            event.action()
        }
        return true
    }
    static func deleteEvent(withName name : String)->Bool{
        let _events = PipeLine.events.filter({$0.name == name})
        for event in _events{
            guard let id = event.id else{return false}
            PipeLine.events.remove(at: id)
        }
        return true
    }
    static func deleteEvent(withID id : Int)->Bool{
        let event = PipeLine.events.filter({$0.id == id}).first
        guard let index = PipeLine.events.index(where: { (_event) -> Bool in
            return _event.id == event?.id
        }) else {return false}
        PipeLine.events.remove(at: index)
        return true
    }
    static func createDataEvent(withName name : String ,dataAction : @escaping (Any?)->()) -> Int{
        PipeLine.dataEvents.append(DataEvent(id : PipeLine.events.count,
                                             name: name,
                                             dataAction: dataAction))
        return PipeLine.dataEvents.last?.id ?? -1
    }
    static func fireDataEvent(withName name : String,data : Any?)-> Bool{
        let _events = PipeLine.dataEvents.filter({$0.name == name})
        for event in _events{
            guard event.name != nil else {return false}
            event.dataAction(data)
        }
        return true
    }
}
