//
//  NotifBannerView.swift
//  Eventful
//
//  Created by Shawn Miller on 3/12/18.
//  Copyright © 2018 Make School. All rights reserved.
//

//custom notification view for in app push notifs
import UIKit
import Foundation
import SwiftyJSON


class NotifBannerView: UIView {

    var userInfoForNotif: [AnyHashable : Any]?{
        didSet{
            guard let currentUserNotif = userInfoForNotif else {
                return
            }
            
            //will handle the notif banner for reply
            if let userInfo = currentUserNotif["repliedBy"] as? String{
                let userInfoDict = convertToDictionary(text: userInfo)
                profileImageView.loadImage(urlString: userInfoDict!["profilePic"] as! String)
                let attributedText = NSMutableAttributedString(string: currentUserNotif["content"] as! String, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10)])
                label.attributedText = attributedText
            }
            //will handle the notif banner for friend request
            if currentUserNotif["notiType"] as? String == notiType.friendRequest.rawValue{
                profileImageView.loadImage(urlString: currentUserNotif["profilePic"] as! String)
                let attributedText = NSMutableAttributedString(string: currentUserNotif["content"] as! String, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10)])
                label.attributedText = attributedText
            }

        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    //profile image view for the notif banner
     var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(label)
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        profileImageView.layer.cornerRadius = 25/2
        label.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 8, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
