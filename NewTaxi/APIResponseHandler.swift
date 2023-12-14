//
//  APIResponseHandler.swift
// NewTaxi
//
//  Created by Seentechs on 31/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation


class APIResponseHandler : APIResponseProtocol{
  
    init(){
    }
    var jsonSeq : Closure<JSON>?
    var dataSeq : Closure<Data>?
    var errorSeq : Closure<String>?
    
    func responseDecode<T>(to modal: T.Type, _ result: @escaping Closure<T>) -> APIResponseProtocol where T : Decodable {
        
        let decoder = JSONDecoder()
        self.dataSeq =  decoder.decode(modal, result: result)
        return self
    }
    
    func responseJSON(_ result: @escaping Closure<JSON>) -> APIResponseProtocol {
        self.jsonSeq = result
        return self
    }
    func responseFailure(_ error: @escaping Closure<String>) {
        self.errorSeq = error
        
      }
      

    

    func handleSuccess(value : Any,data : Data){
        if let jsonEscaping = self.jsonSeq{
            jsonEscaping(value as! JSON)
        }
        if let dataEscaping = dataSeq{
            dataEscaping(data)
            
        }
    }
    func handleFailure(value : String){
        self.errorSeq?(value)
     }
   
}
