//
//  ReferalModel.swift
// NewTaxi
//
//  Created by Seentechs on 24/09/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

enum ReferalStatus : String{
    case pending = "Pending"
    case expired = "Expired"
    case completed = "Completed"
}
enum ReferalType : Int{
    case completed = 1
    case inComplete = 0
}
class ReferalModel{
    var id =  Int()
//    var days =  Int()
    var name = String()
    var profile_image = String()
    var profile_image_url : URL?{
        return URL(string: self.profile_image)
    }
    var remaining_days =  Int()
//    var trips =  Int()
    var remaining_trips =  Int()
//    var start_date =  String()
//    var end_date =  String()
    var earnable_amount =  String()
    var status = ReferalStatus.pending
    lazy var lang = Language.default.object

    var getDesciptionText : String {
        var text = "\(self.remaining_days) "
//        text.append(self.remaining_days == 1 ? "day left | Need to Complete".localize  : "days left | Need to Complete".localize )
        text.append(self.remaining_days == 1 ? self.lang.dayLeft  : self.lang.dayLeft )
        text.append(" \(self.remaining_trips) ")
//        text.append(self.remaining_trips == 1 ? "trip".localize :"trips".localize)
        text.append(self.remaining_trips == 1 ? self.lang.trip :self.lang.trips)

        return text
    }
    init(withJSON json : JSON){
        self.id = json.int("id")
        self.name = json.string("name")
        self.profile_image = json.string("profile_image")
//        self.days = json.int("days")
        self.remaining_days = json.int("remaining_days")
//        self.trips = json.int("trips")
        self.remaining_trips = json.int("remaining_trips")
//        self.start_date = json.string("start_date")
        self.earnable_amount = json.string("earnable_amounts")
        self.status = ReferalStatus.init(rawValue: json.string("payment_status")) ?? .pending
    }
}
