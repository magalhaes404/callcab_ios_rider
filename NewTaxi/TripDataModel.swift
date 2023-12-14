//
//  TripDataModel.swift
// NewTaxi
//
//  Created by Seentechs on 16/11/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
class TripDataModel {
    let id : Int
    let carID : Int
    let seats : Int
    let poolID : Int
    let isShareRide : Bool
    let tripPath : String
    let totalFare : Double
    let carName : String
    let mapImage :String
    let pickupLatitude, pickupLongitude : Double
    let dropLatitude, dropLongitude: Double
    let pickupLocation, dropLocation: String
    let currencySymbol : String
    let scheduleDisplayTime : String
    let subTotalFare: Double
    var status : TripStatus
    let bookingType : BookingEnum
    
    var payment_detail = EndTripModel()
    var invoice = [InvoiceModel]()
    init(_ json : JSON) {
        
        self.poolID = json.int("pool_id")
        self.isShareRide = json.bool("is_pool")
        self.carID =  json.int("car_id")
        self.subTotalFare = json.double("subtotal_fare")
        self.seats = json.int("seats")
        
        let riderJSON = json.array("riders").first ?? JSON()
        self.scheduleDisplayTime = riderJSON.string("schedule_display_date")
        self.carName =  riderJSON.string("car_type")
        self.id =  riderJSON.int("trip_id")
        self.currencySymbol =  riderJSON.string("currency_symbol")
        self.tripPath =  riderJSON.string("trip_path")
        self.totalFare =  riderJSON.double("total_fare")
        self.mapImage =  riderJSON.string("map_image")
        self.pickupLatitude =  riderJSON.double("pickup_lat")
        self.pickupLongitude =  riderJSON.double("pickup_lng")
        self.pickupLocation = riderJSON.string("pickup")
        self.dropLatitude =  riderJSON.double("drop_lat")
        self.dropLongitude =  riderJSON.double("drop_lng")
        self.dropLocation = riderJSON.string("drop")
        
        
        let invoiceArr = riderJSON.array("invoice")
        self.invoice = invoiceArr.compactMap({InvoiceModel.init($0)})
        
        let paymentDetails = riderJSON.json("payment_details")
        self.payment_detail = EndTripModel.init(paymentDetails)
        
        let _status = riderJSON.string("status")
        let _tripsStatus = riderJSON.json("payment_details").string("trips_status")
        self.status =  TripStatus(rawValue: _status.isEmpty ? _tripsStatus : _status) ?? .request
        self.bookingType = BookingEnum(rawValue: riderJSON.string("booking_type")) ?? .auto
    }
    convenience  init(tripID id : Int){
        var json = JSON()
        json["trip_id"] = id
        self.init(json)
    }
}
//MARK:- Equatable,Hashable
extension TripDataModel : Equatable,Hashable{
    static func == (lhs: TripDataModel, rhs: TripDataModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
}
extension TripDataModel : CustomStringConvertible{
    var description: String{
        return self.id.description
    }
}
//MARK:- UDF
extension TripDataModel{
    private var getGooglStaticMap : URL?{
        let startlatlong = "\(self.pickupLatitude),\(self.pickupLongitude)"
        
        let droplatlong = "\(self.dropLatitude),\(self.dropLongitude)"
        
        let tripPath = self.tripPath
        let mapmainUrl = "https://maps.googleapis.com/maps/api/staticmap?"
        let mapUrl  = mapmainUrl + startlatlong
        let size = "&size=" +  "\(Int(640))" + "x" +  "\(Int(350))"
        let enc = "&path=color:0x000000ff|weight:4|enc:" + tripPath
        let key = "&key=" +  iApp.instance.GoogleApiKey//(UserDefaults.value(for: .google_api_key) ?? "")
        let pickupImgUrl = String(format:"%@public/images/pickup_icon|",iApp.baseURL.rawValue)
        let dropImgUrl = String(format:"%@public/images/dropoff_icon|",iApp.baseURL.rawValue)
        let positionOnMap = "&markers=size:mid|icon:" + pickupImgUrl + startlatlong
        let positionOnMap1 = "&markers=size:mid|icon:"  + dropImgUrl + droplatlong
        let staticImageUrl = mapUrl + positionOnMap + size + "&zoom=14" + positionOnMap1 + enc + key
        let urlStr = staticImageUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! as String
        let url = URL(string: urlStr)
        return url
    }
    func getWorkingMapURL() -> URL?{
        if self.mapImage.isEmpty{
            return self.getGooglStaticMap
        }else{
            return URL(string: self.mapImage)
        }
    }
}
