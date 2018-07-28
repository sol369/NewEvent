//
//  UserEventAttendingCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class EventsAttendingCell: UICollectionViewCell {
    
    var event: Event?{
        didSet{
            guard let eventImage = event?.currentEventImage else{
                return
            }
            eventImageView.loadImage(urlString: eventImage)
        }
    }
    
    let eventImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        addSubview(eventImageView)
        eventImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        eventImageView.layer.cornerRadius = 70/2
        eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
