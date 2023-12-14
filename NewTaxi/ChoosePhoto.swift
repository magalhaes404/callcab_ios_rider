/**
* ChoosePhoto.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/



import UIKit
import Foundation

protocol ChoosePhotoDelegate
{
    func onPhotoChoosedDelegateTapped(btnTag:Int)
}

class ChoosePhoto : UIViewController
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet weak var selectPhotoLbl: UILabel!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var chooseLib: UIButton!

    func setDesign() {
        self.viewObjectHolder.setSpecificCornersForTop(cornerRadius: 35)
        self.viewObjectHolder.backgroundColor = .white
        self.viewObjectHolder.elevate(3)
        
        self.selectPhotoLbl.textColor = .Title
        self.selectPhotoLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.takePhoto.backgroundColor = .ThemeYellow
        self.takePhoto.setTitleColor(.Title, for: .normal)
        self.takePhoto.cornerRadius = 15
        self.takePhoto.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.chooseLib.backgroundColor = .ThemeYellow
        self.chooseLib.setTitleColor(.Title, for: .normal)
        self.chooseLib.cornerRadius = 15
        self.chooseLib.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.btnCancel.backgroundColor = .white
        self.btnCancel.setTitleColor(.Title, for: .normal)
        self.btnCancel.border(1, .ThemeYellow)
        self.btnCancel.cornerRadius = 15
        self.btnCancel.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
    }
    
    var strFirstName = ""
    var strLastName = ""
    var isFromOther : Bool = false
    var delegate: ChoosePhotoDelegate?
    lazy var lang = Language.default.object
    
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnCancel.setTitle(self.lang.cancel, for: .normal)
//        self.selectPhotoLbl.text = self.lang.sel

        self.selectPhotoLbl.text = self.lang.selectPhoto
        self.takePhoto.setTitle(self.lang.takePhoto, for: .normal)
        self.chooseLib.setTitle(self.lang.chooseLib, for: .normal)
        self.setDesign()
//        btnCancel.layer.borderColor = UIColor.ThemeMain.cgColor
//        btnCancel.layer.borderWidth = 1.0
    }
    
    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        },  completion: { (finished: Bool) -> Void in
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        setupShareAppViewAnimationWithView(viewObjectHolder)
    }

    // MARK: Navigating to Email field View
    /*
     */
    @IBAction func onAlertTapped(_ sender:UIButton!)
    {
        if sender.tag == 11 || sender.tag == 22
        {
            dismiss(animated: true, completion: {
                self.delegate?.onPhotoChoosedDelegateTapped(btnTag:sender.tag)
            })
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
}
