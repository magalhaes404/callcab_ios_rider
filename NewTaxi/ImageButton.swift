//
//  ImageButton.swift
// NewTaxi
//
//  Created by Seentechs on 03/12/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

class ImageButton : UIView{

    //MARK:-Outlets
    @IBOutlet weak var leftIV : UIImageView!
    @IBOutlet weak var centerIV : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var rightIV : UIImageView!
  
    //MARK: AwakeFromNib
    override
    func awakeFromNib(){
        super.awakeFromNib()
    }

    //MARK:- UDF handlers
    func setTitle(_ title : String?){
        self.titleLabel.text = title
    }
    func setLeftImage(_ image : String){
        self.leftIV.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
    }
    func setRightImage(_ image : String){
        self.rightIV.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
    }
    
    func setCenterImage(_ image : String){
//        self.centerIV.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        self.centerIV.image = UIImage(named: image)
    }
    func setTint(color : UIColor){
        self.leftIV.tintColor = color
        self.rightIV.tintColor  = color
        self.centerIV.tintColor = color
    }
    func setTitle(color : UIColor){
        self.titleLabel.textColor = color
    }
    func setBackground(color : UIColor){
        self.backgroundColor = color
    }
    
    //MARK:- initializeView
    class func initialize(on host : UIView) -> ImageButton{
        let nib = UINib(nibName: "ImageButton", bundle: nil)
        let imgBtn = nib.instantiate(withOwner: nil, options: nil)[0] as! ImageButton
        imgBtn.frame = host.bounds
        host.addSubview(imgBtn)
        let leading = host.leadingAnchor
            .constraint(equalToSystemSpacingAfter: imgBtn.leadingAnchor, multiplier: 0)
        let trailing = host.trailingAnchor
            .constraint(equalToSystemSpacingAfter: imgBtn.trailingAnchor, multiplier: 0)
        let bottom = host.bottomAnchor
            .constraint(equalToSystemSpacingBelow: imgBtn.bottomAnchor, multiplier: 0)
        let top = host.topAnchor
            .constraint(equalToSystemSpacingBelow: imgBtn.topAnchor, multiplier: 0)
        host.addConstraint(leading)
        host.addConstraint(trailing)
        host.addConstraint(bottom)
        host.addConstraint(top)
        
        let height = imgBtn.heightAnchor.constraint(equalToConstant: host.frame.height)
        imgBtn.addConstraint(height)
        imgBtn.layoutIfNeeded()
        return imgBtn
    }
}
