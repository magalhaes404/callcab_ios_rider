/**
* ProgressHud.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import Foundation

class ProgressHud : UIViewController
{
    var isShowLoaderAnimaiton:Bool = false
    var spinnerView = JTMaterialSpinner()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeMain.withAlphaComponent(0.45)
        addProgress()
    }
    
    //MARK:- initWithStory
    class func initWithStory() -> ProgressHud{
        return UIStoryboard.home.instantiateViewController()
    }
    //MARK:- UDF
    func addProgress()
    {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        spinnerView.center = self.view.center
        spinnerView.backgroundColor = UIColor.clear
        spinnerView.circleLayer.lineWidth = 1.0
        spinnerView.circleLayer.strokeColor =  UIColor.white.cgColor
     
            spinnerView.beginRefreshing()
        
    }
    
    func removeProgress()
    {
        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeProgress()
    }
}

