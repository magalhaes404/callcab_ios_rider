//
//  APIResponseProtocol.swift
// NewTaxi
//
//  Created by Seentechs on 31/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
//MARK:- protocol APIResponseProtocol
protocol APIResponseProtocol{
    func responseDecode<T: Decodable>(to modal : T.Type,
                              _ result : @escaping Closure<T>) -> APIResponseProtocol
    func responseJSON(_ result : @escaping Closure<JSON>) -> APIResponseProtocol
    func responseFailure(_ error :@escaping Closure<String>)
}
