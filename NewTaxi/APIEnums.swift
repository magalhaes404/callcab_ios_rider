//
//  APIEnums.swift
// NewTaxi
//
//  Created by Seentechs on 08/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Alamofire

enum APIEnums : String{
    
    
    case force_update = "check_version"
    case login = "login"
    case logout = "logout"
    case validateNumber = "numbervalidation"
    case getNearByDrivers = "get_nearest_vehicles"
    
    case currencyConversion = "currency_conversion"
    case getEssetntials = "common_data"
    case getPaymentOptions = "get_payment_list"
    case riderProfile = "get_rider_profile"
    case getCallerDetails = "get_caller_detail"
    case webPayment = "web_payment"
    case cancel_reasons = "cancel_reasons"
    case getInvoice = "get_invoice"
    case afterPayment = "after_payment"
    case addAmountToWallet = "add_wallet"
    case giveRating = "trip_rating"
    case getReferals = "get_referral_details"
    case getPastTrips = "get_past_trips"
    case getUpcomingTrips = "get_upcoming_trips"
    case requestCars = "request_cars"
    case scheduleRide = "save_schedule_ride"
    
    case addStripeCard = "add_card_details"
    case getStripeCard = "get_card_details"
    
    case getTripDetail = "get_trip_details"
    case sendMessage = "send_message"
    
    case updateLanguage = "language"
    case getPromoDetails = "promo_details"
    case addPromoCode = "add_promo_code"
    
    case signUp = "register"
    case socialSignup = "socialsignup"
    case updatePassword = "forgotpassword"
    case updateRiderProfile = "update_rider_profile"
    case updateRiderLocation = "update_rider_location"
    case cancelTrip = "cancel_trip"
    case updateDeviceToken = "update_device"
    case getDriverLocation = "track_driver"
    case getCurrencyList = "currency_list"
    case updateUserCurrency = "update_user_currency"
    case searchCars = "search_cars"
    case uploadProfileImage = "upload_profile_image"
    case cancelScheduleRide = "schedule_ride_cancel"
    case none
    case sos = "sos"
    case getRiderTrips = "get_rider_trips"
    case sosalert
    case otpVerification = "otp_verification"
}

extension APIEnums{//Return method for API
    var method : HTTPMethod{
        switch self {
        case .getEssetntials,
             .currencyConversion,
             .addAmountToWallet,
             .getPaymentOptions,
             .afterPayment,
             .requestCars,
             .scheduleRide:
            return .post
        default:
            return .get
        }
    }
    var cacheAttribute: Bool{
        switch self {
        case .getPastTrips,.getTripDetail,.riderProfile,.sos:
            return true
        default:
            return false
        }
    }
    var canHandleFailureCases : Bool {
        return [APIEnums.validateNumber]
            .contains(self)
    }
}

enum ResponseEnum{
    case RiderModel(_ rider :DriverDetailModel)
    case newUserNotAuthenticatedYet
    case onAuthenticate(_ loginData : RiderDataModel)
    case LoggedOut
    case RatingGiven(_ statusCode: Int)
    case number(isValid : Bool,OTP : String,message : String)
    case forceUpdate(_ update : ForceUpdate)
    case cancelReason(_ reasons : [CancelReason])
    case amountAddedToWallet(_ statMsg:String)
    case requires3DSecureValidation(forIntent : String)
    case success
    case failure(_ error : String)
    case onReferalSuccess(referal : String,
        totalEarning : String,
        maxReferal : String,
        incomplete : [ReferalModel],
        complete :[ReferalModel],
        appLink: String)
    case onReferalFailure
    
    case callerDetails(callerName : String,image : String)
    case essentialDataReceived
    
    case liveCars(_ cars : [LiveCar])
    case pastTrip(data: [TripDataModel],
        totalPages: Int,
        currentPage: Int)
    case upCommingTrip(data: [TripDataModel],
        totalPages: Int,
        currentPage: Int)
    case onCurrencyConvert(amount : Double,brainTreeClientID : String,currency : String?)
    case tripDetailData(_ data : TripDetailDataModel)
}

