//
//  EventSectionHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 3/21/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class EventSectionHeader: UICollectionViewCell {
    var sectionName: String? {
        didSet {
            guard let sectionName = sectionName else {
                return
            }
             let attributedText = NSMutableAttributedString(string: sectionName, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            sectionNameLabel.attributedText = attributedText
        }
    }
    
    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        return sectionNameLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        backgroundColor = .blue
        //setCellShadow()
       addSubview(sectionNameLabel)
        sectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 4, paddingBottom: -8, paddingRight: 0, width: 0, height: 0)
        
    }
}
