//
//  CellProtocol.swift
// NewTaxi
//
//  Created by Seentechs on 10/09/21.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

protocol ProjectCell {
    associatedtype myCell
    var identifier : String{get}
}
extension UICollectionView{
    func generate<T:ProjectCell>(_ cell : T,forIndex index : IndexPath) -> T.myCell{
        return self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: index) as! T.myCell
    }
}
extension UITableView{
    func generate<T:ProjectCell>(_ cell : T,forIndex index : IndexPath) -> T.myCell{
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: index) as! T.myCell
    }
}
