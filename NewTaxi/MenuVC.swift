//
//  MenuVC.swift
// NewTaxi
//
//  Created by Seentechs on 12/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

protocol MenuResponseProtocol {
    func routeToView(_ view : UIViewController)
    func callAdminForManualBooking()
}

class MenuVC: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
        default:
            print()
        }
    }
    func onFailure(error: String,for API : APIEnums) {
        print(error)
    }
    @IBOutlet weak var sideMenuHolderView : UIView!
    @IBOutlet weak var profileHeaderView : UIView!
    @IBOutlet weak var avatarImage : UIImageView!
    @IBOutlet weak var avatarName : UILabel!
    @IBOutlet weak var helloLbl: UILabel!
    @IBOutlet weak var menuTable : UITableView!
    @IBOutlet weak var bottomView : UIView!
    @IBOutlet weak var driveWithAppLbl : UILabel!
    @IBOutlet weak var driverAppVersionLbl : UILabel!
    var menuItems = [MenuItemModel]()
    var menuDelegate : MenuResponseProtocol?
    lazy var lang = Language.default.object
    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let isRTL = self.lang.isRTLLanguage()
        self.driveWithAppLbl.text = self.lang.driveWith.capitalized + " " + "\(iApp.appName)"
        self.driveWithAppLbl.textAlignment = isRTL ? .right : .left
        self.setprofileInfo()
        self.initView()
        self.initGestures()
        self.initTableDataSources()
        self.setFonts()
    }
    func setFonts()
    {
        self.avatarName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 21)
        self.avatarName.textColor = .ThemeYellow
        self.helloLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 21)
        self.helloLbl.textColor = .Title
        self.driverAppVersionLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.driverAppVersionLbl.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.driveWithAppLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.driveWithAppLbl.textColor = .Title
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showMenu()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
   
    //MARK:- initializers
    func initView(){
//        self.setStatusBarStyle(.lightContent)

        self.menuTable.delegate = self
        self.menuTable.dataSource = self
        self.menuTable.showsVerticalScrollIndicator = false
        self.menuTable.showsHorizontalScrollIndicator = false
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.avatarImage.cornerRadius = 30
        }
        self.driveWithAppLbl.text = self.lang.driveWith+" "+iApp.appName
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String{
            self.driverAppVersionLbl.text = "V " + appVersion
        }
    }
    func initGestures(){
        self.menuTable.addAction(for: .tap) {
        }
        self.sideMenuHolderView.addAction(for: .tap) {
            self.hideMenuAndDismiss()
        }
        self.bottomView.addAction(for: .tap) {
            self.callDriverApp()
        }
        self.profileHeaderView.addAction(for: .tap) {
            let propertyView : EditProfileVC  = UIStoryboard.jeba.instantiateViewController()
            propertyView.delegate = self
            self.menuDelegate?.routeToView(propertyView)
            self.dismiss(animated: false, completion: nil)
        }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleMenuPan(_:)))
        self.sideMenuHolderView.addGestureRecognizer(panGesture)
        self.sideMenuHolderView.isUserInteractionEnabled = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrolling")
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func initTableDataSources(){
        let paymentItem = MenuItemModel(withTitle: self.lang.payment.capitalized, VC: SelectPaymentMethodVC.initWithStory())
        let tripView = TripHistoryVC.initWithStory()   //mainStory.instantiateViewController(withIdentifier: "TripsVC") as! TripsVC
        let listTripsItem = MenuItemModel(withTitle: self.lang.myTrips, VC: tripView)
        let walletItem = MenuItemModel(withTitle: self.lang.wallet, VC: WalletVC.initWithStory())
        let referralItem = MenuItemModel(withTitle: self.lang.referral, VC: ReferalVC.initWithStory())
        let settingsView = SettingsVC.initWithStory()
        settingsView.delegate = self
        let settingItem = MenuItemModel(withTitle: self.lang.settings, VC:settingsView )
        let emergencyContactsView = EmergencyContactViewController.initWithStory()
        let emergencyContactItem  = MenuItemModel(withTitle: self.lang.emergencyContacts, VC: emergencyContactsView)
        let contactAdmin = MenuItemModel(withTitle: self.lang.manualBooking, VC: nil)
        let supportView = SupportVC.initWithStory()
        let supportItem = MenuItemModel(withTitle: self.lang.support, VC:supportView )
        self.menuItems.append(paymentItem)
        self.menuItems.append(listTripsItem)
        self.menuItems.append(walletItem)
        self.menuItems.append(referralItem)
        self.menuItems.append(settingItem)
        self.menuItems.append(emergencyContactItem)
        self.menuItems.append(contactAdmin)
        if Shared.instance.supportArray?.count != 0 {
            self.menuItems.append(supportItem)
        }
        self.menuTable.reloadData()
    }
    //MARK:- initWithStory
    class func initWithStory(_ delegate : MenuResponseProtocol)-> MenuVC{
        let view : MenuVC = UIStoryboard.payment.instantiateViewController()
        view.modalPresentationStyle = .overCurrentContext
        view.menuDelegate = delegate
        return view
    }
    //MARK:- UDF
    func callAdminForManualBooking(){
        guard let number : String = UserDefaults.value(for: .admin_mobile_number) else{return}
        self.presentAlertWithTitle(title: "Dial \(number)",
            message: "Contact admin for manual booking",
            options: "No","Yes") { (index) in
                switch index{
                case 1:
                    UIApplication.shared.openURL(URL(string: "tell://\(number)")!)
                default:
                    break
                }
        }
    }
    func callDriverApp(){
        let instagramUrl = URL(string: "\(iApp.Driver().appName)://")
        if UIApplication.shared.canOpenURL(instagramUrl!)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:"\(iApp.Driver().appName)://")!)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string:"\(iApp.Driver().appName)://")!)
            }
        } else {
            if let url = URL(string: "https://itunes.apple.com/us/app/\(iApp.Driver().appStoreDisplayName)/\(iApp.Driver().appID)?mt=8")
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                    // Fallback on earlier versions
                }
            }
        }
    }
   
    private var animationDuration : Double = 1.0
    private let aniamteionWaitTime : TimeInterval = 0.15
    private let animationVelocity : CGFloat = 5.0
    private let animationDampning : CGFloat = 2.0
    private let viewOpacity : CGFloat = 0.3
    func showMenu(){
        let isRTL = self.lang.isRTLLanguage()
        let rtlValue : CGFloat = isRTL ? 1 : -1
        let width = self.view.frame.width
        self.sideMenuHolderView.transform = CGAffineTransform(translationX: rtlValue * width,
                                                              y: 0)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        while animationDuration > 1.6{
            animationDuration = animationDuration * 0.1
        }
        UIView.animate(withDuration: animationDuration,
                       delay: aniamteionWaitTime,
                       usingSpringWithDamping: animationDampning,
                       initialSpringVelocity: animationVelocity,
                       options: [.curveEaseOut,.allowUserInteraction],
                       animations: {
                        self.sideMenuHolderView.transform = .identity
                        self.view.backgroundColor = UIColor.black.withAlphaComponent(self.viewOpacity)
        }, completion: nil)
    }
    func hideMenuAndDismiss(){
        let isRTL = self.lang.isRTLLanguage()
        let rtlValue : CGFloat = isRTL ? 1 : -1
        let width = self.view.frame.width
        while animationDuration > 1.6{
            animationDuration = animationDuration * 0.1
        }
        UIView.animate(withDuration: animationDuration,
                       delay: aniamteionWaitTime,
                       usingSpringWithDamping: animationDampning,
                       initialSpringVelocity: animationVelocity,
                       options: [.curveEaseOut,.allowUserInteraction],
                       animations: {
                        self.sideMenuHolderView.transform = CGAffineTransform(translationX: width * rtlValue,
                                                                              y: 0)
                        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }) { (val) in
          
            self.dismiss(animated: false, completion: nil)
        }
        
        
    }
    @objc func handleMenuPan(_ gesture : UIPanGestureRecognizer){
        let isRTL = self.lang.isRTLLanguage()
        let rtlValue : CGFloat = isRTL ? 1 : -1
        let translation = gesture.translation(in: self.sideMenuHolderView)
        let xMovement = translation.x
//        guard abs(xMovement) < self.view.frame.width/2 else{return}
        var opacity = viewOpacity * (abs(xMovement * 2)/(self.view.frame.width))
        opacity = (1 - opacity) - (self.viewOpacity * 2)
        print("~opcaity : ",opacity)
        switch gesture.state {
        case .began,.changed:
            guard (isRTL && xMovement > 0) || (!isRTL && xMovement < 0) else {return}
            self.sideMenuHolderView.transform = CGAffineTransform(translationX: xMovement, y: 0)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(opacity)
        default:
            let velocity = gesture.velocity(in: self.sideMenuHolderView).x
            self.animationDuration = Double(velocity)
                if abs(xMovement) <= self.view.frame.width * 0.25{//show
                    self.sideMenuHolderView.transform = .identity
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(self.viewOpacity)
                }else{//hide
                    self.hideMenuAndDismiss()
                }
            
        }
    }
    
}
extension MenuVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:MenuTCell.identifier ) as! MenuTCell
        cell.lblName?.text = self.menuItems[indexPath.row].title
        
        cell.lblName?.textAlignment = self.lang.isRTLLanguage() ? .right : .left
//        cell.setFonts()
        
        cell.contentView.addAction(for: .tap) {
            cell.contentView.backgroundColor = .Background
            cell.contentView.isRoundCorner = true
            self.dismiss(animated: false, completion: {
                let _selectedItem = self.menuItems[indexPath.row]
                if let vc = _selectedItem.viewController{
                    self.menuDelegate?.routeToView(vc)
                }else{
                    self.menuDelegate?.callAdminForManualBooking()
                }
            })
           
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedItem = self.menuItems[indexPath.row]
//        self.hideMenuAndDismiss()
    
//        let selectedCell = menuTable.cellForRow(at: indexPath) as? MenuTCell
//        selectedCell?.contentView.backgroundColor = .systemGray
//        selectedCell?.contentView.isRoundCorner = true
    }
    
}
extension MenuVC : SettingProfileDelegate,EditProfileDelegate{
    //MARK:- SettingProfileDelegate
    func setprofileInfo() {
        self.avatarImage.sd_setImage(with: NSURL(string: Constants().GETVALUE(keyname: USER_IMAGE_THUMB))! as URL, placeholderImage:UIImage(named:""))
        self.avatarName.text = Constants().GETVALUE(keyname: USER_FULL_NAME)
        self.helloLbl.text = "Hello".localize
    }
}

class MenuTCell: UITableViewCell
{
    @IBOutlet var lblName: UILabel!
    static let identifier = "MenuTCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setFonts()
    }
    func setFonts()
    {
        self.lblName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 16)
        self.lblName.textColor = .Title
    }
}
