//
//  customRefreshView.swift
// NewTaxi
//
//  Created by Seentechs on 12/04/21.
//  Copyright © 2021 Vignesh Palanivel. All rights reserved.
//

import Foundation
import Lottie

class CustomRefreshView: UIView {
    @IBOutlet weak var refresherImage: UIView!
    @IBOutlet weak var refreshContentLbl: UILabel!
    
    func setRefresh(image : AnimationView?,content : String?) {
        if let _content = content {
            self.refreshContentLbl.isHidden = false
            self.refreshContentLbl.text = _content
        } else {
            self.refreshContentLbl.isHidden = true
        }
        self.refresherImage.addSubview(image!)
        image?.anchor(toView: self.refresherImage,
                      leading: 0,
                      trailing: 0,
                      top: 0,
                      bottom: 0)
        self.refreshContentLbl.text = content
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    func setDesign() {
        self.refresherImage.tintColor = .ThemeYellow
        self.refreshContentLbl.textColor = UIColor.Title.withAlphaComponent(0.5)
        self.refreshContentLbl.font = iApp.NewTaxiFont.centuryBold.font(size: 12)
    }
    class func initViewFromXib()-> CustomRefreshView{
        let nib = UINib(nibName: "CustomRefreshView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! CustomRefreshView
        return view
    }
    
}
