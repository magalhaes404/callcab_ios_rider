//
//  AppRouter.swift
// NewTaxi
//
//  Created by Seentechs on 28/09/21.
//  Copyright © 2021 Seen Technologies. All rights reserved.
//

import Foundation
import Alamofire


class AppRouter : APIViewProtocol{
    var apiInteractor: APIInteractorProtocol?
    
    func onAPIComplete(_ response: ResponseEnum,for API : APIEnums) {
        switch response {
//        case .RiderModel(let driver):
//            dump(driver)
//            self.routeInCompleteTrips(driver)
//        case .tripDetailData(let detailTripData):
//            self.routeInCompleteTrips(detailTripData)
//
        default:
            print()
        }
    }
    
    func onFailure(error: String,for API : APIEnums) {
//        print(error)
    }
    
    //MARK:- local variables
    fileprivate static var currentViewController : UIViewController?
    //MARK:- initalizers
    init(_ currentVC : UIViewController){
        Self.currentViewController = currentVC
        self.apiInteractor = APIInteractor(self)
    }
    
    
}
extension AppRouter{
    //MARK:- flowRouters
    func routeToFlow(tripStatus status : TripStatus ){
        if AppRouter.isVCForStatusExists(status){
            //alert
        }else{
            self.getTripDetails()
        }
    }
    func getTripDetails()
    {
//        self.apiInteractor?.getResponse(for: APIEnums.getTripDetail)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getTripDetail)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    let detail = TripDetailDataModel(json)
                    self.routeInCompleteTrips(detail)
                }else{
                    UberSupport.shared.removeProgressInWindow()
                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
            })


    }
    static func isVCForStatusExists(_ status : TripStatus) -> Bool{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let currentVCs = appDelegate.window?.rootViewController?.children else{
            return false
        }
            
        
        switch status {
        case .beginTrip:
            return !currentVCs.allSatisfy({!($0 is RouteVC)})
        case .payment:
            return !currentVCs.allSatisfy({!($0 is RatingVC)})
        case .endTrip:
            return !currentVCs.allSatisfy({!($0 is MakePaymentVC)})
        default:
            return true
        }
    }
}

extension AppRouter{
    //MARK:- UDF ROUTERS
    
    func getPaymentInvoiceAndRoute(_ trip : TripDataModel){
        var params = Parameters()
        params["trip_id"] = trip.description
//        self.apiInteractor?.getResponse(forAPI: .getInvoice, params: params).shouldLoad(true)
        UberSupport.shared.showProgressInWindow(showAnimation: true)
        self.apiInteractor?
            .getRequest(for: .getInvoice,params: params)
            .responseJSON({ (json) in
                if json.isSuccess{
                    UberSupport.shared.removeProgressInWindow()
                    var customizedJSON = JSON()
                    customizedJSON["riders"] = [json]
                    let detail = TripDetailDataModel(customizedJSON)
                    self.routeInCompleteTrips(detail)
                }else{
                    UberSupport.shared.removeProgressInWindow()
                }
            }).responseFailure({ (error) in
                    UberSupport.shared.removeProgressInWindow()
            })

    }
    
   
    //MARK: Redierect to incomplet trips
    func routeInCompleteTrips(_ trip : TripDataModel){
        switch trip.status {
        case .cancelled,.completed:
          
            print("ignoring the \(trip.status) status")
            self.routeToDetailTripHistory(forTrip: trip,tripId: trip.id)
        case .rating:
            //redirect to rating page
            self.routeToRating(tripId: trip.id)
          
        case .payment:
            //redirect to payment page
            self.routeToPayment(tripId: trip.id)
        case .scheduled,.beginTrip,.endTrip:
            //redirect to driver info map page
            self.routeToTripScreen(forTrip: trip,tripId: trip.id,tripStatus: trip.status,bookingType: trip.bookingType)
        default:
            print("Some unexpected Status mate !")
            
        }
    }
    func routeInCompleteTripsFromHistory(_ trip : History){
        switch trip.status {
        case .cancelled,.completed:
          
            print("ignoring the \(trip.status) status")
            self.routeToDetailTripHistory(forTrip: nil,tripId: trip.tripID)
        case .rating:
            //redirect to rating page
            self.routeToRating(tripId: trip.tripID)
          
        case .payment:
            //redirect to payment page
            self.routeToPayment(tripId: trip.tripID)
        case .scheduled,.beginTrip,.endTrip:
            //redirect to driver info map page
            self.routeToTripScreen(forTrip: nil,tripId: trip.tripID,tripStatus: trip.status,bookingType: trip.bookingType)
        default:
            print("Some unexpected Status mate !")
            
        }
    }
    func routeToTripScreen(forTrip trip : TripDataModel?,tripId: Int,tripStatus: TripStatus,bookingType: BookingEnum){
        let routeVC = RouteVC.initWithStory()
        if trip?.status == .endTrip{
            routeVC.isTripStarted = true
        }
        else{
            routeVC.isTripStarted = false
        }
        routeVC.tripDataModel = trip
        routeVC.tripStatus = tripStatus
        routeVC.tripID = tripId
        routeVC.bookingType = bookingType
        routeVC.updateTripHistory = Self.currentViewController as? UpdateContentProtocol
        Self.currentViewController?.navigationController?.pushViewController(routeVC, animated: true)
    }
    func routeToPayment(tripId: Int){
        let makePaymentVC = MakePaymentVC.initWithStory()
        makePaymentVC.tripID = tripId
        makePaymentVC.isFromTripPage = true
      
     
        Self.currentViewController?.navigationController?.pushViewController(makePaymentVC, animated: true)
    }
    func routeToRating(tripId: Int){
        let rateDriverVC : RateDriverVC = .initWithStory()
        rateDriverVC.tripId = tripId
        Self.currentViewController?.navigationController?.pushViewController(rateDriverVC,
                                                                       animated: true)
    }
    func routeToDetailTripHistory(forTrip trip : TripDataModel?,tripId: Int){
        //redirect to trip details page
        let propertyView : TripsDetailVC = UIStoryboard.jeba.instantiateViewController()
        propertyView.tripData = trip
        propertyView.tripId = tripId
        Self.currentViewController?.navigationController?.pushViewController(propertyView, animated: true)
    }
 
}
