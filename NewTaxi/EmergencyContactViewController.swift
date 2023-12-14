//
//  EmergencyContactViewController.swift
//  MyRideCiti
//
//  Created by Seentechs Technologies on 02/04/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import ContactsUI

class AddedContactsTVC: UITableViewCell {
    
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    func setfonts() {
        self.contactNameLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.contactNumberLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
    }
}

class EmergencyContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate,APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
        default:
            print()
        }
    }
    func onFailure(error: String,for API : APIEnums) {
        print(error)
    }
    @IBOutlet weak var confirmseparateview: UIView!
    @IBOutlet weak var confirmseparateview1: UIView!
    @IBOutlet weak var contactListTableView: UITableView!
    @IBOutlet weak var addContactButtonOutlet: UIButton!
    @IBOutlet weak var contactview: UIView!
    @IBOutlet weak var AddContactView: UIView!
    
    @IBOutlet weak var travelSaferLbl : UILabel?
    @IBOutlet weak var alertDearOnceLbl : UILabel?
    
    @IBOutlet weak var addUpToLbl : UILabel?
    @IBOutlet weak var removeContactLbl : UILabel?
    @IBOutlet weak var emergencyCntctLbl : UILabel?
    @IBOutlet weak var addCntctBtn : UIButton?
    @IBOutlet weak var backBtn : UIButton!
    
    
    @IBOutlet weak var confirmContactHolderView : UIView!
    @IBOutlet weak var confirmContactLbl : UILabel!
    @IBOutlet weak var confirmNameTF : UITextField!
    @IBOutlet weak var confirmNumberHolderView : UIView!
    @IBOutlet weak var confirmContactBtn : UIButton!
    @IBOutlet weak var cancelContactBtn : UIButton!
    lazy var selectedCountry : CountryModel? = nil
    
    
    lazy var mobileNumberView : MobileNumberView = {
        let mnView = MobileNumberView.getView(with: self.confirmNumberHolderView.bounds)
        mnView.countryHolderView.addAction(for: .tap, Action: {
            self.pushToCountryVC()
        })
        return mnView
    }()
    lazy var toolBar : UIToolbar = {
        let tool = UIToolbar(frame: CGRect(origin: CGPoint.zero,
                                              size: CGSize(width: self.view.frame.width,
                                                           height: 30)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(self.doneAction))
        tool.setItems([space,done], animated: true)
        tool.sizeToFit()
        return tool
    }()
    lazy var contactDictArray = [[String:Any]]()
    lazy var appDelegate = AppDelegate()
    let contactCount = 5
    lazy var language:LanguageProtocol = Language.default.object
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        contactListTableView.isHidden = true
        contactListTableView.delegate = self
        contactListTableView.dataSource = self
        contactListTableView.tableFooterView = UIView()
        self.setfont()
        self.contactview.setSpecificCornersForTop(cornerRadius: 35)
        self.contactview.backgroundColor = .ThemeBgrnd
        self.contactview.elevate(10)
        self.confirmseparateview.setSpecificCornersForTop(cornerRadius: 40)
        self.confirmseparateview1.setSpecificCornersForTop(cornerRadius: 40)
        
        self.travelSaferLbl?.text =  self.language.travelSafer
        self.travelSaferLbl?.textColor = .ThemeMain
        
        self.alertDearOnceLbl?.textColor = .Title
        self.alertDearOnceLbl?.text = self.language.alertUrDears
        DispatchQueue.main.async {
        self.alertDearOnceLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 13)
        }
        self.addUpToLbl?.text = self.language.youCanAddC
        self.removeContactLbl?.text = self.language.removeContact
        self.addCntctBtn?.setTitle(self.language.addContacts, for: .normal)
        self.addCntctBtn?.backgroundColor = .ThemeYellow
        self.addCntctBtn?.cornerRadius = 8
    
        self.emergencyCntctLbl?.text = self.language.emergencyContacts
        
        let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
                         "country_code" : Constants().GETVALUE(keyname: USER_COUNTRY_CODE),
                         "action" : "view"] as JSON
     
//        WebServiceHandler.sharedInstance.getWebService(wsMethod:"sos", paramDict: paramDict, viewController:self, isToShowProgress:true,  isToStopInteraction:false, complete:  { (response) in
//            let responseJson = response
//            DispatchQueue.main.async {
//                if responseJson["status_code"] as? String == "1" {
//                    let contactDict = responseJson["contact_details"] as! [[String:Any]]
//                    self.contactDictArray = contactDict
//                    if self.contactDictArray.count > 0 {
//                        self.contactListTableView.isHidden = false
//                        self.contactListTableView.reloadData()
//                        if self.contactDictArray.count == self.contactCount {
//                            self.addContactButtonOutlet.isHidden = true
//                        }
//                        else {
//                            self.addContactButtonOutlet.isHidden = false
//                        }
//                    }
//                }
//                else {
//                    self.appDelegate.createToastMessage(responseJson["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white)
//                }
//            }
//        }){(error) in
//
//        }
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .sos,params: paramDict)
            .responseJSON({ (json) in
                if json.isSuccess{
                    if json.status_code == 0 {
                        UberSupport.shared.removeProgressInWindow()
                        self.appDelegate.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)

                    }else{
                        UberSupport.shared.removeProgressInWindow()
                        let contactDict = json["contact_details"] as! [[String:Any]]
                        self.contactDictArray = contactDict
                        if self.contactDictArray.count > 0 {
                            self.contactListTableView.isHidden = false
                            self.contactListTableView.reloadData()
                            if self.contactDictArray.count == self.contactCount {
                                self.addContactButtonOutlet.isHidden = true
                            }
                            else {
                                self.addContactButtonOutlet.isHidden = false
                            }
                        }
                    }
                   
                }else{
                    UberSupport.shared.removeProgressInWindow()
                    self.appDelegate.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)

                }
            }).responseFailure({ (error) in
                if error != ""
                {
                    UberSupport.shared.removeProgressInWindow()
                self.appDelegate.createToastMessage(error, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)
                }
            })
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + 0.2) {
                self.initContactConfimationView()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setfont(){
        self.emergencyCntctLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
        self.travelSaferLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 22)
        self.addCntctBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        self.addUpToLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 12)
        self.confirmContactBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
        self.cancelContactBtn?.titleLabel?.font =  UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
        self.confirmContactLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 22)
        self.confirmNameTF?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
      
        
    }
    func initContactConfimationView(){
        let leading = self.confirmContactHolderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailing = self.confirmContactHolderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        let top = self.confirmContactHolderView.topAnchor.constraint(equalTo: self.view.topAnchor)
        let bottom = self.confirmContactHolderView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        self.view.addSubview(self.confirmContactHolderView)
        self.view.bringSubviewToFront(self.confirmContactHolderView)
        confirmContactHolderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leading,trailing,top,bottom])
        
        self.view.layoutIfNeeded()
        
       // self.cancelContactBtn.border(1, .ThemeMain)
        self.cancelContactBtn.cornerRadius = 10
        self.cancelContactBtn.elevate(2)
        self.confirmContactBtn.cornerRadius = 10
        self.confirmContactBtn.backgroundColor = .ThemeYellow
        self.confirmContactBtn.setTitle(self.language.confirm.uppercased(), for: .normal)
        self.cancelContactBtn.setTitle(self.language.cancel.uppercased(), for: .normal)
        self.confirmContactLbl.text = self.language.confirmContact.capitalized
        
        self.confirmNumberHolderView.addSubview(self.mobileNumberView)
        self.confirmNumberHolderView.bringSubviewToFront(self.mobileNumberView)
        self.mobileNumberView.numberTF.inputAccessoryView = self.toolBar
        
        self.confirmNameTF.inputAccessoryView = self.toolBar
        
        self.hideContactView(with: 0.0)
    }
    @IBAction func contactBtnAction(_ sender : UIButton){
        
        self.view.endEditing(true)
        if sender == self.confirmContactBtn{
            guard let name = self.confirmNameTF.text,
                let number = self.mobileNumberView.number,
                let country = self.selectedCountry else{
                    appDelegate.createToastMessage(self.language.enterValidData)
                    return
            }
            self.addContact(withName: name, number: number, country: country)
        }else if sender == self.cancelContactBtn{
            self.hideContactView()
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
        
        self.navigationController!.popViewController(animated: true)
        
    }
    @available(iOS 9.0, *)

    @IBAction func addContactButtonAction(_ sender: Any) {
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        contactPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1")
        contactPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'")
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    class func initWithStory() -> EmergencyContactViewController{
        return UIStoryboard.jeba.instantiateViewController()
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactDictArray.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = contactListTableView.dequeueReusableCell(withIdentifier: "AddedContactsTVC") as! AddedContactsTVC
        cell.contactNameLabel.text = contactDictArray[indexPath.row]["name"] as? String
        cell.contactNameLabel.textColor = .ThemeMain
        cell.contactNumberLabel.text = contactDictArray[indexPath.row]["mobile_number"] as? String
        cell.contactNumberLabel.textColor = UIColor.Title.withAlphaComponent(0.5)
        
        cell.setfonts()
        return cell
     }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
                             "mobile_number" : contactDictArray[indexPath.row]["mobile_number"]!,
                             "action" : "delete",
                             "country_code" : Constants().GETVALUE(keyname: USER_COUNTRY_CODE),
                             "name" : contactDictArray[indexPath.row]["name"]!,
                             "id" : contactDictArray[indexPath.row]["id"]!] as JSON
//            WebServiceHandler.sharedInstance.getWebService(wsMethod:"sos", paramDict: paramDict, viewController:self, isToShowProgress:true, isToStopInteraction:false,complete : { (response) in
//                let responseJson = response
//                DispatchQueue.main.async {
//                    if responseJson["status_code"] as? String == "1" {
//                        // remove the item from the data model
//                        self.contactDictArray.remove(at: indexPath.row)
//                        // delete the table view row
//                        tableView.deleteRows(at: [indexPath], with: .fade)
//                        if self.contactDictArray.count == 0 {
//                            self.contactListTableView.isHidden = true
//                        }
//                        else if self.contactDictArray.count == self.contactCount {
//                            self.addContactButtonOutlet.isHidden = true
//                        }
//                        else if self.contactDictArray.count < self.contactCount && self.contactDictArray.count > 0 {
//                            self.addContactButtonOutlet.isHidden = false
//                        }
//                        else {
//                            self.contactListTableView.isHidden = false
//                        }
//                    }
//                    else {
//                        self.appDelegate.createToastMessageForAlamofire(responseJson["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
//                    }
//
//                }
//            }){(error) in
//
//            }
            
            UberSupport.shared.showProgressInWindow(showAnimation: true)
            self.apiInteractor?
                .getRequest(for: .sos,params: paramDict)
                .responseJSON({ (json) in
                    if json.isSuccess{
                        // remove the item from the data model
                        if json.status_code == 0 {
                            UberSupport.shared.removeProgressInWindow()
                            self.appDelegate.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)
                            
                        } else {
                            UberSupport.shared.removeProgressInWindow()
                            // delete the table view row
                            if let _ = self.contactDictArray.value(atSafe: indexPath.row) {
                                self.contactDictArray.remove(at: indexPath.row)
                                self.contactListTableView.deleteRows(at: [indexPath], with: .automatic)
                            }
//
                            if self.contactDictArray.count == 0 {
                                self.contactListTableView.isHidden = true
                            }
                            else if self.contactDictArray.count == self.contactCount {
                                self.addContactButtonOutlet.isHidden = true
                            }
                            else if self.contactDictArray.count < self.contactCount && self.contactDictArray.count > 0 {
                                self.addContactButtonOutlet.isHidden = false
                            }
                            else {
                                self.contactListTableView.isHidden = false
                            }
                        }
                    }else{
                        UberSupport.shared.removeProgressInWindow()
                        self.appDelegate.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)

                    }
                }).responseFailure({ (error) in
                        UberSupport.shared.removeProgressInWindow()
                    self.appDelegate.createToastMessage(error, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)
                })
        } else if editingStyle == .insert {
            // Not used, but if you were adding a new row, this is where you would do it.
        }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return NSLocalizedString("Delete", comment: "")
        return self.language.delete
    }
    
    
    //MARK:- CNContactPickerDelegate Method
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        var number = String()
        if let phoneNo = contactProperty.value as? CNPhoneNumber{
            number = phoneNo.stringValue
        }else{
            number = "NO NUMBER"
        }
        
        print(contactProperty.contact.phoneNumbers)
        var contactDict = [String:Any]()
        contactDict["name"] = contactProperty.contact.givenName
        contactDict["mobile_number"] = number
        for contact in contactDictArray {
            if (contact["mobile_number"] as? String ?? String()) == (contactDict["mobile_number"] as? String ?? String()) {
                
                let uiAlert = UIAlertController(title: self.language.message, message: self.language.contactAlreadyAdded, preferredStyle: UIAlertController.Style.alert)
                
                self.present(uiAlert, animated: true, completion: nil)
                
                
                uiAlert.addAction(UIAlertAction(title: self.language.ok, style: .default, handler: { action in
                }))
                
                uiAlert.addAction(UIAlertAction(title: self.language.cancel, style: .cancel, handler: { action in
                }))
                
                
                
            }
            
        }
        self.displayContactView(for: contactProperty)
        /*
        
   */
    }
    func addContact(withName name : String,number : String, country : CountryModel){
        // test
        let paramDict = ["token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN),
                         "mobile_number" : number,
                         "country_code" : country.country_code,
                         "action" : "update",
                         "name" : name] as JSON
        
//        WebServiceHandler.sharedInstance.getWebService(wsMethod:"sos", paramDict: paramDict, viewController:self, isToShowProgress:true, isToStopInteraction:false,complete: { (response) in
//            let responseJson = response
//            DispatchQueue.main.async {
//                if responseJson["status_code"] as? String == "1" {
//                    let contactDict = responseJson["contact_details"] as! [[String:Any]]
//                    self.contactDictArray = contactDict
//                    if self.contactDictArray.count > 0 {
//                        self.contactListTableView.isHidden = false
//                        self.contactListTableView.reloadData()
//                        if self.contactDictArray.count == self.contactCount {
//                            self.addContactButtonOutlet.isHidden = true
//                        }
//                        else {
//                            self.addContactButtonOutlet.isHidden = false
//                        }
//                    }
//                    self.hideContactView()
//                }
//                else {
//                    self.appDelegate.createToastMessageForAlamofire(responseJson["status_message"] as? String ?? String(), bgColor: UIColor.black, textColor: UIColor.white, forView:self.view)
//                }
//
//            }
//        }){(error) in
//
//        }
        
        
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .sos,params: paramDict)
            .responseJSON({ (json) in
                if json.isSuccess{
                    if json.status_code == 0 {
                        UberSupport.shared.removeProgressInWindow()
                        self.appDelegate.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)

                    }else{
                    UberSupport.shared.removeProgressInWindow()
                    let contactDict = json["contact_details"] as! [[String:Any]]
                    self.contactDictArray = contactDict
                    if self.contactDictArray.count > 0 {
                        self.contactListTableView.isHidden = false
                        self.contactListTableView.reloadData()
                        if self.contactDictArray.count == self.contactCount {
                            self.addContactButtonOutlet.isHidden = true
                        }
                        else {
                            self.addContactButtonOutlet.isHidden = false
                        }
                    }
                    self.hideContactView()
                }
                }else{
                    UberSupport.shared.removeProgressInWindow()
                    self.appDelegate.createToastMessage(json.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)

                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
                self.appDelegate.createToastMessage(error, bgColor: UIColor.ThemeYellow, textColor: UIColor.Title)
            })
    }

}
extension EmergencyContactViewController : CountryListDelegate{
    func pushToCountryVC(){
        let propertyView = CountryListVC.initWithStory(selectedFlag: nil)
        propertyView.delegate = self
        self.presentInFullScreen(propertyView, animated: true, completion: nil)
    }
    func countryCodeChanged(countryCode: String, dialCode: String, flagImg: UIImage) {
        let country = CountryModel(forDialCode: dialCode, withCountry: countryCode)
        if !country.isAccurate{
            country.country_code = countryCode
            country.dial_code = dialCode
            country.flag = flagImg
        }
        self.selectedCountry = country
        self.mobileNumberView.countryIV.image = country.flag
        self.mobileNumberView.countyCodeLbl.text = country.dial_code
    }
    
    @objc func doneAction(){
        self.view.endEditing(true)
//        self.checkStatus()
    }
    func displayContactView(for contact : CNContactProperty){
        self.confirmNameTF.text = ""
        self.confirmNameTF.placeholder = self.language.firstName
    
        guard let number = (contact.value as? CNPhoneNumber)?.stringValue else{
                return
        }
        let country = CountryModel(withCountry: UserDefaults.standard.string(forKey: USER_COUNTRY_CODE) ?? "US")
        self.selectedCountry = country
        self.confirmContactHolderView.backgroundColor = .clear
        
        UIView.animateKeyframes(
            withDuration: 1.2,
            delay: 0.2,
            options: UIView.KeyframeAnimationOptions.beginFromCurrentState,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) {
                    self.confirmContactHolderView.transform = .identity
                }
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.6) {
                    self.confirmContactHolderView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
                    self.confirmNameTF.text = contact.contact.givenName
                    self.mobileNumberView.numberTF.text = number
                    self.mobileNumberView.countryIV.image = country.flag
                    self.mobileNumberView.countyCodeLbl.text = country.dial_code
                    self.mobileNumberView.numberTF?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
                    self.mobileNumberView.countyCodeLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 18)
                    
                }
        }) { (completed) in
            
        }
        self.listen2Keyboard(withView: self.confirmContactHolderView)
    }
    func hideContactView(with duration : TimeInterval = 0.6){
        UIView.animate(withDuration: duration) {
            self.confirmContactHolderView.backgroundColor = .clear
            self.confirmContactHolderView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        }
        self.selectedCountry = nil
        self.ignore2Keyboard()
    }
}
