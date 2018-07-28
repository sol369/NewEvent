//
//  EventService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/16/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase


struct EventService {
    
    static func show(isFromHomeFeed: Bool,passedDate: Date? = nil,forEventKey eventKey: String, completion: @escaping (Event?) -> Void) {
        // print(eventKey)
        let ref = Database.database().reference().child("events").child(eventKey)
       //  print(eventKey)
        //pull everything
        
        ref.observeSingleEvent(of: .value, andPreviousSiblingKeyWith: { (snapshot,eventKey) in
           print(snapshot.value ?? "")

            guard let event = Event(snapshot: snapshot) else {
                return completion(nil)
            }
            //for the default case
            if passedDate == nil{
                if event.endTime > Date(){
                    completion(event)
                }else{
                    if isFromHomeFeed {
                        completion(nil)
                    }else{
                        completion(event)
                    }
                }
            }else{
                if let date = passedDate{
                    if event.endTime > date {
                        completion(event)
                    }else{
                        completion(nil)
                    }
                }
            }
        })
    }
}
