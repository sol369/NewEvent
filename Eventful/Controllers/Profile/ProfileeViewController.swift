//
//  ProfileeViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/30/17.
//  Copyright © 2017 Make School. All rights reserved.
//
    
import UIKit
import Foundation
import Firebase

    
class ProfileeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
        var profileHandle: DatabaseHandle = 0
        var profileRef: DatabaseReference?
        let cellID = "cellID"
        var userEvents = [Event]()
        var userId: String?
        var user: User?
        var emptyLabel: UILabel?
        let emptyView = UIView()
        var isFollowed = false
        
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
        noFriendLabel2.text = "Follow this user to connect and see what events there going to"
        noFriendLabel2.font = UIFont(name: "Avenir", size: 14)
        noFriendLabel2.numberOfLines = 0
        noFriendLabel2.textAlignment = .center
        return noFriendLabel2
    }()
    
    lazy var privateIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
        var currentUserName: String = ""
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            collectionView?.backgroundColor = UIColor.white
            setupVC()

           

        }
        
        deinit {
            profileRef?.removeObserver(withHandle: profileHandle)
            print("removed from memory")
        }
    
    
    
    
    @objc func setupVC(){
        user = self.user ?? User.current
        if let user = user {
            checkFollowStatus(user: user)
            setupBarButtons(user: user)
        }
        
        self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        navigationItem.title = user?.username
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
    
        collectionView?.register(EventsAttendingCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.alwaysBounceVertical = true
        
  

    }
    
    @objc func setupBarButtons(user: User){
        if user == User.current {
            let viewFriendRequestButton = UIBarButtonItem(image: UIImage(named: "icons8-friends-50")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showFollowers))
            let editProfileButton = UIBarButtonItem(image: UIImage(named: "icons8-Edit-50")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(editProfile))
            
            self.navigationItem.rightBarButtonItem = viewFriendRequestButton
            self.navigationItem.leftBarButtonItem = editProfileButton
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
                            self.collectionView?.reloadData()
                        }
                    }
                }else{
                    //will go here if your not following the user and there private and there not you
                    self.isFollowed = false
                    if (self.user?.isPrivate)! && self.isFollowed == false && self.user != User.current{
                        //show nothing because you have to add them first
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    }else{
                        //if they aren't private or there you show it anyway because they dont care
                        self.profileHandle = UserService.observeProfile(for: self.user!) { [unowned self](ref, user, events) in
                            self.profileRef = ref
                            self.user = user
                            self.userEvents = events
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                            
                        }
                    }
                }
            }
        
    }
    

    @objc func editProfile(){
        let profileSetupTransition = AlterProfileViewController()
        let navController = UINavigationController(rootViewController: profileSetupTransition)
        present(navController, animated: true, completion: nil)
    }
    
    @objc func showFollowers(){
        let followVC = FollowersViewController()
        self.navigationController?.pushViewController(followVC, animated: true)
    }
        
        
        override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! UserProfileHeader
            header.profileViewController = self
            header.user = self.user
            return header
        }
        
 

        
    
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: view.frame.width, height: view.bounds.height / 5)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            //self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = false
            self.collectionView?.reloadData()
        }
        
        
        
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            //if the user has events and your following them or it is current user profile show it
            if userEvents.isEmpty == false && (self.isFollowed == true || user?.uid == User.current.uid) {
                self.collectionView?.backgroundView = nil
                return userEvents.count
                
            }else if userEvents.isEmpty == true && (self.isFollowed == true || user?.uid == User.current.uid){
                //will nil out any previous backgroundview
                self.collectionView?.backgroundView = nil

                //will go here if there are no events at all
                //must also be following them or be you
                emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.alignment = .center
                
                let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraph]
                let myAttrString = NSAttributedString(string:  "Go Attend Some Events", attributes: attributes)

                emptyLabel?.attributedText = myAttrString
                emptyLabel?.textAlignment = .center
                self.collectionView?.backgroundView = emptyLabel
                return userEvents.count
            }else if userEvents.isEmpty == true && (user?.isPrivate)! && self.isFollowed == false && user?.uid != User.current.uid{
                //will go here if the user has no events and there private and your not following
                //there will be no events because you were not following them so thats implied
                //also has to not be you
                emptyView.backgroundColor = .clear
                emptyView.addSubview(privateIconImageView)
                privateIconImageView.image = UIImage(named: "icons8-secure-50")
                privateIconImageView.snp.makeConstraints { (make) in
                    make.center.equalTo(emptyView)
                }
                
                emptyView.addSubview(noFriendLabel)
                noFriendLabel.snp.makeConstraints { (make) in
                    make.bottom.equalTo(privateIconImageView.snp.bottom).offset(30)
                    make.left.right.equalTo(emptyView)
                }
                emptyView.addSubview(noFriendLabel2)
                noFriendLabel2.snp.makeConstraints { (make) in
                    make.bottom.equalTo(noFriendLabel.snp.bottom).offset(50)
                    make.left.right.equalTo(emptyView)
                }
                self.collectionView?.backgroundView = emptyView
                
                return userEvents.count;
            }else{
                //will go here if they aren't private or they are you becasue if they are you want to show them anwyway
                self.collectionView?.backgroundView = nil
                return userEvents.count
            }
        }
    
    
        
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (view.frame.width - 2)/3
            return CGSize(width: width, height: width)
            
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! EventsAttendingCell
            cell.layer.cornerRadius = 70/2
            cell.event = userEvents[indexPath.item]
            
            return cell
        }
        //custom zoom logic
        var blackBackgroundView: UIView?
        var startingFrame: CGRect?
        var startingImageView: UIImageView?

        @objc func performZoomInForStartingImageView(startingImageView: UIImageView){
            self.startingImageView = startingImageView
            self.startingImageView?.isHidden = true
            startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
            let zoomingImageView = UIImageView(frame: startingFrame!)
            zoomingImageView.layer.cornerRadius = 100/2
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))

            //zoomingImageView.backgroundColor = UIColor.red
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
                    zoomingImageView.image = image
                }
                
                }.resume()
            if let keyWindow = UIApplication.shared.keyWindow {
                blackBackgroundView = UIView(frame: keyWindow.frame)
                blackBackgroundView?.backgroundColor = UIColor.black
                blackBackgroundView?.alpha = 0
                keyWindow.addSubview(blackBackgroundView!)
                keyWindow.addSubview(zoomingImageView)

                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackBackgroundView?.alpha = 1
                    // math?
                    // h2 / w1 = h1 / w1
                    // h2 = h1 / w1 * w1
                    let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                    
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    
                    zoomingImageView.center = keyWindow.center
                    
                }, completion: { (completed) in
                    //                    do nothing
                })

            }
        }
        
        @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer){
            if let zoomOutImageView = tapGesture.view {
                //need to animate back out to controller
                zoomOutImageView.layer.cornerRadius = 100/2
                zoomOutImageView.clipsToBounds = true
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    zoomOutImageView.frame = self.startingFrame!
                    self.blackBackgroundView?.alpha = 0
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
                })
                
            }
        }
        
    }
