//
//  APIInteractor.swift
// NewTaxi
//
//  Created by Seentechs on 08/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//
import Foundation

import Alamofire

enum NewTaxiError : Error{
    case failure(_ reason : String)
}
extension NewTaxiError : LocalizedError{
     
    public var errorDescription : String?{
        let language : LanguageProtocol = Language.default.object
        switch self {
        case .failure(let error):
            return error
        default:
            return language.internalServerError
        }
    }
}
//MARK:- Class
class APIInteractor : APILoadersProtocol{
    var isLoading: Bool
    var isFetchingData: Bool{
        return self.fetchCount != 0
    }
    var handler = LocalCacheHandler()

    var apiView: APIViewProtocol
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var preference = UserDefaults.standard
    let strDeviceType = "1"
    let strDeviceToken = YSSupport.getDeviceToken()
    var support = UberSupport()
    
    private let alamofireManager : Session
    private var fetchCount = 0
    
    init(_ view : APIViewProtocol){
        self.apiView = view
        self.isLoading = false
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300 // seconds
        configuration.timeoutIntervalForResource = 500
        alamofireManager = Session.init(configuration: configuration, serverTrustManager: .none)//Alamofire.SessionManager(configuration: configuration)
        
    }
    
    func shouldLoad(_ shouldLoad: Bool,function : String = #function) {
        debug(print: function)
        if shouldLoad{
//            self.support.showProgressInWindow(showAnimation: true)
            Shared.instance.showLoaderInWindow()
        }else{
            guard function.contains("getResponse(forAPI") else{return}
//            self.support.removeProgressInWindow()
            Shared.instance.removeLoaderInWindow()
        }
        self.isLoading = shouldLoad
        
    }
}
extension APIInteractor : APIInteractorProtocol{
 
    
   
    func networkChecker(with StartTime:Date,
                            EndTime: Date,
                            ContentData: Data?) {
            
            let dataInByte = ContentData?.count
            
            if let dataInByte = dataInByte {
                
                // Standard Values
                let standardMinContentSize : Float = 3
                let standardKbps : Float = 2
                
                // Kb Conversion
                let dataInKb : Float = Float(dataInByte / 1000)
                
                // Time Interval Calculation
                let milSec  = EndTime.timeIntervalSince(StartTime)
                let duration = String(format: "%.01f", milSec)
                let dur: Float = Float(duration) ?? 0
                
                // Kbps Calculation
                let Kbps = dataInKb / dur
                
                if dataInKb > standardMinContentSize {
                    if Kbps < standardKbps {
                        print("å:::: Low Network Kbps : \(Kbps)")
                        self.appDelegate.createToastMessage("LOW NETWORK")
                    } else {
                        print("å:::: Normal NetWork Kbps : \(Kbps)")
                    }
                } else {
                    print("å:::: Small Content : \(Kbps)")
                }
                
            }
        }

    func invalidateAllRequest() {
        self.alamofireManager.session.invalidateAndCancel()
    }
 
    
      
    func postRequest(forAPI api: String, params: JSON) -> APIResponseProtocol {
        let responseHandler = APIResponseHandler()
        var parameters = params
        parameters["token"] = preference.string(forKey: USER_ACCESS_TOKEN)
        parameters["user_type"] = "Rider"
        parameters["device_id"] = strDeviceToken ?? ""
        parameters["device_type"] = strDeviceType
        let starttime = Date()
        alamofireManager.request(api,
                                 method: .post,
                                 parameters: parameters,
                                 encoding: URLEncoding.default,
                                 headers: nil)
            .responseJSON { (response) in
                let endtime = Date()
                self.networkChecker(with: starttime, EndTime: endtime, ContentData: response.data)
                print("Å api : ",response.request?.url ?? ("\(api)\(params)"))
                
                guard response.response?.statusCode != 401 else{//Unauthorized
                    if response.request?.url?.description.contains(iApp.APIBaseUrl) ?? false{
                        self.doLogoutActions()
                    }
                    return
                }
                switch response.result{
                case .success(let value):
                    let json = value as! JSON
                    let error = json.string("error")
                    guard error.isEmpty else{
                        if error == "user_not_found"
                            && response.request?.url?.description.contains(iApp.APIBaseUrl) ?? false{
                            self.doLogoutActions()
                        }
                        return
                    }
                    if json.isSuccess
                        || !api.contains(iApp.APIBaseUrl)
                        || response.response?.statusCode == 200{
                        
                        responseHandler.handleSuccess(value: value,data: response.data ?? Data())
                    }else{
                        responseHandler.handleFailure(value: json.status_message)
                    }
                case .failure(let error):
                    responseHandler.handleFailure(value: error.localizedDescription)
                }
        }
        
        
        return responseHandler
    }
    func getRequest(forAPI api: String, params: JSON,CacheAttribute: APIEnums) -> APIResponseProtocol {
        let responseHandler = APIResponseHandler()
        var parameters = params
        parameters["token"] = preference.string(forKey: USER_ACCESS_TOKEN)
        parameters["user_type"] = "Rider"
        parameters["device_id"] = strDeviceToken ?? ""
        parameters["device_type"] = strDeviceType
        let starttime = Date()

        if parameters["language"] == nil{
            parameters["language"] = Language.default.rawValue
        }
        if CacheAttribute != .none
        {
            if CacheAttribute == .getPastTrips || CacheAttribute == .getUpcomingTrips {
                let page = params["page"] as? Int
                if page == 1 {
                    handler.getData(key: CacheAttribute.rawValue) { (result) in
                        if result.compactMap({$0}).count > 0{
                            responseHandler.handleSuccess(value: (result.first!)?.json ?? JSON(),
                                                          data: (result.first!)?.model ?? Data() )
                        }else{
                                responseHandler.handleFailure(value: "")
                        }
                    }
                }
            }
            else if CacheAttribute == .getTripDetail {
                let tripId = params["trip_id"] as? Int
                let cache = params["cache"] as? Int
                if tripId != 0 && tripId != nil && cache == 1{
                    handler.getData(key: CacheAttribute.rawValue+"\(tripId?.description ?? "")") { (result) in
                        if result.compactMap({$0}).count > 0{
                            responseHandler.handleSuccess(value: (result.first!)?.json ?? JSON(),
                                                          data: (result.first!)?.model ?? Data() )
                        }else{
                                responseHandler.handleFailure(value: "")
                        }
                    }
                }
            }
            else if CacheAttribute == .sos{
                let action = params["action"] as? String
                if action != "" && action != nil && action == "view"{
                    handler.getData(key: CacheAttribute.rawValue) { (result) in
                        if result.compactMap({$0}).count > 0{
                            responseHandler.handleSuccess(value: (result.first!)?.json ?? JSON(),
                                                          data: (result.first!)?.model ?? Data() )
                            
                        }else{
                                responseHandler.handleFailure(value: "")
                        }
                    }
                }
            }
            else{
                handler.getData(key: CacheAttribute.rawValue) { (result) in
                    if result.compactMap({$0}).count > 0{
                        responseHandler.handleSuccess(value: (result.first!)?.json ?? JSON(),
                                                      data: (result.first!)?.model ?? Data() )
                        
                    }else{
                            responseHandler.handleFailure(value: "")
                    }
                }
            }
          

        }
        alamofireManager.request(api,
                                 method: .get,
                                 parameters: parameters,
                                 encoding: URLEncoding.default,
                                 headers: nil)
            .responseJSON { (response) in
                let endtime = Date()
                self.networkChecker(with: starttime, EndTime: endtime, ContentData: response.data)

                print("Å api : ",response.request?.url ?? ("\(api)\(params)"))
                
                guard response.response?.statusCode != 401 else{//Unauthorized
                    if response.request?.url?.description.contains(iApp.APIBaseUrl) ?? false{
                        self.doLogoutActions()
                    }
                    return
                }
                switch response.result{
                case .success(let value):
                    let json = value as! JSON
                    if CacheAttribute != .none
                    {
                        if CacheAttribute == .getPastTrips || CacheAttribute == .getUpcomingTrips {
                           let page = params["page"] as? Int
                           if page == 1 {
                            self.handler.store(data: response.data ?? Data() ,apiName: CacheAttribute.rawValue, json: json)
                           }
                        }else if CacheAttribute == .getTripDetail {
                            let tripId = params["trip_id"] as? Int
                            let cache = params["cache"] as? Int
                            if tripId != 0 && tripId != nil && cache == 1{
                                self.handler.store(data: response.data ?? Data(),apiName: CacheAttribute.rawValue+"\(tripId?.description ?? "")",json: json)
                            }

                        }
                        else{
                            self.handler.store(data: response.data ?? Data(),apiName: CacheAttribute.rawValue,json: json)
                        }
                    }
                    let error = json.string("error")
                    guard error.isEmpty else{
                        if error == "user_not_found"
                            && response.request?.url?.description.contains(iApp.APIBaseUrl) ?? false{
                            self.doLogoutActions()
                        }
                        return
                    }
                    if json.isSuccess
                        || !api.contains(iApp.APIBaseUrl)
                        || response.response?.statusCode == 200{
                        
                        responseHandler.handleSuccess(value: value,data: response.data ?? Data())
                    }else{
                        responseHandler.handleFailure(value: json.status_message)
                    }
                case .failure(let error):
                    responseHandler.handleFailure(value: error.localizedDescription)
                }
        }
        
        
        return responseHandler
    }
}
extension APIInteractor{
    /**
     function that convet json to respective model of parsed API
     - Author: Abishek Robin
     - Parameters:
        - api: APIEnum
        - json: API json data
     - Returns: ResponseEnum
     */
    private func handleResponse(forAPI api : APIEnums, json : JSON)-> ResponseEnum{
        switch api {

        default:
            return ResponseEnum.success
        }
    }
    func doLogoutActions(){
        let handler = LocalCacheHandler()
        handler.removeAll()

        Shared.instance.resetUserData()
        UserDefaults.clearAllKeyValues()
        self.appDelegate.option = ""
        self.appDelegate.amount = ""
        self.appDelegate.showAuthenticationScreen()
        self.appDelegate.pushManager.stopObservingUser()
     
    }

    
}

