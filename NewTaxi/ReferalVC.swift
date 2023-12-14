//
//  ReferalVC.swift
// NewTaxi
//
//  Created by Seentechs on 27/03/19.
//  Copyright Â© 2021 Seen Technologies. All rights reserved.
//

import UIKit

class ReferalVC: UIViewController,APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    lazy var lang = Language.default.object

    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch response{
//        case .onReferalSuccess(referal: let referal,
//                               totalEarning: let totalEarning,
//                               maxReferal: let maxReferal,
//                               incomplete: let incomplete,
//                               complete: let complete,
//                               appLink: let appRefLink):
//            self.referalCode = referal
//            self.appLink = appRefLink
//            self.referealTextLBL.text = self.referalCode
//            self.totalEarning = totalEarning.description
//            self.maxReferal = maxReferal.description
//            self.referalDescription.text = self.language.getUpto + " \(maxReferal) " + self.language.everyFriendRides + " \(iApp.appName)"
//            self.inCompleteReferals = incomplete
//            self.completedReferals = complete
//            self.referalTable.springReloadData()
//        case .onReferalFailure:
//            print("refereal failed")
        default:
            print()
        }
    }
    lazy var language : LanguageProtocol = {
           return Language.default.object
       }()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let referalBC = Language.default.object.signUpandGetPaid
    @IBOutlet weak var separateview: UIView!
    @IBOutlet weak var navView : UIView!
    @IBOutlet weak var headerView : UIView!
    @IBOutlet weak var shareBtn : UIButton!
    @IBOutlet weak var referalHolderView : UIView!
    @IBOutlet weak var referalDescription : UILabel!
    @IBOutlet weak var urRefcodeLbl : UILabel!
    @IBOutlet weak var pageTitle : UILabel!
    @IBOutlet weak var referealTextLBL : UILabel!
    @IBOutlet weak var referalTable : UITableView!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    var referalCode = String()
    var totalEarning = String()
    var maxReferal = String()
    var appLink = String()
    lazy var referalSections = [ReferalType]()
    lazy var completedReferals = [ReferalModel]()
    lazy var inCompleteReferals = [ReferalModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setfonts()
        self.apiInteractor = APIInteractor(self)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
//        self.apiInteractor?.getResponse(for: .getReferals).shouldLoad(true)
        self.separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.separateview.elevate(10)
        self.initView()
        self.initGestures()
        self.headerView.cornerRadius = 25
        self.headerView.elevate(6)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.apiInteractor?.getResponse(for: .getReferals).shouldLoad(true)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getReferals)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let referalCode = json.string("referral_code")
                    let refAppLink = json.string("referral_link")
                    let total_earning = json.string("total_earning")
                    let max_referal = json.string("referral_amount")
                    self.maxReferal = max_referal
                    self.totalEarning = total_earning
                    let inCompleteReferals = json.array("pending_referrals")
                        .compactMap({ReferalModel.init(withJSON: $0)})
                    let completedReferals = json.array("completed_referrals")
                        .compactMap({ReferalModel.init(withJSON: $0)})
                    self.referalCode = referalCode
                    self.appLink = refAppLink
                    self.referealTextLBL.text = self.referalCode
                    
                    self.referalDescription.text = self.language.getUpto + " \(self.maxReferal) " + self.language.everyFriendRides + " \(iApp.appName)"
                    self.inCompleteReferals = inCompleteReferals
                    self.completedReferals = completedReferals
                    self.referalTable.springReloadData()
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                    UberSupport.shared.removeProgressInWindow()

                }
            }).responseFailure({ (error) in
                AppDelegate.shared.createToastMessage(error)
                    UberSupport.shared.removeProgressInWindow()

            })

    }
    //MARK:- initailizers
    
    func initView(){
        self.navView.backgroundColor = .ThemeBgrnd
        self.headerView.backgroundColor = .ThemeBgrnd
        self.pageTitle.text = self.language.referral
        self.urRefcodeLbl.text = self.language.YourReferralCode.capitalized
        self.referalTable.delegate = self
        self.referalTable.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.shareBtn.isClippedCorner = true
            self.headerView.elevate(4)
        }
    }
    func setfonts(){
        self.pageTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.urRefcodeLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 14)
        self.referealTextLBL?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.referalDescription?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 14)
        self.copyBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
    }
    func initGestures(){
        self.referalHolderView.addAction(for: .tap) {[weak self] in
            guard let welf = self else{return}
            UIPasteboard.general.string = welf.referalCode
            welf.appDelegate.createToastMessage((self?.language.refCopytoClip)!)
        }
        self.copyBtn.addAction(for:.tap){[weak self] in
            guard let welf = self else{return}
            UIPasteboard.general.string = welf.referalCode
            welf.appDelegate.createToastMessage((self?.language.refCopytoClip)!)
        }
    }
    //MARK:-
    
    //MARK:-Actions
    @IBAction func backAction(_ sender : UIButton?){
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func shareAction(_ sender : UIButton?){
        let urlString = self.appLink
        guard let url = NSURL(string: urlString) else {return}
        let text = self.language.signUpandGetPaid
            + self.language.useMyReferral
            + " "
            + self.referalCode
            + " "
            + self.language.startJourneyonNewTaxi
            + " "
            + "\(url)"
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.presentInFullScreen(activityViewController, animated: true, completion: nil)
    }
    
    
    //MARK:-
    
    class func initWithStory()->ReferalVC{
        let story = UIStoryboard(name: "jeba", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "ReferalVCID") as! ReferalVC
        vc.apiInteractor = APIInteractor(vc)
        return vc
    }
}

extension ReferalVC : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        self.referalSections.removeAll()
        if !self.inCompleteReferals.isEmpty{
            self.referalSections.append(.inComplete)
        }
        if !self.completedReferals.isEmpty{
            self.referalSections.append(.completed)
        }
     
        
        if self.referalSections.isEmpty && !(self.apiInteractor?.isFetchingData ?? false){
            referalTable.alwaysBounceVertical = false
            let no_referal = UILabel()
            no_referal.text = self.language.noRefYet
            no_referal.font = UIFont(name: self.referealTextLBL.font.familyName,
                                     size: 18)
            no_referal.textColor = .ThemeYellow
            
            no_referal.textAlignment = .center
            self.referalTable.backgroundView = no_referal
            
            return 0
        }else{
            self.referalTable.backgroundView = nil
            referalTable.alwaysBounceVertical = true
            
            return self.referalSections.count
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.view.frame.height * 0.08
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerview = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 15))
        headerview.backgroundColor = .ThemeBgrnd
        let label = UILabel()
        label.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = .ThemeBgrnd
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textAlignment = NSTextAlignment.natural

        headerview.addSubview(label)
        label.anchor(toView: headerview, leading: 15, trailing: -15, top: 0, bottom: 0)

        return headerview
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.referalSections[section] {
        case .inComplete:

            return self.language.friendsInComplete.uppercased()
        case .completed:
            
             return self.language.friendsCompleted.uppercased() + "  " + "(" + self.language.earned + "\(!self.totalEarning.isEmpty ? self.totalEarning : "0")" + ")"
        }
     }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.referalSections[section] {
        case .inComplete:
            return self.inCompleteReferals.count
        case .completed:
            return self.completedReferals.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReferalTCell.identifier) as! ReferalTCell
        cell.setfonts()
        let referal : ReferalModel
        if self.referalSections[indexPath.section] == .inComplete{
            referal = self.inCompleteReferals[indexPath.row]
        }else{
            referal = self.completedReferals[indexPath.row]
        }
        cell.setCell(referal)
        return cell
    }
}
//MARK:- ReferealTCell
class ReferalTCell : UITableViewCell{
    
    @IBOutlet weak var decleadingconstraint: NSLayoutConstraint!
    @IBOutlet weak var alertimage: UIImageView!
    @IBOutlet weak var nameLBL : UILabel!
    @IBOutlet weak var descriptionLBL: UILabel!
    @IBOutlet weak var profileIV : UIImageView!
    @IBOutlet weak var daysLeftBtn : UIButton!
    @IBOutlet weak var holderView : UIView!
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    static let identifier = "ReferalTCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.nameLBL.textAlignment = .natural
        self.descriptionLBL.textAlignment = .natural
    }
    func setfonts(){
        self.nameLBL?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.nameLBL.textColor = .Title
        self.descriptionLBL?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.descriptionLBL.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.daysLeftBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
    }
    func setCell(_ referal : ReferalModel){
        self.descriptionLBL.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.nameLBL.text = referal.name
        self.nameLBL?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.profileIV.sd_setImage(with: referal.profile_image_url!)
        self.descriptionLBL.text = referal.getDesciptionText
        self.descriptionLBL?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.daysLeftBtn.isCurvedCorner = true
            self.daysLeftBtn.elevate(0.5)
            self.profileIV.backgroundColor = UIColor.ThemeMain.withAlphaComponent(0.85)
            self.profileIV.cornerRadius = 20
        }
        if iApp.instance.isRTL{
            let text = referal.earnable_amount
            let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
            let editable = text.replacingOccurrences(of:strCurrency, with: "")
            self.daysLeftBtn.setTitle("  \(editable)  " + "\(strCurrency)  ", for: .normal)
        }else{
            self.daysLeftBtn.setTitle("  \(referal.earnable_amount)  ", for: .normal)
        }
        self.daysLeftBtn.isUserInteractionEnabled = false
        if referal.status == .expired{
            self.descriptionLBL.isHidden = false
            self.descriptionLBL.text = self.language.expired
            self.descriptionLBL?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
            self.descriptionLBL.textColor = .ThemeYellow
            self.alertimage.isHidden = false
            self.decleadingconstraint.constant = 5
        }else{
            self.descriptionLBL.isHidden = (referal.remaining_days == 0 || referal.remaining_trips == 0)
            self.alertimage.isHidden = true
            self.decleadingconstraint.constant = 0
        }
        
    }
}
