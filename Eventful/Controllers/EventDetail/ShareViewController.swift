//
//  ShareViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 6/4/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class ShareViewController: UITableViewController  {
    var shareNotificationData : Notifications!
    let shareCell = "shareCell"
    var eventKey = ""
    let titleView = UILabel()
    let emptyView = UIView()
    var peopleToShareWith = [User]()
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var noFriendLabel: UILabel = {
        let noFriendLabel = UILabel()
        noFriendLabel.text = "Sorry,You Currently Have No Followers To Share Events With"
        noFriendLabel.font = UIFont(name: "Avenir", size: 20)
        noFriendLabel.numberOfLines = 0
        noFriendLabel.textAlignment = .center
        return noFriendLabel
    }()

    
    lazy var sendButton : UIBarButtonItem = {
        let sendButton = UIBarButtonItem()
        sendButton.image =  UIImage(named: "icons8-sent-32")?.withRenderingMode(.alwaysOriginal)
        sendButton.style = .plain
        sendButton.target = self
        sendButton.action = #selector(sendEventInvite)
        return sendButton
    }()
    
    lazy var backButton : UIBarButtonItem = {
        let backButton = UIBarButtonItem()
        backButton.image =  UIImage(named: "icons8-Back-64")
        backButton.style = .plain
        backButton.target = self
        backButton.action = #selector(GoBack)
        return backButton
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVc()
        FriendService.system.addFriendObserver(userID: User.current.uid) {
            self.tableView.reloadData()
        }
    }
    @objc func setupVc(){
        view.backgroundColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = sendButton
        //shouldn't initially be able to send
        sendButton.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.allowsMultipleSelection = true
        self.tableView.register(ShareCell.self, forCellReuseIdentifier: shareCell)
        
    }
    
    @objc func sendEventInvite(){
        print("Attempting to Send To Selected Friends")

        //for loop to go thorugh all of the users/followers selected
        SVProgressHUD.show(withStatus: "Sending invites")
        for recievingUsers in peopleToShareWith {
            print(self.eventKey)
            self.shareNotificationData = Notifications.init(reciever: recievingUsers, content: (User.current.username!) + " has shared an event with you", type: notiType.share.rawValue, eventKey: self.eventKey)
            NotificationService.sendShareNotification(self.shareNotificationData)
        }
        SVProgressHUD.dismiss(withDelay: 1) {
            self.navigationController?.popViewController(animated: true)

        }

    }
    //will leave the VC
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: shareCell, for: indexPath) as! ShareCell
        cell.user = FriendService.system.followerList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FriendService.system.followerList.count == 0 {
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-friends-51")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(noFriendLabel)
            noFriendLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(50)
                make.left.right.equalTo(emptyView).inset(5)
            }
            self.tableView.backgroundView = emptyView
            return FriendService.system.followerList.count
            
        }else{
            self.tableView.backgroundView = nil
            return FriendService.system.followerList.count
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        let currentCell = tableView.cellForRow(at: indexPath) as! ShareCell
        peopleToShareWith.append(currentCell.user!)
        //this is made under the assumption that you selected atleast one person to share with
        sendButton.isEnabled = true

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! ShareCell
        self.peopleToShareWith = self.peopleToShareWith.filter { (user) -> Bool in
            return user.uid != currentCell.user?.uid
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        if peopleToShareWith.count == 0 {
            sendButton.isEnabled = false
            }else{
            sendButton.isEnabled = true
        }
    }
    
    deinit {
        //will remove observer here
        FriendService.system.removeFriendObserver()
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    private func initNavigationItemTitleView() {
        titleView.text = "Share This Event"
        titleView.text = titleView.text?.uppercased()
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center;
        self.navigationItem.titleView = titleView
        self.titleView.font = UIFont(name: "Futura-CondensedMedium", size: 18)
        self.titleView.adjustsFontSizeToFitWidth = true
        
    }

    
}
