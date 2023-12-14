//
//  BrianTreeHandler.swift
// NewTaxi
//
//  Created by Seentechs on 22/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Braintree
import BraintreeDropIn


enum BTErrors : Error{
    case clientNotInitialized
    case clientCancelled
}
extension BTErrors : LocalizedError{
    var errorDescription: String?{
        return self.localizedDescription
    }
    var localizedDescription: String{
        let lang = Language.default.object
        switch self {
        case .clientNotInitialized:
            return lang.clientNotInitialized
        case .clientCancelled:
            return lang.cancelled.capitalized
        }
    }
}
protocol BrainTreeProtocol {
    func initalizeClient(with id : String)
    func authenticatePaymentUsing(_ view : UIViewController,
                                  for amount : Double,
                                  result: @escaping BrainTreeHandler.BTResult)
    func authenticatePaypalUsing(_ view : UIViewController,
                                  for amount : Double,
                                  currency: String,
                                  result: @escaping BrainTreeHandler.BTResult)
}

class BrainTreeHandler : NSObject{
    static var ReturnURL  : String  {
        let bundle = Bundle.main
        
        return bundle.bundleIdentifier ?? "com.seentechs.newtaxiuser"
    }
    class func isBrainTreeHandleURL(_ url: URL,options: [UIApplication.OpenURLOptionsKey : Any] ) -> Bool{
        if url.scheme?
            .localizedCaseInsensitiveCompare(BrainTreeHandler.ReturnURL) == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    typealias BTResult = (Result<BTPaymentMethodNonce, Error>) -> Void
    static var `default` : BrainTreeProtocol = {
        BrainTreeHandler()
    }()
    
    
    
    var client : BTAPIClient?
    var hostView : UIViewController?
    var result : BTResult?
    var clientToken : String?
    private override init(){
        super.init()
        
    }
    
}
//MARK:- BrainTreeProtocol
extension BrainTreeHandler : BrainTreeProtocol{
    
    func initalizeClient(with id : String){
        
        self.clientToken = id
        self.client = BTAPIClient(authorization: id)
        BTAppSwitch.setReturnURLScheme(BrainTreeHandler.ReturnURL)
    }
    
    func authenticatePaypalUsing(_ view: UIViewController,
                                  for amount: Double,
                                  currency: String,
                                  result: @escaping BrainTreeHandler.BTResult) {
        guard let currentClient = self.client else{
            result(.failure(BTErrors.clientNotInitialized))
            return
        }
        self.hostView = view
        self.result = result
        let paypalDriver = BTPayPalDriver(apiClient: currentClient)
        paypalDriver.viewControllerPresentingDelegate = self
        paypalDriver.appSwitchDelegate = self
        
        let request = BTPayPalRequest(amount: amount.description)
        //request.amount = "USD"
        request.currencyCode = currency
        paypalDriver.requestOneTimePayment(request) { (payPalAccountNonce, error) in
            guard let paypaNonce = payPalAccountNonce else{
                result(.failure(error ?? BTErrors.clientCancelled))
                return
            }
            print(paypaNonce.email ?? "")
            print(paypaNonce.firstName ?? "")
            print(paypaNonce.nonce)
            result(.success(paypaNonce))
        }
    }
    func authenticatePaymentUsing(_ view : UIViewController,
                                  for amount : Double,
                  result: @escaping BTResult) {
        guard let currentClientToken = self.clientToken else{
            result(.failure(BTErrors.clientNotInitialized))
            return
        }
        self.hostView = view
        self.result = result
        
        
        let request = BTDropInRequest()
        request.threeDSecureVerification = true
        
        let threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.amount = NSDecimalNumber(value: amount)
        threeDSecureRequest.email = UserDefaults.value(for: .user_email_id) ?? "test@email.com"
        threeDSecureRequest.versionRequested = .version2
        
        let address = BTThreeDSecurePostalAddress()
        address.givenName = UserDefaults.value(for: .first_name) ?? "Albin" // ASCII-printable characters required, else will throw a validation error
        address.surname = UserDefaults.value(for: .last_name) ?? "MrngStar" // ASCII-printable characters required, else will throw a validation error
        address.phoneNumber = UserDefaults.value(for: .phonenumber) ?? "123456"
    
       
        threeDSecureRequest.billingAddress = address
        
        // Optional additional information.
        // For best results, provide as many of these elements as possible.
        let info = BTThreeDSecureAdditionalInformation()
        info.shippingAddress = address
        threeDSecureRequest.additionalInformation = info
        
        let dropInRequest = BTDropInRequest()
        dropInRequest.threeDSecureVerification = true
        dropInRequest.threeDSecureRequest = threeDSecureRequest
        
        let _dropIn = BTDropInController(authorization: currentClientToken, request: dropInRequest) { (controller, result, error) in
            if let btError = error {
                // Handle error
                
                self.result?(.failure(btError))
                self.dismissPresentedView()
            } else if (result?.isCancelled == true) {
                // Handle user cancelled flow
                
                self.result?(.failure(BTErrors.clientCancelled))
                self.dismissPresentedView()
            } else if let nonce = result?.paymentMethod{
                self.result?(.success(nonce))
                // Use the nonce returned in `result.paymentMethod`
            }
            
            controller.presentedViewController?.dismiss(animated: true, completion: nil)
            controller.dismiss(animated: true, completion: nil)
        }
        guard let dropIn = _dropIn else{return}
        view.present(dropIn, animated: true, completion: nil)
    }
}
//MARK:- BTDropInViewControllerDelegate
extension BrainTreeHandler : BTDropInViewControllerDelegate{
    func drop(_ viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        viewController.presentedViewController?.dismiss(animated: true, completion: nil)
        self.result?(.success(paymentMethodNonce))
        self.dismissPresentedView()
    }
    
    func drop(inViewControllerDidCancel viewController: BTDropInViewController) {
        viewController.presentedViewController?.dismiss(animated: true, completion: nil)
        self.result?(.failure(BTErrors.clientCancelled))
        self.dismissPresentedView()
    }
    
    
}
//MARK:- UDF
extension BrainTreeHandler {
    @objc func userDidCancelPayment() {
        self.result?(.failure(BTErrors.clientCancelled))
        self.dismissPresentedView()
    }
    
    func dismissPresentedView(){
        self.hostView?.dismiss(animated: true, completion: nil)
    }
}
/*
 
 let dropIn = BTDropInViewController(apiClient: currentClient)
 dropIn.delegate = self
 dropIn.paymentRequest = request
 dropIn.navigationItem
 .leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem
 .SystemItem.cancel,
 target: self,
 action: #selector(self.userDidCancelPayment))
 
 let navigationController = UINavigationController(rootViewController: dropIn)
 navigationController.navigationBar.barStyle = .default
 navigationController.navigationBar.tintColor = .ThemeMain
 view.present(navigationController, animated: true, completion: nil)
 */
extension BrainTreeHandler : BTViewControllerPresentingDelegate{
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
    
    
}
extension BrainTreeHandler : BTAppSwitchDelegate{
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
    
    
}
