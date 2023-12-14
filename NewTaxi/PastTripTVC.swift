//
//  PastTripTVC.swift
// NewTaxi
//
//  Created by Seentechs on 16/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
class PastTripTVC: UITableViewCell {
    
    
    @IBOutlet weak var holderView : UIView!
    @IBOutlet weak var statusLbl : UILabel!
    @IBOutlet weak var tripIDLbl : UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var vehicleNameLbl: UILabel!
    @IBOutlet weak var noofseats: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var ratingBtn : UIButton!
    
    @IBOutlet weak var pickUpLbl : UILabel!
    @IBOutlet weak var dropLbl  : UILabel!
    @IBOutlet weak var addressLeadingConstraint : NSLayoutConstraint!
    lazy var language = Language.default.object

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.ratingBtn.backgroundColor = .ThemeMain
        self.ratingBtn.isClippedCorner = true
        self.ratingBtn.isHidden = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.ratingBtn.isHidden = true
        self.mapImageView.image = UIImage(named: "map_static.png")
    }
    class func getNib() -> UINib{
        return UINib(nibName: "PastTripTVC", bundle: nil)
    }
    func populateCell(with trip : TripDataModel){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.attachRatingButton(trip.status == .rating)
        }
        if Language.default.object.isRTLLanguage(){
            self.lblCost.textAlignment = .left
            self.statusLbl.textAlignment = .left
            self.mapImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else{
            self.lblCost.textAlignment = .right
            self.statusLbl.textAlignment = .right
            self.mapImageView.transform = .identity
        }
        self.addressLeadingConstraint.constant = self.contentView.frame.width * 0.2
        self.tripIDLbl.text = self.language.tripID.capitalized + " " + trip.id.description
        self.lblCost.text = trip.currencySymbol + trip.totalFare.description
        self.statusLbl.text = trip.status.localizedValue
        self.vehicleNameLbl.text = trip.carName
      
        if trip.isShareRide == true{
            noofseats.isHidden = false
            noofseats.text =  "\(language.noofseats) " + trip.seats.description
        }
        else{
            noofseats.isHidden = true
        }
        
      //  self.noofseats.text = trip.seats.description
        if trip.mapImage.isEmpty ||
            trip.mapImage.contains("maps/api/staticmap")  ||
            trip.status == .cancelled ||
            trip.status == .manualBookiingCancelled{
              
              self.mapImageView.image = UIImage(named: "active_trip_bg")
              self.mapImageView.contentMode = .scaleAspectFit
              self.pickUpLbl.text = trip.pickupLocation
              self.dropLbl.text = trip.dropLocation
          }else{
              self.mapImageView.sd_setImage(with: URL(string: trip.mapImage))
              self.mapImageView.contentMode = .scaleToFill
              self.pickUpLbl.text = ""
              self.dropLbl.text = ""
          }
//        self.mapImageView.sd_setImage(with:trip.getWorkingMapURL())
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.connectFromToView()
            self.holderView.elevate(0.25)
        }
    }
    func statusLocalization(_ status :TripStatus){
        switch status{
         case .completed:
            self.statusLbl.text = self.language.completedStatus
         case .payment:
            self.statusLbl.text = self.language.paymentStatus
         case .beginTrip:
            self.statusLbl.text = self.language.beginTripStatus
         case .endTrip:
            self.statusLbl.text = self.language.endTripStatus
         case .cancelled:
            self.statusLbl.text = self.language.cancelledStatus
         case .request:
            self.statusLbl.text = self.language.reqStatus
         case .scheduled:
            self.statusLbl.text = self.language.sheduledStatus
        case .pending:
            self.statusLbl.text = self.language.pendingStatus
        default:
            print()
        }
    
    }
    func attachRatingButton(_ attach : Bool){
        self.ratingBtn.setTitle(self.language.rateYourRide, for: .normal)
        self.ratingBtn.isHidden = true//!attach
        
        
    }
    private func connectFromToView(){
    }
    
}
