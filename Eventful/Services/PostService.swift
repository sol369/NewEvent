//
//  PostService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  UIKit
import Firebase
import GeoFire
import CoreLocation
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase

class PostService {
    static func create(for event: String?,for vidURL: String) {
        // 1
        guard let key = event else {
            return
        }
        let storyUrl = vidURL
        // 2
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let story = Story(url: storyUrl)
        let dict = story.dictValue
        let postRef = Database.database().reference().child("Stories").child(key).childByAutoId()
        let userRef = Database.database().reference().child("users").child(uid).child("Stories").child(key).childByAutoId()
        postRef.updateChildValues(dict)
        userRef.updateChildValues(dict)
        
    }
    
    static func showEvent(cameFromeHomeFeed: Bool,passedDate: Date? = nil,for currentLocation: CLLocation,completion: @escaping ([Event]) -> Void) {
        //getting firebase root directory
        var keys = [String]()
        var currentEvents = [Event]()
        var geoFireRef: DatabaseReference?
        var geoFire:GeoFire?
        geoFireRef = Database.database().reference().child("eventsbylocation")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        let circleQuery = geoFire?.query(at: currentLocation, withRadius: 17.0)
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            if let currentKey = key {
                keys.append(currentKey)
            }
        })
        
        circleQuery?.observeReady({
            if passedDate == nil {
                let dispatchGroup = DispatchGroup()
                for key in keys {
                    dispatchGroup.enter()
                    EventService.show(isFromHomeFeed: cameFromeHomeFeed, forEventKey: key, completion: { (event) in
                        if let currentEvent = event {
                            currentEvents.append(currentEvent)
                        }
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.notify(queue: .main, execute: {
                    completion(currentEvents)
                })
            }else{
                
                let dispatchGroup = DispatchGroup()
                for key in keys {
                    dispatchGroup.enter()
                    EventService.show(isFromHomeFeed: cameFromeHomeFeed, passedDate: passedDate, forEventKey: key, completion: { (event) in
                        if let currentEvent = event {
                            currentEvents.append(currentEvent)
                        }
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.notify(queue: .main, execute: {
                    print(currentEvents.count)
                    completion(currentEvents)
                })
                
            }


        })

    }
    
    static func showFeaturedEvent(cameFromHomeFeed: Bool,passedDate: Date? = nil,for currentLocation: CLLocation,completion: @escaping ([Event]) -> Void) {
        //getting firebase root directory
        var currentEvents = [Event]()
        var keys = [String]()
        var geoFireRef: DatabaseReference?
        var geoFire:GeoFire?
        geoFireRef = Database.database().reference().child("featuredeventsbylocation")
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        let circleQuery = geoFire?.query(at: currentLocation, withRadius: 17.0)
        circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            if let currentKey = key {
                keys.append(currentKey)
            }
        })
        
        
        circleQuery?.observeReady({
            if passedDate == nil {
                let dispatchGroup = DispatchGroup()
                for key in keys {
                    dispatchGroup.enter()
                    EventService.show(isFromHomeFeed: cameFromHomeFeed, forEventKey: key, completion: { (event) in
                        if let currentEvent = event {
                            currentEvents.append(currentEvent)
                        }
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.notify(queue: .main, execute: {
                    print(currentEvents.count)
                    completion(currentEvents)
                })
            }else{
                
                let dispatchGroup = DispatchGroup()
                for key in keys {
                    dispatchGroup.enter()
                    EventService.show(isFromHomeFeed: cameFromHomeFeed, passedDate: passedDate, forEventKey: key, completion: { (event) in
                        if let currentEvent = event {
                            currentEvents.append(currentEvent)
                        }
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.notify(queue: .main, execute: {
                    print(currentEvents.count)
                    completion(currentEvents)
                })
                
            }
            
            
        })
        

    }
    
    static func showFollowingEvent(for followerKey: String,completion: @escaping ([Event]) -> Void) {
        //getting firebase root directory
        let dispatchGroup = DispatchGroup()
        var currentFollowerEvent = [Event]()
        let ref = Database.database().reference()

        ref.child("users").child(followerKey).child("Attending").observeSingleEvent(of: .value, with: { (attendingSnapshot) in
            print(attendingSnapshot)
            guard let eventKeys = attendingSnapshot.children.allObjects as? [DataSnapshot] else{return}
            for event in eventKeys{
                dispatchGroup.enter()
                EventService.show(isFromHomeFeed: false, forEventKey: event.key, completion: { (event) in
                    currentFollowerEvent.append(event!)
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                // dismiss the revealing view
                print("everything done")
                completion(currentFollowerEvent)
            }
            
        }) { (err) in
            print("couldn't grab event info",err)

        }
    }
    
}

