//
//  CurrencyPopupVC.swift
// NewTaxi
//
//  Created by Seentechs on 29/03/21.
//  Copyright © 2021 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Social

class CurrencyPopupVC: UIViewController,UITableViewDelegate, UITableViewDataSource,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    lazy var arrCurrencyData = [CurrencyModel]()
    var callback: ((String?)->())?
    @IBOutlet weak var currencyTable: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var hoverView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var hoverViewHeightCons: NSLayoutConstraint!
    var tabBar : UITabBar?
    var delegate: currencyListDelegate?
    var strCurrentCurrency = ""
    lazy var lang = Language.default.object
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.titleLbl.text = self.lang.currency
        self.setupGesture()
        let userCurrencySym = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let userCurrencyCode = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        self.currencyTable.delegate = self
        self.currencyTable.dataSource = self
        self.hoverViewHeightCons.constant = (self.view.frame.height * 0.6) - 44
        strCurrentCurrency = String(format: "%@ | %@",userCurrencyCode,userCurrencySym)
        self.navigationController?.isNavigationBarHidden = true
        self.callCurrencyAPI()
        self.hoverView.setSpecificCornersForTop(cornerRadius: 35)
        self.hoverView.elevate(4)
    }
    func setupGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)

            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeDown.direction = .down
            self.hoverView.addGestureRecognizer(swipeDown)
        self.dismissView.addAction(for: .tap) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
                self.swipeDownAnimation()
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
                self.swipeUpAnimation()
            default:
                break
            }
        }
        
    }
    func swipeUpAnimation() {
        UIView.animate(withDuration: 1) {
            self.hoverView.frame.origin = CGPoint(x: 0, y: 0)
            self.hoverViewHeightCons.constant = self.view.frame.height
            self.view.backgroundColor = .clear
        }
    }
    
    func swipeDownAnimation() {
        UIView.animate(withDuration: 0.75) {
            self.view.frame.origin.y = self.view.frame.maxY
        } completion: { (completed) in
          if completed {
            self.dismiss(animated: true) {
              self.dismissView.backgroundColor = .clear
            }
          }
        }
      }
        func initLayer(){
//            self.hoverView.isClippedCorner = true
//            self.hoverView.elevate(2)
        }
    internal func RetryTapped()
    {
        callCurrencyAPI()
    }
    
    // MARK: CURRENCY API CALL
    /*
     */
    func callCurrencyAPI()
    {
        var dicts = [AnyHashable: Any]()
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        dicts["token"] = Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
        self.apiInteractor?
            .getRequest(for: APIEnums.getCurrencyList)
            .responseJSON({ (json) in
                UberSupport.shared.removeProgressInWindow()
                if json.isSuccess{
                    let currencies = json
                        .array("currency_list")
                    .compactMap({CurrencyModel(from: $0)})
                    
                    self.arrCurrencyData = currencies
                    self.currencyTable.reloadData()
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
            })
       

    }
    

    //MARK:- initWithStory
    class func initWithStory(_ delegate : currencyListDelegate) -> CurrencyPopupVC{
        let currencyVC : CurrencyPopupVC = UIStoryboard.payment.instantiateViewController()
        currencyVC.delegate = delegate
        return currencyVC
    }
    func showProgress()
    {
        let loginPageView = ProgressHud.initWithStory()
        loginPageView.willMove(toParent: self)
        loginPageView.view.tag = 1234
        self.view.addSubview(loginPageView.view)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        let userCurrencySym = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let userCurrencyCode = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        strCurrentCurrency = String(format: "%@ | %@",userCurrencyCode,userCurrencySym)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
    }
    //
    //MARK: Room Detail Table view Handling
    /*
     Room Detail List View Table Datasource & Delegates
     */
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCurrencyData.count != 0 ? arrCurrencyData.count : 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellCurrency = currencyTable.dequeueReusableCell(withIdentifier: "CellCurrency") as! CellCurrency

        let currencyModel = arrCurrencyData[indexPath.row] as? CurrencyModel
        let strSymbol = self.makeCurrencySymbols(encodedString: (currencyModel?.currency_symbol as String?)!)
        let checkdata = String(format: "%@ | %@",(currencyModel?.currency_code as NSString?)!,strSymbol)
        cell.lblCurrency?.text = String(format: "%@ | %@",(currencyModel?.currency_code as NSString?)!,strSymbol)
        cell.imgTickMark?.isHidden = (strCurrentCurrency == checkdata) ? false : true
        cell.imgTickMark?.image = UIImage(named: "checkbox")

//        self.makeScroll()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedCell = currencyTable.cellForRow(at: indexPath) as! CellCurrency
        appDelegate.nSelectedIndex = indexPath.row
        strCurrentCurrency = (selectedCell.lblCurrency?.text)!
        let str = strCurrentCurrency.components(separatedBy: " | ")
        Constants().STOREVALUE(value: str[1] as? String ?? String(), keyname: USER_CURRENCY_SYMBOL_ORG)// code
        Constants().STOREVALUE(value: str[0] as? String ?? String(), keyname: USER_CURRENCY_ORG)//symbal
        currencyTable.reloadData()
        self.save()
    }
    func save()
    {
            UberSupport.shared.showProgressInWindow(showAnimation: true)
            var dicts = JSON()
            dicts["token"] =  Constants().GETVALUE(keyname: USER_ACCESS_TOKEN)
            let str = strCurrentCurrency.components(separatedBy: " | ")
            dicts["currency_code"] = str[0]
            self.apiInteractor?
                .getRequest(
                    for: APIEnums.updateUserCurrency,
                    params: dicts)
                .responseJSON({ (json) in
                    UberSupport.shared.removeProgressInWindow()
                    if json.isSuccess{
                        let walletAmount = json.string("wallet_amount")
                        Constants().STOREVALUE(value: walletAmount , keyname: USER_WALLET_AMOUNT)
                        self.delegate?.onCurrencyChanged(currency: self.strCurrentCurrency)
                        self.dismiss(animated: true, completion: nil)
                    }else{

                        AppDelegate.shared.createToastMessage(json.status_message)
                    }
                }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
                    AppDelegate.shared.createToastMessage(error)
                })
    }
    
    func makeCurrencySymbols(encodedString : String) -> String
    {
        let encodedData = encodedString.stringByDecodingHTMLEntities
        return encodedData
    }
    

}
