//
//  TextFieldUtil.swift
// NewTaxi
//
//  Created by Seentechs on 14/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
typealias TextFieldEscaping = (_ event : UIControl.Event,_ field : UITextField)->()


class TextFieldUtil : NSObject{
    
    func addValidation(_ validation : ((String) -> Bool)?){
        self.validation = validation
    }
   
 
    private var event : TextFieldEscaping?
 
    let textField : UITextField
    private var validation : ((String) -> Bool)?
    init(_ textField : UITextField) {
        self.textField = textField
        super.init()
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(self.didChange(_:)), for: .editingChanged)
    }
}
extension TextFieldUtil : UITextFieldDelegate{
    func listen(_ event : @escaping TextFieldEscaping){
        self.event = event
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.event?(.editingDidBegin,textField)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.event?(.editingDidEnd,textField)
    }
    @objc func didChange(_ textField : UITextField){
        self.event?(.valueChanged,textField)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textValidaiton = self.validation else{return true}
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                print("Backspace was pressed")
                return true
            }
        }
        if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return textValidaiton(textField.text ?? "" + string)
    }
}
