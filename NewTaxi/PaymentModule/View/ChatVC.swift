//
//  ChatVC.swift
// NewTaxi
//
//  Created by Seentechs on 07/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatVC: UIViewController ,ChatViewProtocol,APIViewProtocol,UITextFieldDelegate{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        debug(print:API.rawValue)
    }
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    //MARK: Protocol implementation
    var chatInteractor: ChatInteractorProtocol?
    
    var messages: [ChatModel] = [ChatModel]()
    
    var firstTime : Bool = true
    let preference = UserDefaults.standard
    func setChats(_ message: [ChatModel]) {
        self.messages = message
        if self.firstTime{
            self.chatTableView.springReloadData()
            self.firstTime = false
        }else{
            self.chatTableView.reloadData()
        }
        let count = self.messages.count - 1
        if count >= 0{
            self.chatTableView.scrollToRow(at: IndexPath(row: count, section: 0),
                                           at: .bottom,
                                           animated: true)
        }
        
    }
    
    //MARK: Outlets
    @IBOutlet weak var riderAvatar : UIImageView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var driverName : UILabel!
    @IBOutlet weak var driverRating : UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var separateview: UIView!
    @IBOutlet weak var chatPlaceholder: UIView!
    @IBOutlet weak var noChatMessage: UILabel!
    
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var bottomChatBar: UIView!
    //MARK: Actions
    @IBAction func BackAct(_ sender: UIButton) {
        Shared.instance.chatVcisActive = false
        self.navigationController?.popViewController(animated: true)
        Self.currentTripID = nil
      
      
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let msg = self.messageTextField.text,!msg.isEmpty else{return}
        
        //to send push notification
//        let driverID : Int? = UserDefaults.value(for: .driver_user_id)
        var param = ["receiver_id": self.driverId.description,
                     "message":msg]
        if let tripId : Int = UserDefaults.value(for: .current_trip_id){
            param["trip_id"] = tripId.description
        }
//        self.apiInteractor?
//            .getResponse(forAPI: .sendMessage,
//                         params: param)
//            .shouldLoad(false)
        self.apiInteractor?
            .getRequest(for: .sendMessage,params: param)
            .responseJSON({ (json) in
                if json.isSuccess{
                    print(json.status_message)
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
            })

        
        //to fire base
        let chat = ChatModel(message: msg, type: .rider)
        ChatInteractor.instance.append(message: chat)
        if self.messages.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                ChatInteractor.instance.getAllChats(ForView : self, AndObserve: true)
            }
        }
        
        self.messageTextField.text = String()
    }
    
    var driverImage : UIImage?

    //var drivername = "Driver".localize
   
    static var currentTripID : String? = nil
    var drivername = String()

    var rating = 0.0
    var driverId : Int!
    lazy var langugage = Language.default.object

    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.elevate(10)
        self.riderAvatar.elevate(4)
        self.apiInteractor = APIInteractor(self)
        self.initLanguage()
        self.initView()
        self.messageTextField.delegate = self
        self.initGesture()
        self.initPipeLines()


    }
    override func viewWillAppear(_ animated: Bool) {
        ChatInteractor.instance.getAllChats(ForView : self, AndObserve: true)
        if self.shouldCloseOnWillApperar{
            self.shouldCloseOnWillApperar = false
            self.BackAct(self.backBtn)
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Shared.instance.needToShowChatVC = false
        Shared.instance.chatVcisActive = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Shared.instance.chatVcisActive = false
    }
    //MARK: initailalizer
    func initView(){
        self.arrowImg.image = self.arrowImg.image?.withRenderingMode(.alwaysTemplate)
        self.arrowImg.tintColor = .ThemeYellow
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        if self.language.isRTLLanguage(){
            self.sendBtn.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.arrowImg.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }else{
            self.sendBtn.transform = .identity
        }
      // self.chatTableView.isElevated = true
        //Set Image
        if let dImage = self.driverImage{
            self.riderAvatar.image = dImage
        }else if let thumb_str = preference.string(forKey: TRIP_DRIVER_THUMB_URL),
            let thumb_url = URL(string: thumb_str) {
            self.riderAvatar.sd_setImage(with: thumb_url)
        }else{
            self.riderAvatar.image = UIImage(named: "user_dummy.png") ?? UIImage()
        }
        
        //Set name
//        if !self.drivername.isEmpty && self.drivername != "Driver".localize{
          if !self.drivername.isEmpty && self.drivername != self.language.driver{
            self.driverName.text = self.drivername
          }else if let name = preference.string(forKey: TRIP_DRIVER_NAME){
            self.driverName.text = name
          }else{            self.driverName.text = self.language.driver
         }
       
        //Set Rating
        if rating != 0.0{
            self.driverRating.isHidden = false
           // self.driverRating.text = "\(rating)⭑"
            let textAtt =  NSMutableAttributedString(string: "\(rating)★")
            textAtt.setColorForText(textToFind: "★", withColor: .ThemeYellow)
            textAtt.setColorForText(textToFind: "\(rating)", withColor: .Title)
            driverRating.attributedText = textAtt
            
        }else if let str_Rating = preference.string(forKey: TRIP_DRIVER_RATING),
            let _rating = Double(str_Rating),
            _rating != 0.0{
            self.rating = _rating
            self.driverRating.isHidden = false
            let textAtt =  NSMutableAttributedString(string: "\(rating)★")
            textAtt.setColorForText(textToFind: "★", withColor: .ThemeYellow)
            textAtt.setColorForText(textToFind: "\(rating)", withColor: .Title)
            driverRating.attributedText = textAtt
        }else{
            self.driverRating.isHidden = true
        }
        if rating == 0.0{
            self.driverRating.isHidden = true
        }else{
            self.driverRating.isHidden = false
            let textAtt =  NSMutableAttributedString(string: "\(rating)★")
            textAtt.setColorForText(textToFind: "★", withColor: .ThemeYellow)
            textAtt.setColorForText(textToFind: "\(rating)", withColor: .Title)
            driverRating.attributedText = textAtt
        }
        self.messageTextField.autocorrectionType = .no
        self.riderAvatar.cornerRadius = 6
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        
//        self.messageTextField.placeholder =  "Type a message...".localize
//        self.noChatMessage.text = "No messages, yet.".localize
        self.messageTextField.placeholder =  self.language.typeMessage
        self.noChatMessage.text = self.language.noMsgYet
        
        
        
        self.bottomChatBar.isRoundCorner = true
        self.bottomChatBar.border(0.5, .gray)
        
        self.bottomChatBar.elevate(2.0)
        self.chatTableView.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func initPipeLines(){
        _ = PipeLine.createEvent(withName: "CHAT_OBSERVER") {
            ChatInteractor.instance.getAllChats(ForView : self, AndObserve: true)
        }
    }
    func initLanguage(){
        if self.drivername.isEmpty{
            self.drivername = self.language.driver.capitalized
        }
    }
    var chatTableRect : CGRect!
    var isKeyboardOpen = false
    func initGesture(){
        self.chatTableView.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        self.view.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        self.bottomChatBar.addAction(for: .tap) {
            
        }
        self.chatTableRect = self.chatTableView.frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.chatTableRect = self.chatTableView.frame
        }
       
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShowning), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHidded), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.driverCancelledTrip), name: NSNotification.Name(rawValue: NotificationTypeEnum.cancel_trip.rawValue), object: nil)
        
        
    }
    @objc func KeyboardShowning(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
 
        UIView.animate(withDuration: 0.15) {
            let height = -keyboardFrame.height + (self.isDeviceHasBottomBar() ? 35 : 0)
            self.bottomChatBar.transform = CGAffineTransform(translationX: 0, y: height)
            
            var contentInsets:UIEdgeInsets
            
            if( UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait) {
                
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0);
            }
            else {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.width, right: 0.0);
                
            }
            self.chatTableView.contentInset = contentInsets
            
            let count = self.messages.count - 1
            if count > 0{
                self.chatTableView.scrollToRow(at: IndexPath(row: count, section: 0),
                                               at: .bottom,
                                               animated: true)
            }
            self.view.layoutIfNeeded()
        }
            
        
    }
    //hide the keyboard
    @objc func KeyboardHidded(notification: NSNotification)
    {
        UIView.animate(withDuration: 0.15) {
            self.bottomChatBar.transform = .identity
            self.chatTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0);
            let count = self.messages.count - 1
            if count > 0{
                self.chatTableView.scrollToRow(at: IndexPath(row: count, section: 0),
                                               at: .bottom,
                                               animated: true)
            }
            self.view.layoutIfNeeded()
        }
    }
    var shouldCloseOnWillApperar = false
    @objc func driverCancelledTrip(){
        shouldCloseOnWillApperar = true
       self.BackAct(self.backBtn)
    }
        
    //MARK: init with story
    class func initWithStory(withTripId trip_id:String,
                             driverRating : Double?,
                             driver_id : Int) -> ChatVC{
        let view : ChatVC = UIStoryboard.jeba.instantiateViewController()
        ChatVC.currentTripID = trip_id
        ChatInteractor.instance.initialize(withTrip: trip_id)
        view.apiInteractor = APIInteractor(view)
        if let _rating = driverRating{
            view.rating = _rating
        }
        view.driverId = driver_id
        view.modalPresentationStyle = .fullScreen
        return view
    }
    
    
}
extension UIViewController {
    func isDeviceHasBottomBar() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136:
                    print("iPhone 5 or 5S or 5C")
                    fallthrough
                case 1334:
                    print("iPhone 6/6S/7/8")
                    fallthrough
                case 1920, 2208:
                    print("iPhone 6+/6S+/7+/8+")
                    return false
                case 2436:
                    print("iPhone X/XS/11 Pro")
                    fallthrough
                case 2688:
                    print("iPhone XS Max/11 Pro Max")
                    fallthrough
                case 1792:
                    print("iPhone XR/ 11 ")
                    return true
                default:
                    print("Unknown")
                    return false
                }
            }
        return false
    }
}
extension ChatVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.messages.count
        if count > 0{
            self.chatTableView.backgroundView = nil
            return count
        } else{
            self.chatTableView.backgroundView = self.chatPlaceholder
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        if message.type == .driver{
            let cell = tableView.dequeueReusableCell(withIdentifier: SenderCell.identifier) as? SenderCell
            cell?.setCell(withMessage: message,avatar: self.riderAvatar.image ?? UIImage(named: "user_dummy.png")! )
            return cell ?? UITableViewCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiverCell.identifier) as? ReceiverCell
            cell?.setCell(withMessage: message)
            return cell ?? UITableViewCell()
        }
    }
    
    
}


//MARK: Cells

class SenderCell : UITableViewCell{
    @IBOutlet weak var messageLbl : UILabel!
    @IBOutlet weak var avatarImage : UIImageView!
    @IBOutlet weak var background : UIView!
    
    static var identifier = "SenderCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.background.isCurvedCorner = true
            self.avatarImage.cornerRadius = 6
            self.background.backgroundColor = .Border
        
    }
    func setCell(withMessage message: ChatModel,avatar : UIImage){
        self.messageLbl.text = message.message
        self.avatarImage.image = avatar
       
    }
}
class ReceiverCell : UITableViewCell{
    @IBOutlet weak var messageLbl : UILabel!
    @IBOutlet weak var background : UIView!
    
    static var identifier = "ReceiverCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.background.isCurvedCorner = true
        self.background.backgroundColor = .ThemeYellow
     
    }
    func setCell(withMessage message: ChatModel){
        self.messageLbl.text = message.message
        
       // dump(message)"76D6FF"
        
    }
    
}
