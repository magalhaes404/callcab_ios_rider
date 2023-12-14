//
//  SelectLanguageVC.swift
// NewTaxiDriver
//
//  Created by Seentechs on 20/04/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import UIKit


class SelectLanguageVC: UIViewController,APIViewProtocol {
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum, for API: APIEnums) {
        
    }
    
    @IBOutlet weak var dismissView : UIView!
    @IBOutlet weak var hoverView : UIView!
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var languageTable : UITableView!
    
    var tabBar : UITabBar?
    lazy var langugage : LanguageProtocol = {
        return Language.default.object
    }()
    lazy var availableLanguages : [Language] = {
        return Language.AvailableLanguages
    }()
    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiInteractor = APIInteractor(self)
        self.initView()
        self.initLanguage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.initLayer()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar?.isHidden = true
        self.view.backgroundColor = .clear
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBar?.isHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    //MARK:- initializers
    func initLanguage(){
        self.titleLbl.text = self.langugage.selectLanguage
    }
    func initView(){
        self.languageTable.dataSource = self
        self.languageTable.delegate = self
        self.dismissView.addAction(for: .tap) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        self.setDesign()
    }
    func initLayer(){
        self.hoverView.setSpecificCornersForTop(cornerRadius: 45)
        self.hoverView.elevate(2)
    }
    func setDesign()
    {
        self.titleLbl.textColor = .Title
        self.titleLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 17)
    }

    class func initWithStory() -> SelectLanguageVC{
        return UIStoryboard.payment.instantiateViewController()
    }
}
extension SelectLanguageVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableLanguages.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.115
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : LanguageTVC = tableView.dequeueReusableCell(for: indexPath)
        guard let data = self.availableLanguages.value(atSafe: indexPath.row) else{return cell}
        cell.populate(with: data)
        return cell
    }
}
extension SelectLanguageVC : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedLang = self.availableLanguages.value(atSafe: indexPath.row),
            let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        if selectedLang == Language.default{
            self.dismiss(animated: true, completion: nil)
        }else{
            if let _ = UserDefaults.standard.string(forKey: USER_ACCESS_TOKEN){
                self.update(language: selectedLang)
            }else{
                selectedLang.saveLanguage()
                appDelegate.onSetRootViewController(viewCtrl: self)
            }
        }
        
    }
    func update(language : Language){
        let support = UberSupport()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        support.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: APIEnums.updateLanguage,
                        params: [
                            "language" : language.rawValue
                ]
        ).responseJSON({ (response) in
            support.removeProgressInWindow()
            if response.isSuccess{
                language.saveLanguage()
                appDelegate?.onSetRootViewController(viewCtrl: self)
            }
        }).responseFailure({ (error) in
            support.removeProgressInWindow()
            appDelegate?.createToastMessage(error)
        })
        
    }
}

class LanguageTVC : UITableViewCell{
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var radioBtn : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.radioBtn.isUserInteractionEnabled = false
        self.nameLbl.textColor = .Title
        self.nameLbl.font = UIFont(name: iApp.NewTaxiFont.centuryBold.rawValue, size: 14)

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    func populate(with language : Language){
        self.nameLbl.text = language.displayName
        let image = UIImage(named: language == Language.default ? "radioOn" : "radioOff")
        self.radioBtn.image = image
//            .withRenderingMode(.alwaysTemplate)
//        self.radioBtn.setImage(image,
//                               for: .normal)
//        self.radioBtn.tintColor = .white
    }
}
