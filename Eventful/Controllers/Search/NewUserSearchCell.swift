//
//  NewUserSearchCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class NewUserSearchCell: BaseCell,UITextFieldDelegate {
    var filteredUsers: [User]? {
        didSet{
//            guard filteredUsers != nil else {
//                return
//            }
            userSearchCollectionView.reloadData()
        }
    }
    var searchVc: NewSearchVC?
    private let cellId = "cellId"
    let userSearchCollectionView: UICollectionView = {
        let layout = CustomFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    
    override func setupViews() {
        backgroundColor = .clear
        addSubview(userSearchCollectionView)
        userSearchCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).inset(5)
        }
        userSearchCollectionView.delegate = self
        userSearchCollectionView.dataSource = self
        userSearchCollectionView.register(UserCell.self, forCellWithReuseIdentifier: cellId)

    }
    
    @objc func GoBack(){
        searchVc?.navigationController?.popViewController(animated: true)
    }
}

extension NewUserSearchCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentCount = filteredUsers?.count else {
            return 0
        }
        return currentCount
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width - 20, height: 60)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserCell
        cell.user = filteredUsers?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers![indexPath.item]
        // print(user.username ?? "")
        let userProfileController = NewProfileVC()
        userProfileController.user = user
        userProfileController.navigationItem.title = user.username
        userProfileController.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        userProfileController.navigationItem.leftBarButtonItem = backButton
        searchVc?.navigationController?.pushViewController(userProfileController, animated: true)
    }
}
