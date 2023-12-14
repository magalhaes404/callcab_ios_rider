//
//  MobileNumberView.swift
// NewTaxi
//
//  Created by Seentechs on 11/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

class MobileNumberView : UIView{
    
    @IBOutlet weak var countryHolderView : UIView!
    @IBOutlet weak var countryIV : UIImageView!
    @IBOutlet weak var countyCodeLbl : UILabel!
    @IBOutlet weak var numberHolderView : UIView!
    @IBOutlet weak var numberTF : UITextField!
    
    var flag : CountryModel?{
        didSet{
            if let _flag = self.flag{
                self.setCountry(_flag)
            }
        }
    }
    
    var number : String?{return numberTF.text}
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func initLayers(){
        self.numberHolderView.isClippedCorner = true
        self.countryHolderView.isClippedCorner = true
//        self.numberHolderView.elevate(2)
//        self.countryHolderView.elevate(2)
        self.numberTF.textAlignment = Language.default.object.getTextAlignment(align: .left)
        
    }
    func clear(){
        self.numberTF.text = ""
    }
    private func setCountry(_ flag : CountryModel){
        self.countryIV.image = flag.flag
        self.countyCodeLbl.text = flag.dial_code
        self.countyCodeLbl.alpha = 0.4
        self.numberTF.textColor = .Title
    }
    static func getView(with frame : CGRect) -> MobileNumberView{
        let nib = UINib(nibName: "MobileNumberView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! MobileNumberView
        view.frame = frame
        view.initLayers()
        view.flag = CountryModel()
        return view
    }
  
    func setfonts(){
       // self.countyCodeLbl.font?.fo
        self.countyCodeLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        self.numberTF?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 18)
        
    }
}
