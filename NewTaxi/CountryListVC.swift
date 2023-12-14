/**
* CountryListVC.swift
*
* @package NewTaxi
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/

import UIKit
import AVFoundation

protocol CountryListDelegate
{
    func countryCodeChanged(countryCode:String, dialCode:String, flagImg:UIImage)
}


class CountryListVC : UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tblCountryList : UITableView!
    @IBOutlet weak var txtFldSearch:UITextField!
    @IBOutlet weak var btnBackprev: UIButton!
    @IBOutlet weak var selectCountryLabel: UILabel!
    var delegate: CountryListDelegate?
    
    @IBOutlet weak var searchBarView: UIView!
    var strPreviousCountry = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    lazy var language = Language.default.object
    lazy var staticCountryArray : [CountryModel] = {
        let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist")
        let arrCountryList = NSMutableArray(contentsOfFile: path!)!
        let countriesArray : [CountryModel] = arrCountryList
                   .compactMap({$0 as? JSON})
                   .compactMap({CountryModel($0)})
        return countriesArray
    }()
    //MARK:- Country DataSources
    var keys = [String]()
    var countries : [String : [CountryModel]] = [:]
    var filteredKeys = [String]()
    var filteredCountries : [String : [CountryModel]] = [:]
    var currentCountry : CountryModel?
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initLanguage()
        self.setDesign()
    }
    func setDesign() {
        self.outerView.setSpecificCornersForTop(cornerRadius: 45)
        self.outerView.elevate(4)
        self.searchBarView.cornerRadius = 15
        self.btnBackprev.setTitleColor(.Title, for: .normal)
        self.selectCountryLabel.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
        self.selectCountryLabel.textColor = .Title
        self.txtFldSearch.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        self.txtFldSearch.textColor = .Title
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let uberLoader = UberSupport()
        uberLoader.showProgressInWindow(showAnimation: true)
        DispatchQueue.main.async { [weak self] in
            self?.generateDataSource()
            uberLoader.removeProgressInWindow()
        }
    }
    func initLanguage(){
         selectCountryLabel.text = self.language.selectCountry
         txtFldSearch.placeholder = self.language.search
        if self.language.isRTLLanguage(){
            btnBackprev.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
     }
     
    //MARK:- initWithStory
    class func initWithStory(selectedFlag:CountryModel?) -> CountryListVC{
        let infoWindow : CountryListVC = UIStoryboard.payment.instantiateViewController()
        infoWindow.currentCountry = selectedFlag
        return infoWindow
    }
    //MARK:- UDF
    
    //MARK:- Generate datasource
    func generateDataSource(){
        
        let countriesArray = self.staticCountryArray
     
        
        self.countries = [:]
        for country in countriesArray{
            let nameFirstChar = "\(country.name.first ?? "#")"
            var internalArray = self.countries[nameFirstChar] ?? [CountryModel]()
            internalArray.append(country)
            self.countries[nameFirstChar] = internalArray
        }
        self.keys = self.countries.keys.sorted(by: {$0 < $1})
        self.tblCountryList.reloadData()
    }
    

 //MARK:- Filter and Update
 func filterCountries(for strSearchText:String) {
     
        let countriesArray : [CountryModel] = self.staticCountryArray
        .filter({$0.name.lowercased().hasPrefix(strSearchText.lowercased())})
     
        
        self.filteredCountries = [:]
        self.filteredKeys.removeAll()
        for country in countriesArray{
            let nameFirstChar = "\(country.name.first ?? "#")"
            var internalArray = self.filteredCountries[nameFirstChar] ?? [CountryModel]()
            internalArray.append(country)
            self.filteredCountries[nameFirstChar] = internalArray
        }
        self.filteredKeys = self.filteredCountries.keys.sorted(by: {$0 < $1})
        self.tblCountryList.reloadData()
 }
 
    
    //MARK: TextField Delegate Method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        return true
    }
    //MARK:- Actions
    @IBAction private func textFieldDidChange(textField: UITextField)
    {
        DispatchQueue.main.async { [weak self] in
            self?.filterCountries(for: textField.text ?? "")
        }
    }
    
    
    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.view.endEditing(true)
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController!.popViewController(animated: true)
        }
    }

   
}
extension CountryListVC :  UITableViewDataSource  {
    //MARK: Table view Datasource
    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
//        if isForFilter{
//            return self.filteredKeys
//        }else{
//            return self.keys
//        }
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
        
        if isForFilter{
            return self.filteredKeys.count
        }else{
            return self.keys.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
        if isForFilter{
            let key = self.filteredKeys.value(atSafe: section) ?? "#"
            return self.filteredCountries[key]?.count ?? 0
        }else{
            let key = self.keys.value(atSafe: section) ?? "#"
            return self.countries[key]?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//         let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
//        if isForFilter{
//            return self.filteredKeys.value(atSafe: section) ?? "#"
//        }else{
//            return self.keys.value(atSafe: section) ?? "#"
//        }
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
        var title = ""
       if isForFilter{
           title = self.filteredKeys.value(atSafe: section) ?? "#"
       }else{
           title =  self.keys.value(atSafe: section) ?? "#"
       }
        let viewHolder:UIView = UIView()
        viewHolder.frame =  CGRect(x: 0, y:0, width: (tblCountryList.frame.size.width) ,height: 40)
        let titleLabel:UILabel = UILabel()
//        titleLabel.frame =  CGRect(x: 10, y:5, width: viewHolder.frame.size.width ,height: 35)
        titleLabel.text = title
        titleLabel.font = UIFont (name: iApp.NewTaxiFont.centuryBold.rawValue, size: 19)
        viewHolder.backgroundColor = UIColor(hex: "DCDCDC")//self.view.backgroundColor
        titleLabel.textAlignment = NSTextAlignment.natural
        titleLabel.textColor = UIColor.Title
        viewHolder.setSpecificCornersForTop(cornerRadius: 15)
        viewHolder.addSubview(titleLabel)
        titleLabel.anchor(toView: viewHolder, leading: 15, trailing: -15, top: 0, bottom: 0)

        return viewHolder
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CellCountry = tblCountryList.dequeueReusableCell(withIdentifier: "CellCountry")! as! CellCountry
        let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
        if isForFilter{
            if let key = self.filteredKeys.value(atSafe: indexPath.section),
                let country = self.filteredCountries[key]?.value(atSafe: indexPath.row){
                cell.populateCell(with: country, currentContry: self.currentCountry)
                
            }
        }else{
            if let key = self.keys.value(atSafe: indexPath.section),
                let country = self.countries[key]?.value(atSafe: indexPath.row){
                cell.populateCell(with: country, currentContry: self.currentCountry)

            }
        }
        return cell
    }
    
  
   
    
}
extension CountryListVC : UITableViewDelegate{
    //MARK:- TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let isForFilter = (txtFldSearch?.text?.count) ?? 0 > 0
        if isForFilter{
            if let key = self.filteredKeys.value(atSafe: indexPath.section),
                let country = self.filteredCountries[key]?.value(atSafe: indexPath.row){
                delegate?.countryCodeChanged(countryCode:country.country_code,
                                             dialCode:country.dial_code,
                                             flagImg:country.flag)
            }
        }else{
            if let key = self.keys.value(atSafe: indexPath.section),
                let country = self.countries[key]?.value(atSafe: indexPath.row){
                delegate?.countryCodeChanged(countryCode:country.country_code,
                                             dialCode:country.dial_code,
                                             flagImg:country.flag)
            }
        }
  
        self.view.endEditing(true)
        
        if self.isPresented(){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
class CellCountry : UITableViewCell
{
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgFlag: UIImageView!
    func populateCell(with flag : CountryModel,currentContry:CountryModel?){
        self.lblTitle?.text = flag.name
        self.imgFlag.image = flag.flag
        self.lblTitle.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)
        self.lblTitle.textColor = .Title
        if let current = currentContry,
           flag.country_code == current.country_code{
            
            self.contentView.backgroundColor = UIColor.ThemeInactive
        }else{
            self.contentView.backgroundColor = UIColor.white
        }
        
    }
}

extension UIImage{
    class func imageFlagBundleNamed(named:String)->UIImage{
        let image = UIImage(named: "assets.bundle".appendingFormat("/"+(named as String)))!
        return image
    }
}
