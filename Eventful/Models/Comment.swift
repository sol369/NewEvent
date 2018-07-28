//
//  Comment.swift
//  Eventful
//
//  Created by Shawn Miller on 8/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot


class Comments {
    
    var key: String?
    var content: String
    let timeStamp: Date
    let profilePic: String
    let uid: String
    let eventKey: String
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval,
            let eventKey = dict["eventKey"] as? String,
            let uid = dict["uid"] as? String,
            let profilePic = dict["profileimageURL"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.uid = uid
        self.profilePic = profilePic
        self.eventKey = eventKey
    }
    
    init(content: String, uid: String, profilePic: String, eventKey: String) {
        self.content = content
        self.timeStamp = Date()
        self.profilePic = profilePic
        self.uid = uid
        self.eventKey = eventKey
    }
    
    var dictValue: [String : Any] {
        
        return ["uid" : uid,
                "profileImageURL": profilePic,
                "content" : content,
                "timestamp" : timeStamp.timeIntervalSince1970,
                "eventKey": eventKey]
    }
    
    
}
