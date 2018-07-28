//
//  EventSearchCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class SearchCell: BaseCell {
    var event: Event?{
        didSet{
            eventNameLabel.text = event?.currentEventName.uppercased()
            
            guard let eventImageURL = event?.currentEventImage else{
                return
            }
            eventCityLabel.text = (event?.currentEventCity)! + "," + (event?.currentEventState)!
            eventDescriptionLabel.text = event?.currentEventDescription
            eventImageView.loadImage(urlString: eventImageURL)
            let formatter = NumberFormatter()
            formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
            formatter.numberStyle = .currency
            guard let eventPrice = Int((event?.eventPrice)!) else {
                return
            }
            if let formattedTicketAmount = formatter.string(from: eventPrice as NSNumber) {
                eventPriceLabel.text = formattedTicketAmount
            }
        }
    }
    let eventImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let eventNameLabel : UILabel = {
        let label = UILabel()
        label.text = "EventName"
        guard let customFont = UIFont(name: "ProximaNovaSoft-Regular", size: 18) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let eventCityLabel : UILabel = {
        let label = UILabel()
        label.text = "EventName"
        guard let customFont = UIFont(name: "ProximaNovaSoft-Bold", size: 18) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let eventDescriptionLabel : UILabel = {
        let label = UILabel()
        label.text = "EventName"
        guard let customFont = UIFont(name: "ProximaNova-Light", size: 16) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 8
        return label
    }()
    
    
    let eventPriceLabel : UILabel = {
        let label = UILabel()
        label.text = "EventName"
        guard let customFont = UIFont(name: "ProximaNova-Light", size: 16) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    
    
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setupShadow2()
        return cellView
    }()
    
    override func setupViews() {
        backgroundColor = .white
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        cellView.addSubview(eventImageView)
        eventImageView.backgroundColor = .red
        eventImageView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self).inset(5)
            make.left.equalTo(self.snp.left).inset(5)
            make.width.equalTo(self.frame.width / 3)
        }
        cellView.addSubview(eventNameLabel)
        
        eventNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(4)
            make.left.equalTo(eventImageView.snp.right).offset(10)
            make.right.equalTo(cellView.snp.right).inset(10)
        }
        
        cellView.addSubview(eventCityLabel)
        
        eventCityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventNameLabel.snp.bottom).offset(5)
            make.left.equalTo(eventImageView.snp.right).inset(5)
            make.right.equalTo(self.snp.right).inset(5)
        }
        cellView.addSubview(eventDescriptionLabel)
        
        eventDescriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventCityLabel.snp.bottom).offset(10)
            make.left.equalTo(eventImageView.snp.right).offset(5)
            make.right.equalTo(self.snp.right)
        }
        
        cellView.addSubview(eventPriceLabel)
        eventPriceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(cellView.snp.bottom)
            make.right.equalTo(cellView.snp.right)
        }
    }
}
