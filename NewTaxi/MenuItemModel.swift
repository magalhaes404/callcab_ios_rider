//
//  MenuItemModel.swift
// NewTaxi
//
//  Created by Seentechs on 12/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

class MenuItemModel{
    var title : String
    var viewController : UIViewController?
    init(withTitle title :String,VC : UIViewController? ){
        self.title = title
        self.viewController = VC
    }
}
class CellMenus: UITableViewCell
{
    @IBOutlet var lblName: UILabel?
}
