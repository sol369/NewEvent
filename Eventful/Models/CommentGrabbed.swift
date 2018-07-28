//
//  CommentGrabbed.swift
//  Eventful
//
//  Created by Shawn Miller on 8/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  IGListKit
import Firebase

class CommentGrabbed: NSObject {
    let content: String
    var key: String?
    let sender: User
    let creationDate: Date
    var commentID: String? = ""
    let eventKey:String
    
    init(content: String,eventKey: String) {
        self.content = content
        self.creationDate = Date()
        self.eventKey = eventKey
        self.sender = User.current
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let _ = dict["timestamp"] as? TimeInterval,
            let eventKey = dict["eventKey"] as? String,
            let secondsFrom1970 = dict["timestamp"] as? Double,
        let userDict = dict["sender"] as? [String : Any],
        let uid = userDict["uid"] as? String,
        let username = userDict["username"] as? String,
        let profilePic = userDict["profilePic"] as? String
            else { return nil }
        self.key = snapshot.key
        self.content = content
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.eventKey = eventKey
        self.sender = User(uid: uid, username: username,profilePic: profilePic)
    }
    
    var dictValue: [String : Any] {
        let userDict = ["username" : sender.username,
                        "uid" : sender.uid,
                        "profilePic": sender.profilePic]
        
        return ["sender" : userDict,
                "content" : content,"eventKey":eventKey,
                "timestamp" : creationDate.timeIntervalSince1970]
    }
    
}

extension CommentGrabbed {
    static public func ==(rhs: CommentGrabbed, lhs: CommentGrabbed) ->Bool{
        return rhs.key == lhs.key
    }
}

extension CommentGrabbed: ListDiffable{
    public func diffIdentifier() -> NSObjectProtocol {
        return key! as NSObjectProtocol
    }
    public func isEqual(toDiffableObject object: ListDiffable?) ->Bool{
        guard let object = object as? CommentGrabbed else {
            return false
        }
        return  self.key==object.key
    }
}

