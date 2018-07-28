//
//  UserHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SnapKit

class UserProfileHeader: UICollectionViewCell {
    var user: User?{
        didSet {
            setupProfileImage()
            //  userNameLabel.text = user?.username
            setupUserInteraction()
        }
    }
    var followNotificationData : Notifications!
    weak var profileViewController: ProfileeViewController!
    var isFollowed: Bool?
    var isRequestPresent: Bool?
    
    lazy var profileImage: UIImageView = {
        let profilePicture = UIImageView()
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.clipsToBounds = true
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.contentMode = .scaleToFill
        profilePicture.isUserInteractionEnabled = true
        profilePicture.layer.shouldRasterize = true
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        // will allow you to add a target to an image click
        profilePicture.layer.masksToBounds = true
        return profilePicture
    }()
    lazy var statsLabel : UILabel = {
        let statsLabel = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Score", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        statsLabel.attributedText = attributedText
        statsLabel.numberOfLines = 0
        statsLabel.textAlignment = .center
        return statsLabel
    }()
  
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
       // button.setTitle("Edit Profile", for: .normal)
        button.setCellShadow()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        return button
    }()

    var userStackView: UIStackView?
    var currentUserDividerView: UIView?
    var notCurrentUserDividerView: UIView?

    fileprivate func setupUserInteraction (){
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else{
            return
        }
        guard let uid = user?.uid else{
            return
        }

        self.currentUserDividerView?.removeFromSuperview()
        self.notCurrentUserDividerView?.removeFromSuperview()
        self.followButton.removeFromSuperview()
        self.userStackView?.removeFromSuperview()
        
        if currentLoggedInUser == uid {
            //will hide buttons related to user that is not current user
            setupCurrentLoggedInUserView()

        } else{
            addSubview(self.followButton)
            followButton.anchor(top: profileStackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 50, paddingBottom:0 , paddingRight: 50, width: 0, height: 0)
             notCurrentUserDividerView = UIView()
            notCurrentUserDividerView?.backgroundColor = UIColor.lightGray
            addSubview(notCurrentUserDividerView!)
            notCurrentUserDividerView?.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            // check if following
            if let user = user {
                FollowService.isUserFollowed(user) { (followStatus) in
                    if followStatus{
                        self.isFollowed = followStatus
                        self.followButton.setTitle("Unfollow", for: .normal)
                    } else {
                        self.isFollowed = false
                        //check if there is a request present
                        //if so show request sent if not show the follow style
                        FriendService.system.checkForRequest(uid, success: { (success) in
                            //will return true if there is a request
                            self.isRequestPresent = success
                            if success{
                                self.setupRequestStyle()
                            }else{
                                //if there is no request show regular follow style
                                self.setupFollowStyle()
                            }
                        })
                    }
                }
            }
            
        }
    }
    
    
    @objc func setupCurrentLoggedInUserView() {
        currentUserDividerView = UIView()
        currentUserDividerView?.backgroundColor = UIColor.lightGray
        addSubview(currentUserDividerView!)
        currentUserDividerView?.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer){
        //Pro Tip: Dont perform a lot of custom logic inside a view class
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            self.profileViewController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    @objc func didTapFollowButton(){
        print("function handled")
        followButton.isUserInteractionEnabled = false
        let followee = user
        if let followStatus = self.isFollowed {
            if followStatus {
                //if your following them and you tap the follow button unfollow the user
                FollowService.setIsFollowing((followee?.isFollowed)!, fromCurrentUserTo: followee!) { [unowned self] (success) in
                    defer {
                        self.followButton.isUserInteractionEnabled = true
                    }
                    
                    guard success else { return }
                    followee?.isFollowed = !(followee?.isFollowed)!
                    print(followee?.isFollowed ?? "true")
                    print("Successfully unfollowed user:", self.user?.username ?? "")
                    self.setupFollowStyle()
                    self.isFollowed = false
                }
                
            }else{
                //first check if the user is private
                if let privateStatus = user?.isPrivate {
                    if privateStatus {
                        //will first check if a request is present because if it is and you click it again it should delete the request
                        if self.isRequestPresent! {
                            if let followeeUID = followee?.uid{
                                FriendService.system.removeFriendRequest(followeeUID)
                                self.setupFollowStyle()
                                self.followButton.isUserInteractionEnabled = true
                                self.isRequestPresent = false
                            }
                        }else{
                            //send the user a friend request because they want to make sure they know who they are following
                            if let followeeUID = followee?.uid {
                                //will send the user a friend request and wait for them to accept it
                                FriendService.system.sendRequestToUser(followeeUID)
                                self.isRequestPresent = true
                                setupRequestStyle()
                                self.followButton.isUserInteractionEnabled = true
                            }
                        }

                    }else{
                        //if they are not private you can just follow them because they don't care
                        FollowService.setIsFollowing(!(followee?.isFollowed)!, fromCurrentUserTo: followee!) { [unowned self] (success) in
                            defer {
                                self.followButton.isUserInteractionEnabled = true
                            }
                            
                            guard success else { return }
                            print(followee?.isFollowed ?? "true")
                            
                            followee?.isFollowed = !(followee?.isFollowed)!
                            print(followee?.isFollowed ?? "true")
                            
                            self.followNotificationData = Notifications.init(reciever: self.user!, content: User.current.username! + " has followed you", type: notiType.follow.rawValue)
                            
                            FollowService.sendFollowNotification(self.followNotificationData)
                            print("Successfully followed user: ", self.user?.username ?? "")
                            self.followButton.setTitle("Unfollow", for: .normal)
                            self.followButton.backgroundColor = .white
                            self.followButton.setTitleColor(.black, for: .normal)
                            self.isFollowed = true
                        }
                    }
                }
            }
        }
        
            
        }
        
        
    
    //will setup the style change for when you first enter the screen and you have to follow the user
    fileprivate func setupFollowStyle() {
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        self.followButton.setTitleColor(.white, for: .normal)
        self.followButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    //will setup the button style for when you send the friend request for the user
    fileprivate func setupRequestStyle() {
        self.followButton.setTitle("Request Sent", for: .normal)
        self.followButton.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255)
        self.followButton.setTitleColor(.black, for: .normal)
        self.followButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profilePic else {return }
        
        guard let url = URL(string: profileImageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //check for the error, then construct the image using data
            if let err = err {
                print("Failed to fetch profile image:", err)
                return
            }
            
            //perhaps check for response status of 200 (HTTP OK)
            
            guard let data = data else { return }
            
            let image = UIImage(data: data)
            
            //need to get back onto the main UI thread
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
            
            }.resume()
    }
    
    lazy var profileStackView = UIStackView(arrangedSubviews: [profileImage])
    
    fileprivate func setupProfileStack(){
        addSubview(profileStackView)
        profileStackView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 125, height: 125)
        profileStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        profileImage.layer.cornerRadius = 125/2
        setupProfileStack()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
