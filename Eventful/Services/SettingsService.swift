//
//  SettingsService.swift
//  Eventful
//
//  Created by Shawn Miller on 5/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import Firebase

class SettingsService{
    static func setIsPrivate(_ isPrivate: Bool, success: @escaping (Bool, User?) -> Void) {
        let ref = Database.database().reference().child("users").child(User.current.uid)
        let userAttrs = ["isPrivate": isPrivate] as [String : Any]
        ref.updateChildValues(userAttrs) { (error, ref) in
            if let error = error {
                print("Failed to update child value: \(error)")
                return success(false,nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                success(true,user)
            })
            
        }

    }
}
