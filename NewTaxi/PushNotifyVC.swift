/**
* PushNotifyVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
* @version - Stable 1.0
* @link http://seentechs.com
*/



import UIKit
import Foundation

class PushNotifyVC : UIViewController,UITextFieldDelegate
{
    @IBOutlet var btnNext: UIButton!
    
    @IBOutlet weak var descLabel: UILabel!
    //Launch PushNotify page
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnNext.layer.cornerRadius = btnNext.frame.size.height/2
        
           descLabel.text = "\(NSLocalizedString("Please enable push notifications from ", comment: ""))\(APP_NAME) \(NSLocalizedString("when prompted", comment: "")))"
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
    }
    
    // MARK: Navigating to Main Map Page
    /*
     After Login or Signup Success
     */
    @IBAction func onNextTapped(_ sender:UIButton!)
    {
    }
    
    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController!.popViewController(animated: true)
    }
    
}
