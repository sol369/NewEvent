//
//  ShareCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/4/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit


class ShareCell: UITableViewCell {
    
    
    
    var user: User?{
        didSet{
            userNameLabel.text = user?.username
            
            guard let userProfilePic = user?.profilePic else{
                return
            }
            
            userImageView.loadImage(urlString: userProfilePic)
        }
    }
    
    lazy var userImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    lazy var userNameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 14)
        return label
    }()


    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        addSubview(userImageView)
        addSubview(userNameLabel)
        userImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(45)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).offset(10)
        }
        userImageView.layer.cornerRadius = 45/2
        
        userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.centerY.equalTo(self.safeAreaLayoutGuide.snp.centerY)
            
        }

    }
    
}
