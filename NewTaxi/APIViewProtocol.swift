//
//  APIViewProtocol.swift
// NewTaxi
//
//  Created by Seentechs on 31/01/20.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
//MARK:- protocol APIViewProtocol
protocol APIViewProtocol {
    var apiInteractor : APIInteractorProtocol?{get set}
    
    /**
     api success handler
     - Author: Abishek Robin
     - Parameters:
     - response: ResponseEnum which holds apiResponse in it.
     - API: API type enum is parsed
     */
    func onAPIComplete(_ response : ResponseEnum,for API : APIEnums)
    func onFailure(error : String,for API : APIEnums)
    
}
extension APIViewProtocol{
    /**
     api failure handler
     - Author: Abishek Robin
     - Parameters:
     - error: Failure reason is parsed
     - API:  API type enum is parsed
     */
    func onFailure(error : String,for API : APIEnums){
        
    }
}
