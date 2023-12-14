//
//  TripHistoryVC.swift
// NewTaxi
//
//  Created by Seentechs on 14/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Alamofire
import Lottie

class TripHistoryVC: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        switch response {

        default:
            break
        }
    }
    func onFailure(error: String, for API: APIEnums) {
        switch API {
        default:
            break
        }
    }
    enum Tabs{
        case past
        case upComming
    }
    
    //MARK:- Outlets
    @IBOutlet weak var navView : UIView!
    @IBOutlet weak var pageTitleLbl : UILabel!
    @IBOutlet weak var backBtn : UIButton!
    
    @IBOutlet weak var pastTitleBtn : UIButton!
    @IBOutlet weak var upCommingTitleBtn : UIButton!
    @IBOutlet weak var sliderView : UIView!
   
    @IBOutlet weak var parentScrollView : UIScrollView!
    @IBOutlet weak var stackScrollChild : UIStackView!
    @IBOutlet weak var viewScrollChild : UIView!
    @IBOutlet weak var pastTable : UITableView!
    @IBOutlet weak var upCommingTable : UITableView!
    
    @IBOutlet weak var pendingBgView: UIView!
    @IBOutlet weak var upcommingBgView: UIView!
    @IBOutlet weak var btnsBGView: UIView!
    
    @IBOutlet weak var pastHolder: UIView!
    @IBOutlet weak var upcomingHolder: UIView!
    
    var isFromSchdule:Bool = false
    //MARK:- Getter setters
    var currentTab : Tabs = .past{
        didSet{
            let isPast = currentTab == .past
            
            UIView.animate(withDuration: 0.3, animations: {
                
             
                if self.language.isRTLLanguage(){
                    
                    self.parentScrollView.contentOffset = isPast
                        ? CGPoint(x: self.pastHolder.frame.minX,
                                  y: 0)
                        : CGPoint.zero
                    self.sliderView.transform = isPast
                        ? .identity
                        : CGAffineTransform(translationX: -self.pastTitleBtn.frame.minX, y: 0)
                }else{
                    self.parentScrollView.contentOffset = isPast
                        ? CGPoint.zero
                        : CGPoint(x: self.upcomingHolder.frame.minX,
                                  y: 0)
                    self.sliderView.transform = isPast
                        ? .identity
                        : CGAffineTransform(translationX: self.upCommingTitleBtn.frame.minX , y: 0)
                    
                }
                
            }){ completed in
                if completed{
                    isPast ? self.pastTable.reloadData() : self.upCommingTable.reloadData()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.pastTrips.removeAll()
//        self.upCommingTrips.removeAll()
//        self.apiInteractor = nil
//        self.pastTable.tableFooterView = nil
//        self.upCommingTable.tableFooterView = nil
//        self.pastTable.refreshControl = nil
//        self.upCommingTable.refreshControl = nil
//        self.pastLoader?.removeFromSuperview()
//        self.upCommingLoader?.removeFromSuperview()
//        self.pastRefresher?.removeFromSuperview()
//        self.upCommingRefresher?.removeFromSuperview()
//        self.pastLoader = nil
//        self.upCommingLoader = nil
//        self.pastRefresher = nil
//        self.upCommingRefresher = nil
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("ååååå: Memory Warning")
    }
    
    func setDesign() {
        self.pageTitleLbl.textColor = .Title
        self.pageTitleLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        
        self.btnsBGView.backgroundColor = .white
    
        self.pastTitleBtn.setTitleColor(.Title, for: .normal)
        self.pastTitleBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 21)
        self.pastTitleBtn.backgroundColor = .white
        
        
        self.upCommingTitleBtn.setTitleColor(.Title, for: .normal)
        self.upCommingTitleBtn.titleLabel?.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 21)
        self.upCommingTitleBtn.backgroundColor = .white
        
        self.sliderView.backgroundColor = .ThemeYellow
        
        self.pendingBgView.setSpecificCornersForTop(cornerRadius: 35)
        self.pendingBgView.elevate(4)
        
        self.upcommingBgView.setSpecificCornersForTop(cornerRadius: 35)
        self.upcommingBgView.elevate(4)
        
    }
    //MARK:- Variabels
    var pastTrips = [History]()
    var upCommingTrips = [History]()
    
    //MARK:- Refreshers
    var pastRefresher : UIRefreshControl?

    var upCommingRefresher : UIRefreshControl?
    //MARK:- loaders
    var pastLoader : UIActivityIndicatorView?
    
    var upCommingLoader : UIActivityIndicatorView?
    //MARK:- indexed
    var currentUpCommingTripPageIndex = 1{
        didSet{
            debug(print:currentUpCommingTripPageIndex.description)
        }
    }
    var totalUpCommingTripPages = 1{
        didSet{
            debug(print: totalPastTripPages.description)
        }
    }
    var currentPastTripPageIndex = 1{
        didSet{
            debug(print:currentPastTripPageIndex.description)
        }
    }
    var totalPastTripPages = 1{
        didSet{
            debug(print:totalPastTripPages.description)
        }
    }
    var oneTimeForUpcoming : Bool = true
    var oneTimeForPast : Bool = true

    //MARK:- indexed
    var HittedUpcomingTripPageIndex = 0
    var HittedPastTripPageIndex = 0
    
    var language : LanguageProtocol = Language.default.object

    var selectedTrip : History?
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backBtn.setTitle(self.language.getBackBtnText(), for: .normal)
        self.initView()
        self.initLanguage()
      
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.initLanguage()
        }
        self.setDesign()
        self.initialFunc()
    }
    
    func createLottieView(view: UIView) -> AnimationView{
        
        let animationView = AnimationView.init(name: "app_loader")
        
        animationView.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView.loopMode = .loop
        
        // 5. Adjust animation speed
        
        animationView.animationSpeed = 1.5
        
        // 6. Play animation
        
        animationView.play()
        return animationView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initalting api interactor Delegate
        self.apiInteractor = APIInteractor(self)
    }
    func initialFunc()
    {
        // Refresher
        self.pastRefresher = self.getRefreshController()
        self.upCommingRefresher = self.getRefreshController()
        self.pastLoader = self.getBottomLoader()
        self.upCommingLoader = self.getBottomLoader()
        
        self.currentPastTripPageIndex = 0
        self.currentUpCommingTripPageIndex = 0
        self.HittedUpcomingTripPageIndex = 0
        self.HittedPastTripPageIndex = 0
        self.setRefreshControl()
        self.pastTrips.removeAll()
        self.upCommingTrips.removeAll()
        self.pastTable.reloadData()
        self.upCommingTable.reloadData()
        self.fetchPastTripsData()
        self.fetchUpCommingTripsData()
    }
    //MAKR:- initializers
    func initView(){
        self.parentScrollView.delegate = self
        self.pastTable.register(PastTripTVC.getNib(), forCellReuseIdentifier: "PastTripTVC")
        self.pastTable.register(PastAndUpcommingTVC.getNib(), forCellReuseIdentifier: "PastAndUpcommingTVC")
        self.pastTable.delegate = self
        self.pastTable.dataSource = self
        self.pastTable.showsVerticalScrollIndicator = false
        self.pastTable.showsHorizontalScrollIndicator = false
//        self.pastTable.prefetchDataSource = self
        self.upCommingTable.register(UpCommingTripTVC.getNib(), forCellReuseIdentifier: "UpCommingTripTVC")
        self.upCommingTable.register(PastAndUpcommingTVC.getNib(), forCellReuseIdentifier: "PastAndUpcommingTVC")
        self.upCommingTable.register(PastTripTVC.getNib(), forCellReuseIdentifier: "PastTripTVC")
        self.upCommingTable.showsVerticalScrollIndicator = false
        self.upCommingTable.showsHorizontalScrollIndicator = false
        self.upCommingTable.delegate = self
        self.upCommingTable.dataSource = self
//        self.upCommingTable.prefetchDataSource = self
    }
    
    func getImage(from string: String) -> UIImage? {
        //2. Get valid URL
        guard let url = URL(string: string)
            else {
                print("Unable to create URL")
                return nil
        }

        var image: UIImage? = nil
        do {
            //3. Get valid data
            let data = try Data(contentsOf: url, options: [])

            //4. Make image
            image = UIImage(data: data)
        }
        catch {
            print(error.localizedDescription)
        }

        return image
    }

    func setRefreshControl()
    {
        //Refresh contoller
        if #available(iOS 10.0, *) {
            self.pastTable.refreshControl = self.pastRefresher
            self.upCommingTable.refreshControl = self.upCommingRefresher
        } else {
            self.pastTable.addSubview(self.pastRefresher!)
            self.upCommingTable.addSubview(self.upCommingRefresher!)
        }
        //BottomLaoder
        self.pastTable.tableFooterView = self.pastLoader
        self.upCommingTable.tableFooterView = self.upCommingLoader
    }
    
    func initLanguage(){
        
        self.pageTitleLbl.text = self.language.yourTrips
        self.pastTitleBtn.setTitle(self.language.past.capitalized, for: .normal)
        self.upCommingTitleBtn.setTitle(self.language.upComming.capitalized, for: .normal)
        if self.language.isRTLLanguage() && !self.isFromSchdule {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.currentTab = .past
            }
        }else if isFromSchdule && !self.language.isRTLLanguage(){
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.currentTab = .upComming
            }
        }
    }
    //MARK:- initWithStory
    class func initWithStory() -> TripHistoryVC{
        let view : TripHistoryVC = UIStoryboard(name: "karuppasamy", bundle: nil).instantiateViewController()
        view.apiInteractor = APIInteractor(view)
        return view
    }
    //MARK:- actions
    @IBAction func backAction(_ sender : UIButton?){
        if isFromSchdule == true {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        if isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func switchTabAction(_ sender : UIButton?){
        if sender == self.pastTitleBtn {
            self.currentTab = .past
            self.pastTable.reloadData()
        }else{
            self.currentTab = .upComming
            self.upCommingTable.reloadData()
        }
    }
   
    @objc func onRefresh(_ sender : UIRefreshControl){
        if sender == self.pastRefresher{
            self.pastTrips.removeAll()
            self.currentPastTripPageIndex = 0
            self.HittedPastTripPageIndex = 0
            self.fetchPastTripsData()
        }else{
            self.upCommingTrips.removeAll()
            self.currentUpCommingTripPageIndex = 0
            self.HittedUpcomingTripPageIndex = 0
            self.fetchUpCommingTripsData()
        }
    }
    func editScheduledTime(for trip: History) {
        self.selectedTrip = trip
        let scheduleRideVC = ScheduleRiderVC.initWithStory()
        scheduleRideVC.view.backgroundColor = UIColor.clear
        scheduleRideVC.delegate = self
        scheduleRideVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        present(scheduleRideVC, animated: false, completion: nil)
    }
    
    func cancelRideSelected(for trip: History) {
        let cancelRiderVC = CancelRideVC.initWithStory()
        cancelRiderVC.isToCancelSchedule = true
        cancelRiderVC.strTripId = trip.tripID.description
        self.navigationController?.pushViewController(cancelRiderVC, animated: false)
    }
    //MARK:- UDF
    func fetchPastTripsData(){
        var paramForAPI = Parameters()
        paramForAPI["page"] = self.currentPastTripPageIndex + 1
        guard  self.HittedPastTripPageIndex != self.currentPastTripPageIndex + 1 else {
            return
        }

        self.apiInteractor?
            .getRequest(for: .getPastTrips,params: paramForAPI)
//            .responseJSON({ (json) in
//                if json.isSuccess{
//                    let totalPages = json.int("total_pages")
//                    let currentPage = json.int("current_page")
//                    let data = json.array("data").compactMap({TripDataModel($0)})
//                    if self.pastRefresher?.isRefreshing ?? false{
//                        self.pastTable.reloadData()
//                        self.pastRefresher?.endRefreshing()
//                    }
//                    if currentPage == 1 {
//                        self.pastTrips.removeAll()
//                    }
//                    self.pastTrips.append(contentsOf: data)
//                    self.currentPastTripPageIndex = currentPage
//                    self.HittedPastTripPageIndex = currentPage
//                    self.totalPastTripPages = totalPages
//                    self.pastLoader?.stopAnimating()
//                    self.pastTable.reloadData()
//                    self.oneTimeForPast = true
//                    self.view.layoutIfNeeded()
//                }else{
//                    self.pastRefresher?.endRefreshing()
//                    self.pastLoader?.stopAnimating()
//                    self.pastTable.reloadData()
//                }
//            })
            .responseDecode(to: TripHistoryModel.self, { (response) in
                if response.statusCode == "1" {
                    let totalPages = response.totalPages
                    let currentPage = response.currentPage
                    let data = response.data
                    if self.pastRefresher?.isRefreshing ?? false{
                        self.pastTable.reloadData()
                        self.pastRefresher?.endRefreshing()
                    }
                    if currentPage == 1 {
                        self.pastTrips.removeAll()
                    }
                    self.pastTrips.append(contentsOf: data)
                    self.currentPastTripPageIndex = currentPage
                    self.HittedPastTripPageIndex = currentPage
                    self.totalPastTripPages = totalPages
                    self.pastLoader?.stopAnimating()
                    self.pastTable.reloadData()
                    self.oneTimeForPast = true
                    self.view.layoutIfNeeded()
                }else{
                    self.pastRefresher?.endRefreshing()
                    self.pastLoader?.stopAnimating()
                    self.pastTable.reloadData()
                }

                })
            
            .responseFailure({ (error) in
                self.pastRefresher?.endRefreshing()
                self.pastLoader?.stopAnimating()
                self.pastTable.reloadData()
            })

        if !(self.pastRefresher?.isRefreshing ?? false){
            self.pastLoader?.startAnimating()
        }
    }
    func fetchUpCommingTripsData(){
        var paramForAPI = Parameters()
        paramForAPI["page"] = self.currentUpCommingTripPageIndex + 1
        guard  self.HittedUpcomingTripPageIndex != self.currentUpCommingTripPageIndex + 1 else {
            return
        }
        self.apiInteractor?
            .getRequest(for: .getUpcomingTrips,params: paramForAPI)
//            .responseJSON({ (json) in
//                if json.isSuccess{
//                    let totalPages = json.int("total_pages")
//                    let currentPage = json.int("current_page")
//                    let data = json.array("data").compactMap({TripDataModel($0)})
//                    if self.upCommingRefresher?.isRefreshing ?? false{
//                        self.upCommingTable.reloadData()
//                        self.upCommingRefresher?.endRefreshing()
//                    }
//                    if currentPage == 1 {
//                        self.upCommingTrips.removeAll()
//                    }
//                    self.upCommingTrips.append(contentsOf: data)
//                    self.currentUpCommingTripPageIndex = currentPage
//                    self.HittedUpcomingTripPageIndex = currentPage
//                    self.totalUpCommingTripPages = totalPages
//                    self.upCommingLoader?.stopAnimating()
//                    self.upCommingTable.reloadData()
//                    self.view.layoutIfNeeded()
//                    self.oneTimeForUpcoming = true
//                }else{
//                    self.upCommingRefresher?.endRefreshing()
//                    self.upCommingLoader?.stopAnimating()
//                    self.upCommingTable.reloadData()
//
//                }
//            })
            .responseDecode(to: TripHistoryModel.self, { (response) in
                if response.statusCode == "1" {
                    let totalPages = response.totalPages
                    let currentPage = response.currentPage
                    let data = response.data
                    if self.upCommingRefresher?.isRefreshing ?? false{
                        self.upCommingTable.reloadData()
                        self.upCommingRefresher?.endRefreshing()
                    }
                    if currentPage == 1 {
                        self.upCommingTrips.removeAll()
                    }
                    self.upCommingTrips.append(contentsOf: data)
                    self.currentUpCommingTripPageIndex = currentPage
                    self.HittedUpcomingTripPageIndex = currentPage
                    self.totalUpCommingTripPages = totalPages
                    self.upCommingLoader?.stopAnimating()
                    self.upCommingTable.reloadData()
                    self.oneTimeForUpcoming = true
                    self.view.layoutIfNeeded()
                }else{
                    self.upCommingRefresher?.endRefreshing()
                    self.upCommingLoader?.stopAnimating()
                    self.upCommingTable.reloadData()
                }

                })
            .responseFailure({ (error) in
                self.upCommingRefresher?.endRefreshing()
                self.upCommingLoader?.stopAnimating()
                self.upCommingTable.reloadData()

            })
        if !(self.upCommingRefresher?.isRefreshing ?? true){
            self.upCommingLoader?.startAnimating()
        }
    }
    func ratingAction(forTrip trip : TripDataModel){
        
        let propertyView = RateDriverVC.initWithStory()
        propertyView.tripId = trip.id
        self.navigationController?.pushViewController(propertyView, animated: true)
        
    }
    func getRefreshController() -> UIRefreshControl {
        
        let refresher = UIRefreshControl()
        refresher.tintColor = .clear
        refresher.addTarget(self, action: #selector(self.onRefresh(_:)), for: .valueChanged)
        
        // Refresh View
        let customRefreshView = CustomRefreshView.initViewFromXib()
        let loader = self.createLottieView(view: customRefreshView.refresherImage)
        customRefreshView.setRefresh(image: loader, content: self.language.pullToRefresh)
        refresher.addSubview(customRefreshView)
        customRefreshView.anchor(toView: refresher,
                                 leading: 0,
                                 trailing: 0,
                                 top: 0,
                                 bottom: 0)
        return refresher
    }
    func getBottomLoader() -> UIActivityIndicatorView{
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = UIColor.clear
        let customRefreshView = CustomRefreshView.initViewFromXib()
        let loader = self.createLottieView(view: customRefreshView.refresherImage)
        customRefreshView.setRefresh(image: loader, content: nil)
        spinner.addSubview(customRefreshView)
        spinner.hidesWhenStopped = true
        customRefreshView.anchor(toView: spinner,
                                 leading: 0,
                                 trailing: 0,
                                 top: 0,
                                 bottom: 0)
        return spinner
    }
}
//MARK:- ScrollView Delegate
extension TripHistoryVC : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.loadMore()
        guard scrollView == self.parentScrollView else{return}
        
//        if self.language.isRTLLanguage(){
//            self.sliderView
//                .transform = CGAffineTransform(translationX: (scrollView
//                    .contentOffset.x / 2) - self.sliderView.frame.width ,
//                                               y: 0)
//        }else{
//            self.sliderView
//                .transform = CGAffineTransform(translationX: scrollView
//                    .contentOffset.x / 2,
//                                               y: 0)
//        }
    }
    func loadMore()
    {
        if self.currentTab == .past {
            let cell = pastTable.visibleCells.last as? PastAndUpcommingTVC
            guard ((cell?.tripIdLbl.text) != nil),(self.pastTrips.last != nil) else {return}
            if cell?.tripIdLbl.text?.replacingOccurrences(of:"\(self.language.tripID.capitalized) ", with: "") == self.pastTrips.last?.tripID.description && oneTimeForPast && self.currentPastTripPageIndex != self.totalPastTripPages && cell?.accessibilityHint == (self.pastTrips.count - 1).description{
                self.fetchPastTripsData()
                self.oneTimeForPast = !self.oneTimeForPast
                print("å:: This is Last For Completed")
            } else {
                print("å:: Already Hitted Api Completed")
            }
        } else {
            if ((upCommingTable.visibleCells.last?.isKind(of: PastAndUpcommingTVC.self)) != nil) {
                let cell = upCommingTable.visibleCells.last as? PastAndUpcommingTVC
                guard ((cell?.tripIdLbl.text) != nil),(self.upCommingTrips.last != nil) else {return}

                if  cell?.tripIdLbl.text?.replacingOccurrences(of:"\(self.language.tripID.capitalized) ", with: "") == self.upCommingTrips.last?.tripID.description && oneTimeForUpcoming && self.currentUpCommingTripPageIndex != self.totalUpCommingTripPages && cell?.accessibilityHint == (self.upCommingTrips.count - 1).description{
                    self.fetchUpCommingTripsData()
                    self.oneTimeForUpcoming = !self.oneTimeForUpcoming
                    print("å:: This is Last For Pending")
                } else {
                    print("å:: Already Hitted Api Pending")
                }
            }
            
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == self.parentScrollView else{return}
        let currentX = scrollView.contentOffset.x
        let maxX = self.view.frame.width
        
        if self.language.isRTLLanguage(){
            self.currentTab = currentX >= maxX ? .past : .upComming
        }else{
            self.currentTab = currentX >= maxX ? .upComming : .past
        }
    }
}

extension TripHistoryVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count : Int
        if tableView == self.pastTable{
            count = self.pastTrips.count
            if !(self.apiInteractor?.isFetchingData ?? true),count == 0 && !(self.pastLoader?.isAnimating ?? false){
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.pastTable.bounds.size.width, height: self.pastTable.bounds.size.height))
                noDataLabel.text = self.language.youHaveNoTrips.capitalized
                noDataLabel.textColor = UIColor.ThemeYellow
                noDataLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
                noDataLabel.textAlignment = NSTextAlignment.center
                self.pastTable.backgroundView = noDataLabel
            }else{
                self.pastTable.backgroundView = nil
            }
        }else{
            count = self.upCommingTrips.count
            if !(self.apiInteractor?.isFetchingData ?? true),count == 0  && !(self.upCommingLoader?.isAnimating ?? false){
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.upCommingTable.bounds.size.width, height: self.upCommingTable.bounds.size.height))
                noDataLabel.text = self.language.youHaveNoTrips.capitalized
                noDataLabel.textColor = UIColor.ThemeYellow
                noDataLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 20)
                noDataLabel.textAlignment = NSTextAlignment.center
                self.upCommingTable.backgroundView = noDataLabel
            }else{
                self.upCommingTable.backgroundView = nil
            }
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch tableView{
        case self.pastTable:
            let cell : PastAndUpcommingTVC = tableView.dequeueReusableCell(for: indexPath)
            if let trip = self.pastTrips.value(atSafe: indexPath.row) {
                cell.populateCell(with : trip)
            }
            cell.accessibilityHint = indexPath.row.description
            return cell
        case self.upCommingTable:
            let cell : PastAndUpcommingTVC = tableView.dequeueReusableCell(for: indexPath)
            if let trip = self.upCommingTrips.value(atSafe: indexPath.row) {
                cell.populateCell(with : trip)
                cell.editTimeBtn.addAction(for: .tap) { [weak self] in
                    self?.editScheduledTime(for: trip)
                }
                cell.cancelRideBtn.addAction(for: .tap) { [weak self] in
                    self?.cancelRideSelected(for: trip)
                }
            }
            cell.accessibilityHint = indexPath.row.description

            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
}
extension TripHistoryVC : UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.pastTable{
            if let trip = self.pastTrips.value(atSafe: indexPath.row){
                AppRouter(self).routeInCompleteTripsFromHistory(trip)
            }
        }else{
            if let trip = self.upCommingTrips.value(atSafe: indexPath.row),
//               trip.bookingType == .auto
               trip.status != .pending {
                AppRouter(self).routeInCompleteTripsFromHistory(trip)
            }
        }
    }
}

//MARK:- ScheduleRiderDelegate
extension TripHistoryVC : ScheduleRiderDelegate{
    func onScheduleRiderTapped(scheduledTime: String) {
        
        let date : String  = scheduledTime.components(separatedBy: " at ")[0]
        let time : String  = scheduledTime.components(separatedBy: " at ")[1]
        let beginTime : String = time.components(separatedBy: " - ")[0]
        let endTime : String = time.components(separatedBy: " - ")[1]
        var receivedDateString = String((scheduledTime.split(separator: "-"))[0])
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "en_US")
        receivedDateString = String(format:"%@",receivedDateString.replacingOccurrences(of: "at", with: "\(myDateFormatter.string(from: Date())) ~"))
        receivedDateString.removeLast()
        myDateFormatter.dateFormat = "EEE, dd MMM yyyy ~ hh:mm a"
        print("Begin Time : \(beginTime)")
        print("End Time : \(endTime)")
        myDateFormatter.locale = Locale(identifier: "en_US")
        guard let mySelectedDate = myDateFormatter.date(from: "\(date) ~ \(beginTime)") else{
            self.appDelegate.createToastMessage(DisplayErrors.somethingWentWrong.rawValue)
            return
        }
        myDateFormatter.dateFormat = "HH:mm"
        myDateFormatter.locale = Locale(identifier: "en_US")
        let scheduledTimeAloneString = myDateFormatter.string(from: mySelectedDate)
        myDateFormatter.dateFormat = "dd-MM-yyyy"
        let scheduledDateAloneString = myDateFormatter.string(from: mySelectedDate)
        let paramDict = ["schedule_date":scheduledDateAloneString,
                         "schedule_time":scheduledTimeAloneString,
                         "schedule_id": self.selectedTrip?.tripID.description ?? "",
                        "token" : Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)]
            as [String : Any]
        let loader = UberSupport()
        loader.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .scheduleRide,
                        params: paramDict)
            .responseJSON({ (response) in
                loader.removeProgressInWindow()
                if response.isSuccess {
                    self.upCommingTrips.removeAll()
                    self.upCommingTable.reloadData()
                   // self.upCommingTable.reloadData()
                    self.currentUpCommingTripPageIndex = 0
                    self.HittedUpcomingTripPageIndex = 0
                    self.fetchUpCommingTripsData()
                }else {
                    self.appDelegate.createToastMessageForAlamofire(response.status_message, bgColor: UIColor.ThemeYellow, textColor: UIColor.white, forView:self.view)
                }
            })
            .responseFailure({ (error) in
                loader.removeProgressInWindow()
                self.appDelegate.createToastMessage(error)
            })
   
        
    }
}
extension TripHistoryVC : UpdateContentProtocol{
    func updateContent() {
//        self.pastRefresher = self.getRefreshController()
        self.upCommingRefresher = self.getRefreshController()
//        self.pastLoader = self.getBottomLoader()
        self.upCommingLoader = self.getBottomLoader()
        
//        self.currentPastTripPageIndex = 0
        self.currentUpCommingTripPageIndex = 0
        self.HittedUpcomingTripPageIndex = 0
//        self.HittedPastTripPageIndex = 0
        self.setRefreshControl()
//        self.pastTrips.removeAll()
        self.upCommingTrips.removeAll()
//        self.pastTable.reloadData()
        self.upCommingTable.reloadData()
//        self.fetchPastTripsData()
        self.fetchUpCommingTripsData()
    }
    
    
}
extension UIScreen {

    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6 = 1334.0
        case iPhone6Plus = 1920.0
    }

    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}
