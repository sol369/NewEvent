//
//  Event.swift
//  Eventful
//
//  Created by Shawn Miller on 8/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

@objc(Event)
class Event:NSObject{
    var key: String?
    let currentEventName: String
    let currentEventImage: String
    let currentEventPromo: String?
    let currentEventDescription: String
    //nested properties
    let currentEventStreetAddress: String
    let currentEventCity: String
    let currentEventState: String
    let currentEventDate: String?
    let currentEventEndDate: String?
    let currentEventTime: String?
    let currentEventEndTime: String?
    let eventPrice: String
    let endTime: Date
    let startTime: Date
    let currentEventZip: Int
    var category: String
    //nested properties stop
    var currentAttendCount: Int
    var isAttending = false
    var eventDictionary: [String: Any]{
        
        
        let dateDict = ["start:date":currentEventDate, "start:time": currentEventTime,"end:time":currentEventEndTime, "end:date": currentEventEndDate]
        let timeDict = ["end":endTime, "start": startTime]
        
        return ["event:name":currentEventName,"event:imageURL" : currentEventImage,
                "event:description": currentEventDescription, "attend:count": currentAttendCount,
                "event:street:address": currentEventStreetAddress,"event:zip": currentEventZip,"event:price":eventPrice,
                "event:state": currentEventState, "event:city": currentEventCity, "event:promo": currentEventPromo ?? "", "event:date": dateDict, "event:category":category,"event:datetime": timeDict]
    }
    
    init(currentEventKey: String, dictionary: [String:Any]) {
        self.key = currentEventKey
        self.currentEventName = dictionary["event:name"] as? String ?? ""
        self.currentEventImage = dictionary["event:imageURL"] as? String ?? ""
        self.currentEventDescription = dictionary["event:description"] as? String ?? ""
        self.currentEventPromo = dictionary["event:promo"] as? String ?? ""
        self.currentAttendCount = dictionary["attend:count"] as? Int ?? 0
        self.category = dictionary["event:category"] as? String ?? ""
        self.eventPrice = dictionary["event:price"] as? String ?? ""
        //nested properties
        self.currentEventStreetAddress = dictionary["event:street:address"] as? String ?? ""
        self.currentEventCity = dictionary["event:city"] as? String ?? ""
        self.currentEventState = dictionary["event:state"] as? String ?? ""
        self.currentEventZip = dictionary["event:zip"] as? Int ?? 0
        //////
        let eventTime = dictionary["event:datetime"] as? [String: Any]
        let startInSeconds = eventTime!["start"] as? Double
        let endInSeconds = eventTime!["end"] as? Double
        self.startTime = Date(timeIntervalSince1970: startInSeconds!)
        self.endTime = Date(timeIntervalSince1970: endInSeconds!)
        ////////
        let eventDate = dictionary["event:date"] as? [String: Any]
        self.currentEventDate = eventDate?["start:date"] as? String ?? ""
        self.currentEventTime = eventDate?["start:time"] as? String ?? ""
        self.currentEventEndTime = eventDate?["end:time"] as? String ?? ""
        self.currentEventEndDate = eventDate?["end:date"] as? String ?? ""
        
    }
    

   
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let currentEventName = dict["event:name"] as? String,
            let currentEventImage = dict["event:imageURL"] as? String,
            let currentEventDescription = dict["event:description"] as? String,
            let currentEventPromo = dict["event:promo"] as? String,
            let category = dict["event:category"] as? String,
            let currentEventStreetAddress = dict["event:street:address"] as? String,
            let currentEventCity = dict["event:city"] as? String,
            let currentEventState = dict["event:state"] as? String,
            let currentEventZip = dict["event:zip"] as? Int,
            let currentAttendCount = dict["attend:count"] as? Int,
            let eventPrice = dict["event:price"] as? String,
            //////
            let eventDate = dict["event:date"] as? [String: Any],
            let currentEventDate = eventDate["start:date"] as? String,
            let currentEventEndDate = eventDate["end:date"] as? String,
            let currentEventTime = eventDate["start:time"] as? String,
            let currentEventEndTime = eventDate["end:time"] as? String,
            /////
            let eventTime = dict["event:datetime"] as? [String: Any],
            let startInSeconds = eventTime["start"] as? Double,
            let endInSeconds = eventTime["end"] as? Double
            else { return nil }
        self.key = snapshot.key
        self.currentEventName = currentEventName
        self.currentEventImage = currentEventImage
        self.currentEventDescription = currentEventDescription
        self.currentEventStreetAddress = currentEventStreetAddress
        self.currentEventCity = currentEventCity
        self.currentEventState = currentEventState
        self.currentEventZip = currentEventZip
        self.currentAttendCount = currentAttendCount
        self.currentEventPromo = currentEventPromo
        self.currentEventDate = currentEventDate
        self.currentEventTime = currentEventTime
        self.currentEventEndTime = currentEventEndTime
        self.category = category
        self.eventPrice = eventPrice
        self.currentEventEndDate = currentEventEndDate
        self.endTime = Date(timeIntervalSince1970: endInSeconds)
        self.startTime = Date(timeIntervalSince1970: startInSeconds)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let event = object as? Event else { return false }
        return self.key == event.key
    }
    
}
