 //
//  LocationService.swift
//  Eventful
//
//  Created by Shawn Miller on 1/15/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftLocation

struct LocationService {
    static func getUserLocation(completion: @escaping (CLLocation?) -> Void){
       // print("Atttempting to get user location")
        //May need location manager function
        //may need to change to always for significant location to work
        Locator.requestAuthorizationIfNeeded(.whenInUse)

        //It then delivers location updates to your app only when the user’s position changes by a significant amount, such as 500 meters or more.
        //To subscribe to significant location changes, use the method Locator.subscribeSignificantLocations. This instructs location services to begin monitoring for significant location changes, which is very power efficient. The block will execute indefinitely (until canceled), once for every new updated location regardless of its accuracy.
        
       // Note: If there are other simultaneously active location requests or subscriptions, the block will execute for every location update (not just for significant location changes).
    
//        Locator.subscribeSignificantLocations(onUpdate: { newLocation in
//            print("New location \(newLocation)")
//            completion(newLocation)
//        }) { (err, lastLocation) -> (Void) in
//            print("Failed with err: \(err)")
//        }
        Locator.currentPosition(accuracy: .city, onSuccess: { (location) -> (Void) in
           // print("Location found: \(location)")
            completion(location)
        }) { (err, last) -> (Void) in
             print("Failed to get location: \(err)")
        }


    }
    
    
}
