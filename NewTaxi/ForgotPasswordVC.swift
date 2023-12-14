/**
* ForgotPasswordVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/



import UIKit
import Foundation

protocol ForgotPasswordDelegate
{
    func onForgotAlertBtnTapped(btnTag:Int)
}

class ForgotPasswordVC : UIViewController
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet var lblTitle: UILabel!
   
    var delegate: ForgotPasswordDelegate?

    var strFirstName = ""
    var strLastName = ""
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnCancel.layer.borderColor = UIColor.ThemeMain.cgColor
        btnCancel.layer.borderWidth = 1.0
    }
    // MARK: Navigating to Email field View
    /*
     BUTTON TAG = 11 -> EMAIL
     BUTTON TAG = 22 -> MOBILE
     BUTTON TAG = 33 -> CANCEL
     */
    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        },  completion: { (finished: Bool) -> Void in
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        setupShareAppViewAnimationWithView(viewObjectHolder)
    }
        
    
    // MARK: When User Press Back Button

    @IBAction func onButtonTapped(_ sender:UIButton!)
    {
        if sender.tag == 11 || sender.tag == 22
        {
            dismiss(animated: true, completion: {
                self.delegate?.onForgotAlertBtnTapped(btnTag:sender.tag)
            })
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
}
