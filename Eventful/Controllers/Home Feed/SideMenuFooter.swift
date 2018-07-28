//
//  SideMenuFooter.swift
//  Eventful
//
//  Created by Shawn Miller on 4/21/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class SideMenuFooter: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.rgb(red: 243, green: 249, blue: 252): UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.black : UIColor.rgb(red: 53, green: 56, blue: 57)
            iconImageView.tintColor = isHighlighted ? UIColor.rgb(red: 34, green: 153, blue: 234) : UIColor.black
            
        }
    }
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameLabel.textColor = UIColor.rgb(red: 53, green: 56, blue: 57)
        return nameLabel
    }()
    
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override func setupViews() {
        backgroundColor = .white
        let currentUserDividerView = UIView()

        addSubview(iconImageView)
        addSubview(currentUserDividerView)

        currentUserDividerView.backgroundColor = UIColor.lightGray
        currentUserDividerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self.snp.top)
            make.height.greaterThanOrEqualTo(0.75)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(currentUserDividerView.snp.bottom).offset(10)
            make.left.equalTo(self.snp.left).inset(5)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(5)
            make.top.equalTo(self.snp.top).offset(14)
        }
        
    }
}
