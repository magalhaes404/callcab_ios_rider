//
//  PlistReader.swift
// NewTaxi
//
//  Created by Seentechs on 15/05/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
protocol PlistKeys {
    var key : String{get}
    static var fileName : String {get}
}
class PlistReader<KeyContainer : PlistKeys>{
    fileprivate var data : JSON
    init?(){
        
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
          let plistPath: String? = Bundle.main.path(
            forResource: KeyContainer.fileName,
            ofType: "plist"
            )! //the path of the data
          let plistXML = FileManager.default.contents(atPath: plistPath!)!
          do {//convert the data to a dictionary and handle errors.
            self.data = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! JSON

          } catch {
        
              print("Error reading plist: \(error), format: \(propertyListFormat)")
            return nil
          }
    }
}
extension PlistReader {
    func value<T>(for key : KeyContainer) -> T?{
        return self.data[key.key] as? T
    }
    func value<T>(for key : KeyContainer) -> [T]?{
        return self.data[key.key] as? [T]
    }
}

