/**
* ScheduleRiderVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/



import UIKit
import Foundation


protocol ScheduleRiderDelegate
{
    func onScheduleRiderTapped(scheduledTime:String)
}


class ScheduleRiderVC : UIViewController
{
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var viewObjectHolder: UIView!
    @IBOutlet weak var lblSchedleTime: UILabel!
    @IBOutlet weak var viewPickerHolder: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var setUrPickLbl:UILabel!
    @IBOutlet weak var setPickupTime: UIButton!
    
    var strFirstName = ""
    var strLastName = ""
    var delegate: ScheduleRiderDelegate?
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    lazy var language:LanguageProtocol = Language.default.object

    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setDesign()
        self.setUrPickLbl.text = self.language.setUrPickUp
        self.setPickupTime.setTitle(self.language.setPicktUpTime, for: .normal)
        if #available(iOS 13.4, *) {
            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            } // Replace .inline with .compact
                   }
        datePicker.minimumDate = Date().addingTimeInterval(15 * 60)
        datePicker.maximumDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
        datePicker.locale = NSLocale(localeIdentifier: "en_US") as Locale
        datePicker.addTarget(self, action: #selector(self.onDidChangeDate), for: .valueChanged)
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "EEE, dd MMM yyyy ~ hh:mm a"
        myDateFormatter.locale = Locale(identifier: "en_US")
        let endDateFormatter: DateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "hh:mm a"
        endDateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        let mySelectedDate: NSString = myDateFormatter.string(from: Date().addingTimeInterval(15 * 60)) as NSString
        lblSchedleTime.text = "\(String(format:"%@",mySelectedDate.replacingOccurrences(of: "~", with: "at"))) - \(endDateFormatter.string(from: Date().addingTimeInterval(30 * 60)) as NSString)"       
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.dismissTapped(_:)))
        self.view.addGestureRecognizer(tap)
//        self.lblSchedleTime.font = UIFont(name: iApp.NewTaxiFont.medium.font, size: 15)
        
    }
    func setDesign()
    {
        self.viewObjectHolder.setSpecificCornersForTop(cornerRadius: 35)
        self.viewObjectHolder.elevate(4)
        self.setUrPickLbl.textColor = .Title
        self.setUrPickLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.setPickupTime.cornerRadius = 15
        self.setPickupTime.backgroundColor = .ThemeYellow
        self.setPickupTime.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.setPickupTime.setTitleColor(.Title, for: .normal)
        self.lblSchedleTime.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.lblSchedleTime.textColor = .Title
        self.border.backgroundColor = .Border
    }
    //MARK:- initWithStory
    class func initWithStory() -> ScheduleRiderVC{
        return UIStoryboard.payment.instantiateViewController()
    }
    @objc func dismissTapped(_:UIGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // called when the date picker called.
    @objc internal func onDidChangeDate(){
        // date formatdidchagepic
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "EEE, dd MMM yyyy ~ hh:mm a"
        myDateFormatter.locale = Locale(identifier: "en_us_posix")
        let endDateFormatter: DateFormatter = DateFormatter()
        endDateFormatter.dateFormat = "hh:mm a"
        endDateFormatter.locale = NSLocale(localeIdentifier: "en_us_posix") as Locale
        // get the date string applied date format
        let mySelectedDate: NSString = myDateFormatter.string(from: datePicker.date) as NSString
        lblSchedleTime.text = "\(String(format:"%@",mySelectedDate.replacingOccurrences(of: "~", with: "at"))) - \(endDateFormatter.string(from: datePicker.date.addingTimeInterval(15 * 60)) as NSString)"
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
        
// MARK:- SETTING PICKUP TIME TO DELEGATE    
    @IBAction func onButtonTapped(_ sender:UIButton!)
    {
        guard let time = self.lblSchedleTime.text else {return}
        dismiss(animated: true, completion: {
            self.delegate?.onScheduleRiderTapped(scheduledTime:time)
        })
    }
}

