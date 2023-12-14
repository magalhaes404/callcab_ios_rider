//
//  APIInteractorProtocol.swift
// NewTaxi
//
//  Created by Seentechs on 31/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Alamofire
//MARK:- protocol APIInteractorProtocol
protocol APIInteractorProtocol {
    var apiView : APIViewProtocol{get set}
    
    var isLoading : Bool{get}
    var isFetchingData : Bool{get}
    
     
    func invalidateAllRequest()
    
    func getRequest(forAPI api: String, params : JSON,CacheAttribute: APIEnums) -> APIResponseProtocol
      
    func postRequest(forAPI api: String,
                          params: JSON)
             -> APIResponseProtocol
}
extension APIInteractorProtocol{
    /**
        api handler
        - Author: Abishek Robin
        - Parameters:
        - api: APIEnums
        - Returns: APIResponseProtocol
        */
    func getRequest(for api : APIEnums,params : Parameters )-> APIResponseProtocol{
        if api.method == .get{
            return self.getRequest(forAPI: iApp.APIBaseUrl+api.rawValue, params: params,CacheAttribute: api.cacheAttribute ? api : .none)
        }else{
            return self.postRequest(forAPI: iApp.APIBaseUrl+api.rawValue, params: params)
        }
    }
    
    /**
        api handler
        - Author: Abishek Robin
        - Parameters:
        - api: APIEnums
        - Returns: APIResponseProtocol
        */
    func getRequest(for api : APIEnums)-> APIResponseProtocol{
        return self.getRequest(for: api, params: [:])
    }
}
