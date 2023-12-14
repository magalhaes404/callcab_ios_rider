//
//  TripHistoryModel.swift
// NewTaxi
//
//  Created by Seentechs on 13/05/21.
//  Copyright © 2021 Vignesh Palanivel. All rights reserved.
//

import Foundation
class TripHistoryModel: Codable {
    let statusCode, statusMessage: String
    let currentPage, totalPages: Int
    let data: [History]

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case data
    }
    required init(from decoder : Decoder) throws{
         let container = try decoder.container(keyedBy: CodingKeys.self)
         let dataArr = try? container.decode([History].self, forKey: .data)
        self.data = dataArr ?? [History]()
        self.statusCode = container.safeDecodeValue(forKey: .statusCode)
        self.statusMessage = container.safeDecodeValue(forKey: .statusMessage)
        self.currentPage = container.safeDecodeValue(forKey: .currentPage)
        self.totalPages = container.safeDecodeValue(forKey: .totalPages)
     }
}
class History: Codable {
    let status: TripStatus
    let bookingType : BookingEnum
    let tripID,seats: Int
    let pickup, drop, mapImage: String
    let scheduleDisplayDate: String
    let carType, currencySymbol, totalFare, driverEarnings: String
    let isPool : Bool
    enum CodingKeys: String, CodingKey {
        case status
        case tripID = "trip_id"
        case pickup, drop
        case mapImage = "map_image"
        case scheduleDisplayDate = "schedule_display_date"
        case carType = "car_type"
        case currencySymbol = "currency_symbol"
        case totalFare = "total_fare"
        case driverEarnings = "driver_earnings"
        case seats
        case isPool = "is_pool"
        case bookingType = "booking_type"
    }
    required init(from decoder : Decoder) throws{
         let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tripID = container.safeDecodeValue(forKey: .tripID)
        self.pickup = container.safeDecodeValue(forKey: .pickup)
        self.drop = container.safeDecodeValue(forKey: .drop)
        self.mapImage = container.safeDecodeValue(forKey: .mapImage)
        self.scheduleDisplayDate = container.safeDecodeValue(forKey: .scheduleDisplayDate)
        self.carType = container.safeDecodeValue(forKey: .carType)
        self.currencySymbol = container.safeDecodeValue(forKey: .currencySymbol)
        self.totalFare = container.safeDecodeValue(forKey: .totalFare)
        self.driverEarnings = container.safeDecodeValue(forKey: .driverEarnings)
        self.seats = container.safeDecodeValue(forKey: .seats)
        self.isPool = container.safeDecodeValue(forKey: .isPool)
        let status = try? container.decode(TripStatus.self, forKey: .status)
        self.status = status ?? TripStatus.request
        let type = try? container.decode(BookingEnum.self, forKey: .bookingType)
        self.bookingType = type ?? BookingEnum.auto
     }
}
