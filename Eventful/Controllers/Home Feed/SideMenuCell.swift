//
//  SideMenuCell.swift
//  Eventful
//
//  Created by Shawn Miller on 4/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit

class SideMenuCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.rgb(red: 243, green: 249, blue: 252): UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.black : UIColor.rgb(red: 53, green: 56, blue: 57)
            iconImageView.tintColor = isHighlighted ? UIColor.rgb(red: 34, green: 153, blue: 234) : UIColor.black
            
        }
    }
    var sideMenu: SideMenu? {
    didSet{
        nameLabel.text = (sideMenu?.name).map { $0.rawValue }
        if let imageName = sideMenu?.imageName {
            iconImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor.darkGray
        }
    }
    }
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
       nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameLabel.textColor = UIColor.rgb(red: 53, green: 56, blue: 57)
        return nameLabel
    }()
    
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    @objc func setupViews(){
        backgroundColor = .white
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(10)
            make.left.equalTo(self.snp.left).inset(5)
        }
        addSubview(nameLabel)
       nameLabel.snp.makeConstraints { (make) in
        make.left.equalTo(iconImageView.snp.right).offset(5)
        make.top.equalTo(self.snp.top).offset(14)
        }
        let currentUserDividerView = UIView()
        currentUserDividerView.backgroundColor = UIColor.lightGray
        addSubview(currentUserDividerView)
        currentUserDividerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.height.greaterThanOrEqualTo(0.75)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
