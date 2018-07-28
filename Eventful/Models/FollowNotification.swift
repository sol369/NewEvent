//
//  FollowNotification.swift
//  Eventful
//
//  Created by Shawn Miller on 2/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class FollowNotification {
    
    var content : String
    var creationDate : Double = 0
    var timeStamp : Date?
    var key : String?
    var followee : String
    var follower : String
    var profilePic : String
    var notiType: String
    
    init( followee: String, follower: String, content: String,profilePic : String, type: String) {
        self.content = content
        self.creationDate = Date().timeIntervalSince1970
        self.followee = followee
        self.follower = follower
        self.profilePic = profilePic
        self.notiType = type
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let follower = dict["repliedBy"] as? String,
            let followee = dict["repliedTo"] as? String,
            let profilePic = dict["profilePic"] as? String,
            let notiType = dict["notiType"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.followee = followee
        self.follower = follower
        self.profilePic = profilePic
        self.notiType = notiType
    }
    
    var dictValue: [String : Any] {
        
        return [
                "content": content,
                "followee" : followee,
                "follower" : follower,
                "creationDate": creationDate,
                "profilePic" : profilePic,
                "notiType" : notiType]
    }

}
