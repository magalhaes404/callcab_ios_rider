/**
* PromoCodeVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/



import UIKit
import Foundation

class PromoCodeVC : UIViewController,UITextFieldDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var txtFldPromoCode: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnUpdatePhoneNo: UIButton!
    @IBOutlet weak var viewPromoHolder: UIView!
    @IBOutlet weak var lblProgress: UIView!
   
    var strFirstName = ""
    var strLastName = ""
    // MARK: - ViewController Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            txtFldPromoCode.keyboardType = .asciiCapable
        } else {
            // Fallback on earlier versions
            txtFldPromoCode.keyboardType = .default
        }
        btnNext.layer.cornerRadius = btnNext.frame.size.height/2

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //Show the keyboard

    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UberSupport().keyboardWillShowOrHide(keyboarHeight: keyboardFrame.size.height, btnView: btnNext)
    }
    //Hide the keyboard
    @objc func keyboardWillHide(notification: NSNotification)
    {
        UberSupport().keyboardWillShowOrHide(keyboarHeight: 0, btnView: btnNext)
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.checkNextButtonStatus()
    }
    
   
    // MARK: TextField Delegate Method
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        self.checkNextButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let notAllowedCharacters = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";
    
        if range.location == 0 && (string == " ") {
            return false
        }
        if (string == "") {
            return true
        }
        else if (string == " ") {
            return false
        }
        else if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }

    // MARK: Checking Next Button status
    /*
        First & Last name filled or not
        and making user interaction enable/disable
     */
    func checkNextButtonStatus()
    {
        btnNext.isUserInteractionEnabled = ((txtFldPromoCode.text?.count)!>0) ? true : false
    }
    
    
// MARK: When User Press Next Button
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
