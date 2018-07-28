//
//  SideMenuHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 4/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit

class SideMenuHeader: UICollectionViewCell {
    var user: User? {
        didSet{
            if let profilePic = User.current.profilePic, let username = User.current.username {
                if let imageURL = URL(string: profilePic){
                    self.profileImage.af_setImage(withURL: imageURL)
                    self.nameLabel.text = username
                }
            }
         
        }
    }
    
    lazy var profileImage: CustomImageView = {
        let profilePicture = CustomImageView()
        profilePicture.layer.borderWidth = 1.0
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.clipsToBounds = true
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.contentMode = .scaleToFill
        profilePicture.isUserInteractionEnabled = true
        profilePicture.layer.shouldRasterize = true
//        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        // will allow you to add a target to an image click
        profilePicture.layer.masksToBounds = true
        return profilePicture
    }()
    
    lazy var dismissButton : UIButton = {
        let locationMarker = UIButton(type: .system)
        locationMarker.setImage(#imageLiteral(resourceName: "icons8-left-52").withRenderingMode(.alwaysOriginal), for: .normal)
        return locationMarker
    }()
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        return nameLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    fileprivate func setupViews(){
        backgroundColor = .white
        addSubview(profileImage)
        profileImage.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(20)
            make.left.equalTo(self.snp.left).offset(10)
            make.height.width.equalTo(60)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImage.snp.bottom).offset(5)
            make.left.equalTo(self.snp.left).offset(10)
        }
        addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(15)
            make.right.equalTo(self.snp.right).inset(10)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
