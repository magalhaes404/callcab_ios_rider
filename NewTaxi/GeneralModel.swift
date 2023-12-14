/**
* GeneralModel.swift
*
* @package Makent
* @author Seentechs Product Team
*
* @link http://seentechs.com
*/


import Foundation
import UIKit

class GeneralModel : NSObject {
    
    //MARK Properties
    var status_message : String = ""
    var status_code : String = ""
    var otp_code : String = ""
    
    // This is for room booking
    var availability_msg : String = ""
    var pernight_price : String = ""

    // Inbox
    var unread_message_count : String = ""
    
    var min_price : String = ""
    var max_price : String = ""
    
    var promo_amount : String = ""
    var wallet_amount : String = ""
    var payment_method : String = ""
    var arraycount : String = ""

    var room_id : String = ""
    var room_location : String = ""

    var message : String = ""
    var message_time : String = ""

    var amount : String = ""
    var currency_code : String = ""
    
    var cars = [SearchCarsModel]()
    
    var dictTemp1 : NSMutableDictionary = NSMutableDictionary()
    var dictTemp2 : NSMutableDictionary = NSMutableDictionary()

    var arrTemp1 : NSMutableArray = NSMutableArray()
    var arrTemp2 : NSMutableArray = NSMutableArray()
    var arrTemp3 : NSMutableArray = NSMutableArray()
    
}

