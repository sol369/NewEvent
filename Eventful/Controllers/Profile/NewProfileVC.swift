//
//  NewProfileVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/14/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class NewProfileVC: UIViewController,UIScrollViewDelegate {
    let cellID = "cellID"
    let headerID = "headerID"
    var profileHandle: DatabaseHandle = 0
    var profileRef: DatabaseReference?
    var userEvents = [Event]()
    var userId: String?
    var user: User?
    var isFollowed = false
    var emptyView = UIView()

    lazy var myCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        return cv
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "Go Attend Some Events"
        emptyLabel.font = UIFont(name: "Avenir", size: 14)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        return emptyLabel
    }()
    
    lazy var noFriendLabel: UILabel = {
        let noFriendLabel = UILabel()
        noFriendLabel.text = "This User Is Private"
        noFriendLabel.font = UIFont(name: "Avenir", size: 20)
        noFriendLabel.numberOfLines = 0
        noFriendLabel.textAlignment = .center
        return noFriendLabel
    }()
    
    
    lazy var noFriendLabel2: UILabel = {
        let noFriendLabel2 = UILabel()
        noFriendLabel2.text = "Follow this user to connect \nand see what events there going to"
        noFriendLabel2.font = UIFont(name: "Avenir", size: 14)
        noFriendLabel2.numberOfLines = 0
        noFriendLabel2.textAlignment = .center
        return noFriendLabel2
    }()
    
    

    let titleView = UILabel()
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.register(NewUserHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        myCollectionView.register(NewUserEventAttendingCell.self, forCellWithReuseIdentifier: cellID)
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let user = user{
            grabFollowers(user: user)
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    deinit {
        profileRef?.removeObserver(withHandle: profileHandle)
        FriendService.system.removeFriendObserver()
        FriendService.system.removeFollowingObserver()
        print("removed from memory")
    }
    
    private func initNavigationItemTitleView() {
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center;
        titleView.text = self.user?.username
        self.navigationItem.titleView = titleView
        self.titleView.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleView.adjustsFontSizeToFitWidth = true
        
    }
    
    @objc func setupVC(){
    //will be responsible for setting up vc
        user = self.user ?? User.current
        if let user = user {
            checkFollowStatus(user: user)
            //grabFollowers(user: user)

        }
        view.addSubview(myCollectionView)
        myCollectionView.snp.makeConstraints { (make) in
           make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    @objc func grabFollowers(user: User){
        FriendService.system.addFollowingObserver(userID: user.uid) {
            FriendService.system.addFriendObserver(userID: user.uid, {
                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
                
            })
        }
    }
    
    

    
    @objc func checkFollowStatus(user: User){
        FollowService.isUserFollowed(user) { (success) in
            if success {
                //will enter here if the user is followed
                self.profileHandle = UserService.observeProfile(for: self.user!) { [unowned self](ref, user, events) in
                    self.profileRef = ref
                    self.user = user
                    self.userEvents = events
                    self.isFollowed = true
                    DispatchQueue.main.async {
                        self.myCollectionView.reloadData()
                    }
                }
            }else{
                //will go here if your not following the user and there private and there not current user
                self.isFollowed = false
                if (self.user?.isPrivate)! && self.isFollowed == false && self.user != User.current{
                    //show nothing because you have to add them first
                    DispatchQueue.main.async {
                        self.myCollectionView.reloadData()
                    }
                    
                }else{
                    //if user isn't private or user is you show it anyway because they dont care
                    self.profileHandle = UserService.observeProfile(for: self.user!) { [unowned self](ref, user, events) in
                        self.profileRef = ref
                        self.user = user
                        self.userEvents = events
                        DispatchQueue.main.async {
                            self.myCollectionView.reloadData()
                        }
                        
                        
                    }
                }
            }
        }
        
    }
    
}

extension NewProfileVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if the user has events and your following them or it is current user profile show it
        if userEvents.isEmpty == false && (self.isFollowed == true || user?.uid == User.current.uid) {
            emptyView.isHidden = true
            return userEvents.count
            
        }else if userEvents.isEmpty == true && (self.isFollowed == true || user?.uid == User.current.uid){
            //will nil out any previous backgroundview
            //will go here if there are no events at all
            //must also be following them or be you
            self.myCollectionView.addSubview(emptyView)

            emptyView.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.myCollectionView.snp.centerY).offset(160)
                make.centerX.equalTo(self.myCollectionView.snp.centerX)

            }
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-the-toast-64")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(emptyLabel)
            emptyLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(30)
                make.left.right.equalTo(emptyView)
            }
            return userEvents.count
        }else if userEvents.isEmpty == true && (user?.isPrivate)! && self.isFollowed == false && user?.uid != User.current.uid{
            //will go here if the user has no events and there private and your not following
            //there will be no events because you were not following them so thats implied
            //also has to not be you
            self.myCollectionView.addSubview(emptyView)
            
            emptyView.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.myCollectionView.snp.centerY).offset(160)
                make.centerX.equalTo(self.myCollectionView.snp.centerX)
                
            }
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-secure-50")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(noFriendLabel)
            noFriendLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(20)
                make.left.right.equalTo(emptyView)
            }
            emptyView.addSubview(noFriendLabel2)
            noFriendLabel2.snp.makeConstraints { (make) in
                make.bottom.equalTo(noFriendLabel.snp.bottom).offset(45)
                make.left.right.equalTo(emptyView).inset(10)
            }
            
            return userEvents.count;
        }else{
            //will go here if they aren't private or they are you becasue if they are you want to show them anwyway
            emptyView.isHidden = true
            return userEvents.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewUserEventAttendingCell
        cell.event = userEvents[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 169
        return CGSize(width: collectionView.bounds.size.width - 30, height: CGFloat(kWhateverHeightYouWant))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - 20, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventDetails = EventDetailViewController()
        eventDetails.currentEvent = userEvents[indexPath.item]
        self.navigationController?.pushViewController(eventDetails, animated: true)
    }
    
    fileprivate func setupHeaderLabel(count: String, type: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(count)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: type, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
        return attributedText
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! NewUserHeader
        header.user = user
        header.profileViewController = self
        header.eventsLabel.attributedText = setupHeaderLabel(count: String(userEvents.count), type: "events")
        header.followersLabel.attributedText = setupHeaderLabel(count: String(FriendService.system.followerList.count), type: "followers")
        header.followingLabel.attributedText = setupHeaderLabel(count: String(FriendService.system.followingList.count), type: "following")
        return header
    }
    
    
}
