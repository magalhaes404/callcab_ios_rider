//
//  ReusableView.swift
// NewTaxi
//
//  Created by Seentechs on 16/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

//MARK:- Extensions
protocol ReusableView: class {}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// UIViewController.swift
extension UIViewController: ReusableView { }

// UIStoryboard.swift
extension UIStoryboard {
    
   
    
    static var payment : UIStoryboard{
        return UIStoryboard(name: "Payment", bundle: nil)
    }
    static var tripBooking : UIStoryboard{
        return UIStoryboard(name: "TripBooking", bundle: nil)
    }
    static var trip : UIStoryboard{
        return UIStoryboard(name: "Trip", bundle: nil)
    }
    static var account : UIStoryboard{
        return UIStoryboard(name: "Account", bundle: nil)
        
    }
    static var jeba : UIStoryboard{
        return UIStoryboard(name: "jeba", bundle: nil)
        
    }
    static var home : UIStoryboard{
        return UIStoryboard(name: "Home", bundle: nil)
    }
    static var karthi : UIStoryboard{
        return UIStoryboard(name: "Karthi", bundle: nil)
    }
    /**
     initialte viewController with identifier as class name
     - Author: Abishek Robin
     - Returns: ViewController
     - Warning: Only ViewController which has identifier equal to class should be parsed
     */
    func instantiateViewController<T>() -> T where T: ReusableView {
        return instantiateViewController(withIdentifier: T.reuseIdentifier) as! T
    }
    /**
     initialte viewController with identifier as class name and suffix("ID")
     - Author: Abishek Robin
     - Returns: ViewController
     - Warning: Only ViewController with "ID" in suffix should be parsed
     */
    func instantiateIDViewController<T>() -> T where T: ReusableView {
        return instantiateViewController(withIdentifier: T.reuseIdentifier + "ID") as! T
    }
}

extension UITableViewCell: ReusableView { }
extension UICollectionViewCell: ReusableView { }
extension UITableView{
    
    /**
     initialte UITableViewCell with identifier as class name
     - Author: Abishek Robin
     - Returns: ReusableView(UITableViewCell)
     - Warning: Only UITableViewCell which has identifier equal to class should be parsed
     */
    func dequeueReusableCell<T>(for index : IndexPath) -> T where T : ReusableView{
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: index) as! T
    }
}

extension UICollectionView{
    /**
     initialte UICollectionViewCell with identifier as class name
     - Author: Abishek Robin
     - Returns: ReusableView(UITableViewCell)
     - Warning: Only UICollectionViewCell which has identifier equal to class should be parsed
     */
    func dequeueReusableCell<T>(for index : IndexPath) -> T where T : ReusableView{
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: index) as! T
    }
}

