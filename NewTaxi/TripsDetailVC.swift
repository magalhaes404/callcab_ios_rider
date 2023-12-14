/**
* TripsDetailVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import AVFoundation

class TripsDetailVC : UIViewController,APIViewProtocol, UITableViewDelegate, UITableViewDataSource
{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch response {
        default:
            break
        }
    }
    func onFailure(error: String, for API: APIEnums) {
    }
    var seats = Int()
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var SeparateView: UIView!
    @IBOutlet weak var imgMapRoot : UIImageView!
    @IBOutlet weak var imgUserThumb : UIImageView!
    @IBOutlet weak var tblTripsInfo : UITableView!
    @IBOutlet weak var lblPickUpLoc : UILabel!
    @IBOutlet weak var lblDropLoc : UILabel!
    @IBOutlet weak var lblTripTime: UILabel!
    @IBOutlet weak var NoofSeats: UILabel!
    @IBOutlet weak var tripIDlbl: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblCarType: UILabel!
    @IBOutlet weak var lblTripStatus: UILabel!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var lblPageTitle : UILabel!
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var greenDotView: UIView!
    @IBOutlet weak var mapIVHeight : NSLayoutConstraint!
    @IBOutlet weak var headerView : UIView!
    @IBOutlet weak var dottedView: UIView!
    var tripData : TripDataModel!
    var tripId: Int = 0
    
    var tripDetailData : TripDetailDataModel?{
        didSet{
            if let detail = self.tripDetailData {self.tripData = detail}
            
        }
    }
    lazy var tripsDetailsDict = [[String:Any]]()
    lazy var selectedIndex = Int()
    var arrInfoKey : NSMutableArray = NSMutableArray()
    let strCurrency = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)

    lazy var language : LanguageProtocol = {Language.default.object}()
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.SeparateView.setSpecificCornersForTop(cornerRadius: 35)
        self.SeparateView.elevate(10)
        self.setfonts()
        self.settextcolor()
        self.dottedView.backgroundColor = .clear
//        self.drawDottedLine(start: CGPoint(x: self.dottedView.bounds.minX, y: self.dottedView.bounds.minY), end: CGPoint(x: self.dottedView.bounds.maxX, y: self.dottedView.bounds.maxY), view: self.dottedView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dottedView.backgroundColor = .clear
            self.dottedView.addDashedBorder(view: self.dottedView)
        }
        self.imgMapRoot.cornerRadius = 20
        self.greenDotView.isHidden = true
        self.redDotView.isHidden = true
        self.apiInteractor = APIInteractor(self)
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        if let data = tripDetailData{
            self.setDefaultUserInfo(withTripDetail: data)
        }else{
            UberSupport.shared.showProgressInWindow(showAnimation: true)
            self.apiInteractor?
                .getRequest(for: .getTripDetail,params: ["trip_id" : self.tripId,"cache" : 1])
                .responseJSON({ (json) in
                    if json.isSuccess{
                        UberSupport.shared.removeProgressInWindow()
                        let detail = TripDetailDataModel(json)
                        self.tripId = detail.id
                        self.setDefaultUserInfo(withTripDetail : detail)
                    }else{
                        if json.status_message != ""
                        {
                            AppDelegate.shared.createToastMessage(json.status_message)
                            UberSupport.shared.removeProgressInWindow()
                        }
                    }
                }).responseFailure({ (error) in
                    if error != "" {
                        AppDelegate.shared.createToastMessage(error)
                            UberSupport.shared.removeProgressInWindow()
                    }
                })
        }
        self.initView()
        self.initLanguage()
        self.initLayer()
        
    }
    //MARK:- initializers
    func initView(){
        
        self.tblTripsInfo.backgroundColor = .clear
    }
    func initLayer(){
        
        imgUserThumb.clipsToBounds = true
        imgUserThumb.layer.cornerRadius = 10
    }
    func initLanguage(){
        self.lblPageTitle.text = self.language.tripDetails
    }
    func setfonts(){
        self.lblTripTime?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblCarType?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.NoofSeats?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblCost?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.lblTripStatus?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblPickUpLoc?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblDropLoc?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblDriverName?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblPageTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.tripIDlbl?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 15)
        
        
    }
    func settextcolor(){
        self.lblTripTime.textColor = .Title
        self.lblTripTime.alpha = 0.5
        self.lblCarType.textColor = .Title
        self.lblCarType.alpha = 0.5
        self.NoofSeats.textColor = .Title
        self.NoofSeats.alpha = 0.5
        self.lblCost.textColor = .Title
        self.lblTripStatus.textColor = .Title
        self.lblTripStatus.alpha = 0.5
        self.lblPickUpLoc.textColor = .Title
        self.lblDropLoc.textColor = .Title
        self.lblDriverName.textColor = .ThemeYellow
        self.lblPageTitle.textColor = .Title
        self.tripIDlbl.textColor = .Title
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.DarkTitle.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3]
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
   // SET THE TRIPS DETAIL VALUES FROM THE API
    func setDefaultUserInfo(withTripDetail data : TripDetailDataModel) {
        
        var height : CGFloat = 470
        if [TripStatus.cancelled,
            .manualBookiingCancelled].contains(data.status) {
            height = 320
            self.mapView.isHidden = true
        } else {
//            imgMapRoot.sd_setImage(with: data.getWorkingMapURL())
            if data.mapImage != ""
            {
                self.mapView.isHidden = false
                imgMapRoot.sd_setImage(with: data.getWorkingMapURL())
            }else{
                height = 320
                self.mapView.isHidden = true
            }

        }
        
        let header = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: self.tblTripsInfo.frame.width,
                                          height: height))
        self.contentStack.sizeToFit()
        header.addSubview(self.headerView)
        self.contentStack.anchor(toView: header,
                                 leading: 15,
                                 trailing: -15,
                                 top: 15,
                                 bottom: -15)
        header.sizeToFit()
        self.tblTripsInfo.tableHeaderView = header
        self.redDotView.isHidden = false
        self.greenDotView.isHidden = false
        self.tripDetailData = data
        if arrInfoKey.count == 0 {
        }
        lblPickUpLoc.text = data.pickupLocation
        lblDropLoc.text = data.dropLocation
        lblTripTime.text = data.createdAt
        
        if data.isShareRide == true {
            NoofSeats.isHidden = false
            NoofSeats.text =  "\(language.noofseats) " + tripData.seats.description
            
        }else{
            
            NoofSeats.isHidden = true
            
        }
        tripIDlbl.text = "\(language.tripID )" + " " + data.getTripID
        lblCost.text = String(format:"%@ %@",strCurrency,data.totalFare.description)
        lblTripStatus.text = NSLocalizedString("\(data.status)", comment: "")
        lblCarType.text = data.vehicleName
        imgUserThumb.sd_setImage(with: URL(string: data.driverThumbImage), placeholderImage:UIImage(named:"user_dummy.png"))
        lblDriverName.text = "\(self.language.yourTripWith) \(data.driverName)"
        self.view.layoutIfNeeded()
        self.tblTripsInfo.layoutIfNeeded()
        self.headerView.layoutIfNeeded()
        tblTripsInfo.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: *****Table view Delegate and Datasource Methods *****
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.tripDetailData?.invoice.count ?? 0//arrInfoKey.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellTripsInfo = tblTripsInfo.dequeueReusableCell(withIdentifier: "CellTripsInfo")! as! CellTripsInfo
        cell.contentView.backgroundColor = .clear
        
        guard let trip = self.tripDetailData,
            let invoiceItem = trip.invoice.value(atSafe: indexPath.row) else{return cell}
        cell.lblTitle?.text = invoiceItem.invoiceKey
        cell.lblCostInfo.text = invoiceItem.invoiceValue
        cell.setBar(invoiceItem.bar == 1)
        let colorStr = invoiceItem.color
        if !colorStr.isEmpty{
            if invoiceItem.invoiceKey == "Total trip fare" {
                cell.lblCostInfo.textColor = .ThemeYellow
                cell.lblTitle?.textColor = .ThemeYellow
                
            }else{
                cell.lblCostInfo.textColor = .Title
                cell.lblTitle?.textColor = .Title
            }
            cell.lblCostInfo.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(18))
            cell.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(18))
        }else{
            cell.lblCostInfo.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(16))
            cell.lblTitle?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: CGFloat(16))
            let color = UIColor(hex: "000000")
            cell.lblCostInfo.textColor = color
            cell.lblTitle?.textColor = color
        }
        if let comment = invoiceItem.comment{
            cell.lblTitle?.text = cell.lblTitle!.text! + " ⓘ"
            cell.lblTitle!.addAction(for: .tap) { [unowned self] in
                self.showPopOver(withComment: comment,on : cell.lblTitle!)
            }
        }else{
            cell.lblTitle?.addAction(for: .tap) {}
        }
        return cell
    }

    // MARK: When User Press Back Button
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        self.navigationController!.popViewController(animated: true)
    }
    
    
}

class CellTripsInfo : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var lblArrow: UILabel!
    @IBOutlet var lblCostInfo: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    let bar = UIView()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.subviews.forEach { (child) in
            child.isHidden = child.frame.height <= 2
        }
        bar.frame = CGRect(x: 0, y: 1, width: self.contentView.frame.width, height: 1)
        bar.backgroundColor = .BorderCell
        self.contentView.addSubview(bar)
    }
    func setBar(_ val : Bool){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.bar.frame = CGRect(x: 0, y: 1, width: self.contentView.frame.width, height: 1)
            self.bar.isHidden = !val
        }
    }
}
