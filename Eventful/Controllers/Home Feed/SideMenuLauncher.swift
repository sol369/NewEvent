//
//  SideMenuLauncher.swift
//  Eventful
//
//  Created by Shawn Miller on 4/2/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideMenuLauncher: NSObject, UICollectionViewDelegateFlowLayout {
    override init() {
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SideMenuCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(SideMenuHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView.register(SideMenuFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerID)
    }
    let collectionView :UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    

    let sideMenu: [SideMenu] = {
        return[SideMenu(name: .SeizeTheNight, imageName:"icons8-night-50"),SideMenu(name: .SeizeTheDay, imageName:"icons8-sun-50"),SideMenu(name:.TwentyOneAndUp, imageName:"21"), SideMenu(name: .FriendsEvents, imageName:"icons8-friends-50")]
    }()
    weak var homeFeedController: HomeFeedController?
    let cellID = "cellID"
    let headerID = "headerID"
    let footerID = "footerID"
    let blackView = UIView()

    @objc func presentSideMenu(){
        print("Button pressed")
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(blackView)
            window.addSubview(collectionView)
            collectionView.frame = CGRect(x: 0, y: 0, width: 0, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: 0, width: window.frame.width * (2.50/4), height: self.collectionView.frame.height)
            }, completion: nil)
        }
    }
    @objc func handleDismiss(sideMenu: SideMenu){
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: -(window.frame.width), y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }, completion: { (completed: Bool) in
            print("finished")
        })
    }

    
    @objc func handleDismissOne(sideMenu: SideMenu){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: -(window.frame.width), y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }, completion: { (completed: Bool) in
                self.homeFeedController?.showControllerForCategory(sideMenu: sideMenu)
        })
    }
    
}


extension SideMenuLauncher: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return sideMenu.count
     
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height:45)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
             let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! SideMenuHeader
            header.user = User.current
                        header.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
             return header

        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerID, for: indexPath) as! SideMenuFooter
            footer.nameLabel.text = "Settings"
            footer.iconImageView.image = UIImage(named: "icons8-Settings-50")
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            footer.addGestureRecognizer(tapGesture)
            return footer

        default:
             //assert(false, "Unexpected element kind")
             return UICollectionReusableView()
        }
        
    }
    
    
    
    
    
    @objc func handleTap(_ recognizer:UITapGestureRecognizer) {
        _ = recognizer.view
        print("footer tapped")
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: -(window.frame.width), y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }, completion: { (completed: Bool) in
            let settingView = SettingsViewController()
        self.homeFeedController?.navigationController?.pushViewController(settingView, animated: true)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 45)
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SideMenuCell
            cell.sideMenu = sideMenu[indexPath.item]
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let sideMenuTitle = self.sideMenu[indexPath.item]
            handleDismissOne(sideMenu: sideMenuTitle)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let theHeight = collectionView.safeAreaLayoutGuide.layoutFrame.height
        return UIEdgeInsets(top: 25, left: 0, bottom: theHeight - 350, right: 0)
 
    }
}

extension SideMenuLauncher: UICollectionViewDelegate {
    
}
