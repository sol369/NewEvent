//
//  Post.swift
//  Eventful
//
//  Created by Shawn Miller on 8/5/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import UIKit
import SwiftyJSON


class Post {
    
    //Post Variables
    
   // var eventId: String
    var eventImageURL: String
    var eventDescription: String
    var eventName: String
    var eventStreetAddress: String
    var eventCity: String
    var eventState: String
    var eventZIP: Int
    var eventDate: String
    var attendCount: Int
    
    init(json:JSON) {
        self.eventName = json["event:name"].stringValue
        self.eventDescription = json["event:description"].stringValue
        self.eventStreetAddress =  json["event:location"]["event:street:address"].stringValue
        self.eventCity =  json["event:location"]["event:city"].stringValue
        self.eventState =  json["event:location"]["event:state"].stringValue
        self.eventZIP = json["event:location"]["event:zip"].intValue
        self.eventDate = json["event:date"]["start:date"].stringValue
        self.eventImageURL = json["event:imageURL"].stringValue
        self.attendCount = json["attend:count"].intValue
    }
     
    
    /*
    init(eventImageURL: String,eventDescription: String, eventName: String, eventStreetAddress: String, eventCity: String, eventState: String, eventZip: Int, eventDate: String ) {
        self.eventImageURL = eventImageURL
        self.eventDescription = eventDescription
        self.eventName = eventName
        self.eventStreetAddress = eventStreetAddress
        self.eventCity = eventCity
        self.eventState = eventState
        self.eventZIP = eventZip
        self.eventDate = eventDate
    }
    */


}
