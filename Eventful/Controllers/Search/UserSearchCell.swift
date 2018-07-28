//
//  UserSearchCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class UserSearchCell: UICollectionViewCell {
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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(userImageView)
        addSubview(userNameLabel)
        userImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        userImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userImageView.layer.cornerRadius = 50/2
        userNameLabel.anchor(top: topAnchor, left: userImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
//        let separatorView = UIView()
//        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
//        addSubview(separatorView)
//        separatorView.anchor(top: nil, left: userNameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
