/**
 * SearchCarsModel.swift
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

class SearchCarsModel : NSObject {
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var base_fare : String = ""
    var capacity : String = ""
    var car_id : String = ""
    var car_name : String = ""
    var fare_estimation : String = ""
    var min_fare : String = ""
    var min_time : String = ""
    var per_km : String = ""
    var per_min : String = ""
    var apply_peak = Bool()
    var peak_price = String()
    var peak_id = Int()
    var car_image = String()
    var car_active_image = String()
    var location_id = String()
    
    var arrcCarLocations : NSMutableArray = NSMutableArray()
    
    var shareRideEnabled = false
    var additionalRiderPercentage  = Double()
    var waitingTime = Int()
    var waitingCharge = Double()
    var driverIDS : [String] = [String]()
    
    lazy var language : LanguageProtocol = {
        return Language.default.object
    }()
    var appliedWaitingChargeDescription : String?{
        
        guard !waitingCharge.isZero && waitingTime != 0 else{return nil}
        let currency  = Constants().GETVALUE(keyname: USER_CURRENCY_SYMBOL_ORG)
        let time = self.language.minArrivalTillStart
        let fee = self.language.minWaitingApplied
        return "\(currency)\(self.waitingCharge)\(fee) \(self.waitingTime) \(time)"
    }
    func initCarDetailsArray(responseArray: NSDictionary) -> Any
    {
        base_fare = UberSupport().checkParamTypes(params: responseArray, keys:"base_fare") as String
        capacity = UberSupport().checkParamTypes(params: responseArray, keys:"capacity") as String
        car_id = UberSupport().checkParamTypes(params: responseArray, keys:"car_id") as String
        car_name = UberSupport().checkParamTypes(params: responseArray, keys:"car_name") as String
        fare_estimation = UberSupport().checkParamTypes(params: responseArray, keys:"fare_estimation") as String
        min_fare = UberSupport().checkParamTypes(params: responseArray, keys:"min_fare") as String
        min_time = UberSupport().checkParamTypes(params: responseArray, keys:"min_time") as String
        per_km = UberSupport().checkParamTypes(params: responseArray, keys:"per_km") as String
        per_min = UberSupport().checkParamTypes(params: responseArray, keys:"per_min") as String
        if let json = responseArray as? JSON{
            waitingTime = json.int("waiting_time")
            waitingCharge = json.double("waiting_charge")

            self.driverIDS = json.array("drivers").compactMap({$0.string("id")})
        }
        if let _apply_peak = UberSupport().checkParamTypes(params: responseArray, keys:"apply_peak") as? String{
            self.apply_peak = (_apply_peak.lowercased() == "yes")
        }
        if let _peak_price = UberSupport().checkParamTypes(params: responseArray, keys:"peak_price") as? String{
            self.peak_price = _peak_price
        }
        if let _peak_id = UberSupport().checkParamTypes(params: responseArray, keys:"peak_id") as? String{
            self.peak_id = Int(_peak_id) ?? 0
        }
        if let latestValue = responseArray["location"] as? NSArray
        {
            arrcCarLocations = NSMutableArray()
            
            for i in 0 ..< latestValue.count
            {
                arrcCarLocations.addObjects(from: [latestValue[i]])
            }
        }
        
        self.car_image = UberSupport().checkParamTypes(params: responseArray, keys:"car_image") as String
        self.car_active_image = UberSupport().checkParamTypes(params: responseArray, keys:"car_active_image") as String
        self.location_id = UberSupport().checkParamTypes(params: responseArray, keys:"location_id") as String
        self.shareRideEnabled = (responseArray as? JSON)?.bool("is_pool") ?? false
        self.additionalRiderPercentage = (responseArray as? JSON)?.double("additional_rider_percentage") ?? 0.0
        return self
    }
    init(_ json : JSON) {
        base_fare = json.string("base_fare")
        capacity = json.string("capacity")
        car_id = json.string("car_id")
        car_name = json.string("car_name")
        fare_estimation = json.string("fare_estimation")
        min_fare = json.string("min_fare")
        min_time = json.string("min_time")
        per_km = json.string("per_km")
        per_min = json.string("per_min")
        self.apply_peak = json.string("apply_peak").lowercased() == "yes"
        self.peak_price = json.string("peak_price")
        self.peak_id = json.int("peak_id")
     
        self.waitingTime = json.int("waiting_time")
        self.waitingCharge = json.double("waiting_charge")
        let locaitonArray = json.array("location")
        arrcCarLocations = NSMutableArray()
        self.driverIDS = json.array("drivers").compactMap({$0.string("id")})
        for location in locaitonArray{
            arrcCarLocations.addObjects(from: [location as Any])
        }
        
        self.waitingTime = json.int("waiting_time")
        self.waitingCharge = json.double("waiting_charge")
        
        self.car_image = json.string("car_image")
        self.car_active_image = json.string("car_active_image")
        self.location_id = json.string("location_id")
        
        self.shareRideEnabled = json.bool("is_pool")
        self.additionalRiderPercentage = json.double("additional_rider_percentage")
    }
}

