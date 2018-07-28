//
//  NewCommentsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Firebase
import Foundation


class NewCommentsViewController: UIViewController, UITextFieldDelegate,CommentsSectionDelegate,CommentInputAccessoryViewDelegate, UIScrollViewDelegate {
    //array of comments which will be loaded by a service function
    var comments = [CommentGrabbed]()
    var messagesRef: DatabaseReference?
    var messageHandle: DatabaseHandle = 0
    var commentRer: DatabaseReference?
    var commentHandle: DatabaseHandle = 0
    var items = [ListDiffable]()
    var bottomConstraint: NSLayoutConstraint?
    var loading = false
    public let spinToken = "spinner" as ListDiffable
    public var eventKey = ""
    var isReplying = false
    var notificationData : Notifications!
    var isFinishedPaging = false
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
    
    //will fetch the comments from the database and append them to an array
    fileprivate func fetchComments(){
        //first lets fetch comments for current event
        //comments.removeAll()
        print(eventKey)
        ChatService.fetchComments(forChatKey: eventKey, currentPostCount: 0, lastKey: "", isFinishedPaging: false) { ( currentComments,boolValue) in
            self.comments = currentComments
            self.isFinishedPaging = boolValue
            self.adapter.performUpdates(animated: true)
        }
    }
    
    fileprivate func tryObserveComments(){
        print(eventKey)
        commentHandle = ChatService.observeMessages(forChatKey: eventKey) { (ref, newComments) in
            self.commentRer = ref
            self.comments.append(newComments!)
            self.adapter.performUpdates(animated: true, completion: { (finished) in
                if finished {
                    let item = self.collectionView.numberOfItems(inSection: self.collectionView.numberOfSections - 1) - 1
                    let insertionIndexPath = IndexPath(item: item, section: self.collectionView.numberOfSections - 1)
                    self.collectionView.scrollToItem(at: insertionIndexPath, at: UICollectionViewScrollPosition.top, animated: true)
                }
            })

        }
    }
    
    
    fileprivate func sortComments(comments: [CommentGrabbed]) -> [CommentGrabbed]{
        var tempCommentArray = comments
        tempCommentArray.sort(by: { (reply1, reply2) -> Bool in
            return reply1.creationDate.compare(reply2.creationDate) == .orderedAscending
        })
        return tempCommentArray
    }
    
    //allows you to gain access to the input accessory view that each view controller has for inputting text
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame:frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    

    @objc func handleSubmit(for comment: String?){
        guard let comment = comment, comment.count > 0 else{
            return
        }
        
        let userText = CommentGrabbed(content: comment,eventKey: eventKey)
        sendMessage(userText)
        // will clear the comment text field
        self.containerView.clearCommentTextField()
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userinfo = notification.userInfo {
            
            if let keyboardFrame = (userinfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                self.bottomConstraint?.constant = -(keyboardFrame.height)
                
                let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
                
                self.bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame.height) : 0
                if isKeyboardShowing{
                    let contentInset = UIEdgeInsetsMake(0, 0, (keyboardFrame.height), 0)
                    collectionView.contentInset = UIEdgeInsetsMake(0, 0, (keyboardFrame.height), 0)
                    collectionView.scrollIndicatorInsets = contentInset
                }else {
                    let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    collectionView.scrollIndicatorInsets = contentInset
                }
                
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (completion) in
                    if self.collectionView.numberOfSections > 0  && isKeyboardShowing {
                        let item = self.collectionView.numberOfItems(inSection: self.collectionView.numberOfSections - 1) - 1
                        let lastItemIndex = IndexPath(item: item, section: self.collectionView.numberOfSections - 1)
                        self.collectionView.scrollToItem(at: lastItemIndex, at: UICollectionViewScrollPosition.top, animated: true)
                    }
                })
            }
        }
    }

    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        self.fetchComments()
//        self.tryObserveComments()
    }
    
    @objc func setupViews(){
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        collectionView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-40)
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: "CommentCell")
        collectionView.register(SpinnerCell.self, forCellWithReuseIdentifier: "SpinnerrCell")
        collectionView.keyboardDismissMode = .onDrag
        navigationItem.title = "Comments"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    
    deinit {
        print("NewCommentsController class removed from memory")
        messagesRef?.removeObserver(withHandle: messageHandle)
        commentRer?.removeObserver(withHandle: commentHandle)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
    //look here
    func CommentSectionUpdared(sectionController: CommentsSectionController,comment: CommentGrabbed){
        print("like")
        self.comments = comments.filter({ (someComment: CommentGrabbed) -> Bool in
            return someComment.key != comment.key
        })
        self.adapter.performUpdates(animated: true)
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
//                    let itemCount = self.comments.count
                    //will append new objects here
//                    self.comments.append(Array(comments..<itemCount + 5))
                    print("attempting pagiantion")
                    //put true or false condition to stop pagination
                    guard let lastKey = self.comments.last?.key else {
                        self.adapter.performUpdates(animated: true, completion: nil)
                        return
                    }
                        ChatService.fetchComments(forChatKey: self.eventKey, currentPostCount: self.comments.count, lastKey: lastKey, isFinishedPaging: self.isFinishedPaging, completion: { ( pagComments,boolValue) in
                            self.isFinishedPaging = boolValue
                            self.comments.append(contentsOf: pagComments)
                            self.adapter.performUpdates(animated: true, completion: nil)
                        })

                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        //self.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.becomeFirstResponder()
        self.isFinishedPaging = false
        self.fetchComments()
        self.tryObserveComments()
        tabBarController?.tabBar.isHidden = true
        //submitButton.isUserInteractionEnabled = true
        
    }
    //viewDidLayoutSubviews() is overridden, setting the collectionView frame to match the view bounds.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //    collectionView.frame = view.bounds
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension NewCommentsViewController: ListAdapterDataSource {
    // 1 objects(for:) returns an array of data objects that should show up in the collection view. loader.entries is provided here as it contains the journal entries.
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        items = comments
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
        let sectionController = CommentsSectionController()
        sectionController.currentViewController = self
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
        let myAttrString = NSAttributedString(string:  "Leave a Comment", attributes: attributes)
        emptyLabel.attributedText = myAttrString
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        view.backgroundColor = UIColor.white
        return view
    }
}

extension NewCommentsViewController {
    func sendMessage(_ message: CommentGrabbed) {
        //two cases that need to be handled
        //if it is a reply we need to also send a notificaiton
        //if it is a regular comment we just post it
        if isReplying {
            //First send message
            ChatService.sendMessage(message, eventKey: eventKey)
            //send notification
            ChatService.sendNotification(notificationData)
            //set back to false when done
            isReplying = false
            return
        }
        else{
            ChatService.sendMessage(message, eventKey: eventKey)

        }
        
    }
}
