/**
 * DriverLocationModel.swift
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

class DriverLocationModel : NSObject {
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var arrival_time : String = ""
    var driver_latitude : String = ""
    var driver_longitude : String = ""
    
    override init() {super.init()}
    convenience init(from json : JSON){
        self.init()
        self.status_message = json.status_message
        self.status_code = json.status_code.description
        
        if self.status_code == "1"
        {
            self.driver_latitude = json.string("driver_latitude")
            self.driver_longitude = json.string("driver_longitude")
        }
    }
    
}
