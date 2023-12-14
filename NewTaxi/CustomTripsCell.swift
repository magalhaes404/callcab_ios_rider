/**
* CustomTripsCell.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/


import UIKit

class CustomTripsCell: UICollectionViewCell,ProjectCell {
    typealias myCell = CustomTripsCell
    var identifier: String {return "Cell"}
    
    @IBOutlet var imgMapView: UIImageView?
    @IBOutlet var lblTripTime: UILabel?
    @IBOutlet var lblCost: UILabel?
    @IBOutlet var lblCarType: UILabel?
    @IBOutlet var lblTripStatus: UILabel?
    
    var rateYourRiderButton = UIButton()
    lazy var lang = Language.default.object

    func setExploreData(ratingCount : String)
    {
     
    }
    func attachRatingButton(_ attach : Bool){
        self.rateYourRiderButton.removeFromSuperview()
        if attach{
            let additionalWidth : CGFloat = 27
            let reductionHeight : CGFloat = 5
            self.rateYourRiderButton.setTitle(self.lang.rateYourRide, for: .normal)
            self.rateYourRiderButton.titleLabel?.font = self.lblTripStatus?.font
            self.rateYourRiderButton.backgroundColor = .ThemeMain
            self.rateYourRiderButton.layer.cornerRadius = reductionHeight
            self.rateYourRiderButton.clipsToBounds = true
            self.rateYourRiderButton.elevate(1.5)
            
            guard let referenceFrame = self.lblTripStatus?.frame else{return}
            self.rateYourRiderButton.frame = CGRect(x: referenceFrame.minX - additionalWidth,
                                                    y: referenceFrame.minY + reductionHeight,
                                                    width: referenceFrame.width + additionalWidth,
                                                    height: referenceFrame.height)
            
            self.addSubview(self.rateYourRiderButton)
            self.bringSubviewToFront(self.rateYourRiderButton)
        }
        
    }
}
