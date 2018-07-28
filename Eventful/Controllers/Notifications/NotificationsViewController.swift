//
//  NotificationsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 1/28/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

private let reuseIdentifier = "Cell"

class NotificationsViewController: UIViewController,NotificationsSectionDelegate,UIScrollViewDelegate {
    
    
    var emptyLabel: UILabel?
    //array of notifications which will be loaded by a service function
    var notifs = [Notifications]()
    var noti: Notifications!
    var notiHandle: DatabaseHandle = 0
    var notiRef: DatabaseReference?
    var observeNotiHandle: DatabaseHandle = 0
    var observeNotiRef: DatabaseReference?
    public let spinToken = "spinner" as ListDiffable
    var isFinishedPaging = false
    var loading = false
    var items = [ListDiffable]()
    //This creates a lazily-initialized variable for the IGListAdapter. The initializer requires three parameters:
    //1 updater is an object conforming to IGListUpdatingDelegate, which handles row and section updates. IGListAdapterUpdater is a default implementation that is suitable for your usage.
    //2 viewController is a UIViewController that houses the adapter. This view controller is later used for navigating to other view controllers.
    //3 workingRangeSize is the size of the working range, which allows you to prepare content for sections just outside of the visible frame.
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    // 1 IGListKit uses IGListCollectionView, which is a subclass of UICollectionView, which patches some functionality and prevents others.
    let collectionView: UICollectionView = {
        // 2 This starts with a zero-sized rect since the view isn’t created yet. It uses the UICollectionViewFlowLayout just as the ClassicFeedViewController did.
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        // 3 The background color is set to white
        view.backgroundColor = UIColor.white
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notificaitons"
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        UINavigationBar.appearance().titleTextAttributes = attributes
        //will add the collectionView for the iglistkit
        collectionView.frame = CGRect.init(x: 0, y: 5, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-40)
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
        adapter.dataSource = self
        collectionView.register(NotificationCell.self, forCellWithReuseIdentifier: "NotificaationCell")
        self.fetchNotifs()
      self.tryObserveNoti()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //may have to do something here to make pag work properly
//        self.fetchNotifs()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        notiRef?.removeObserver(withHandle: notiHandle)
        observeNotiRef?.removeObserver(withHandle: observeNotiHandle)
    }
    
    
    fileprivate func fetchNotifs(){
 
        NotificationService.fetchUserNotif(currentNotifCount: self.notifs.count, isFinishedPaging: false, withCompletion: { ( noti,boolValue) in
            print("user has \(noti.count) notifications")
            self.notifs = noti
            self.isFinishedPaging = boolValue
            self.adapter.performUpdates(animated: true)
        })
    }
    
    fileprivate func tryObserveNoti(){
        observeNotiHandle = NotificationService.observeNotifs(completion: { (ref, noti) in
            self.observeNotiRef = ref
            if let currentNoti = noti {
                self.notifs.insert(currentNoti, at: 0)
                self.adapter.performUpdates(animated: true, completion: nil)
            }
        })
    }
    
    //will sort the notifications based off of timeStamp
    fileprivate func sortNotifs(notifArray: [Notifications]) -> [Notifications]{
        var tempNotifArray = notifArray
        tempNotifArray.sort(by: { (reply1, reply2) -> Bool in
            return reply1.timeStamp?.compare(reply2.timeStamp!) == .orderedDescending
        })
        return tempNotifArray
    }
    
    func NotificationsSectionUpdared(sectionController: NotificationsSectionController) {
        self.adapter.performUpdates(animated: true)
        
    }
    
    func NotifVcTransition(notifCell: NotificationCell) {
        print("function called")
        guard let notiType1 = notifCell.notification?.notiType else {
            return
        }
        
        if notiType1 == notiType.comment.rawValue{
            guard let notifEventKey = notifCell.notification?.eventKey else {
                return
            }
             let newCommentsController = NewCommentsViewController()
            newCommentsController.eventKey = notifEventKey
            newCommentsController.comments.removeAll()
            newCommentsController.adapter.reloadData { (updated) in
            }
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(newCommentsController, animated: false)
        }else if notiType1 == notiType.follow.rawValue {
            guard let sender = notifCell.notification?.sender else {
                return
            }
 let userProfileController = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = sender
            userProfileController.navigationItem.title = sender.username
            userProfileController.navigationItem.hidesBackButton = true
            let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(self.GoBack))
            userProfileController.navigationItem.leftBarButtonItem = backButton
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }else if notiType1 == notiType.share.rawValue{
            guard let eventKey = notifCell.notification?.eventKey else {
                return
            }
            EventService.show(isFromHomeFeed: false, forEventKey: eventKey) { (event) in
                let eventDetailVC = EventDetailViewController()
                eventDetailVC.currentEvent = event
                self.navigationController?.pushViewController(eventDetailVC, animated: true)
            }
          
        }else{
            print("doing nothing")
        }
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //    //will use this perform pagination
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        //distance from bottom of screen
        print(distance)
        if !loading && distance < 200 {
            //will begin to add spinning indicatior
            loading = true
            adapter.performUpdates(animated: true, completion: nil)
            DispatchQueue.global(qos: .default).async {
                // fake background loading task
                sleep(2)
                DispatchQueue.main.async {
                    self.loading = false
                    print("attempting pagiantion")
                    //put true or false condition to stop pagination
                   // print("Last key is: \(self.notifs.last?.key)")
                    guard let value = self.notifs.last?.timeStamp?.timeIntervalSince1970 else {
                        self.adapter.performUpdates(animated: true)
                        return
                    }
                          NotificationService.fetchUserNotif(currentNotifCount: self.notifs.count, lastKey: value, isFinishedPaging: self.isFinishedPaging, withCompletion: { ( noti,boolValue) in
                            print("user has \(noti.count) notifications")
                           self.isFinishedPaging = boolValue
                            self.notifs.append(contentsOf: noti)
                            self.adapter.performUpdates(animated: true)
                        })
                }
            }
        }
    }

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NotificationsViewController: ListAdapterDataSource {
    // 1 objects(for:) returns an array of data objects that should show up in the collection view. loader.entries is provided here as it contains the journal entries.
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        items = notifs
        if loading {
            items.append(spinToken as ListDiffable)
        }
        //print("comments = \(comments)")
        return items
    }
    
    // 2 For each data object, listAdapter(_:sectionControllerFor:) must return a new instance of a section controller. For now you’re returning a plain IGListSectionController to appease the compiler — in a moment, you’ll modify this to return a custom journal section controller.
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        //the comment section controller will be placed here but we don't have it yet so this will be a placeholder
        if let object = object as? ListDiffable, object === spinToken {
            return spinnerSectionController()
        }else{
        let sectionController = NotificationsSectionController()
        sectionController.delegate = self
        return sectionController
        }
    }
    
    // 3 emptyView(for:) returns a view that should be displayed when the list is empty. NASA is in a bit of a time crunch, so they didn’t budget for this feature.
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        let view = UIView()
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 14.0), NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightGray, NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraph]
        let myAttrString = NSAttributedString(string:  "No Activity to Show", attributes: attributes)
        emptyLabel.attributedText = myAttrString
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        view.backgroundColor = UIColor.white
        return view
    }
}

