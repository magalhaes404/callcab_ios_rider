/**
* PriceBreakDownVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import Foundation

class PriceBreakDownVC : UIViewController
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var viewObjectHolder: UIView!
    @IBOutlet weak var lblBaseFare: UILabel!
    @IBOutlet weak var lblMinFare: UILabel!
    @IBOutlet weak var lblPerMinFare: UILabel!
    @IBOutlet weak var lblPerKmFare: UILabel!
    @IBOutlet weak var pageTit: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var perMinLbl: UILabel!
    @IBOutlet weak var perKmLbl: UILabel!
    @IBOutlet weak var baseFareLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!

    var carModel : SearchCarsModel!
    lazy var lang = Language.default.object
    
    func setDesign() {
        self.pageTit.textColor = .Title
        self.pageTit.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.descriptionLbl.textColor = UIColor.Title.withAlphaComponent(0.45)
        self.descriptionLbl.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 13)
        
        self.baseFareLbl.textColor = .Title
        self.baseFareLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.lblBaseFare.textColor = .Title
        self.lblBaseFare.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.perKmLbl.textColor = .Title
        self.perKmLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.lblPerKmFare.textColor = .Title
        self.lblPerKmFare.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    
        self.perMinLbl.textColor = .Title
        self.perMinLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.lblPerMinFare.textColor = .Title
        self.lblPerMinFare.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.viewObjectHolder.backgroundColor = .white
        self.viewObjectHolder.setSpecificCornersForTop(cornerRadius: 35)
        self.view.backgroundColor = .white
        self.viewObjectHolder.elevate(4)
    }
 
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.pageTit.text = self.lang.fareBreakDown
        self.descriptionLbl.text = self.lang.descriptionPriceBreak
        self.perKmLbl.text = "+" + self.lang.perKm
        self.perMinLbl.text = "+" + self.lang.perMin
        self.baseFareLbl.text = self.lang.baseFare
        self.backBtn.setTitle(self.lang.getBackBtnText(), for: .normal)
       
        if carModel != nil
        {
            self.setPriceInfo()
        }
        self.setDesign()
    }
    //MARK:- initWithStory
    class func initWithStory(for car : SearchCarsModel) -> PriceBreakDownVC{
        let priceBreakDownVC : PriceBreakDownVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        priceBreakDownVC.carModel = car
        //priceBreakDownVC.view.backgroundColor = UIColor.clear
        priceBreakDownVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        return priceBreakDownVC
    }
    func setPriceInfo()
    {
        let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        lblBaseFare.text = String(format:"%@ %@",strCurrency,carModel.base_fare)
        lblPerMinFare.text = String(format:"%@ %@",strCurrency,carModel.per_min)
        lblPerKmFare.text = String(format:"%@ %@",strCurrency,carModel.per_km)
    }
   
        
    // MARK: SETTING PICKUP TIME TO DELEGATE
    /*
     */
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        dismiss(animated: true, completion: {
        })
    }
}
