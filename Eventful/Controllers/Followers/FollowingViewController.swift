//
//  FollowersViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 6/1/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import IGListKit

class FollowingViewController: UITableViewController  {
    let friendCell = "friendCell"
    let emptyView = UIView()
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var noFriendLabel: UILabel = {
        let noFriendLabel = UILabel()
        noFriendLabel.text = "You Are Currently Following No One"
        noFriendLabel.font = UIFont(name: "Avenir", size: 20)
        noFriendLabel.numberOfLines = 0
        noFriendLabel.textAlignment = .center
        return noFriendLabel
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVc()
    }
    
    @objc func setupVc(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Following"
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
         self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        self.tableView.register(FollowerCell.self, forCellReuseIdentifier: friendCell)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCell, for: indexPath) as! FollowerCell
        cell.user = FriendService.system.followingList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FriendService.system.followingList.count == 0 {
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-friends-51")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(noFriendLabel)
            noFriendLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(50)
                make.left.right.equalTo(emptyView).inset(5)            }
            self.tableView.backgroundView = emptyView
            return FriendService.system.followingList.count

        }else{
            self.tableView.backgroundView = nil
            return FriendService.system.followingList.count
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    deinit {
        //will remove observer here
        FriendService.system.removeFriendObserver()
    }
    
}


