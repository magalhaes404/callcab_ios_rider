//
//  StripeHandler.swift
// NewTaxi
//
//  Created by Seentechs on 21/11/19.       
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Stripe
final class StripeHandler : NSObject {
    
    class func initStripeModule(){
        guard let key :  String = UserDefaults.value(for: .stripe_publish_key) else{return}
        STPPaymentConfiguration
            .shared.publishableKey = key
    }
    class func isStripeHandleURL(_ url : URL) -> Bool{
        return Stripe.handleURLCallback(with: url)
    }
    let client = STPAPIClient.shared
    private let viewController : UIViewController
    init(_ viewController : UIViewController) {
        self.viewController = viewController
    }
    ///create token for given card with 3dSecureValidation
    func setUpCard(
        textField: STPPaymentCardTextField,
        secret : String,
        completion: @escaping (Result<String, Error>) -> Void) {
        let paymentMethodParams =  STPPaymentMethodParams(
            card: textField.cardParams,
            billingDetails: nil,
            metadata: nil
        )
        let setup = STPSetupIntentConfirmParams(clientSecret: secret)
        setup.paymentMethodParams = paymentMethodParams
        STPPaymentHandler
            .shared()
            .confirmSetupIntent(setup,
                                with: self)
            { (actionStatus,intent, error) in
                switch actionStatus{
                case .succeeded:
                    if let _intent = intent{
                        completion(.success(_intent.stripeID))
                    }
                case .failed,.canceled:
                    if let _error = error{
                        completion(.failure(_error))
                    }
                @unknown default:
                    break
                }
                
        }

    
    }
    ///confirms payment for the given token with 3dSecureValidation
    func confirmPayment(for token : String,
                        completion : @escaping (Result<String,Error>)->()){
        let intent = STPPaymentIntentParams(clientSecret: token)
        STPPaymentHandler
        .shared()
        .confirmPayment(withParams: intent,
                        authenticationContext: self)
        { (actionStatus,intent, error) in
            switch actionStatus{
            case .succeeded:
                if let _intent = intent{
                    completion(.success(_intent.stripeId))
                }
            case .failed,.canceled:
                if let _error = error{
                    completion(.failure(_error))
                }
            @unknown default:
                break
            }
            
        }
    }
}
extension StripeHandler : STPAuthenticationContext{
    func authenticationPresentingViewController() -> UIViewController {
        
        return self.viewController
    }
}
