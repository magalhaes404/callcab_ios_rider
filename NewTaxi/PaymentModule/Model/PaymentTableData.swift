//
//  PaymentTableData.swift
// NewTaxi
//
//  Created by Seentechs on 03/01/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation



class PaymentTableSection{
    var title : String!
    var datas = [PaymentTableData]()
    init(withTitle title : String,datas : [PaymentTableData] ){
        self.title = title
        self.datas = datas
    }
}
class PaymentTableData{
    
    var name : String!
    var image : UIImage?
    var imageURL : URL?
    var isSelected = false
    init(withName name : String){
        self.name = name
    }
}
