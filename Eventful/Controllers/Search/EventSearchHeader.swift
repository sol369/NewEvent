//
//  EventSearchHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 8/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit

class SearchHeader: UICollectionViewCell {
   let dividerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(self)
        }
        dividerView.backgroundColor = UIColor.lightGray
        addSubview(dividerView)
        dividerView.snp.makeConstraints { (make) in
            make.bottom.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(self)
            make.height.equalTo(1.1)
        }
    }
    

    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.searchBarStyle = .minimal
        sb.showsScopeBar = true
        sb.sizeToFit()
        sb.setScopeBarButtonTitleTextAttributes([ NSAttributedStringKey.foregroundColor.rawValue : UIColor.black], for: .normal)
        let textFieldInsideUISearchBar = sb.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.systemFont(ofSize: 14)
        sb.scopeButtonTitles = ["Events", "Users"]
        sb.barTintColor = UIColor.white
        sb.tintColor = UIColor.lightText
        sb.showsCancelButton = true
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
         UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setupShadow2()
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black], for: .normal)
        sb.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey(NSAttributedStringKey.font.rawValue).rawValue: UIFont(name: "Avenir-Heavy", size: 15) as Any,NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue: UIColor.black as Any], for: .selected)
        sb.setScopeBarButtonTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue: UIColor.lightGray as Any], for: .normal)
        //  sb.delegate = self
        return sb
    }()
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

