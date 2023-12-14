//
//  PastAndUpcommingTVC.swift
// NewTaxi
//
//  Created by Seentechs on 27/03/21.
//  Copyright © 2021 Vignesh Palanivel. All rights reserved.
//

import UIKit

class PastAndUpcommingTVC: UITableViewCell {

    lazy var language = Language.default.object
    
    /// Whole Stacks
    @IBOutlet weak var bgHolderStack: UIStackView!
    @IBOutlet weak var headerStack: UIStackView!
    @IBOutlet weak var contentStack: UIStackView!
    
    /// Normal Trips Stacks (Begin Job,Pending,End Job)
    @IBOutlet weak var tripStatusBgStack: UIStackView!
    @IBOutlet weak var tripIdBgView: UIStackView!
    
    /// Schedule trip Stacks
    @IBOutlet weak var scheduleBgView: UIView!
    @IBOutlet weak var scheduleRideStack: UIStackView!
    @IBOutlet weak var scheduleTimeStack: UIStackView!
    
    
    /// location and map
    @IBOutlet weak var locStack: UIStackView!
    @IBOutlet weak var mapBgView: UIView!
    @IBOutlet weak var numberSeatsView: UIView!
    @IBOutlet weak var lineView: UIView!
    
    
    
    @IBOutlet weak var jobStatusLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var tripIdLbl: UILabel!
    @IBOutlet weak var vehicleTypeLbl: UILabel!
    @IBOutlet weak var mapIV: UIImageView!
    @IBOutlet weak var pinBgView: UIView!
    @IBOutlet weak var dropIV: UIImageView!
    @IBOutlet weak var pickupIV: UIImageView!
    @IBOutlet weak var dottedView: UIView!
    @IBOutlet weak var pickLocLbl: UILabel!
    @IBOutlet weak var dropLocLbl: UILabel!
    @IBOutlet weak var addressStack: UIStackView!
    @IBOutlet weak var schduleTripLbl: UILabel!
    @IBOutlet weak var scheduleTimeLbl: UILabel!
    @IBOutlet weak var schedulePriceLbl: UILabel!
    @IBOutlet weak var numberOfSeats: UILabel!
    @IBOutlet weak var editTimeBtn: UIButton!
    @IBOutlet weak var cancelRideBtn: UIButton!
    @IBOutlet weak var lineLbl: UILabel!
    
    
    func setDesign() {

        
        self.lineLbl.backgroundColor = .Title
        
        self.jobStatusLbl.textColor = .Title
        self.jobStatusLbl.alpha = 0.4
        self.jobStatusLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.amountLbl.textColor = .Title
        self.amountLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.tripIdLbl.textColor = .Title
        self.tripIdLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.vehicleTypeLbl.textColor = .ThemeYellow
        self.vehicleTypeLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.scheduleTimeLbl.textColor = .Title
        self.scheduleTimeLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.schedulePriceLbl.textColor = .Title
        self.schedulePriceLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.schduleTripLbl.textColor = .ThemeYellow
        self.schduleTripLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.pickLocLbl.textColor = .Title
        self.pickLocLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.dropLocLbl.textColor = .Title
        self.dropLocLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.editTimeBtn.setTitleColor(.ThemeYellow, for: .normal)
        self.editTimeBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.editTimeBtn.setTitle(self.language.editTime.capitalized, for: .normal)
        
        self.cancelRideBtn.setTitleColor(.ThemeYellow, for: .normal)
        self.cancelRideBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.cancelRideBtn.setTitle(self.language.cancelRide.capitalized, for: .normal)
        
        self.numberOfSeats.textColor = .Title
        self.numberOfSeats.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.setDesign()
    }

    class func getNib() -> UINib{
        return UINib(nibName: "PastAndUpcommingTVC", bundle: nil)
    }
    func populateCell(with trip : History){
        self.schedulePriceLbl.text = "\(trip.carType) \(trip.currencySymbol + trip.totalFare.description)"
        self.pickLocLbl.text = trip.pickup
        self.dropLocLbl.text = trip.drop
        self.tripIdLbl.text = self.language.tripID.capitalized + " " + trip.tripID.description
        self.amountLbl.text = trip.currencySymbol + trip.totalFare.description
        self.jobStatusLbl.text = trip.status.localizedValue
        self.vehicleTypeLbl.text = trip.carType
        self.numberOfSeats.text =  "\(language.noofseats) " + trip.seats.description
        self.scheduleTimeLbl.text = trip.scheduleDisplayDate
        self.mapIV.sd_setImage(with: URL(string: trip.mapImage))
        if trip.isPool == true {
            self.numberSeatsView.isHidden = false
        } else{
            self.numberSeatsView.isHidden = true
        }
        
        
        switch trip.status {
        
        case .completed:
            fallthrough
        case .rating:
            fallthrough
        case .payment:
            self.locStack.isHidden = true
            if trip.mapImage != ""
            {
                self.mapBgView.isHidden = false
            }else{
                self.mapBgView.isHidden = true
                self.locStack.isHidden = false
            }
            self.scheduleBgView.isHidden = true
            self.scheduleTimeStack.isHidden = true
            self.scheduleRideStack.isHidden = true
            
        
        case .cancelled:
            fallthrough
        case .request:
            fallthrough
        case .beginTrip:
            fallthrough
        case .scheduled:
            fallthrough
        case .manualBookiingCancelled:
            fallthrough
        case .endTrip:
            self.locStack.isHidden = false
            self.mapBgView.isHidden = true
            self.scheduleBgView.isHidden = true
            self.scheduleTimeStack.isHidden = true
            self.scheduleRideStack.isHidden = true
            
        
        case .manuallyBookedReminder:
            fallthrough
        case .manualBookingInfo:
            fallthrough
        case .pending:
            fallthrough
        case .manuallyBooked:
            self.amountLbl.text = ""
            self.tripIdBgView.isHidden = true
            self.mapBgView.isHidden = true
            self.locStack.isHidden = false
            self.scheduleBgView.isHidden = false
            self.scheduleTimeStack.isHidden = false
            self.scheduleRideStack.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dottedView.backgroundColor = .clear
            DispatchQueue.main.async {
//                self.drawDottedLine(start: CGPoint(x: self.dropIV.frame.maxX,y: self.dropIV.frame.maxY), end: CGPoint(x:self.pickupIV.frame.minX,y: self.pickupIV.frame.minY), view: self.dottedView)
                self.dottedView.addDashedBorder(view: self.dottedView)
            }
          
            self.mapIV.cornerRadius = 22
        }
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.DarkTitle.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3]
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}


extension UIView{
    func addDashedBorder(view: UIView) {
        //Create a CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.DarkTitle.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [7, 3]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: 0, y: view.frame.height)])
        
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
}
