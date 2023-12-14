//
//  WebServiceHandler.swift
//  WeGoo
//
//  Created by Vignesh Palanivel on 09/03/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Alamofire

typealias OnSuccess = ([String: Any])->()
typealias OnFailure = (Error) ->()

class WebServiceHandler: NSObject {

    static var sharedInstance = WebServiceHandler()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

//    func getWebService(wsMethod:String,
//                       paramDict: [String:Any],
//                       viewController:UIViewController,
//                       isToShowProgress:Bool,
//                       isToStopInteraction:Bool,
//                       complete:@escaping (_ response: [String:Any]) -> Void,
//                       didFail : @escaping  OnFailure) {
//
//        if isToShowProgress {
//            UberSupport.shared.showProgressInWindow(showAnimation: true)
//        }
//        else if isToStopInteraction {
//            UIApplication.shared.beginIgnoringInteractionEvents()
//        }
//        var params = Parameters()
//        paramDict.forEach { (key,val) in
//            params[key] = val
//        }
//        AF.request("\(iApp.APIBaseUrl)\(wsMethod)",
//            method: .get,
//            parameters: paramDict)
//            .validate()
//            .responseJSON { response in
//                if isToShowProgress {
//                    UberSupport.shared.removeProgressInWindow()
//                }
//                else {
//                    UIApplication.shared.endIgnoringInteractionEvents()
//                }
//                switch response.result {
//                case .success(let value):
//                    print("Validation Successful")
//                    print(value)
//                    complete(value as! [String : Any])
//                case .failure(let error):
//                    print(error)
//                }
//        }
//    }
    func uploadPost(wsMethod:String, paramDict: [String:Any], fileName:String="image", imgData:Data, viewController:UIViewController, isToShowProgress:Bool, isToStopInteraction:Bool, complete:@escaping (_ response: [String:Any]) -> Void) {

        if isToShowProgress {
            UberSupport().showProgressInWindow(showAnimation: true)
        }
        if isToStopInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }


        print(imgData)
        print(fileName)
        AF.upload(multipartFormData: { (multipartFormData) in
                   let fileName1 =  String(Date().timeIntervalSince1970 * 1000) + "\(fileName).jpg"
                   multipartFormData.append(imgData, withName: fileName,fileName: fileName1, mimeType: "image/jpeg")

                   for (key, value) in paramDict {
                       multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                   } //Optional for extra parameters
               }, to: "\(iApp.APIBaseUrl)\(wsMethod)")
            .responseJSON { (response) in
                if isToShowProgress {
                                       UberSupport().removeProgressInWindow()
                                   }
                                   if isToStopInteraction {
                                       UIApplication.shared.endIgnoringInteractionEvents()
                                   }
                switch response.result{
                case .success(let data):
                    let responseDict = data as? [String : Any] ?? [String:Any]()

//                    guard responseDict["error"] == nil else {
//                        self.appDelegate.createToastMessageForAlamofire(responseDict.string("error"), bgColor: .black, textColor: .white, forView: viewController.view)
//                        return
//                    }

                    guard responseDict.count > 0 else {
                        self.appDelegate.createToastMessageForAlamofire("Image upload failed", bgColor: .ThemeYellow, textColor: .white, forView: viewController.view)
                        return
                    }

                    if (responseDict["status_code"] as! String ) == "0" && ((responseDict["success_message"] as! String) == "Inactive User" || (responseDict["success_message"] as! String) == "The token has been blacklisted" ||  responseDict["success_message"] as! String == "User not found") {
                        //                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "k_LogoutUser"), object: nil)
                    }
                    else {
                        complete(data as? [String : Any] ?? [:])
                    }
                case .failure(let error):
                    print(error)
                    if error._code == 4 {
                        self.appDelegate.createToastMessageForAlamofire("We are having trouble fetching the menu. Please try again.", bgColor: .ThemeYellow, textColor: .white, forView: viewController.view)

                    }
                    else {
                        self.appDelegate.createToastMessageForAlamofire(error.localizedDescription, bgColor: .ThemeYellow, textColor: .white, forView: viewController.view)
                    }
                }
        }


    }

    func getThridPartyWebService(wsMethod:String, paramDict: [String:Any], viewController:UIViewController, isToShowProgress:Bool, isToStopInteraction:Bool, complete:@escaping (_ response: [String:Any]) -> Void) {

        if isToShowProgress {
            UberSupport().showProgressInWindow(showAnimation: true)
        }
        if isToStopInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }

        AF.request("\(wsMethod)", method: .get, parameters: paramDict)
            .validate()
            .responseJSON { response in
                if isToShowProgress {
                     UberSupport().removeProgressInWindow()
                }
                if isToStopInteraction {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                print(response.request?.url!)
                switch response.result {
                case .success(let value):
                    print("Validation Successful")
                    print(value)
                    complete(value as! [String : Any])
                case .failure(let error):
                    print(error)
                    if error._code == 4 {
                        self.appDelegate.createToastMessageForAlamofire("We are having trouble fetching the menu. Please try again.", bgColor: .ThemeYellow, textColor: .white, forView: viewController.view)

                    }
                    else {
                        self.appDelegate.createToastMessageForAlamofire(error.localizedDescription, bgColor: .ThemeYellow, textColor: .white, forView: viewController.view)
                    }
                }
        }
    }
    
}
