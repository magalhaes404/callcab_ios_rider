//
//  ChangePaymentMethod.swift
// NewTaxi
//
//  Created by Seentechs on 12/10/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
class ChangePaymentMethod: UIView{
    
    @IBOutlet weak var payPalImg: UIImageView!
    @IBOutlet weak var cashLbl: UILabel!
    @IBOutlet weak var promolbl: UILabel!
    @IBOutlet weak var walletImg : UIImageView!
    @IBOutlet weak var changeBtn : UIButton!
    @IBOutlet weak var walletHolder: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.changeBtn.layer.cornerRadius = 5
        self.promolbl.layer.cornerRadius = 5
        self.changeBtn.backgroundColor = .ThemeLight
    }
    func setFrame(_ parentFrame: CGRect) -> CGRect{
        let frame = CGRect(x: 0, y: 0, width: parentFrame.width, height:  parentFrame.height)
        return frame
    }
  
    class func initViewFromXib()-> ChangePaymentMethod{
        let nib = UINib(nibName: "ChangePaymentMethod", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! ChangePaymentMethod
        return view
    }
    
    
    
}

