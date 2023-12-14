/**
* AddPaymentVC.swift
*
* @package UberClone
* @author Seentechs Product Team
* @version - Stable 1.0
* @link http://seentechs.com
*/

import UIKit
import AVFoundation

//protocol EditProfileDelegate
//{
//    func profileInfoChanged(modelPro: ProfileModel)
//}

class AddPaymentVC : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var tblPayment : UITableView!
    @IBOutlet var btnBack : UIButton!
    @IBOutlet var lblTitle : UILabel!

    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var strPayPalEmailID = Constants().GETVALUE(keyname: USER_PAYPAL_EMAIL_ID)
    var isFromHomePage : Bool = false
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnBack.isHidden = isFromHomePage ? true : false
        lblTitle.text = "Payout"
        if isFromHomePage
        {
            var rectLbl = lblTitle.frame
            rectLbl.origin.y = 20
            lblTitle.frame = rectLbl
            
            var rectTable = tblPayment.frame
            rectTable.origin.y = 20 + lblTitle.frame.size.height
            rectTable.size.height = tblPayment.frame.size.height + lblTitle.frame.size.height
            tblPayment.frame = rectTable
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        UberSupport().changeStatusBarStyle(style: .lightContent)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: ---------------------------------------------------------------
    //MARK: ***** Edit Profile Table view Datasource Methods *****
    /*
     Edit Profile List View Table Datasource & Delegates
     */
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (self.view.frame.size.width) ,height: 35)
        viewHolder.backgroundColor = UIColor(red: 249.0 / 255.0, green: 249.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
        return viewHolder
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return  1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellPayment = tblPayment.dequeueReusableCell(withIdentifier: "CellPayment")! as! CellPayment
        cell.lblTitle?.text = (strPayPalEmailID.characters.count > 0) ? strPayPalEmailID : "Add Payout Method"
        cell.lblTitle?.textColor = (strPayPalEmailID.characters.count > 0) ? UIColor.black : UIColor(red: 28.0 / 255.0, green: 92.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
//        var rect = cell.lblTitle?.frame
//        if (strPayPalEmailID.characters.count > 0)
//        {
//            rect?.origin.x = 60
//        }
//        else
//        {
//            rect?.origin.x = 20
//        }
//        cell.lblTitle?.frame = rect!
        return cell
    }
    
    //MARK: ---- Table View Delegate Methods ----
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let propertyView = self.storyboard?.instantiateViewController(withIdentifier: "PaymentEmailVC") as! PaymentEmailVC
//        propertyView.strEmailID = strPayPalEmailID
//        propertyView.delegate = self
//        self.navigationController?.pushViewController(propertyView, animated: true)
    }
    
    // MARK: - PAYMENTEMAILVC DELEGATE METHOD
    /*
        AFTER USER ADDED THE PAYPAL EMAIL ID
     */
    internal func onPayPalEmailAdded(emailID: String)
    {
        Constants().STOREVALUE(value: emailID, keyname: USER_PAYPAL_EMAIL_ID)
        strPayPalEmailID = emailID
        tblPayment.reloadData()
        
        if isFromHomePage
        {
            let userDefaults = UserDefaults.standard
            userDefaults.set("driver", forKey:"getmainpage")
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onSetRootViewController(viewCtrl: self)
        }
    }
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController!.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

