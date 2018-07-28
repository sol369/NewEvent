//
//  Private.swift
//  Eventful
//
//  Created by Shawn Miller on 5/25/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class PrivateCell: UITableViewCell {
    var stackView: UIStackView?
    lazy var switchStatementLabel : UILabel =  {
        let switchStatementLabel = UILabel()
        switchStatementLabel.textAlignment = .justified
        switchStatementLabel.text =  "Make Profile Private"
        return switchStatementLabel
    }()
    
    lazy var privateSwitch : UISwitch  = {
       let privateSwitch = UISwitch(frame:  CGRect(x: 0, y: 0, width: 70, height: 70))
        privateSwitch.isOn = User.current.isPrivate!
        privateSwitch.onTintColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        privateSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: UIControlEvents.valueChanged)
        return privateSwitch
    }()
    
    //will allow me to know when a user's profile is private or not
    @objc func switchToggled(_ sender: UISwitch) {
        if privateSwitch.isOn {
            print("switch turned on")
            
            SettingsService.setIsPrivate(true) { (success, user) in
                if success {
                    print("User is private")
                    if let user = user {
                        User.setCurrent(user, writeToUserDefaults: true)
                    }
                }
            }

        }else{
            print("switch turned off")
            SettingsService.setIsPrivate(false) { (success, user) in
                if success {
                    print("User is private")
                    if let user = user {
                        User.setCurrent(user, writeToUserDefaults: true)
                    }
                }
            }

        }
    }
    @objc func setupViews(){
       // privateSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: UIControlEvents.valueChanged)
        backgroundColor = .white
        stackView = UIStackView(arrangedSubviews: [ switchStatementLabel, privateSwitch])
        stackView?.axis = .horizontal
        stackView?.distribution = .equalSpacing
//        stackView?.spacing = 10.0
        if let firstStackView = stackView{
            self.addSubview(firstStackView)
            firstStackView.snp.makeConstraints { (make) in
                make.edges.equalTo(self).inset(10)
            }
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
