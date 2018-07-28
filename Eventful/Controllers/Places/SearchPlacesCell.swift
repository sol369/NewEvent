//
//  SearchPlacesCell.swift
//  Eventful
//
//  Created by Shawn Miller on 4/6/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit

class SearchPlacesCell: UICollectionViewCell {
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setupShadow2()
        return cellView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    var dividerView: UIView?

    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"Avenir", size: 16.5)
        return sectionNameLabel
    }()
    @objc func setupViews(){
        addSubview(cellView)
        cellView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        cellView.addSubview(sectionNameLabel)
        sectionNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).inset(15)
            make.left.equalTo(self.snp.left).offset(10)
        }
        
           dividerView = UIView()
        dividerView?.backgroundColor = UIColor.lightGray
        cellView.addSubview(dividerView!)
        dividerView?.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
