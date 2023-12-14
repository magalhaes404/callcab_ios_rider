/**
 * DriverDetailModel.swift
 *
 * @package NewTaxi
 * @subpackage Controller
 * @category Calendar
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

import Foundation
import UIKit

class DriverDetailModel : NSObject {
    //MARK Properties+
    var id = Int()
    var status_message : String = ""//
    var status_code : String = ""//
    var trip_status : String = ""
    var trip_id : String = ""
    var driver_name : String = ""
    var mobile_number : String = ""
    var driver_thumb_image : String = ""
    var rating_value : String = ""
    var car_type : String = ""
    var pickup_location : String = ""
    var drop_location : String = ""
    var driver_latitude : String = ""
    var driver_longitude : String = ""
    var pickUp_latitude : String = ""
    var pickUp_longitude : String = ""
    var drop_latitude : String = ""
    var drop_longitude : String = ""
    var vehicle_number : String = ""
    var vehicle_name : String = ""
    var arrival_time : String = ""
    var currency_symbol : String = ""
    var currency_code : String = ""
    var wallet_amount : String = ""
    var rating : String  = ""
    var car_name : String  = ""
    
    var car_id = Int()
    var driver_id = String()
    var status = String()
    
    var paymentMode : String = ""
//    var paypal_mode = Int()
//    var paypal_app_id = String()
    var trip_path = String()
    var map_image = String()
//    var total_time = String()
    var total_fare = String()
    var driver_payout = String()
    var total_km = String()
//    var begin_trip = String()
//    var end_trip = String()
    var created_at = String()
//    var updated_at = String()
    var source : BookingEnum = .auto
    var contact = String()
    var otp = String()
    var getTripID : String{
        return self.trip_id.isEmpty ? self.id.description : self.trip_id
    }
    var getPayableAmount : String {
        return (Double(self.total_fare) ?? 0.0).isZero
            ? self.payment_detail.total_fare
            : self.total_fare
    }
    var getPaymentMethod : String{
        return self.paymentMode.isEmpty
            ? self.payment_detail.paymentMode
            : self.paymentMode
    }
    var getRating : Double{
        return Double(self.rating) ?? (Double(self.rating_value) ?? 0.0)
    }
    var tripStatus : TripStatus = .request
    var payment_detail = EndTripModel()
    var invoices = [InvoiceModel]()
    
    
    var waitingTime = Int()
    var waitingCharge = Double()
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    
    var appliedWaitingChargeDescription : String?{
        
        guard !waitingCharge.isZero && waitingTime != 0 else{return nil}
        let currency  = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        //        let fee = "/min Waiting Fee applies after".localize
        //        let time = "min of arrival till trip starts.".localize
        let time = self.language.minArrivalTillStart
        let fee = self.language.minWaitingApplied
        return "\(currency)\(self.waitingCharge)\(fee) \(self.waitingTime) \(time)"
    }
    
    override init(){}
    
    
    
    init(withJson json : JSON){
        super.init()
        self.id = json.int("id")
        self.trip_id = json.string("id")
        self.driver_thumb_image = json.string("driver_thumb_image")
        self.driver_name = json.string("driver_name")
        self.rating_value = json.string("rating_value")
        self.car_type = json.string("car_type")
        self.pickup_location = json.string("pickup_location")
        self.drop_location = json.string("drop_location")
        self.pickUp_latitude = json.string("pickup_latitude")
        self.pickUp_longitude = json.string("pickup_longitude")
        self.drop_latitude = json.string("drop_latitude")
        self.drop_longitude = json.string("drop_longitude")
        self.mobile_number = json.string("mobile_number")
        self.paymentMode = json.string("payment_mode")
        self.vehicle_name = json.string("vehicle_name")
        self.driver_name = json.string("driver_name")
        self.car_id = json.int("car_id")
        self.driver_id = json.string("driver_id")
        self.status = json.string("status")
        self.otp = json.string("otp")
        self.trip_id = json.string("trip_id")
        self.trip_status = json.string("trip_status")
        if let status = TripStatus(rawValue: self.trip_status){
            self.tripStatus = status
        }else if let status = TripStatus(rawValue: self.status){
            self.tripStatus = status
        }else{
            self.tripStatus = .request
        }
        let paymentDetails = json.json("payment_details")
        
        self.waitingTime = json.int("waiting_time")
        self.waitingCharge = json.double("waiting_charge")
        
        
//        self.paypal_mode = json.int("paypal_mode")
//        self.paypal_app_id = json.string("paypal_app_id")
        self.trip_path = json.string("trip_path")
        self.map_image = json.string("map_image")
//        self.total_time = json.string("total_time")
        self.total_fare = json.string("total_fare")
//        self.driver_payout = json.string("driver_payout")
//        self.total_km = json.string("total_km")
//        self.begin_trip = json.string("begin_trip")
//        self.end_trip = json.string("end_trip")
        self.created_at = json.string("created_at")
//        self.updated_at = json.string("updated_at")
        self.source  = .auto
        
        self.driver_name = json.string("driver_name")
        self.driver_id = json.string("driver_id")
        self.driver_thumb_image = json.string("driver_thumb_image")
        self.payment_detail = EndTripModel.init(paymentDetails)
        
        let invoiceArr = json.array("invoice")
        self.invoices = invoiceArr.compactMap({InvoiceModel.init($0)})
        if !self.getRating.isZero{
            UserDefaults.standard.set(self.getRating, forKey: TRIP_DRIVER_RATING)
        }
        self.status_code = json.string("status_code")
        self.status_message = json.string("status_message")
        UserDefaults.set(self.driver_id, for: .driver_user_id)
        UserDefaults.set(self.driver_name, for: .driver_user_name)
        UserDefaults.set(self.driver_thumb_image, for: .driver_user_image)
    }
    //MARK:- fucnitonalities
    var getGooglStaticMap : URL?{
        let startlatlong = "\(self.pickUp_latitude),\(self.pickUp_longitude)"
        
        let droplatlong = "\(self.drop_latitude),\(self.drop_longitude)"
        
        let tripPath = self.trip_path//pastTripsDict[indexPath.row]["trip_path"] as? String ?? String()
        let mapmainUrl = "https://maps.googleapis.com/maps/api/staticmap?"
        let mapUrl  = mapmainUrl + startlatlong
        let size = "&size=" +  "\(Int(640))" + "x" +  "\(Int(350))"
        let enc = "&path=color:0x000000ff|weight:4|enc:" + tripPath
        let key = "&key=" +  iApp.instance.GoogleApiKey//(UserDefaults.value(for: .google_api_key) ?? "")
        let pickupImgUrl = String(format:"%@public/images/pickup_icon|",iApp.APIBaseUrl)
        let dropImgUrl = String(format:"%@public/images/dropoff_icon|",iApp.APIBaseUrl)
        let positionOnMap = "&markers=size:mid|icon:" + pickupImgUrl + startlatlong
        let positionOnMap1 = "&markers=size:mid|icon:"  + dropImgUrl + droplatlong
        let staticImageUrl = mapUrl + positionOnMap + size + "&zoom=14" + positionOnMap1 + enc + key
        let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as String
        let url = URL(string: urlStr)
        return url
    }
    func storeDriverInfo(_ val : Bool){
        let preference = UserDefaults.standard
        if val{
            preference.set(self.driver_thumb_image, forKey: TRIP_DRIVER_THUMB_URL)
            preference.set(self.driver_name, forKey: TRIP_DRIVER_NAME)
            preference.set(self.rating_value, forKey: TRIP_DRIVER_RATING)
        }else{
            preference.removeObject(forKey: TRIP_DRIVER_THUMB_URL)
            preference.removeObject(forKey: TRIP_DRIVER_NAME)
            preference.removeObject(forKey: TRIP_DRIVER_RATING)
        }
    }
    
    
    convenience init(jsonForRiderProfile json : JSON){
        self.init(withJson: json)
        let rider = RiderDataModel(json)
        dump(rider)
        if json.isSuccess{
            rider.storeRiderBasicDetail()
        }
        
        self.status_message = json["status_message"] as? String ?? String()
        self.status_code = json["status_code"] as? String ?? String()
        if self.status_code == "1"
        {
            
            self.otp = json["otp"] as? String ?? String()
            self.currency_symbol = json["currency_symbol"] as? String ?? String()
            self.currency_code = json["currency_code"] as? String ?? String()
            self.wallet_amount = json["wallet_amount"] as? String ?? String()
            self.contact = json["contact"] as? String ?? String()
            
            let profileImage = json.string("profile_image")
            let mobileNuber = json.string("mobile_number")
            if !mobileNuber.isEmpty{
                Constants().STOREVALUE(value: mobileNuber, keyname: USER_PHONE_NUMBER)
            }
            Constants().STOREVALUE(value: profileImage, keyname: USER_IMAGE_THUMB)
            
            let currencySymbol = json.string("currency_symbol").stringByDecodingHTMLEntities
            Constants().STOREVALUE(value: currencySymbol, keyname: USER_CURRENCY_SYMBOL_ORG)// Symbol $
            Constants().STOREVALUE(value: json.string("currency_code"), keyname: USER_CURRENCY_ORG)// code USD
            Constants().STOREVALUE(value: json.string("wallet_amount"), keyname: USER_WALLET_AMOUNT)
            Constants().STOREVALUE(value: json.string("country_code"), keyname: USER_COUNTRY_CODE)
            
        }
        
    }
}
