//
//  CategoryEventCell.swift
//  Eventful
//
//  Created by Shawn Miller on 3/21/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CategoryEventCell: BaseRoundedCardCell {
    
    var event: Event? {
    didSet{
        guard let currentEvent = event else {
            return
        }
        guard URL(string: currentEvent.currentEventImage) != nil else { return }
        backgroundImageView.loadImage(urlString: currentEvent.currentEventImage)
        eventNameLabel.text = currentEvent.currentEventName.capitalized
    }
    }
    
    public var backgroundImageView: CustomImageView = {
        let firstImage = CustomImageView()
        firstImage.clipsToBounds = true
        firstImage.translatesAutoresizingMaskIntoConstraints = false
        firstImage.contentMode = .scaleToFill
        firstImage.layer.cornerRadius = 5
        return firstImage
    }()
    
    let eventNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"DINCondensed-Bold", size: 16.0)
        sectionNameLabel.textAlignment = .center
        return sectionNameLabel
    }()
    
    let eventNameHolder : UIView = {
        let eventNameHolder = UIView()
        eventNameHolder.backgroundColor = .clear
        eventNameHolder.layer.cornerRadius = 5
        return eventNameHolder
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @objc func setupViews(){
        backgroundColor = .clear
       // setCellShadow()
        addSubview(backgroundImageView)
        addSubview(eventNameHolder)
        eventNameHolder.addSubview(eventNameLabel)
        backgroundImageView.setContentCompressionResistancePriority(UILayoutPriority(600), for: .vertical)
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        eventNameHolder.anchor(top: backgroundImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        eventNameLabel.snp.makeConstraints { (make) in
        
        make.edges.equalTo(eventNameHolder).inset(1)
            
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
