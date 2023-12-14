//
//  DispatchQueue+extension.swift
// NewTaxi
//
//  Created by Seentechs on 18/02/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

extension DispatchQueue{
    enum Threads {
        case main
        case high
        case veryHigh
        case backGround
        case low
        case unSpecified
        case deFault
        var queue: DispatchQueue {
            switch self {
            case .main:
                return DispatchQueue.main
            case .backGround:
                return DispatchQueue(label: "com.seentechs.newtaxiuser",
                                     qos: .background,
                                     target: nil)
            case .high:
                return DispatchQueue.global(qos: .userInitiated)
            case .veryHigh:
                return DispatchQueue.global(qos: .userInteractive)
            case .low:
                return DispatchQueue.global(qos: .utility)
            case .unSpecified:
                return DispatchQueue.global(qos: .unspecified)
            default:
                return DispatchQueue.global(qos: .default)
            }
        }
    }
    
    static func performSync(on thread : Threads,
                        withDelay delay : DispatchTime = .now(),
                        task : @escaping  ()->()){
        thread.queue.sync {
            task()
        }
    }
    static func performAsync(on thread : Threads,
                        withDelay delay : DispatchTime = .now(),
                        task : @escaping  ()->()){
        thread.queue.asyncAfter(deadline: delay) {
            task()
        }
    }
    static func performAsync(on thread : Threads,
                         withDelay delay : DispatchTime = .now(),
                         task : @escaping  ()->(),
                         onCompleted : @escaping ()->()){
         thread.queue.asyncAfter(deadline: delay) {
             task()
             onCompleted()
         }
     }
}
