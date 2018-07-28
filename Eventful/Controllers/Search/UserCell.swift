//
//  UserCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class UserCell: BaseCell {
    var user: User?{
        didSet{
            userNameLabel.text = user?.username
            
            guard let userProfilePic = user?.profilePic else{
                return
            }
            
            userImageView.loadImage(urlString: userProfilePic)
        }
    }
    let userImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.text = "EventName"
        guard let customFont = UIFont(name: "ProximaNovaSoft-Regular", size: 22) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
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
        cellView.addSubview(userImageView)
        userImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.left).offset(10)
            make.width.height.equalTo(50)
        }
        userImageView.layer.cornerRadius = 50 / 2
        
        cellView.addSubview(userNameLabel)
        
        userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userImageView.snp.right).offset(15)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
}
