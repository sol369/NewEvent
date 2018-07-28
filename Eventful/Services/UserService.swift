//
//  UserService.swift
//  Eventful
//
//  Created by Shawn Miller on 7/26/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging
import FirebaseDatabase
import  UIKit



struct UserService {
    
    /// will create a user in the database
    static func create(_ firUser: FIRUser, username: String,profilePic: String,isPrivate: Bool, completion: @escaping (User?) -> Void) {
        //  print(profilePic)
        //   print(username)
        guard let fcmToken = Messaging.messaging().fcmToken else {
            return
        }
        
        print("")
        let userAttrs = ["username": username,
                         "profilePic": profilePic,"fcmToken":fcmToken, "isPrivate": isPrivate] as [String : Any]
        //creats the path in the database where we want our user attributes to be created
        //Also sets the value at that point in the tree to the user Attributes array
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    // Will update device token for the user
    static func updateDeviceToken(deviceToken: String, userId: String){
        let userAttrs = ["fcmToken": deviceToken] as [String : Any]
        
        let ref = Database.database().reference().child("users").child(userId)
        ref.updateChildValues(userAttrs){ (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let updatedUser = User(snapshot: snapshot)
                print(updatedUser as Any)
            })
        }
    }
    //Will allow you to edit user data in firebase
    static func edit(username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username] as [String : Any]
        
        let ref = Database.database().reference().child("users").child(User.current.uid)
        ref.updateChildValues(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    // will strictly handle editing the user section in the database
    static func editProfileImage(url: String, completion: @escaping (User?) -> Void) {
       // print(url)
        
        let userAttrs = ["profilePic": url]
        let ref = Database.database().reference().child("users").child(User.current.uid)
        ref.updateChildValues(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    /// add / edit current index of story
    static func setCurrentIndexOfStory(currentIndex: Int, eventId: String, completion: @escaping (User?) -> Void) {
        let userAttrs = [eventId: currentIndex]
        
        let ref = Database.database().reference().child("users").child(User.current.uid)
        ref.child("storyIndexes").updateChildValues(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    /// get current index of story if it exists
    static func getCurrentIndexOfStory(eventId: String, userId: String, completion: @escaping (Int?) -> Void) {
        
        UserService.show(forUID: userId) { (user) in
            
            if let user = user {
                
                if user.storyIndexes != nil {
                    
                    if let result = user.storyIndexes?[eventId] as? Int {
                        //the saved index is saved so set to the current index
                        return completion(result)
                    }
                    
                }
                //doesnt exist
                return completion(nil)
                
            } else {
                //something went wrong getting the user
                return completion(nil)
            }
        }
        
    }
    
    // will observe the user object in the database for any changes and make sure that they are updated
    static func observeProfile(for user: User, completion: @escaping (DatabaseReference, User?, [Event]) -> Void) -> DatabaseHandle {
        // 1
        let userRef = Database.database().reference().child("users").child(user.uid)
        
        // 2
        return userRef.observe(.value, with: { snapshot in
            // 3
           // print(snapshot)
            guard let user = User(snapshot: snapshot) else {
                return completion(userRef, nil, [])
            }
            
          //  print(user)
           // print(user.uid)
            // 4
            Events(for: user, completion: { events in
                // 5
                print(events)
                completion(userRef, user, events)
            })
        })
    }
    
    //will show the vents that a user is attending
    static func Events(for user: User, completion: @escaping ([Event]) -> Void)
    {
        var currentEvents = [Event]()

        //Getting firebase root directory
        let ref = Database.database().reference().child("users").child(user.uid).child("attending")
        
   
        ref.observe(.value, with: { (snapshot) in

            guard let eventDictionary = snapshot.value as? [String: Any] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()

            eventDictionary.forEach({ (key,value) in
                dispatchGroup.enter()
                EventService.show(isFromHomeFeed: false, forEventKey: key , completion: { (event) in
                    
                    AttendService.isEventAttended(event, byCurrentUserWithCompletion: { (isAttended) in
                        event?.isAttending = isAttended
                        dispatchGroup.leave()

                    })
                    if let event = event {
                        currentEvents.append(event)
                    }
                })
            })

            dispatchGroup.notify(queue: .main, execute: {
                completion(currentEvents)
            })
        })
    }
    
    
    //shows the data at the user endpoint
    //observeSingleEvent(of:with:) will only trigger the event callback once. This is useful for reading data that only needs to be loaded once and isn't expected to change
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
                
            }
            
            completion(user)
        })
    }
    
    static func following(for user: User = User.current, completion: @escaping ([User]) -> Void) {
        // 1
        let followingRef = Database.database().reference().child("following").child(user.uid)
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // 2
            guard let followingDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            // 3
            var following = [User]()
            let dispatchGroup = DispatchGroup()
            
            for uid in followingDict.keys {
                dispatchGroup.enter()
                
                show(forUID: uid) { user in
                    if let user = user {
                        following.append(user)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            // 4
            dispatchGroup.notify(queue: .main) {
                completion(following)
            }
        })
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        // 1
        let ref = Database.database().reference().child("users")
        
        // 2
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            // 3
            let users =
                snapshot
                    .compactMap(User.init)
                    .filter { $0.uid != currentUser.uid }
            
            // 4
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                // 5
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            
            // 6
            dispatchGroup.notify(queue: .main, execute: {
                completion(users)
            })
        })
    }
    
}
