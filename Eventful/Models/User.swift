//
//  User.swift
//  Eventful
//
//  Created by Shawn Miller on 7/26/17.
//  Copyright © 2017 Make School. All rights reserved.
//
import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User : NSObject {
    //User variables
    let uid : String
    let username : String?
    let profilePic: String?
    var isPrivate: Bool?
    var isFollowed = false
    
    /// indexes of stories they have already seen
    var storyIndexes: NSDictionary?
    
    var dictValue: [String : Any] {
        return ["username" : username as Any,
                "profilePic" : profilePic as Any,
                "isPrivate": isPrivate as Any]
    }
    //Standard User init()
    init(uid: String, username: String, profilePic: String, isPrivate: Bool? = nil) {
        self.uid = uid
        self.username = username
        self.profilePic = profilePic
        self.isPrivate = isPrivate
        super.init()
    }
    
    init?(key: String, postDictionary: [String : Any]) {
        //var dict : [String : Any]
        //print(postDictionary as? [String:])
        let dict = postDictionary
        print(dict)
        let profilePic = dict["profilePic"] as? String ?? ""
        let username = dict["username"] as? String ?? ""
        let isPrivate = dict["isPrivate"] as? Bool ?? false
        self.uid = key
        self.profilePic = profilePic
        self.username = username
        self.isPrivate = isPrivate
    }
    //User init using Firebase snapshots
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let profilePic = dict["profilePic"] as? String,
            let isPrivate = dict["isPrivate"] as? Bool
            else { return nil }
        self.uid = snapshot.key
        self.username = username
        self.profilePic = profilePic
        self.isPrivate = isPrivate
        self.storyIndexes = dict["storyIndexes"] as? NSDictionary
    }
    //UserDefaults
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "uid") as? String,
            let username = aDecoder.decodeObject(forKey: "username") as? String,
            let profilePic = aDecoder.decodeObject(forKey: "profilePic") as? String,
            let isPrivate = aDecoder.decodeObject(forKey: "isPrivate") as? Bool
            else { return nil }
        self.uid = uid
        self.username = username
        self.profilePic = profilePic
        self.isPrivate = isPrivate
        super.init()
    }

    //User singleton for currently logged user
    private static var _current: User?
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = true) {
        //print(user)
       // print("")
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            UserDefaults.standard.set(data, forKey: "currentUser")
            UserDefaults.standard.synchronize()
        }
        _current = user
        //print(_current ?? "")
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(profilePic, forKey: "profilePic")
        aCoder.encode(isPrivate, forKey: "isPrivate")

    }
}
