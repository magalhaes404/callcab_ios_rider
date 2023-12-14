//
//  GoogleDirectionModel.swift
// NewTaxi
//
//  Created by Seentechs on 27/02/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation

// MARK: - GoogleGeocode
class GoogleGeocode: Codable {
    let geocodedWaypoints: [GeocodedWaypoint]
    let routes: [Route]
    let status: String

    enum CodingKeys: String, CodingKey {
        case geocodedWaypoints = "geocoded_waypoints"
        case routes = "routes"
        case status = "status"
    }

    init(geocodedWaypoints: [GeocodedWaypoint], routes: [Route], status: String) {
        self.geocodedWaypoints = geocodedWaypoints
        self.routes = routes
        self.status = status
    }
}

// MARK: - GeocodedWaypoint
class GeocodedWaypoint: Codable {
    let geocoderStatus: String
    let placeid: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case geocoderStatus = "geocoder_status"
        case placeid = "place_id"
        case types = "types"
    }

    init(geocoderStatus: String, placeid: String, types: [String]) {
        self.geocoderStatus = geocoderStatus
        self.placeid = placeid
        self.types = types
    }
}

// MARK: - Route
class Route: Codable {
    let bounds: Bounds
    let copyrights: String
    let legs: [Leg]
    let overviewPolyline: Polyline
    let summary: String
    let warnings: [JSONAny]
    let waypointOrder: [JSONAny]

    enum CodingKeys: String, CodingKey {
        case bounds = "bounds"
        case copyrights = "copyrights"
        case legs = "legs"
        case overviewPolyline = "overview_polyline"
        case summary = "summary"
        case warnings = "warnings"
        case waypointOrder = "waypoint_order"
    }

    init(bounds: Bounds, copyrights: String, legs: [Leg], overviewPolyline: Polyline, summary: String, warnings: [JSONAny], waypointOrder: [JSONAny]) {
        self.bounds = bounds
        self.copyrights = copyrights
        self.legs = legs
        self.overviewPolyline = overviewPolyline
        self.summary = summary
        self.warnings = warnings
        self.waypointOrder = waypointOrder
    }
}

// MARK: - Bounds
class Bounds: Codable {
    let northeast: GoogleLocation
    let southwest: GoogleLocation

    enum CodingKeys: String, CodingKey {
        case northeast = "northeast"
        case southwest = "southwest"
    }

    init(northeast: GoogleLocation, southwest: GoogleLocation) {
        self.northeast = northeast
        self.southwest = southwest
    }
}

// MARK: - Northeast
class GoogleLocation: Codable {
    let lat: Double
    let lng: Double

    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }

    init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    var location : CLLocation{
        return CLLocation(latitude: self.lat,
                          longitude: self.lng)
    }
    func distance(from location: CLLocation) -> Double{
        return location.distance(from: self.location)
    }
}

// MARK: - Leg
class Leg: Codable {
    let distance: Distance
    let duration: Distance
    let endAddress: String
    let endLocation: GoogleLocation
    let startAddress: String
    let startLocation: GoogleLocation
    let steps: [Step]
    let trafficSpeedEntry: [JSONAny]
    let viaWaypoint: [JSONAny]

    enum CodingKeys: String, CodingKey {
        case distance = "distance"
        case duration = "duration"
        case endAddress = "end_address"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case startLocation = "start_location"
        case steps = "steps"
        case trafficSpeedEntry = "traffic_speed_entry"
        case viaWaypoint = "via_waypoint"
    }

    init(distance: Distance, duration: Distance, endAddress: String, endLocation: GoogleLocation, startAddress: String, startLocation: GoogleLocation, steps: [Step], trafficSpeedEntry: [JSONAny], viaWaypoint: [JSONAny]) {
        self.distance = distance
        self.duration = duration
        self.endAddress = endAddress
        self.endLocation = endLocation
        self.startAddress = startAddress
        self.startLocation = startLocation
        self.steps = steps
        self.trafficSpeedEntry = trafficSpeedEntry
        self.viaWaypoint = viaWaypoint
    }
}

// MARK: - Distance
class Distance: Codable {
    let text: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case text = "text"
        case value = "value"
    }

    init(text: String, value: Int) {
        self.text = text
        self.value = value
    }
}

// MARK: - Step
class Step: Codable {
    let distance: Distance
    let duration: Distance
    let endLocation: GoogleLocation
    let htmlInstructions: String
    let polyline: Polyline
    let startLocation: GoogleLocation
    let travelMode: String
    let maneuver: String?

    enum CodingKeys: String, CodingKey {
        case distance = "distance"
        case duration = "duration"
        case endLocation = "end_location"
        case htmlInstructions = "html_instructions"
        case polyline = "polyline"
        case startLocation = "start_location"
        case travelMode = "travel_mode"
        case maneuver = "maneuver"
    }

    init(distance: Distance, duration: Distance, endLocation: GoogleLocation, htmlInstructions: String, polyline: Polyline, startLocation: GoogleLocation, travelMode: String, maneuver: String?) {
        self.distance = distance
        self.duration = duration
        self.endLocation = endLocation
        self.htmlInstructions = htmlInstructions
        self.polyline = polyline
        self.startLocation = startLocation
        self.travelMode = travelMode
        self.maneuver = maneuver
    }
}

// MARK: - Polyline
class Polyline: Codable {
    let points: String

    enum CodingKeys: String, CodingKey {
        case points = "points"
    }

    init(points: String) {
        self.points = points
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

/*
import Foundation
// MARK: - GoogleGeocode
class GoogleGeocode: Codable {
    let geocodedWaypoints: [GeocodedWaypoint]?
    let routes: [Route]?
    let status: String

    enum CodingKeys: String, CodingKey {
        case geocodedWaypoints = "geocoded_waypoints"
        case routes = "routes"
        case status = "status"
    }
    
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.geocodedWaypoints = try container.decodeIfPresent([GeocodedWaypoint].self, forKey: .geocodedWaypoints)
        self.routes = try container.decodeIfPresent([Route].self, forKey: .geocodedWaypoints)
        self.status = container.safeDecodeValue(forKey: .status)
        
    }

}

// MARK: - GeocodedWaypoint
class GeocodedWaypoint: Codable {
    let geocoderStatus: String
    let placeid: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case geocoderStatus = "geocoder_status"
        case placeid = "place_id"
        case types = "types"
    }
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.geocoderStatus = container.safeDecodeValue(forKey: .geocoderStatus)
        self.placeid = container.safeDecodeValue(forKey: .placeid)
        self.types = container.safeDecodeValue(forKey: .types)
    }

}

// MARK: - Route
class Route: Codable {
    let bounds: Bounds?
    let copyrights: String
    let legs: [Leg]?
    let overviewPolyline: Polyline?
    let summary: String
    let warnings: [JSONAny]?
    let waypointOrder: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case bounds = "bounds"
        case copyrights = "copyrights"
        case legs = "legs"
        case overviewPolyline = "overview_polyline"
        case summary = "summary"
        case warnings = "warnings"
        case waypointOrder = "waypoint_order"
    }
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bounds = try container.decodeIfPresent(Bounds.self, forKey: .bounds)
        self.copyrights = container.safeDecodeValue(forKey: .copyrights)
        self.legs = try container.decodeIfPresent([Leg].self, forKey: .legs)
        self.overviewPolyline = try container.decodeIfPresent(Polyline.self, forKey: .overviewPolyline)
        self.summary = container.safeDecodeValue(forKey: .summary)
        self.warnings = try container.decodeIfPresent([JSONAny].self, forKey: .warnings)
        self.waypointOrder = try container.decodeIfPresent([JSONAny].self, forKey: .waypointOrder)
    }

}

// MARK: - Bounds
class Bounds: Codable {
    let northeast: GoogleLocation?
    let southwest: GoogleLocation?

    enum CodingKeys: String, CodingKey {
        case northeast = "northeast"
        case southwest = "southwest"
    }
    
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.northeast =  try container.decodeIfPresent(GoogleLocation.self, forKey: CodingKeys.northeast)
        self.southwest =  try container.decodeIfPresent(GoogleLocation.self, forKey: CodingKeys.southwest)
    }

}

// MARK: - Northeast
class GoogleLocation: Codable {
    let lat: Double
    let lng: Double

    enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lng"
    }
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lat =  container.safeDecodeValue(forKey: .lat)
        self.lng = container.safeDecodeValue(forKey: .lng)
    }
    var location : CLLocation{
        return CLLocation(latitude: self.lat,
                          longitude: self.lng)
    }
    func distance(from location: CLLocation) -> Double{
        return location.distance(from: self.location)
    }
}

// MARK: - Leg
class Leg: Codable {
    let distance: Distance?
    let duration: Distance?
    let endAddress: String
    let endLocation: GoogleLocation?
    let startAddress: String
    let startLocation: GoogleLocation?
    let steps: [Step]?
    let trafficSpeedEntry: [JSONAny]?
    let viaWaypoint: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case distance = "distance"
        case duration = "duration"
        case endAddress = "end_address"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case startLocation = "start_location"
        case steps = "steps"
        case trafficSpeedEntry = "traffic_speed_entry"
        case viaWaypoint = "via_waypoint"
    }
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.distance = try container.decodeIfPresent(Distance.self, forKey: .distance)
        self.duration = try container.decodeIfPresent(Distance.self, forKey: .duration)
        self.endLocation = try container.decodeIfPresent(GoogleLocation.self, forKey: .endLocation)
        self.startLocation = try container.decodeIfPresent(GoogleLocation.self, forKey: .startLocation)
        
        self.endAddress = container.safeDecodeValue(forKey: .endAddress)
        self.startAddress = container.safeDecodeValue(forKey: .startAddress)
        self.steps = try container.decodeIfPresent([Step].self, forKey: .steps)
        self.trafficSpeedEntry = try container.decodeIfPresent([JSONAny].self, forKey: .trafficSpeedEntry)
        self.viaWaypoint = try container.decodeIfPresent([JSONAny].self, forKey: .viaWaypoint)
    }

}

// MARK: - Distance
class Distance: Codable {
    let text: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case text = "text"
        case value = "value"
    }
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text =  container.safeDecodeValue(forKey: .text)
        self.value = container.safeDecodeValue(forKey: .value)
    }
 
}

// MARK: - Step
class Step: Codable {
    let distance: Distance?
    let duration: Distance?
    let endLocation: GoogleLocation?
    let htmlInstructions: String
    let polyline: Polyline?
    let startLocation: GoogleLocation?
    let travelMode: String
    let maneuver: String?

    enum CodingKeys: String, CodingKey {
        case distance = "distance"
        case duration = "duration"
        case endLocation = "end_location"
        case htmlInstructions = "html_instructions"
        case polyline = "polyline"
        case startLocation = "start_location"
        case travelMode = "travel_mode"
        case maneuver = "maneuver"
    }
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.distance = try container.decodeIfPresent(Distance.self, forKey: .distance)
        self.duration = try container.decodeIfPresent(Distance.self, forKey: .duration)
        self.endLocation = try container.decodeIfPresent(GoogleLocation.self, forKey: .endLocation)
        self.startLocation = try container.decodeIfPresent(GoogleLocation.self, forKey: .startLocation)
        self.polyline = try container.decodeIfPresent(Polyline.self, forKey: .polyline)
        
        self.htmlInstructions = container.safeDecodeValue(forKey: .htmlInstructions)
        self.travelMode = container.safeDecodeValue(forKey: .travelMode)
        self.maneuver = container.safeDecodeValue(forKey: .maneuver)
    }

}

// MARK: - Polyline
class Polyline: Codable {
    let points: String

    enum CodingKeys: String, CodingKey {
        case points = "points"
    }

 
    required init(from decoder : Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.points =  container.safeDecodeValue(forKey: .points)
    }
}
*/
