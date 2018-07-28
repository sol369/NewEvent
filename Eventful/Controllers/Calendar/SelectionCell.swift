//
//  SelectionCellTableViewCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/12/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SwipeCellKit

class SelectionCell: SwipeTableViewCell {
    var event: Event?{
        didSet{
            if let currentEvent = event {
                eventImageView.loadImage(urlString: currentEvent.currentEventImage)
                eventNameLabel.text = currentEvent.currentEventName.capitalized
                eventTimeLabel.text = currentEvent.currentEventTime
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setupShadow2()
        return cellView
    }()
    
    lazy var eventImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var eventNameLabel : UILabel = {
        let label = UILabel()
        label.font =  UIFont(name:"HelveticaNeue", size: 16)
        return label
    }()
    
    lazy var eventTimeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name:"HelveticaNeue", size: 12)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func setupViews(){
        print("setting up views")
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(4)
            make.top.bottom.equalTo(self).inset(4)
        }
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 45, green: 162, blue: 232)
        lineSeparatorView.setCellShadow()
        cellView.addSubview(lineSeparatorView)
        lineSeparatorView.snp.makeConstraints { (make) in
            make.left.equalTo(cellView.snp.left)
            make.top.bottom.equalTo(cellView)
            make.width.equalTo(5)
        }
        
        cellView.addSubview(eventImageView)
        eventImageView.snp.makeConstraints { (make) in
            make.left.equalTo(lineSeparatorView.snp.left).offset(10)
            make.top.bottom.equalTo(cellView).inset(4)
            make.centerY.equalTo(cellView.snp.centerY)
            make.height.width.equalTo(40)
        }
        
        cellView.addSubview(eventNameLabel)
        eventNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(eventImageView.snp.right).offset(8)
            make.centerY.equalTo(cellView.snp.centerY)
        }
        
        cellView.addSubview(eventTimeLabel)
        eventTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(cellView.snp.right).inset(4)
            make.centerY.equalTo(cellView.snp.centerY)
        }
        

        
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
