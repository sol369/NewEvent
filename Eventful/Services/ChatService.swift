//
//  ChatService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseAuth


class ChatService {
    static func fetchComments(forChatKey eventKey: String,currentPostCount: Int,lastKey: String,isFinishedPaging:Bool, completion: @escaping ( [CommentGrabbed],Bool) -> Void){
        print(currentPostCount)
        var isFinishedPagingTemp = isFinishedPaging
        var currentCommentsArray = [CommentGrabbed]()
        var currentComment: CommentGrabbed!
        //change this back if I want to sort by creationD
        _ = "creationDate"
        let commentRef = Database.database().reference().child("comments").child(eventKey)
        var query = commentRef.queryOrderedByKey()
        if currentPostCount > 0 {
            print(lastKey)
            query = query.queryStarting(atValue: lastKey)
        }
       
        query.queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (commentSnapshot) in
            guard var allComments = commentSnapshot.children.allObjects as? [DataSnapshot] else {
                return completion( [],true)
            }
            if currentPostCount > 0 {
                allComments.removeFirst()
            }
            if allComments.count < 1 {
                isFinishedPagingTemp = true
                return completion([],true)
            }
            for comments in allComments {
                currentComment = CommentGrabbed(snapshot: comments)
                // print(currentComment.key)
                currentCommentsArray.append(currentComment)
                print(currentComment)
            }
            
            if currentCommentsArray.count == allComments.count && !isFinishedPagingTemp {
                completion(currentCommentsArray,false)
            }else{
                return completion([],true)
            }
        }) { (err) in
            print("Couldn't find comments in DB", err)
        }
        
    }
    
    
    static func sendMessage(_ message: CommentGrabbed, eventKey: String,success: ((Bool) -> Void)? = nil) {
        var multiUpdateValue = [String : Any]()
        let messagesRef = Database.database().reference().child("comments").child(eventKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["comments/\(eventKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    static func sendNotification(_ notification: Notifications, success: ((Bool) -> Void)? = nil) {
        var multiUpdateValue = [String : Any]()
        _ = Database.database().reference().child("notifcations").child((notification.receiver?.uid)!)
        multiUpdateValue["notifications/\((notification.receiver?.uid)!)/\(notification.commentId ?? "")"] = notification.dictValue
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            success?(true)
        })
    }

    
    static func flag(_ comment: CommentGrabbed) {
        // 1
        guard let commentKey = comment.commentID else { return }
        
        // 2
        let flaggedPostRef = Database.database().reference().child("flaggedComments").child(commentKey)
        
        // 3
        let flaggedDict = ["image_url": comment.sender.profilePic,
                           "poster_uid": comment.sender.uid,
                           "reporter_uid": User.current.uid]
        
        // 4
        flaggedPostRef.updateChildValues(flaggedDict as Any as! [AnyHashable : Any])
        
        // 5
        let flagCountRef = flaggedPostRef.child("flag_count")
        flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            
            mutableData.value = currentCount + 1
            
            return TransactionResult.success(withValue: mutableData)
        })
    }
    
    static func deleteComment(_ comment: CommentGrabbed, _ eventKey: String,success: ((Bool) -> Void)? = nil){
        //1
        guard let commentkey = comment.key else {
            return
        }
        let commentData = ["comments/\(eventKey)/\(commentkey)": NSNull(),"notifications/\(User.current.uid)/\(commentkey)" : NSNull()]
     
        
        Database.database().reference().updateChildValues(commentData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
            }else{
                success?(true)
            }
        }
        
    }
    //will support real time data syncing of comments
    static func observeMessages(forChatKey eventKey: String, completion: @escaping (DatabaseReference, CommentGrabbed?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("comments").child(eventKey)
        return messagesRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: Date().timeIntervalSince1970).observe(.childAdded, with: { snapshot in
            guard let message = CommentGrabbed(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            completion(messagesRef, message)
        })
    }
}
