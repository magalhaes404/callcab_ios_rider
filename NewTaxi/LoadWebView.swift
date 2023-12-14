/**
* LoadWebView.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import MessageUI
import Social

class LoadWebView : UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var lblTitle: UILabel!
    lazy var lang = Language.default.object
    var strPageTitle = ""
    var strWebUrl = ""
    var strCancellationFlexible = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate

    let arrHelpInfo = [NSLocalizedString("Help", comment: ""),NSLocalizedString("Additional topics", comment: ""),NSLocalizedString("Trips and Fare Review", comment: ""),NSLocalizedString("Account and Payment Options", comment: ""),"\(NSLocalizedString("A Guide to ", comment: ""))\(iApp.appName)",NSLocalizedString("Signing Up", comment: ""),NSLocalizedString("More", comment: ""),NSLocalizedString("Accessibility", comment: "")]
// MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.backBtn.setTitle(self.lang.getBackBtnText(), for: .normal)
        self.navigationController?.isNavigationBarHidden = true
        lblTitle.text = self.lang.help
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func goBack()
    {
        OperationQueue.main.addOperation {
            self.navigationController!.popViewController(animated: true)
        }
    }

    @IBAction func onAddTitleTapped(_ sender:UIButton!)
    {
        
    }

    @IBAction func onAddSummaryTapped(_ sender:UIButton!)
    {
        
    }

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController!.popViewController(animated: true)
    }
    
   
    func onAddListTapped(){
        
    }
}

