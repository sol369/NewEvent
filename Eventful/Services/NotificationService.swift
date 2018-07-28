//
//  NotificationService.swift
//  Eventful
//
//  Created by Shawn Miller on 2/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import Firebase

class NotificationService {
    static func fetchUserNotif(for user: User = User.current,currentNotifCount: Int,lastKey: TimeInterval? = nil, isFinishedPaging: Bool,withCompletion completion: @escaping ( [Notifications],Bool) -> Void){
        //array of user notifications
        var currentNotifsArray = [Notifications]()
        var currentNotif:Notifications!
       var isFinishedPagingTemp = isFinishedPaging
        //2
        let key = "creationDate"
        let notifRef = Database.database().reference().child("notifications").child(user.uid)
        var query = notifRef.queryOrdered(byChild: key)
        if currentNotifCount > 0 {
            print(lastKey as Any)
            query = query.queryEnding(atValue: lastKey, childKey: key)
        }
        
        print(query)
        
        query.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (notifSnapshot) in
            guard var allUserNotifs = notifSnapshot.children.allObjects as? [DataSnapshot] else {
                return completion( [],true)
            }
            allUserNotifs.reverse()
            
            
            if currentNotifCount > 0 && allUserNotifs.count > 0{
                allUserNotifs.removeFirst()
                
            }
            
            if allUserNotifs.count < 1 {
                isFinishedPagingTemp = true
                return completion([],true)
            }
            
            for userNotifs in allUserNotifs{
                if userNotifs.childrenCount == 7 {
                    //  print("comment notification")
                    currentNotif = Notifications(snapshot:userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
                if userNotifs.childrenCount == 5 {
                    //    print("follow notification")
                    print(userNotifs.children.allObjects)
                    currentNotif = Notifications(followSnapshot: userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
                if userNotifs.childrenCount == 6 {
                    print(userNotifs.children.allObjects)
                    currentNotif = Notifications(shareSnapShot: userNotifs)
                    currentNotifsArray.append(currentNotif)
                }
                // print(userNotifs.childrenCount)
            }
            if currentNotifsArray.count == allUserNotifs.count && !isFinishedPagingTemp{
                completion(currentNotifsArray,false)
            }else{
                return completion([],true)
            }
        }) { (err) in
            print("Couldn't find comments in DB", err)
        }
        
    }
    
    static func observeNotifs(for user: User = User.current, completion: @escaping (DatabaseReference, Notifications?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("notifications").child(user.uid)
        
        return messagesRef.queryOrdered(byChild: "creationDate").queryStarting(atValue: Date().timeIntervalSince1970).observe(.childAdded, with: { snapshot in
            if snapshot.childrenCount == 7{
                guard let notif = Notifications(snapshot: snapshot) else {
                    return completion(messagesRef, nil)
                }
                completion(messagesRef, notif)
            }
            if snapshot.childrenCount == 5{
                guard let notif = Notifications(followSnapshot: snapshot) else {
                    return completion(messagesRef, nil)
                }
                completion(messagesRef, notif)
            }
            if snapshot.childrenCount == 6{
                guard let notif = Notifications(shareSnapShot: snapshot) else {
                    return completion(messagesRef, nil)
                }
                completion(messagesRef, notif)
            }
            
        })
        
    }
    
    static func sendShareNotification(_ notification: Notifications, success: ((Bool) -> Void)? = nil) {
        
        var multiUpdateValue = [String : Any]()
        
        let messagesRef = Database.database().reference().child("notifcations").child((notification.receiver?.uid)!).childByAutoId()
        let messageKey = messagesRef.key
        
        multiUpdateValue["notifications/\((notification.receiver?.uid)!)/\(messageKey)"] = notification.shareDictValue
        print(notification.shareDictValue)
        
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
}
