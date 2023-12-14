//
//  PromotionsVC.swift
// NewTaxi
//
//  Created by Seentechs Technologies on 24/11/17.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class PromotionsVC: UIViewController,UITableViewDelegate, UITableViewDataSource,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var promotbl: UITableView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblTitlePromo: UILabel!
    
    func setDesign() {
        self.lblTitlePromo.textColor = .Title
        self.lblTitlePromo.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.contentView.setSpecificCornersForTop(cornerRadius: 35)
        self.contentView.elevate(4)
        
    }
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    
    lazy var arrPromoData  = [PromoMode]()
    
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var tripModel : PromoMode!
    var code: [String] = []
    var expire_date: [String] = []
    var offer: [String] = []
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.lblTitlePromo.text = self.language.promotions
        self.btnBack.setTitle(self.language.getBackBtnText(), for: .normal)
        self.onPromoCode()
        self.setDesign()
        
    }
    
    // CALL API TO VIEW PROMO CODE
    func onPromoCode()
    {
        var dicts = [AnyHashable: Any]()
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?.getRequest(for: .getPromoDetails)
            .responseDecode(
                to: PromoContainerModel.self,
                { (container) in
                    UberSupport.shared.removeProgressInWindow()
                    self.arrPromoData = container.promos
                    self.promotbl.reloadData()
                }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
                    AppDelegate.shared.createToastMessage(error)
                })
        
    }
    // MARK: When User Press Back Button
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController!.popViewController(animated: true)
    }
    //TABLE VIEW  DATA SOURCE METHODS
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  arrPromoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellPromo = promotbl.dequeueReusableCell(withIdentifier: "CellPromo")! as! CellPromo
        let promoModel = arrPromoData[indexPath.row]
        let amount = promoModel.amount as String
        let code = promoModel.code as String
        let date = promoModel.expire_date as String
        //        cell.lblOffer?.text = "(\(strCurrency)\(amount) \(NSLocalizedString("OFF", comment: ""))"
        cell.lblOffer?.text = "\(strCurrency)\(amount) \(self.language.off)"
        //        cell.lblSubTitle?.text = "(\(NSLocalizedString("Free trip up to", comment: "")) \(strCurrency)\(amount) \(NSLocalizedString("from", comment: "")) \(code))"
        cell.lblSubTitle?.text = "\(self.language.freeTripUpto) \(strCurrency)\(amount) \(self.language.from) \(code)"
        cell.lblOffer?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        cell.lblOffer?.isCurvedCorner = true
        cell.lblDate?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 15)
        cell.lblDate?.textColor = UIColor.Title.withAlphaComponent(0.5)
        cell.lblSubTitle?.textColor = .Title
        cell.lblDate?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        cell.barLbl.backgroundColor = .BorderCell
        cell.lblDate?.text = "\(date)"
        return cell
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    
    
}

class CellPromo : UITableViewCell
{
    @IBOutlet var lblOffer: UILabel?
    @IBOutlet var lblSubTitle: UILabel?
    @IBOutlet var lblDate: UILabel?
    @IBOutlet weak var barLbl: UILabel!
    
}

