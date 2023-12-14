//
//  UIImageView+extension.swift
//  ZoomTransitioning
//
//  Created by WorldDownTown on 07/16/2016.
//  Copyright © 2016 WorldDownTown. All rights reserved.
//

import UIKit

extension UIView {

    convenience init(baseImageView: UIView, frame: CGRect) {
        self.init(frame: CGRect.zero)
        self.frame = frame
    }
}
