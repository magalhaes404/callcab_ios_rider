//
//  TripEnums.swift
// NewTaxi
//
//  Created by Seentechs on 09/04/19.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

enum TripStatus : String,Codable{
    case cancelled = "Cancelled"
    case completed = "Completed"
    case rating = "Rating"
    case payment = "Payment"
    case request = "Request"
    case beginTrip = "Begin trip"
    case endTrip =  "End trip"
    case scheduled = "Scheduled"
    case pending  =  "Pending"
    
    case manuallyBooked = "manual_booking_trip_assigned"
    case manuallyBookedReminder = "manual_booking_trip_reminder"
    case manualBookiingCancelled = "manual_booking_trip_canceled_info"
    case manualBookingInfo = "manual_booking_trip_booked_info"
    
    var isTripStarted :Bool{
          return [TripStatus.beginTrip,.endTrip].contains(self)
      }
}
enum BookingEnum : String,Codable{
    case schedule = "ScheduleRide"
    case auto = "Trip"
    case manualBooking = "Manual Booking"//ignore case
}

extension TripStatus {
    var getAlertTitle : String{
        switch self {
        case .request:
            return ""
        default:
            return ""
        }
    }
    var localizedValue : String{
        let language = Language.default.object
        switch self {
            case .pending :  return language.pendingStatus
            case .cancelled :  return language.cancelledStatus
            case .completed :  return language.completedStatus
            case .rating :  return language.ratingStatus
            case .payment :  return language.paymentStatus
            case .request :  return language.requestStatus
            case .beginTrip :  return language.beginTripStatus
            case .endTrip :  return language.endTripStatus
            case .scheduled :  return language.scheduledStatus
            default : return self.rawValue
        }
    }
}
