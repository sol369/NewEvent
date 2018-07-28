//
//  FriendRequestCell.swift
//  Eventful
//
//  Created by Shawn Miller on 5/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class FriendRequestCell: UITableViewCell {
    var stackView: UIStackView?
    var followNotificationData : Notifications!

    var user: User?{
        didSet{
            userNameLabel.text = user?.username
            
            guard let userProfilePic = user?.profilePic else{
                return
            }
            
            userImageView.loadImage(urlString: userProfilePic)
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()

    }
    
    lazy var acceptButton: UIButton = {
       let acceptButton = UIButton()
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.setTitleColor(.black, for: .normal)
        acceptButton.titleLabel?.font =  UIFont(name: "Avenir-Heavy", size: 15)
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        return acceptButton
    }()
    
    lazy var denyButton: UIButton = {
        let denyButton = UIButton()
        denyButton.setTitle("Deny", for: .normal)
        denyButton.setTitleColor(.black, for: .normal)
        denyButton.titleLabel?.font =  UIFont(name: "Avenir-Heavy", size: 15)
        denyButton.addTarget(self, action: #selector(denyTapped), for: .touchUpInside)
        return denyButton
    }()
    
    @objc func denyTapped(){
        //will deny the users friend request and remove it
        print("deny tapped")
        FriendService.system.removeFriendRequest((user?.uid)!)
    }
    
    @objc func acceptTapped(){
        //will accept the users friend request
        print("accept tapped")
        FriendService.system.acceptFriendRequest((user?.uid)!)
        self.followNotificationData = Notifications.init(reciever: User.current, content: (self.user?.username!)! + " has followed you", type: notiType.follow.rawValue)
        //will make sure the user gets the notifcation
        FollowService.sendFollowNotification(self.followNotificationData)
        FriendService.system.removeFriendRequest((user?.uid)!)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews(){
        stackView = UIStackView(arrangedSubviews: [ acceptButton, denyButton])
        stackView?.axis = .horizontal
        stackView?.distribution = .fillEqually
        
        addSubview(userImageView)
        addSubview(userNameLabel)
        addSubview(stackView!)
        userImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(45)
            make.centerY.equalTo(self.safeAreaLayoutGuide.snp.centerY)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).offset(10)
        }
        userImageView.layer.cornerRadius = 45/2
        
        userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.centerY.equalTo(self.safeAreaLayoutGuide.snp.centerY)

        }
        stackView?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).inset(10)
            make.top.bottom.equalTo(self).inset(10)
            make.width.equalTo(150)
        })
        }
    }

