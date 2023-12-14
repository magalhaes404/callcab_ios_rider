//
//  CallViewController.swift
// NewTaxiDriver
//
//  Created by Seentechs on 11/12/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

import UIKit


class CallViewController: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
        switch response {
//        case .callerDetails(callerName: let name, image: let image):
//            self.callerNameLbl.text = name
//            if let url = URL(string: image){
//                self.callerIV.sd_setImage(with: url, completed: nil)
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
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    
    //MARK:- varaibels
    private var screenMode = ScreenMode.fullScreen
    private var hostWindow : UIWindow?
    weak var delegate : UICallHandlingDelegate?
    
    let micOnIcon = UIImage(named: "mic_on")
    let micOffIcon = UIImage(named : "mic_off")
    
    let speakerOnIcon = UIImage(named: "speaker_on")
    let speakerOffIcon = UIImage(named: "speaker_off")
    var timer : Timer?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initGesture()
        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                          target: self,
                                          selector: #selector(self.updateCallTime),
                                          userInfo: nil,
                                          repeats: true)
        timer?.fire()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //resetting images since same view is called over and over again
        self.mic_IV.image = micOnIcon
        self.speaker_IV.image = speakerOffIcon
        //update view according to call status
        self.updateComponents()
        //get user image and name
        if let callerID = self.delegate?.callerID{
//            self.apiInteractor?.getResponse(forAPI: APIEnums.getCallerDetails,
//                                            params: ["user_id":callerID]).shouldLoad(false)
            self.apiInteractor?
                .getRequest(for: .getCallerDetails,params: ["user_id":callerID])
                .responseJSON({ (json) in
                    if json.isSuccess{
                        let name = json.string("first_name") + " " + json.string("last_name")
                        let image = json.string("profile_image")
                        self.callerNameLbl.text = name
                        if let url = URL(string: image){
                            self.callerIV.sd_setImage(with: url, completed: nil)
                        }
                    }else{
                    }
                }).responseFailure({ (error) in
                })

        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateComponents()
    }
    override func viewDidLayoutSubviews() {

         DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
             self.imageHolderView.isRoundCorner = true
             self.callerIV.isRoundCorner = true
         }
        super.view.layoutIfNeeded()
    }
    
    class func initWithStory(_ delegate : UICallHandlingDelegate) -> CallViewController{
        let callView = CallViewController(nibName: "CallViewController", bundle: nil)
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
                    welf.view.layoutIfNeeded()
                }
            }
        }
        self.declien_IV.addAction(for: .tap) {
            self.delegate?.decline()
        }
        
    }
    func refreshView(){
        
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
        self.view.layoutIfNeeded()
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
            self.speaker_IV.isHidden = true
            self.mic_IV.isHidden = true
            self.answer_IV.isHidden = true
            self.declien_IV.isHidden = true
            switch callDelegate.callState{
            case .ringing:
                self.callDurationLbl.text = self.language.ringing.capitalized
                self.answer_IV.isHidden = true
                self.declien_IV.isHidden = false
            case .inComming:
                self.callDurationLbl.text = ""
                self.answer_IV.isHidden = false
                self.answer_IV.alpha = 1
                self.declien_IV.isHidden = false
            case .inCall:
                // self.callDurationLbl.text = duraiton
                self.speaker_IV.isHidden = false
                self.mic_IV.isHidden = false
                self.answer_IV.isHidden = true
                self.declien_IV.isHidden = false
            case .outGoing:
                self.callDurationLbl.text = self.language.connecting.capitalized
                self.answer_IV.isHidden = true
                self.declien_IV.isHidden = false
                
            default:
                 self.callDurationLbl.text = self.language.connecting.capitalized
                self.answer_IV.alpha = 1
                break
                
            }
        }
    }
    func setScreenMode(to mode : ScreenMode,on window : UIWindow){
        self.screenMode = mode
        let alpha : CGFloat
        if mode == .fullScreen{
            self.view.frame = window.bounds
            alpha = 1
            self.transparentContentView.transform = .identity
            
            self.transparentContentView.elevate(1)
        }else{
            self.view.frame = CGRect(x: 0,
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
//        self.callDurationLbl.alpha = alpha
        self.callDurationLbl.isUserInteractionEnabled = alpha == 1
    }
    func attach(with mode : ScreenMode){
        let window = UIApplication.shared.keyWindow!
        self.hostWindow = window
        self.setScreenMode(to: mode, on: window)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let root = appDelegate.window?.rootViewController{
            self.modalPresentationStyle = .overFullScreen
            root.present(self, animated: true, completion: nil)
        }
    }
    func detach(){
        self.dismiss(animated: true, completion: nil)
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
                        self.view.layoutIfNeeded()
        }) { (completed) in
            
        }
        
    }
}
