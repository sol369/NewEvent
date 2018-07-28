//
//  StoryService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Firebase
import UIKit

struct StoryService {
    
    static func showEvent(for eventKey: String,completion: @escaping ([Story]) -> Void) {
        //getting firebase root directory
        let ref = Database.database().reference().child("Stories").child(eventKey)
        ref.observe( .value, with: { (snapshot) in
            print(snapshot.value ?? "")
            
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else{
                return
            }
            print(snapshot)
            
            let story: [Story] = snapshot.compactMap{
                guard let story1 = Story(snapshot: $0) else{
                    return nil
                }
                return story1
            }
            print(story)
            
            //            guard let event = Event(snapshot: snapshot) else {
            //                return completion(nil)
            //
            //            }
            
            completion(story)
        })
    }
    
    
    
    
}
