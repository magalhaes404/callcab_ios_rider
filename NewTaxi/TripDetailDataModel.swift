//
//  TripDetailDataModel.swift
// NewTaxi
//
//  Created by Seentechs on 16/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

class TripDetailDataModel : TripDataModel {
    //MARK Properties+
    let mobileNumber : String
    let ratingValue : String
    let carType : String
    var driverLatitude : Double
    var driverLongitude : Double

    let vehicleNumber : String
    let vehicleName : String
    let arrivalTime : String
//    let currencycode : String
//    let walletAmount : String
    var rating : String
    
    let driverId : Int
    let driverName : String
    var driverThumbImage : String
    
    let carId : Int
    let paymentMode : String
//    let paypalMode : Int
//    let paypalAppId : String
//    let totalTime : String
//    let driverPayout : String
//    let totalKm : String
    let createdAt : String
//    let updatedAt : String
    
//    let contact : String
    let otp : String
    //MARK:- GetterSetters
    var getTripID : String{
        return self.id.description
    }
    var getPayableAmount : String {
        return self.totalFare.isZero
            ? self.payment_detail.total_fare
            : self.totalFare.description
    }
    var getPaymentMethod : String{
        return self.paymentMode.isEmpty
            ? self.payment_detail.paymentMode
            : self.paymentMode
        
        
    }
    var driverLocation : CLLocation{
        return CLLocation(latitude: self.driverLatitude, longitude: self.driverLongitude)
    }
    var getRating : Double{
        return Double(self.rating) ?? (Double(self.ratingValue) ?? 0.0)
    }
    lazy var language = Language.default.object
    var tripStatus : TripStatus = .request
    
    
    var waitingTime = Int()
    var waitingCharge = Double()
    
    var arrivalFromGoogle : String?
    var appliedWaitingChargeDescription : String?{
        
        guard !waitingCharge.isZero && waitingTime != 0 else{return nil}
        let currency  = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let fee = self.language.minWaitingApplied 
        let time = self.language.minArrivalTillStart
        return "\(currency)\(self.waitingCharge)\(fee) \(self.waitingTime) \(time)"
    }
 
    var etaToDestination : String{
        let duration : String
        let language = Language.default.object
        if let googleDuration = self.arrivalFromGoogle{
            duration = googleDuration.capitalized
        }else{
            duration = "\(self.arrivalTime) \(language.mins.capitalized)"
        }
        return duration
    }
    override init(_ json : JSON){
        
        
        self.driverLatitude = json.double("driver_latitude")
        self.driverLongitude = json.double("driver_longitude")
        self.driverThumbImage = json.string("driver_thumb_image")
        self.driverName = json.string("driver_name")
        self.carType = json.string("car_type")
        self.mobileNumber = json.string("mobile_number")
        self.carId = json.int("car_id")
        self.driverId = json.int("driver_id")
        self.ratingValue = json.string("rating_value")
        self.paymentMode = json.string("payment_mode")
        self.vehicleName = json.string("vehicle_name")
        self.vehicleNumber = json.string("vehicle_number")
        
        self.arrivalTime = json.string("arrival_time").replacingOccurrences(of: "-", with: "")
   
        
        
        
//        self.paypalMode = json.int("paypal_mode")
//        self.paypalAppId = json.string("paypal_app_id")
        
        let riderJSON = json.array("riders").first ?? JSON()
        self.otp = riderJSON.string("otp")
        self.waitingTime = riderJSON.int("waiting_time")
        self.waitingCharge = riderJSON.double("waiting_charge")
//        self.totalTime = riderJSON.string("total_time")
//        self.driverPayout = riderJSON.string("driver_payout")
//        self.totalKm = riderJSON.string("total_km")
        self.createdAt = riderJSON.string("created_at")
//        self.updatedAt = riderJSON.string("updated_at")
        
//        self.currencycode = riderJSON.string("currency_code")
//        self.walletAmount = riderJSON.string("wallet_amount")
        self.rating = json.string("rating")
//        self.contact = riderJSON.string("contact")
        
      
        UserDefaults.set(self.driverId, for: .driver_user_id)
        UserDefaults.set(self.driverName, for: .driver_user_name)
        UserDefaults.set(self.driverThumbImage, for: .driver_user_image)
        
        
        super.init(json)
        if !self.getRating.isZero{
            UserDefaults.standard.set(self.getRating, forKey: TRIP_DRIVER_RATING)
        }
        self.storeDriverInfo(true)
    }
    //MARK:- storeUser Data
    func storeDriverInfo(_ val : Bool){
        let preference = UserDefaults.standard
        if val{
            UserDefaults.set(self.driverId, for: .driver_user_id)
            preference.set(self.driverThumbImage, forKey: TRIP_DRIVER_THUMB_URL)
            preference.set(self.driverName, forKey: TRIP_DRIVER_NAME)
            preference.set(self.ratingValue, forKey: TRIP_DRIVER_RATING)
        }else{
            UserDefaults.removeValue(for: .driver_user_id)
            preference.removeObject(forKey: TRIP_DRIVER_THUMB_URL)
            preference.removeObject(forKey: TRIP_DRIVER_NAME)
            preference.removeObject(forKey: TRIP_DRIVER_RATING)
        }
    }
}
//MARK:- EndTripModel
class EndTripModel  {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var access_fee : String = ""
    var base_fare : String = ""
    var driver_payout : String = ""
    var drop_location : String = ""
    var pickup_location : String = ""
//    var payment_status : String = ""
    var total_fare : String = ""
//    var total_km : String = ""
//    var total_km_fare : String = ""
//    var total_time : String = ""
    var total_time_fare : String = ""
    var paymentMode : String = ""
    var owe_amount : String = ""
    var applied_owe_amount : String = ""
    var wallet_amount : String = ""
    var promo_amount : String = ""
    
//    var paypal_app_id = String()
//    var paypal_mode = Int()
    
    var arrTemp2 : NSMutableArray = NSMutableArray()
    
    var arrTemp3 : NSMutableArray = NSMutableArray()
    init(){}
    init(_ json : JSON){
        self.access_fee = json.string("access_fee")
        self.base_fare = json.string("base_fare")
        self.drop_location = json.string("drop_location")
        self.pickup_location = json.string("pickup_location")
        self.total_fare = json.string("total_fare")
//        self.total_km = json.string("total_km")
//        self.total_km_fare = json.string("total_km_fare")
//        self.total_time = json.string("total_time")
        self.total_time_fare = json.string("total_time_fare")
        self.paymentMode = json.string("payment_mode")
//        self.driver_payout = json.string("driver_payout")
//        self.payment_status = json.string("payment_status")
//        self.paypal_app_id = json.string("paypal_app_id")
//        self.paypal_mode = json.int("paypal_mode")
        
    }
    
}
