//
//  InfoCommentPopOverVC.swift
// NewTaxi
//
//  Created by Seentechs on 06/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit

import UIKit

class InfoCommentPopOverVC: UIViewController {
    
    
    @IBOutlet weak var commentLbl : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setFont(_ font : iApp.NewTaxiFont,weight : CGFloat){
        
        self.commentLbl.font = UIFont(name: font.rawValue,
                                      size: weight)
    }
    //MARK:- initWithStory
    class func initWithStory(preferredFrame size : CGSize,on host : UIView) -> InfoCommentPopOverVC{
        let infoWindow : InfoCommentPopOverVC = UIStoryboard.home.instantiateViewController()
        infoWindow.preferredContentSize = size
        infoWindow.modalPresentationStyle = .popover
        let popover: UIPopoverPresentationController = infoWindow.popoverPresentationController!
        popover.delegate = infoWindow
        popover.sourceView = host
        popover.backgroundColor = UIColor(hex: "ECF2FB")
        popover.permittedArrowDirections = UIPopoverArrowDirection.down
        
        
        return infoWindow
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension InfoCommentPopOverVC : UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
extension UIViewController{
    func showPopOver(withComment comment : String,on host : UIView){
        let infoWindow = InfoCommentPopOverVC
            .initWithStory(preferredFrame: CGSize(width: self.view.frame.width,
                                                  height: 100),
                           on: host)
        self.presentInFullScreen(infoWindow, animated: true, completion: { [weak self] in
            infoWindow.commentLbl.text = comment
            infoWindow.setFont(.bold, weight: 17)
        })
    }
}
