//
//  NewUserEventAttendingCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class NewUserEventAttendingCell: BaseRoundedCardCell {
    
    var event: Event? {
        didSet {
            if let currentEvent = event {
                eventImageView.loadImage(urlString: currentEvent.currentEventImage)
                eventNameLabel.text = currentEvent.currentEventName.capitalized
                eventCityLabel.text = currentEvent.currentEventCity + "," + currentEvent.currentEventState
                let dateComponets = getDayAndMonthFromEvent(currentEvent)
                eventTimeLabel.text = dateComponets.1 + ", \(dateComponets.0)\n\(currentEvent.currentEventTime?.lowercased() ?? "")"
            }
            print("recieved event")
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setCellShadow()
        return cellView
    }()
    
    lazy var eventImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.setCellShadow()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var eventNameLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue-Medium", size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var eventCityLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue", size: 15.5)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var eventTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue-Medium", size: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(4)
            make.top.bottom.equalTo(self).inset(4)
        }
        cellView.addSubview(eventImageView)
        eventImageView.snp.makeConstraints { (make) in
            make.left.equalTo(cellView.snp.left).inset(4)
            make.top.bottom.equalTo(cellView).inset(4)
            make.centerY.equalTo(cellView.snp.centerY)
            make.height.equalTo(self.frame.height - 20)
            make.width.equalTo(self.frame.width / 3)
        }
        
        cellView.addSubview(eventNameLabel)
        eventNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(eventImageView.snp.right).offset(18)
            make.right.equalTo(cellView.snp.right).inset(5)
            make.top.equalTo(cellView.snp.top).inset(10)
        }
        cellView.addSubview(eventCityLabel)
        eventCityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventNameLabel.snp.bottom).offset(15)
            make.left.equalTo(eventImageView.snp.right).offset(18)
            make.right.equalTo(cellView.snp.right).inset(5)
        }
        
        cellView.addSubview(eventTimeLabel)
        eventTimeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(cellView.snp.bottom).inset(10)
            make.left.equalTo(eventImageView.snp.right).offset(18)
            make.right.equalTo(cellView.snp.right).inset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func getDayAndMonthFromEvent(_ event:Event) -> (String, String) {
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        let eventDate = df.date(from: event.currentEventDate!)!
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        return (dayElement, monthElement)
    }
    
    
    
}
