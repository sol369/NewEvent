//
//  Friend.swift
//  Eventful
//
//  Created by Shawn Miller on 2/10/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation

class Friend:NSObject{
    
    var friendName:String?
    var imageUrl:String?
    var events:[Event]
    var id:Int?
    var collapsed: Bool
    //future init
    init(friendName: String, events: [Event],imageUrl: String, collapsed: Bool = true) {
        self.friendName = friendName
        self.events = events
        self.collapsed = collapsed
        self.imageUrl = imageUrl
    }

    
}
