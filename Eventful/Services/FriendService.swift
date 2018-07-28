//
//  FriendService.swift
//  Eventful
//
//  Created by Shawn Miller on 5/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import Firebase

class FriendService{
    static let system = FriendService()

    // MARK: - Firebase references
    /** The base Firebase reference */
    let BASE_REF = Database.database().reference()
    /* The user Firebase reference */
    let USER_REF = Database.database().reference().child("users")
    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: DatabaseReference {
        let id = Auth.auth().currentUser!.uid
        return USER_REF.child("\(id)")
    }
    /** The Firebase reference to the current user's friend request tree */
    var BASE_REQUESTS_REF: DatabaseReference {
        return BASE_REF.child("requests").child(CURRENT_USER_ID)
    }
    /** The Firebase reference to the request tree */
    var BASE_REQUESTS_REF2: DatabaseReference {
        return BASE_REF.child("requests")
    }
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = User.current.uid
        return id
    }
    /** The Firebase reference to the followers  tree for the current user */
    var BASE_USER_FOLLOWER_REF: DatabaseReference {
        return BASE_REF.child("followers")
    }
    
    /** The Firebase reference to the current user's following tree */
    var BASE_USER_FOLLOWING_REF: DatabaseReference {
        return BASE_REF.child("following")
    }

     /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String){
        BASE_REQUESTS_REF2.child(userID).child(CURRENT_USER_ID).setValue(true)
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(_ userID: String) {
        //makes the user one of my followers
        BASE_REF.child("followers").child(CURRENT_USER_ID).child(userID).setValue(true)
    }
    
    /** Removes a friend request from the user with the specified id */
    func removeFriendRequest(_ userID: String){
        if userID != CURRENT_USER_ID {
            BASE_REQUESTS_REF.child(userID).removeValue()
        }else{
            BASE_REQUESTS_REF2.child(userID).child(CURRENT_USER_ID).removeValue()
        }
    }
    
    
    
    
    func checkForRequest(_ userID: String, success: @escaping (Bool) -> Void){
        BASE_REQUESTS_REF2.child(userID).queryEqual(toValue: nil, childKey: CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                success(true)
            } else {
                success(false)
            }
        })
    }
    
    // MARK: - All friends
    /** The list of all friends of the current user. */
    var followerList = [User]()
    /** Adds a friend observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFriendObserver(userID: String,_ update: @escaping () -> Void) {
        print(userID)
        BASE_USER_FOLLOWER_REF.child(userID).observe(.value, with: { (snapshot) in
            self.followerList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                UserService.show(forUID: id, completion: { (user) in
                    self.followerList.append(user!)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend observer. This should be done when leaving the view that uses the observer. */
    func removeFriendObserver() {
        BASE_USER_FOLLOWER_REF.removeAllObservers()
    }
    
    // MARK: - All following
    /** The list of all people the current user is following */
    var followingList = [User]()
    /** Adds a friend observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFollowingObserver(userID: String,_ update: @escaping () -> Void) {
        print(userID)
        BASE_USER_FOLLOWING_REF.child(userID).observe(.value, with: { (snapshot) in
            self.followingList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                UserService.show(forUID: id, completion: { (user) in
                    self.followingList.append(user!)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    
    /** Removes the following observer. This should be done when leaving the view that uses the observer. */
    func removeFollowingObserver() {
        BASE_USER_FOLLOWING_REF.removeAllObservers()
    }

    
    //will observe the request tree for users
    // MARK: - All requests
    /** The list of all friend requests the current user has. */
    var requestList = [User]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addRequestObserver(_ update: @escaping () -> Void) {
        BASE_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                
                UserService.show(forUID: id, completion: { (user) in
                    self.requestList.append(user!)
                    update()
                })

            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        BASE_REQUESTS_REF.removeAllObservers()
    }
    
}
