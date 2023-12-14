/**
 * FareEstimationVC.swift
 *
 * @package NewTaxi
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */



import UIKit
import Foundation

class FareEstimationVC : UIViewController//, SMDatePickerDelegate
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var viewObjectHolder: UIView!
    @IBOutlet var btnPriceBreakdown: UIButton!
    @IBOutlet var lblBaseFare: UILabel!
    @IBOutlet var lblSeatCapacity: UILabel!
    @IBOutlet var lblCarName: UILabel!
    @IBOutlet weak var carImageBtn : UIButton!
    @IBOutlet weak var affordableLbl: UILabel!
    @IBOutlet weak var fareTit: UILabel!
    @IBOutlet weak var capacityTit: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    lazy var lang = Language.default.object

    func setDesign() {
        
        self.carImageBtn.imageView?.contentMode = .scaleAspectFit
        
        self.viewObjectHolder.setSpecificCornersForTop(cornerRadius: 35)
        self.lblCarName.textColor = .Title
        self.lblCarName.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 25)
        
        self.affordableLbl.textColor = .Title
        self.affordableLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        
        self.lblBaseFare.textColor = .Title
        self.lblBaseFare.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.fareTit.textColor = .Title
        self.fareTit.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        
        self.capacityTit.textColor = .Title
        self.capacityTit.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.lblSeatCapacity.textColor = .Title
        self.lblSeatCapacity.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        
        self.descriptionLbl.textColor = UIColor.Title.withAlphaComponent(0.45)
        self.descriptionLbl.font = UIFont(name: iApp.NewTaxiFont.centuryRegular.rawValue, size: 13)
        
        self.btnPriceBreakdown.setTitleColor(.Title, for: .normal)
        
        self.doneBtn.setTitleColor(.Title, for: .normal)
        self.doneBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.doneBtn.cornerRadius = 15
        self.doneBtn.backgroundColor = .ThemeYellow
        
    }
    
    
    var carModel : SearchCarsModel!
    
    var strCarName = ""
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.affordableLbl.text = self.lang.affordableEveryRide
        self.fareTit.text = self.lang.fare
        self.capacityTit.text = self.lang.capacity
        self.doneBtn.setTitle(self.lang.done, for: .normal)
        self.descriptionLbl.text = self.lang.descriptionFareEstimation
        
        if carModel != nil
        {
            self.setFareInfo()
        }
        self.setDesign()
    }
    //MARK:- initWithStory
    class func initWithStory(for car : SearchCarsModel) -> FareEstimationVC{
        let fareVC : FareEstimationVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        fareVC.carModel = car
        fareVC.view.backgroundColor = UIColor.clear
        fareVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        return fareVC
    }
    func setFareInfo()
    {
        let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        lblBaseFare.text = String(format:"%@ %@",strCurrency,carModel.fare_estimation)
        lblSeatCapacity.text = carModel.capacity
        lblCarName.text = NSLocalizedString(carModel.car_name, comment: "")
        self.carImageBtn.setImage(nil, for: .normal)
        self.carImageBtn.setBackgroundImage(nil, for: .normal)
        self.carImageBtn.sd_setImage(with: URL(string: carModel.car_active_image), for: .normal)
    }
    // MARK: When User Press pricedrop down Button
    
    @IBAction func onPriceBreakDownTapped(_sender : UIButton!)
    {
        let viewPrice = PriceBreakDownVC.initWithStory(for: self.carModel)
       
        present(viewPrice, animated: true, completion: nil)
    }
    
    @IBAction func onCarOrDoneTapped(_sender : UIButton!)
    {
        dismiss(animated: true, completion: {
        })
    }
    
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
}
