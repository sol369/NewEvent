//
//  FollowerCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/1/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit


class FollowerCell: UITableViewCell {
    
    
    
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
    lazy var unfollowButton: UIButton = {
        let unfollowButton = UIButton()
        unfollowButton.setTitle("Unfollow", for: .normal)
        unfollowButton.setTitleColor(.black, for: .normal)
        unfollowButton.titleLabel?.font =  UIFont(name: "Avenir-Heavy", size: 15)
        unfollowButton.addTarget(self, action: #selector(unfollowTapped), for: .touchUpInside)
        return unfollowButton
    }()
    
    @objc func unfollowTapped(){
        //will deny the users friend request and remove it
        print("deny tapped")
        //will unfollow the user
        if let user = user {
            FollowService.setIsFollowing(false, fromCurrentUserTo: user) { (success) in
                if success {
                    print("unfollowed user")
                }
            }
        }
      
    }
    
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
        addSubview(unfollowButton)
        userImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).offset(10)
        }
        userImageView.layer.cornerRadius = 50/2
        
        userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.centerY.equalTo(self.safeAreaLayoutGuide.snp.centerY)
            
        }
        unfollowButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).inset(10)
            make.top.bottom.equalTo(self).inset(10)
        }
    }
    
}
