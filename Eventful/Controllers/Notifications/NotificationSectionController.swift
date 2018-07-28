//
//  NotificationSectionController.swift
//  Eventful
//
//  Created by Shawn Miller on 2/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//
import Foundation
import IGListKit
import Firebase
protocol NotificationsSectionDelegate: class {
    func NotificationsSectionUpdared(sectionController: NotificationsSectionController)
    func NotifVcTransition(notifCell: NotificationCell)
}
class NotificationsSectionController: ListSectionController,NotificationCellDelegate {
    
    weak var delegate: NotificationsSectionDelegate? = nil
    weak var notif: Notifications?
    
    override init() {
        super.init()
        // supplementaryViewSource = self
        //sets the spacing between items in a specfic section controller
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        return 1
    }
    override func didSelectItem(at index: Int) {
        guard let cell = collectionContext?.dequeueReusableCell(of: NotificationCell.self, for: self, at: index) as? NotificationCell else {
            fatalError()
        }
        cell.notification = notif
        cell.delegate = self
        delegate?.NotifVcTransition(notifCell: cell)
    
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = NotificationCell(frame: frame)
        dummyCell.notification = notif
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, (estimatedSize.height))
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: NotificationCell.self, for: self, at: index) as? NotificationCell else {
            fatalError()
        }
        //  print(comment)
        cell.notification = notif
        cell.delegate = self
        return cell
    }
    
    override func didUpdate(to object: Any) {
        notif = object as? Notifications
    }
    
    func NotificationsSectionUpdared(sectionController: NotificationsSectionController){
        print("Tried to update")
        delegate?.NotificationsSectionUpdared(sectionController: self)
    }
    
    
    
    func handleProfileTransition(tapGesture: UITapGestureRecognizer) {
        let userProfileController = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = notif?.sender
        userProfileController.navigationItem.title = notif?.sender.username
        userProfileController.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        userProfileController.navigationItem.leftBarButtonItem = backButton
        let navController = UINavigationController(rootViewController: userProfileController)
        if Auth.auth().currentUser?.uid != notif?.sender.uid{
            self.viewController?.present(navController, animated: true, completion: nil)
        }else{
            //do nothing
            
        }
    }

    @objc func GoBack(){
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    override var minimumLineSpacing: CGFloat {
        get {
            return 0.0
        }
        set {
            self.minimumLineSpacing = 0.0
        }
    }
    
    deinit {
        print("NotifSectionController class removed from memory")
    }
    
}
