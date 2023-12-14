//
//  closure.swift
// NewTaxi
//
//  Created by Seentechs on 31/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

typealias Closure<T> = (T)->()

extension JSONDecoder{
    func decode<T : Decodable>(_ model : T.Type,
                               result : @escaping Closure<T>) ->Closure<Data>{
        return { data in
            if let value = try? self.decode(model.self, from: data){
                result(value)
            }
        }
    }
}
