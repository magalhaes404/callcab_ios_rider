//
//  SupportVC.swift
// NewTaxi
//
//  Created by Seentechs on 16/11/20.
//  Copyright © 2020 Vignesh Palanivel. All rights reserved.
//

import UIKit

class SupportVC: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var Separateview: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var supportTable: UITableView!
    @IBOutlet weak var holderview: UIView!
    @IBOutlet weak var baseView: UIView!
    lazy var lang = Language.default.object

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Separateview.setSpecificCornersForTop(cornerRadius: 35)
        self.Separateview.elevate(10)
        self.supportTable.delegate = self
        self.supportTable.dataSource = self
        self.titleLabel.text = self.lang.support
        self.backBtn.setTitle(self.lang.isRTLLanguage() ? "I" : "e", for: .normal)
        self.setfont()
    }
    func setfont(){
        self.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
    }
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Shared.instance.supportArray?.count ?? 0
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SupportTCell = tableView.dequeueReusableCell(for: indexPath)
        guard let supportModel = Shared.instance.supportArray?.value(atSafe: indexPath.row) else{
                return cell
        }
        cell.outerView.border(1, .Border)
        cell.outerView.cornerRadius = 10
        cell.menuIcon.sd_setImage(with: NSURL(string: supportModel.image)! as URL, completed: nil)
        cell.titleLbl.text = supportModel.name
        cell.titleLbl?.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 16)
        cell.titleLbl.textColor = .ThemeMain
         return cell
     }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        guard let supportModel = Shared.instance.supportArray?.value(atSafe: indexPath.row) else{
                return
        }
        if supportModel.id == 1 {
            let phoneNumber = supportModel.link.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
//            let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)&text=")!
//            let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
//            let usefullWhere: String = "whatsapp://?app"//
            let usefullWhere: String = "whatsapp://send?phone=\(phoneNumber)&text=hi"
            let url : URL = NSURL(string: usefullWhere)! as URL
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // WhatsApp is not installed

//                    let appURL = URL(string: "https://apps.apple.com/in/app/whatsapp-messenger/id310633997")!
                let appURL = URL(string: "https://www.whatsapp.com")!

                    if UIApplication.shared.canOpenURL(appURL) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(appURL)
                        }
                    }

            }
        }else if supportModel.id == 2 {
            let skype: NSURL = NSURL(string: String(format: "skype:" + supportModel.link.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "") + "?chat"))! //add object skype like this
            if UIApplication.shared.canOpenURL(skype as URL) {
                UIApplication.shared.open(skype as URL)
             }
            else {
            // skype not Installed in your Device
                let skypeUrl: NSURL = NSURL(string: String(format: "https://itunes.apple.com/in/app/skype/id304878510?mt=8"))!
                UIApplication.shared.open(skypeUrl as URL)
            }
            
        }else{
            guard let skypeUrl: NSURL = NSURL(string: String(format: supportModel.link.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: ""))) else {
                self.presentAlertWithTitle(title: iApp.appName.capitalized,
                                           message: self.lang.notAValidData,
                                           options: self.lang.ok) { (_) in
                                            
                }
                return
            }
            if UIApplication.shared.canOpenURL(skypeUrl as URL) {
                UIApplication.shared.open(skypeUrl as URL)
            }else{
                let skypeUrl2: NSURL = NSURL(string: String(format: "http://" + supportModel.link.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")))!
                if UIApplication.shared.canOpenURL(skypeUrl2 as URL) {
                    UIApplication.shared.open(skypeUrl2 as URL)
                }else{
                    self.presentAlertWithTitle(title: iApp.appName.capitalized,
                                               message: self.lang.notAValidData,
                                               options: self.lang.ok) { (_) in
                                                
                    }
                }
            }
        }
     }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
        return 80
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    class func initWithStory()-> SupportVC{
        let view : SupportVC = UIStoryboard(name: "jeba", bundle: nil).instantiateViewController()
        return view
    }
    
}
class SupportTCell: UITableViewCell
{
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    static let identifier = "SupportTCell"
}
