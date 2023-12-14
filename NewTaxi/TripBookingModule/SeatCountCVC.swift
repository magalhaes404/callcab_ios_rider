//
//  SeatCountCVC.swift
// NewTaxi
//
//  Created by Seentechs on 24/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class SeatCountCVC: UICollectionViewCell {
    @IBOutlet weak var holderView : UIView!
    @IBOutlet weak var countLbl : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func setData(_ data : Int){
        self.countLbl.text = data.description
        self.countLbl.textColor = .Title
        self.countLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 35)
       
    }
}
