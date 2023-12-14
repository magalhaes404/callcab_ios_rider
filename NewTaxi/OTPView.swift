//
//  OTPView.swift
// NewTaxi
//
//  Created by Seentechs on 11/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit


protocol TextFieldBackSpaceDelegate{
    func onBackSpaceTap(for textField : UITextField)
}
class DeleteTextField :UITextField{
    var backSpaceDelegate : TextFieldBackSpaceDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func delete(_ sender: Any?) {
        super.delete(sender)
    }
    override func deleteBackward() {
        self.backSpaceDelegate?.onBackSpaceTap(for: self)
        super.deleteBackward()
    }
    
}

class OTPView: UIView {

    @IBOutlet weak var tf1 : DeleteTextField!
    @IBOutlet weak var tf2 : DeleteTextField!
    @IBOutlet weak var tf3 : DeleteTextField!
    @IBOutlet weak var tf4 : DeleteTextField!
    @IBOutlet weak var holderStackView : UIStackView!
    @IBOutlet weak var invalidOTPLbl : UILabel!
    var checkStatusDelegate  : CheckStatusProtocol?
    var otp : String?{
        if let text1 = tf1.text,
            let text2 = tf2.text,
            let text3 = tf3.text,
            let text4 = tf4.text{
            return text1+text2+text3+text4
        }
        return nil
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initView(){
    //    self.elevate(2)
        self.tf1.delegate = self
        self.tf2.delegate = self
        self.tf3.delegate = self
        self.tf4.delegate = self
        self.tf1.backSpaceDelegate = self
        self.tf2.backSpaceDelegate = self
        self.tf3.backSpaceDelegate = self
        self.tf4.backSpaceDelegate = self
        
        
        self.tf1.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.tf2.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.tf3.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.tf4.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.invalidOTPLbl.isHidden = true
        
        
    }
    func rotate(){
        var i = 0
        for view in self.holderStackView.arrangedSubviews.reversed(){
            self.holderStackView.insertArrangedSubview(view, at: i)
            i += 1
        }
    }
    func invalidOTP(){
        
        let lang = Language.default.object
        self.invalidOTPLbl.text = lang.enterValidOTP
        self.holderStackView.shake {
            self.invalidOTPLbl.isHidden = false

        }
    }
    func clear(){
        self.tf1.text = ""
        self.tf2.text = ""
        self.tf3.text = ""
        self.tf4.text = ""
        self.tf1.becomeFirstResponder()
    }
    func setToolBar(_ bar : UIToolbar){
        self.tf1.inputAccessoryView = bar
        self.tf2.inputAccessoryView = bar
        self.tf3.inputAccessoryView = bar
        self.tf4.inputAccessoryView = bar
    }
    static func getView(with delegate : CheckStatusProtocol,using frame : CGRect) -> OTPView{
        let nib = UINib(nibName: "OTPView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! OTPView
        view.frame = frame
        view.checkStatusDelegate = delegate
        view.initView()
        return view
    }
}


//MARK:- for otp
extension OTPView : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.invalidOTPLbl.isHidden = true
        let text1 = tf1.text ?? ""
        let text2 = tf2.text ?? ""
        let text3 = tf3.text ?? ""
        let text4 = tf4.text ?? ""
       
        guard (textField.text ?? "").isEmpty else{return true}
        switch textField {
        case self.tf1:
            return true
        case self.tf2:
            return !text1.isEmpty || !text3.isEmpty || !text4.isEmpty
        case self.tf3:
            return !text1.isEmpty || !text2.isEmpty || !text4.isEmpty
        case self.tf4:
            return !text1.isEmpty || !text2.isEmpty || !text3.isEmpty
        default:
            return false
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !(textField.text  ?? "").isEmpty {
            textField.selectAll(nil)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard !(textField.text?.isEmpty ?? true) else{return}
        let nextTF : UITextField?
        switch textField {
        case self.tf1:
            nextTF = self.tf2
        case self.tf2:
            nextTF = self.tf3
        case self.tf3:
            nextTF = self.tf4
        case self.tf4:
            fallthrough
        default:
            nextTF = nil
            self.endEditing(true)
            self.checkStatusDelegate?.checkStatus()
        }
        if let next = nextTF{
            next.becomeFirstResponder()
            if !(next.text ?? "").isEmpty{
                next.selectAll(nil)
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.invalidOTPLbl.isHidden = true
        guard let text = textField.text else{return true}
        let char = string.cString(using: String.Encoding.utf8)
        let isBackSpace: Bool = Int(strcmp(char, "\u{8}")) == -8
        if textField.selectedTextRange == textField.textRange(from: textField.beginningOfDocument,
                                                              to: textField.endOfDocument){
            return true
        }
        if text.count == 1 && !isBackSpace{
            return false
        }
        if text.count == 1 && isBackSpace{
            return true
            textField.text = ""
            switch textField{
            case self.tf4:
                self.tf3.becomeFirstResponder()
            case self.tf3:
                self.tf2.becomeFirstResponder()
            case self.tf2:
                self.tf1.becomeFirstResponder()
            case self.tf1:
                fallthrough
            default:
                self.endEditing(true)
            }
            return false
        }
        if text.count == 0 && isBackSpace{
            switch textField{
            case self.tf4:
                self.tf3.becomeFirstResponder()
            case self.tf3:
                self.tf2.becomeFirstResponder()
            case self.tf2:
                self.tf1.becomeFirstResponder()
            case self.tf1:
                fallthrough
            default:
                self.endEditing(true)
            }
            return false
        }
        return true
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard !(textField.text?.isEmpty ?? true) else{return}
        switch textField {
        case self.tf1:
            
            self.tf2.becomeFirstResponder()
        case self.tf2:
            self.tf3.becomeFirstResponder()
        case self.tf3:
            self.tf4.becomeFirstResponder()
        case self.tf4:
            fallthrough
        default:
            self.endEditing(true)
            self.checkStatusDelegate?.checkStatus()
        }
    }
  
}


extension OTPView : TextFieldBackSpaceDelegate{
    func onBackSpaceTap(for textField: UITextField) {
        guard textField.text?.isEmpty ?? true else {return}
        switch textField {
        case self.tf4:
            self.tf3.text = ""
            self.tf3.becomeFirstResponder()
        case self.tf3:
            self.tf2.text = ""
            self.tf2.becomeFirstResponder()
        case self.tf2:
            self.tf1.text = ""
            self.tf1.becomeFirstResponder()
        case self.tf1:
            fallthrough
        default:

            self.checkStatusDelegate?.checkStatus()
        }
    }
    
    
}
