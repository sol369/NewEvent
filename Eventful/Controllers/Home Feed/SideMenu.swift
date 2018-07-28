//
//  SideMenu.swift
//  Eventful
//
//  Created by Shawn Miller on 4/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class SideMenu: NSObject {
    let name: SideMenuName
    let imageName: String
    init(name: SideMenuName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

enum SideMenuName: String {
    case SeizeTheNight = "Seize The Night"
    case SeizeTheDay = "Seize The Day"
    case TwentyOneAndUp = "21 & Up"
    case FriendsEvents = "Friends Events"
}
