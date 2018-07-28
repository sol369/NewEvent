//
//  Notification.swift
//  Eventful
//
//  Created by Shawn Miller on 2/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot
import  IGListKit


class Notifications: NSObject {
    
    var content : String
    var creationDate : Double = 0
    var timeStamp : Date?
    var eventKey : String?
    var key : String?
    var commentId : String?
    var notiType: notiType.RawValue?
    let sender: User
    let receiver: User?

    //init for comment notif
    init(eventKey: String,reciever: User, content: String, type: notiType.RawValue,commentId:String){
        self.content = content
        self.creationDate = Date().timeIntervalSince1970
        self.eventKey = eventKey
        self.commentId = commentId
        self.sender = User.current
        self.notiType = type
        self.receiver = reciever

    }
    
    //init for follow notif
    init(reciever: User, content: String, type: notiType.RawValue){
        self.content = content
        self.notiType = type
        self.receiver = reciever
        self.sender = User.current
        self.creationDate = Date().timeIntervalSince1970
    }
    
    //int for share notif
    
    init(reciever: User, content: String,type: notiType.RawValue,eventKey: String) {
        self.content = content
        self.receiver = reciever
        self.content = content
        self.notiType = type
        self.sender = User.current
        self.eventKey = eventKey
        self.creationDate = Date().timeIntervalSince1970
    }

    
    //snapshot for comment notif
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let eventKey = dict["eventKey"] as? String,
            let commentId = dict["commentId"] as? String,
            let senderDict = dict["sender"] as? [String : Any],
            let isPrivateForSender = senderDict["isPrivate"] as? Bool,
            let uid = senderDict["uid"] as? String,
            let username = senderDict["username"] as? String,
            let profilePic = senderDict["profilePic"] as? String,
            let receiverDict = dict["receiver"] as? [String : Any],
            let receiverUid = receiverDict["uid"] as? String,
            let isPrivateForReciever = receiverDict["isPrivate"] as? Bool,
            let receiverUsername = receiverDict["username"] as? String,
            let receiverProfilePic = receiverDict["profilePic"] as? String,
            let notiType = dict["notiType"] as? notiType.RawValue
            
            else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.eventKey = eventKey
        self.commentId = commentId
        self.notiType = notiType
        self.sender = User(uid: uid, username: username,profilePic: profilePic, isPrivate: isPrivateForSender)
        self.receiver = User(uid: receiverUid, username: receiverUsername,profilePic: receiverProfilePic, isPrivate: isPrivateForReciever)
    }
    
    //snapshot for follow notif
    init?(followSnapshot: DataSnapshot) {
        guard let dict = followSnapshot.value as? [String : Any],
            let content = dict["content"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
        let senderDict = dict["sender"] as? [String : Any],
        let uid = senderDict["uid"] as? String,
        let username = senderDict["username"] as? String,
        let profilePic = senderDict["profilePic"] as? String,
            let isPrivateForSender = senderDict["isPrivate"] as? Bool,
            let receiverDict = dict["receiver"] as? [String : Any],
            let receiverUid = receiverDict["uid"] as? String,
            let isPrivateForReciever = receiverDict["isPrivate"] as? Bool,
            let receiverUsername = receiverDict["username"] as? String,
            let receiverProfilePic = receiverDict["profilePic"] as? String,
            let notiType = dict["notiType"] as? notiType.RawValue
            else { return nil }
        
        self.key = followSnapshot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.notiType = notiType
        self.sender = User(uid: uid, username: username,profilePic: profilePic, isPrivate: isPrivateForSender)
        self.receiver = User(uid: receiverUid, username: receiverUsername,profilePic: receiverProfilePic, isPrivate: isPrivateForReciever)
    }
    
    //snapshot for share notif
    init?(shareSnapShot: DataSnapshot) {
        guard let dict = shareSnapShot.value as? [String : Any],
            let content = dict["content"] as? String,
            let eventKey = dict["eventKey"] as? String,
            let timestamp = dict["creationDate"] as? TimeInterval,
            let senderDict = dict["sender"] as? [String : Any],
            let uid = senderDict["uid"] as? String,
            let username = senderDict["username"] as? String,
            let profilePic = senderDict["profilePic"] as? String,
            let isPrivateForSender = senderDict["isPrivate"] as? Bool,
            let receiverDict = dict["receiver"] as? [String : Any],
            let receiverUid = receiverDict["uid"] as? String,
            let isPrivateForReciever = receiverDict["isPrivate"] as? Bool,
            let receiverUsername = receiverDict["username"] as? String,
            let receiverProfilePic = receiverDict["profilePic"] as? String,
            let notiType = dict["notiType"] as? notiType.RawValue
            else { return nil }
        
        self.key = shareSnapShot.key
        self.content = content
        self.timeStamp = Date(timeIntervalSince1970: timestamp)
        self.notiType = notiType
        self.sender = User(uid: uid, username: username,profilePic: profilePic, isPrivate: isPrivateForSender)
        self.receiver = User(uid: receiverUid, username: receiverUsername,profilePic: receiverProfilePic, isPrivate: isPrivateForReciever)
        self.eventKey = eventKey
    }
    
    //dictvalue for comment
    var dictValue: [String : Any] {
        let userDict = ["username" : sender.username as Any,
                        "uid" : sender.uid,
                        "profilePic": sender.profilePic as Any,
                        "isPrivate": sender.isPrivate as Any]
        
        let receiverDict = ["username" : receiver?.username as Any,
                            "uid" : receiver?.uid as Any,
                            "profilePic": receiver?.profilePic as Any,
                             "isPrivate": sender.isPrivate as Any]
        
        
        return ["eventKey" : eventKey  as Any,
                "content": content,
                "creationDate": creationDate,
                "commentId" : commentId as Any,
                "sender" : userDict,
                "receiver" : receiverDict,
                "notiType" : notiType as Any]
    }
    // dict value for follow notif
    var followDictValue: [String : Any] {
        let userDict = ["username" : sender.username as Any,
                        "uid" : sender.uid,
                        "profilePic": sender.profilePic as Any,
                        "isPrivate": sender.isPrivate as Any]
        
        let receiverDict = ["username" : receiver?.username as Any,
                            "uid" : receiver?.uid as Any,
                            "profilePic": receiver?.profilePic as Any,
                            "isPrivate": sender.isPrivate as Any]
        
        return [
            "content": content,
            "creationDate": creationDate,
            "sender" : userDict,
            "receiver" : receiverDict,
            "notiType" : notiType as Any]
    }
    //dict value for share notif
    var shareDictValue: [String : Any] {
        let userDict = ["username" : sender.username as Any,
                        "uid" : sender.uid,
                        "profilePic": sender.profilePic as Any,
                        "isPrivate": sender.isPrivate as Any]
        
        let receiverDict = ["username" : receiver?.username as Any,
                            "uid" : receiver?.uid as Any,
                            "profilePic": receiver?.profilePic as Any,
                            "isPrivate": sender.isPrivate as Any]
        
        
        return ["eventKey" : eventKey  as Any,
                "content": content,
                "creationDate": creationDate,
                "sender" : userDict,
                "receiver" : receiverDict,
                "notiType" : notiType as Any]
    }
    
}
extension Notifications{
    static public func  ==(rhs: Notifications, lhs: Notifications) ->Bool{
        return (rhs.commentId == lhs.commentId || rhs.receiver == lhs.receiver)
    }
}
extension Notifications: ListDiffable{
    public func diffIdentifier() -> NSObjectProtocol {
        if let currentCommentID = key {
            return currentCommentID as NSObjectProtocol
        }else {
            guard let currentFollowee = receiver else {
                return receiver as! NSObjectProtocol
            }
            return currentFollowee as NSObjectProtocol
        }
    }
    public func isEqual(toDiffableObject object: ListDiffable?) ->Bool{
        guard let object = object as? Notifications else {
            return false
        }
        return  self.key==object.key || self.receiver == object.receiver
    }
}

enum notiType: String {
    case follow = "follow"
    case comment = "comment"
    case friendRequest = "friendRequest"
    case share = "share"

}

