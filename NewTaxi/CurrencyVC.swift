//
//  CurrencyVC.swift
// NewTaxi
//
//  Created by Seentechs on 16/05/18.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit
import Social

protocol currencyListDelegate
{
    func onCurrencyChanged(currency:String)
}

class CurrencyVC: UIViewController,UITableViewDelegate, UITableViewDataSource,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    

    @IBOutlet weak var tblCurrency: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var currLbl: UILabel!
  
  
    var delegate: currencyListDelegate?
    lazy var lang = Language.default.object
    var strCurrentCurrency = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    var arrCurrencyData  = [CurrencyModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.currLbl.text = self.lang.currency
        self.btnSave.setTitle(self.lang.save ,for: .normal)
        let userCurrencySym = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let userCurrencyCode = Constants().GETVALUE(keyname: USER_CURRENCY_ORG)
        self.tblCurrency.delegate = self
        self.tblCurrency.dataSource = self
        strCurrentCurrency = String(format: "%@ | %@",userCurrencyCode,userCurrencySym)
        self.navigationController?.isNavigationBarHidden = true
        self.callCurrencyAPI()
        btnSave.layer.cornerRadius = 5.0

    }

    //MARK: INTERNET OFFLINE DELEGATE METHOD
    /*
     Here Calling the API again
     */
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
                    self.tblCurrency.reloadData()
                }else{
                    AppDelegate.shared.createToastMessage(json.status_message)
                }
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
            })
       

    }
    func makeScroll()
    {
        for i in 0...arrCurrencyData.count-1
        {
            let currencyModel = arrCurrencyData[i] as? CurrencyModel
            let str = strCurrentCurrency.components(separatedBy: "  |  ")
            if currencyModel?.currency_code as? String == str[0]
            {
                let indexPath = IndexPath(row: i, section: 0)
                tblCurrency.scrollToRow(at: indexPath, at: .top, animated: true)
                break
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //MARK:- initWithStory
    class func initWithStory(_ delegate : currencyListDelegate) -> CurrencyVC{
        let currencyVC : CurrencyVC = UIStoryboard.home.instantiateViewController()
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
        let cell:CellCurrency = tblCurrency.dequeueReusableCell(withIdentifier: "CellCurrency") as! CellCurrency

        let currencyModel = arrCurrencyData[indexPath.row] as? CurrencyModel
        let strSymbol = self.makeCurrencySymbols(encodedString: (currencyModel?.currency_symbol as String?)!)
        let checkdata = String(format: "%@ | %@",(currencyModel?.currency_code as NSString?)!,strSymbol)
        cell.lblCurrency?.text = String(format: "%@ | %@",(currencyModel?.currency_code as NSString?)!,strSymbol)
        cell.imgTickMark?.isHidden = (strCurrentCurrency == checkdata) ? false : true
        cell.imgTickMark?.image = UIImage(named: "tick.png")
//        self.makeScroll()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedCell = tblCurrency.cellForRow(at: indexPath) as! CellCurrency
        appDelegate.nSelectedIndex = indexPath.row
        strCurrentCurrency = (selectedCell.lblCurrency?.text)!
        let str = strCurrentCurrency.components(separatedBy: " | ")
        Constants().STOREVALUE(value: str[1] as? String ?? String(), keyname: USER_CURRENCY_SYMBOL_ORG)// code
        Constants().STOREVALUE(value: str[0] as? String ?? String(), keyname: USER_CURRENCY_ORG)//symbal
        tblCurrency.reloadData()
    }
    
    
    func makeCurrencySymbols(encodedString : String) -> String
    {
        let encodedData = encodedString.stringByDecodingHTMLEntities
        return encodedData
    }
    
    @IBAction func onSaveTapped(_ sender:UIButton!)
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
                    self.navigationController!.popViewController(animated: true)
                }else{

                    AppDelegate.shared.createToastMessage(json.status_message)
                }
            }).responseFailure({ (error) in
                UberSupport.shared.removeProgressInWindow()
                AppDelegate.shared.createToastMessage(error)
            })
       
    }
    
    func updateOrgCurrency()
    {
        let currencyModel = arrCurrencyData[appDelegate.nSelectedIndex] as? CurrencyModel
    }
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onAddListTapped(){
        
    }
}

class CellCurrency: UITableViewCell
{
    @IBOutlet var lblCurrency: UILabel?
    @IBOutlet var imgTickMark: UIImageView?
}


