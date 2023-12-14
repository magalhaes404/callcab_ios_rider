//
//  CallView.swift
// NewTaxi
//
//  Created by Seentechs on 28/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

protocol UICallHandlingDelegate : class{
    func decline()
    func accept()
    var callState : CallManager.CallState {get}
    var callerID : String? {get}
    
    var callDuration : String?{get}
    func muteMic(_ mute : Bool)
    func disableLoudSpeaker(_ disable : Bool)
}

class CallView: UIView,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
        switch response {
//        case .callerDetails(callerName: let name, image: let image):
//            self.callerNameLbl.text = name
//            if let url = URL(string: image){
//                self.callerIV.sd_setImage(with: url) { (_, _, _, _) in
//                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
//                        self.imageHolderView.isRoundCorner = true
//                        self.callerIV.isRoundCorner = true
//                    }
//                }
//
//            }
        default:
            break
        }
    }
    
    
    
    enum ScreenMode {
        case fullScreen
        case toast
    }
    
    @IBOutlet weak var imageHolderView : UIView!
    @IBOutlet weak var callerIV : UIImageView!
    @IBOutlet weak var callerNameLbl  :UILabel!
    @IBOutlet weak var callDurationLbl : UILabel!
    
    @IBOutlet weak var headerStackView : UIStackView!
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var transparentContentView : UIVisualEffectView!
    
    @IBOutlet weak var footerView : UIView!
    
    @IBOutlet weak var callResponseStackView : UIStackView!
    
    
    @IBOutlet weak var answer_IV : UIImageView!
    @IBOutlet weak var declien_IV : UIImageView!
    @IBOutlet weak var mic_IV : UIImageView!
    @IBOutlet weak var speaker_IV : UIImageView!
    
    
    
    //MARK:- varaibels
    private var screenMode = ScreenMode.fullScreen
    private var hostWindow : UIWindow?
    weak var delegate : UICallHandlingDelegate?
    
    let micOnIcon = UIImage(named: "mic_on")
    let micOffIcon = UIImage(named : "mic_off")
    
    let speakerOnIcon = UIImage(named: "speaker_on")
    let speakerOffIcon = UIImage(named: "speaker_off")
    var timer : Timer?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initGesture()
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(self.updateCallTime),
                                          userInfo: nil,
                                          repeats: true)
        timer?.fire()
    }
    override func layoutIfNeeded() {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.imageHolderView.isRoundCorner = true
            self.callerIV.isRoundCorner = true
        }
        self.transparentContentView.elevate(self.screenMode != .fullScreen ? 4 : 0)
        
        
        self.transparentContentView.isClippedCorner = self.screenMode != .fullScreen
        
        //        self.backgroundColor = self.screenMode == .fullScreen ? .white : .clear
        self.headerStackView.axis = self.screenMode == .fullScreen ? .vertical : .horizontal
        self.speaker_IV.isHidden = true
        self.mic_IV.isHidden = true
        self.updateComponents()
        self.mic_IV.isClippedCorner = true
        self.speaker_IV.isClippedCorner = true
        
        self.speaker_IV.elevate(4)
        self.mic_IV.elevate(4)
        
        
        self.callResponseStackView.layoutIfNeeded()
        self.footerView.layoutIfNeeded()
        super.layoutIfNeeded()
    }
    class func getView(_ delegate : UICallHandlingDelegate) -> CallView{
        let nib = UINib(nibName: "CallView", bundle: nil)
        let callView = nib.instantiate(withOwner: nil, options: nil).first as! CallView
        callView.delegate = delegate
        callView.apiInteractor = APIInteractor(callView)
        return callView
    }
    
    //MARK:- initializers
    func initGesture(){
        self.contentView.addAction(for: .tap) { [weak self] in
            self?.toggle()
        }
        self.footerView.addAction(for: .tap) {
            
        }
        self.mic_IV.addAction(for: .tap) { [weak self] in
            guard let welf = self else{return}
            let isOn = welf.mic_IV.image == welf.micOnIcon
            welf.mic_IV.image = isOn ? welf.micOffIcon : welf.micOnIcon
            welf.delegate?.muteMic(isOn)
        }
        self.speaker_IV.addAction(for: .tap) { [weak self] in
            guard let welf = self else{return}
            let isOn = welf.speaker_IV.image == welf.speakerOnIcon
            welf.speaker_IV.image = isOn ? welf.speakerOffIcon : welf.speakerOnIcon
            welf.delegate?.disableLoudSpeaker(isOn)
        }
        self.answer_IV.addAction(for: .tap) { [weak self] in
            self?.delegate?.accept()
            guard let welf = self else{return}
            if welf.screenMode != .fullScreen,let window = welf.hostWindow {
                UIView.animate(withDuration: 0.6) {
                    welf.setScreenMode(to: .fullScreen, on: window)
                    welf.layoutIfNeeded()
                }
            }
        }
        self.declien_IV.addAction(for: .tap) {
            self.delegate?.decline()
        }
        
    }
    
    //MARK:- UDF
    @objc func updateCallTime(){
        if let delegate = self.delegate,
            let duration = delegate.callDuration{
            self.callDurationLbl.text = duration
        }
    }
    func updateComponents(){
        if let callDelegate = self.delegate {
            self.answer_IV.alpha = 0
            switch callDelegate.callState{
            case .inComming:
                self.callDurationLbl.text = ""
                self.answer_IV.isHidden = false
                self.answer_IV.alpha = 1
                self.declien_IV.isHidden = false
            case .inCall:
                // self.callDurationLbl.text = duraiton
                self.speaker_IV.isHidden = false
                self.mic_IV.isHidden = false
                fallthrough
            case .outGoing:
                self.callDurationLbl.text = ""
                self.answer_IV.isHidden = true
                self.declien_IV.isHidden = false
                
            default:
                self.answer_IV.alpha = 1
                break
                
            }
            if let callerID = callDelegate.callerID{
//                self.apiInteractor?.getResponse(forAPI: APIEnums.getCallerDetails,
//                                                params: ["user_id":callerID]).shouldLoad(false)
                self.apiInteractor?
                    .getRequest(for: .getCallerDetails,params: ["user_id":callerID])
                    .responseJSON({ (json) in
                        if json.isSuccess{
                            let name = json.string("first_name") + " " + json.string("last_name")
                            let image = json.string("profile_image")
                            self.callerNameLbl.text = name
                            if let url = URL(string: image){
                                self.callerIV.sd_setImage(with: url) { (_, _, _, _) in
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                        self.imageHolderView.isRoundCorner = true
                                        self.callerIV.isRoundCorner = true
                                    }
                                }
                            }

                        }else{
                            AppDelegate.shared.createToastMessage(json.status_message)
                        }
                    }).responseFailure({ (error) in
                        AppDelegate.shared.createToastMessage(error)
                    })

            }
        }
    }
    func setScreenMode(to mode : ScreenMode,on window : UIWindow){
        self.screenMode = mode
        let alpha : CGFloat
        if mode == .fullScreen{
            self.frame = window.bounds
            alpha = 1
            self.transparentContentView.transform = .identity
            
            self.transparentContentView.elevate(1)
        }else{
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: window.frame.width,
                                height: window.frame.height * 0.22)
            alpha = 0
            self.transparentContentView
                .transform = CGAffineTransform(scaleX: 0.95,
                                               y: 0.95)
                    .concatenating(CGAffineTransform(translationX: 0,
                                                     y: 20))
            
            self.transparentContentView.elevate(2)
            
        }
        
        self.mic_IV.alpha = alpha
        self.mic_IV.isUserInteractionEnabled = alpha == 1
        self.speaker_IV.alpha = alpha
        self.speaker_IV.isUserInteractionEnabled = alpha == 1
        self.callDurationLbl.alpha = alpha
        self.callDurationLbl.isUserInteractionEnabled = alpha == 1
    }
    func attach(with mode : ScreenMode){
        let window = UIApplication.shared.keyWindow!
        self.hostWindow = window
        self.setScreenMode(to: mode, on: window)
        window.addSubview(self);
        let direction : CGFloat = mode == .fullScreen ? 1 : -1
        self.transform = CGAffineTransform(translationX: 0, y: direction * window.frame.height)
        UIView.animate(withDuration: 0.6,
                       delay: 0.1,
                       options: .curveEaseInOut,
                       animations: {
                        self.transform = .identity
                        self.layoutIfNeeded()
                        if mode != .fullScreen{
                            self.transform = .identity
                            if mode == .toast{
                                
                                
                                self.transparentContentView
                                    .transform = CGAffineTransform(scaleX: 0.95,
                                                                   y: 0.95)
                                        .concatenating(CGAffineTransform(translationX: 0,
                                                                         y: 20))
                                
                                self.transparentContentView.elevate(2)
                            }else{
                                self.transparentContentView.transform = .identity

                                self.transform = .identity
                                self.contentView.transform = .identity
                                self.transparentContentView.elevate(1)
                            }
                            self.layoutIfNeeded()
                        }
        }) { (completed) in
            if completed && mode == .fullScreen{
                self.transform = .identity
                self.contentView.transform = .identity
                self.transparentContentView.transform = .identity
                self.transform = .identity
            }
        }
    }
    func detach(){
        UIView.animate(withDuration: 0.6,
                       animations: {
                        let mult : CGFloat = self.screenMode == .fullScreen ?  1 : -1
                        self.transform = CGAffineTransform(translationX: 0,
                                                           y: mult * (self.hostWindow?.bounds.height ?? 350))
        }) { (completed) in
            guard completed else{return}
            self.removeFromSuperview()
            self.hostWindow = nil
            self.transform = .identity
            self.transparentContentView.transform = .identity
        }
    }
    func toggle(){
        return
        guard let window = self.hostWindow else{return}
        UIView.animate(withDuration: 0.6,
                       delay: 0.1,
                       options: .curveEaseInOut,
                       animations: {
                        if self.screenMode == .fullScreen{
                            self.setScreenMode(to: .toast, on: window)
                        }else{
                            self.setScreenMode(to: .fullScreen, on: window)
                        }
                        self.layoutIfNeeded()
        }) { (completed) in
            
        }
        
    }
}
