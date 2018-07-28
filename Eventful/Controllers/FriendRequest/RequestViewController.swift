//
//  RequestViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 5/29/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class RequestViewController: UITableViewController {
    let requestCell = "requestCell"
    let emptyView = UIView()
    
    lazy var noFriendLabel: UILabel = {
        let noFriendLabel = UILabel()
        noFriendLabel.text = "Sorry, You Currently Have No Friend Request"
        noFriendLabel.font = UIFont(name: "Avenir", size: 20)
        noFriendLabel.numberOfLines = 0
        noFriendLabel.textAlignment = .center
        return noFriendLabel
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
          setupVc()
        print(FriendService.system.requestList)
        
        FriendService.system.addRequestObserver {
            print(FriendService.system.requestList)
            self.tableView.reloadData()
        }
    }
    @objc func setupVc(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Pending Friend Request"
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.allowsSelection = false
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.register(FriendRequestCell.self, forCellReuseIdentifier: requestCell)
        //NotificationCenter.default.post(name: heartAttackNotificationName, object: nil)
    }
    
    deinit {
        //will remove observer here
        FriendService.system.removeRequestObserver()
    }
    
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FriendService.system.requestList.count == 0 {
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-handshake-heart-50")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(noFriendLabel)
            noFriendLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(50)
make.left.right.equalTo(emptyView).inset(5)            }
            self.tableView.backgroundView = emptyView
            return FriendService.system.requestList.count
        }else{
            self.tableView.backgroundView = nil
            return FriendService.system.requestList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: requestCell, for: indexPath) as! FriendRequestCell
         cell.user = FriendService.system.requestList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}
