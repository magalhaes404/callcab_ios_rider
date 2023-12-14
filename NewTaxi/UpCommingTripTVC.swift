//
//  UpComingTripTVC.swift
// NewTaxi
//
//  Created by Seentechs on 16/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

class UpCommingTripTVC : UITableViewCell{
  
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeAndVehicleNameView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var sourceLocLabel: UILabel!
    @IBOutlet weak var destiLocLabel: UILabel!
    @IBOutlet weak var editTimeButtonOutlet: UIButton!
    @IBOutlet weak var cancelRideButtonOutlet: UIButton!
    lazy var language = Language.default.object
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.editTimeButtonOutlet.setTitle(self.language.editTime, for: .normal)
        self.cancelRideButtonOutlet.setTitle(self.language.cancelRide, for: .normal)
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func statusLocalization(_ status :TripStatus){
    switch status{
     case .completed:
        self.statusLabel.text = self.language.completedStatus
     case .payment:
        self.statusLabel.text = self.language.paymentStatus
     case .beginTrip:
        self.statusLabel.text = self.language.beginTripStatus
     case .endTrip:
        self.statusLabel.text = self.language.endTripStatus
     case .cancelled:
        self.statusLabel.text = self.language.cancelledStatus
     case .request:
        self.statusLabel.text = self.language.reqStatus
     case .scheduled:
        self.statusLabel.text = self.language.sheduledStatus
    case .pending:
        self.statusLabel.text = "\(self.language.pendingStatus)"
    default:
        print()
    }
    }
    func populateCell(with trip : TripDataModel){
       
        self.sourceLocLabel!.text = trip.pickupLocation
        self.destiLocLabel!.text = trip.dropLocation
        self.contentView.addBar(at: .bottom)
        if self.language.isRTLLanguage(){
            self.statusLabel!.text = NSLocalizedString("\(trip.status.rawValue.capitalized)   ", comment: "")
             self.timeLabel!.text = "\(trip.scheduleDisplayTime)"
            self.vehicleNameLabel!.text = "\(self.language.schedule) \(self.language.trip)|\(trip.carName)|\(trip.currencySymbol) \(trip.totalFare)     "
        }else{
            self.statusLabel!.text = NSLocalizedString("\(trip.status.rawValue.capitalized)", comment: "")
             self.timeLabel!.text = "\(trip.scheduleDisplayTime)"
            self.vehicleNameLabel!.text = "\(self.language.schedule) \(self.language.trip)| \(trip.carName)|\(trip.currencySymbol) \(trip.totalFare)"
        }
    }
    class func getNib() -> UINib{
        return UINib(nibName: "UpCommingTripTVC", bundle: nil)
    }
}
