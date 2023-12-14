//
//  PermissionManager.swift
// NewTaxi
//
//  Created by Seentechs on 16/09/21.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

enum Permissions{
    case allowed
    case denied
    case ignored
    case none
}

protocol PermissionConfiguration
{
    var title : String{get}
    var reason : String{get}
    var getState : Permissions{get}
}
class LocationConfig : PermissionConfiguration {
    
    
    var language : LanguageProtocol
    var title: String
    var reason: String
    var getState: Permissions {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case  .restricted, .denied:
                return .denied
            case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
                return .allowed
                
            }
        } else {
            return .denied
        }
    }
    
    
    init(){
        
        self.language = Language.default.object
        self.title = self.language.locationService
        self.reason = self.language.tracking
    }

}
class MediaConfig : PermissionConfiguration {

    var language : LanguageProtocol
    var title: String {
        
        return "\(self.sourceType == .camera ? "\(self.language.camera.capitalized)" : "\(self.language.photoLibrary.capitalized)") \(self.language.service.capitalized)"
        
    }
    var reason: String
    private var sourceType : UIImagePickerController.SourceType
    var getState: Permissions {
        if sourceType == .camera{
            let cameraMediaType = AVMediaType.video
            let authorization = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
           
            return authorization == .authorized ? .allowed : authorization == .notDetermined ? .allowed : .denied
        }else{
            let authorized = [.notDetermined,.authorized].contains(PHPhotoLibrary.authorizationStatus())
            return authorized ? .allowed : .denied
          
        }
    }
    
    
    init(_ sourceType : UIImagePickerController.SourceType){
        self.sourceType = sourceType

    self.language = Language.default.object
    self.reason = self.language.app.capitalized
    }
}
class MicrophoneConfig : PermissionConfiguration{
    var language : LanguageProtocol
    var title: String
    
    var reason: String
    
    var getState: Permissions{
        switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                return .allowed
            case AVAudioSession.RecordPermission.denied:
                return .denied
            case AVAudioSession.RecordPermission.undetermined:
                return .allowed
            /*AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    return .allowed
                } else {
                    return .denied
                }
            })*/
            default:
                return .denied
        }
    }
    init(){
        
        self.language = Language.default.object

        self.title = self.language.microphoneSerivce
        self.reason = self.language.inAppCall
    }
    
}
class PermissionManager{
    lazy var lanugage : LanguageProtocol = {
         return Language.default.object
     }()
     
    
    let viewController : UIViewController
    let config : PermissionConfiguration
    init(_ view : UIViewController,_ config : PermissionConfiguration){
        self.viewController = view
        self.config = config
    }
    var isEnabled : Bool{
        return self.config.getState == .allowed
    }
    func forceEnableService(){
        if !self.isEnabled{
            self.showSettingsToService()
        }
    }
    private func showSettingsToService(){
        self.viewController.presentAlertWithTitle(title: "\(self.lanugage.pleaseEnable) \(config.title)",
            message: "\(iApp.appName) \(self.lanugage.requires) \(config.title) \(self.lanugage._for) \(config.reason) \(self.lanugage.functionality).",
            options: self.lanugage.ok.capitalized) { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.openURL(settingsUrl)
                    } else {
                        // Fallback on earlier versions
                    }
                }
        }
        
    }
}
