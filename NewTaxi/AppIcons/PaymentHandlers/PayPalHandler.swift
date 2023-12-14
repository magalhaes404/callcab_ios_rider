//
//  PaymentManager.swift
// NewTaxi
//
//  Created by Seentechs on 27/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//
/*
import Foundation
protocol PayPalHandlerDelegate : class{
    func paypalHandler(didComplete paymentID: String)
    func paypalHandler(didFail error: String)
}
enum PaymentFor{
    case wallet,trip
}
final class PayPalHandler : NSObject{
  
    var environment:String = PayPalEnvironmentSandbox{
          willSet(newEnvironment) {
              if (newEnvironment != environment) {
                  
                  PayPalMobile.preconnect(withEnvironment: newEnvironment)
              }
          }
      }
    private var payPalConfig = PayPalConfiguration()
    weak var delegate : PayPalHandlerDelegate?
    
    public init(_ delegate : PayPalHandlerDelegate){
        super.init()
        self.delegate = delegate
        
        self.initializePaypalConfiguaration()
    }
   
    
    
    
 
    class func initPaypalModule(){
        PayPalMobile.initialize()
        guard let paypal_app_id : String = UserDefaults.value(for: .paypal_client_key),
            let paypal_mode : String = UserDefaults.value(for: .paypal_mode) else{return}
        
        let environmentConfig : [AnyHashable : Any]
        if paypal_mode == "1"{
            environmentConfig = [PayPalEnvironmentProduction: "\(paypal_app_id)"]
        }else{
            environmentConfig = [PayPalEnvironmentSandbox: "\(paypal_app_id)"]
        }

        PayPalMobile.initialize()
        PayPalMobile.initializeWithClientIds(forEnvironments: environmentConfig)
    }
    ///call this on Appear delegates
    func preconnect(){
        
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    func initializePaypalConfiguaration(){
        let paypal_app_id : String = UserDefaults.value(for: .paypal_client_key) ?? ""
        let paypalMode : String = UserDefaults.value(for: .paypal_mode) ?? "0"
        UIApplication.shared.statusBarStyle = .lightContent
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        DispatchQueue.main.async {
            // Set up payPalConfig
            self.payPalConfig.acceptCreditCards = false
            self.payPalConfig.merchantName = "Awesome Shirts, Inc."
            self.payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
            self.payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
            let environmentConfig : [AnyHashable : Any]
            if paypalMode == "1"{
                environmentConfig = [PayPalEnvironmentProduction: "\(paypal_app_id)"]
            }else{
                environmentConfig = [PayPalEnvironmentSandbox: "\(paypal_app_id)"]
            }
            PayPalMobile.initialize()
            PayPalMobile.initializeWithClientIds(forEnvironments: environmentConfig)
        }
    }
    /**
     initialize payment for the given amount
     - Author: Abishek Robin
     - Parameter amount: Amount to be payed
     - Parameter currency: currency for transaction
     - Parameter name: Payment for trip / wallet
     - Warning: Paypal should be initialized and preconnection should be done before calling this function
     */
    func makePaypal(payentOf amount : Double,
                    currency : String,
                    for name : PaymentFor) {
        let payamount = amount.description
        let item1 = PayPalItem(name: "\(name)",
                                  withQuantity: 1,
                                  withPrice: NSDecimalNumber(string: payamount),
                                  withCurrency: "\(currency)",
            withSku: "\(name)-\(Int(amount))")
           print("item1 \(item1)")
           let items = [item1]
           let subtotal = PayPalItem.totalPrice(forItems: items)
           
           let shipping = NSDecimalNumber(string: "0.00")
           let tax = NSDecimalNumber(string: "0.00")
           let paymentDetails = PayPalPaymentDetails(subtotal: subtotal,
                                                     withShipping: shipping, withTax: tax)
           let total = subtotal.adding(shipping).adding(tax)
           let payment = PayPalPayment(amount: total, currencyCode: "\(currency)", shortDescription: "\(iApp.appName) \(NSLocalizedString("Payment", comment: ""))", intent: .sale)
           payment.items = items
           payment.paymentDetails = paymentDetails

           if (payment.processable) {
               let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
              
            let viewController = self.delegate as? UIViewController
            viewController?.present(paymentViewController!, animated: true, completion: nil)
           }
           else {
               print("Payment not processalbe: \(payment)")
           }
       }
}
extension PayPalHandler : PayPalPaymentDelegate{
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismiss(animated: true) {
            self.delegate?.paypalHandler(didFail : "Cancelled".localize)
        }
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        print(" ∂π\(completedPayment.confirmation)")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            if completedPayment.confirmation["response"] != nil,
                let dict = completedPayment.confirmation["response"] as? NSDictionary
            {
                
                if dict["id"] != nil
                {
                    self.delegate?.paypalHandler(didComplete : dict["id"] as? String ?? String())
                    print("Transaction ID:",dict["id"] as? String ?? String())
                }
            }
         
        })
    }
    
    
}
*/
