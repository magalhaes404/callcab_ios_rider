//
//  Array+Extension.swift
// NewTaxi
//
//  Created by Seentechs on 27/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
