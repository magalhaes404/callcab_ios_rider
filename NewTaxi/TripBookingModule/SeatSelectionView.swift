//
//  SelectSeatsVC.swift
// NewTaxi
//
//  Created by Seentechs on 24/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit


protocol SeatSelectionDelegate : class{
    func seatsSelected(_ selected : Int)
    func seatsSelectionCancelled()
}

class SeatSelectionView: UIView {

    //MARK:- Outlets
    
    
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var seatCollectionView : UICollectionView!
    @IBOutlet weak var acceptSeatBtn : UIButton!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var messageLbl : UILabel!
    @IBOutlet weak var titleLbl : UILabel!
    weak var selectionDelegate : SeatSelectionDelegate?
    var seatCounts = [1,2]
    var selectedSeats : Int = 1
    var car : SearchCarsModel?
    
    func setDesign() {
        
        self.setSpecificCornersForTop(cornerRadius: 35)
        self.elevate(4)
        
        self.priceLbl.textColor = .Title
        self.priceLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        
        self.titleLbl.textColor = .Title
        self.titleLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.messageLbl.textColor = UIColor.Title.withAlphaComponent(0.49)
        self.messageLbl.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 14)
        
        self.acceptSeatBtn.setTitleColor(.Title, for: .normal)
        self.acceptSeatBtn.backgroundColor = .ThemeYellow
        self.acceptSeatBtn.cornerRadius = 15
        self.acceptSeatBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    }
    
    lazy var lang = Language.default.object
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initView()
    }
    
    func initView(){
        let seatCountCVCNib = UINib(nibName: "SeatCountCVC", bundle: nil)
        self.seatCollectionView.register(seatCountCVCNib, forCellWithReuseIdentifier: "SeatCountCVC")
        self.seatCollectionView.delegate = self
        self.seatCollectionView.dataSource = self
//        self.seatCollectionView.layo
        
        self.titleLbl.text = self.lang.howManySeats
        self.messageLbl.text = self.lang.thisFareMayVary
        self.acceptSeatBtn.setTitle(self.lang.request.uppercased(), for: .normal)
        self.backBtn.setTitle(self.lang.getBackBtnText(), for: .normal)
        self.setDesign()
    }
    func setData(forCar car : SearchCarsModel){
        self.selectedSeats = 1
        self.car = car
        self.acceptSeatBtn.setTitle("\(self.lang.request) \(car.car_name)".uppercased() ,
                                    for: .normal)
        self.seatCollectionView.reloadData()
    }
    class func getView(_ delegate :  SeatSelectionDelegate) -> SeatSelectionView{
        let nib = UINib(nibName: "SeatSelectionView", bundle: nil)
        let view : SeatSelectionView = nib.instantiate(withOwner: nil, options: nil).first as! SeatSelectionView
        view.selectionDelegate = delegate
        view.selectedSeats = 1
        view.seatCollectionView.reloadData()
        return view
    }

    //MARK:- Actions
    @IBAction
    func backAction(_ sender : UIButton?){
        self.selectedSeats = 1
        self.selectionDelegate?.seatsSelectionCancelled()
    }
    @IBAction
    func confirmSeatsAction(_ sender : UIButton?){
//        guard let seats = self.selectedSeats else{
//            AppDelegate.shared.createToastMessage(Language.default.object.pleaseSelectOption.capitalized)
//            return
//        }
     
        self.selectionDelegate?.seatsSelected(self.selectedSeats)
        self.selectedSeats = 1
    }

}
extension SeatSelectionView : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.seatCounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SeatCountCVC = collectionView.dequeueReusableCell(for: indexPath)
        let seat = self.seatCounts[indexPath.row]
        cell.setData(seat)
        cell.holderView.backgroundColor = self.selectedSeats == seat ? .ThemeYellow : .ThemeInactive
        let minFare : Double  = Double(self.car?.fare_estimation ?? "" ) ?? 0.0
        let multiplier = ((car?.additionalRiderPercentage ?? 0.0) * 0.01) + 1
        let finalAmount = (self.selectedSeats == 1 ? minFare : (minFare * multiplier))
        let stringFinalAmount = String(format: "%.2f", finalAmount)
        self.priceLbl.text = "\(strCurrency) \(stringFinalAmount)"
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
        cell.holderView.isRoundCorner = true
        }
        return cell
    }
}
//extension SeatSelectionView : UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = self.seatCollectionView.frame.width
//        let height = self.seatCollectionView.frame.height
//        return CGSize(width: width * 0.5, height: height)
//    }
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
////        let viewWidth = self.seatCollectionView.frame.width
////        let cellWidth = self.seatCollectionView.frame.height
////        let padding = (viewWidth - (cellWidth * 2)) * 0.5
////        return UIEdgeInsets(top: 0, left:padding, bottom: 0, right: padding)
////    }
//
//}
extension SeatSelectionView : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedSeats = self.seatCounts[indexPath.row]
        collectionView.reloadData()
    }
//    func didse
}

