//
//  Storage.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase

extension StorageReference
{
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newPostVideoReference() -> StorageReference
    {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("videos/posts/\(uid)/\(timestamp).mov")
    }
    
    static func newPostImageReference() -> StorageReference
    {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
}
