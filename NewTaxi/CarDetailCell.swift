/**
 * CarDetailCell.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import UIKit

class CarDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgCarThumb: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblCarName: UILabel!
    @IBOutlet weak var carPoolIV : UIImageView!
    @IBOutlet weak var carPoolLbl : UILabel!

// get the car values from the json value
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.carPoolLbl.backgroundColor = .ThemeYellow
        self.carPoolLbl.textColor = .DarkTitle
        self.carPoolLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
    }
    func setCarInfo(carModel: SearchCarsModel)
    {
        let lang = Language.default.object
        lblTime.text = (carModel.arrcCarLocations.count == 0 || (carModel.min_time == "0")) ? lang.noCabs: String(format:(carModel.min_time == "1") ? "%@ \(lang.min)" : "%@ \(lang.mins)",carModel.min_time)
        print(lblTime.text!)
        let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        lblPrice.text = String(format:"%@ %@",strCurrency,carModel.fare_estimation)
        self.carPoolIV.isHidden = true//!carModel.shareRideEnabled
        self.carPoolLbl.isHidden = !carModel.shareRideEnabled
        self.carPoolLbl.text = lang.pool.capitalized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//            self.carPoolLbl.isRoundCorner = true
            self.carPoolLbl.cornerRadius = 5
            self.carPoolLbl.border(1, .white)
            self.outerView.backgroundColor = .white
            self.outerView.alpha = (carModel.arrcCarLocations.count == 0 || (carModel.min_time == "0")) ? 0.33 : 1
            self.outerView.cornerRadius = 10
            self.outerView.clipsToBounds = true
            self.outerView.elevate(2)
            self.lblPrice.cornerRadius = 6
        }
        self.setFonts()
        
        
    }
    func setFonts()
    {
        self.lblTime.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 10)
        self.lblTime.textColor = .black
        self.lblCarName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.lblCarName.textColor = .black
        self.lblPrice.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 12)
        self.lblPrice.textColor = .Subtitle
        self.lblPrice.backgroundColor = .ThemeYellow
        
    }
}
