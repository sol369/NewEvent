//
//  CommentsSectionController.swift
//  Eventful
//
//  Created by Shawn Miller on 9/23/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import IGListKit
import Foundation
import Firebase
import SwipeCellKit
import XLActionController

protocol CommentsSectionDelegate: class {
    func CommentSectionUpdared(sectionController: CommentsSectionController, comment: CommentGrabbed)
}
class CommentsSectionController: ListSectionController,CommentCellDelegate {
    weak var delegate: CommentsSectionDelegate? = nil
    weak var comment: CommentGrabbed?
    var currentViewController: NewCommentsViewController!
    var eventKey: String?
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
    override func sizeForItem(at index: Int) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: collectionContext!.containerSize.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comment
        dummyCell.layoutIfNeeded()
        let targetSize =  CGSize(width: collectionContext!.containerSize.width, height: 55)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40+8+8, (estimatedSize.height))
        return  CGSize(width: collectionContext!.containerSize.width, height: height)
        
    }
    
    override var minimumLineSpacing: CGFloat {
        get {
            return 0.0
        }
        set {
            self.minimumLineSpacing = 0.0
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: CommentCell.self, for: self, at: index) as? CommentCell else {
            fatalError()
        }
        cell.comment = comment
        cell.delegate = self
        return cell
    }
    override func didUpdate(to object: Any) {
        comment = object as? CommentGrabbed
    }
    override func didSelectItem(at index: Int){
    }
    
    func optionsButtonTapped(cell: CommentCell){
        print("like")
   
        let comment = self.comment
        _ = comment?.sender.uid
        
        // 3
        let actionSheet = TwitterActionController()
        
        // 4
        if comment?.sender.uid != User.current.uid {
            actionSheet.addAction(Action(ActionData(title: "Report as Inappropriate",image: UIImage(named: "icons8-Info-64")!), style: .default, handler: { action in
                // do something useful
                ChatService.flag(comment!)
                
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.viewController?.present(okAlert, animated: true, completion: nil)
            }))
            actionSheet.addAction(Action(ActionData(title: "Reply To Comment", image: UIImage(named: "icons8-reply-arrow-50")!), style: .default, handler: { action in
                // do something useful
                self.handleReply()
            }))
            
            
        }else{
            actionSheet.addAction(Action(ActionData(title: "Delete Comment",image: UIImage(named: "icons8-waste-50")!), style: .default, handler: { action in
                // do something useful
                
                ChatService.deleteComment(comment!,  (comment?.eventKey)!, success: { (success) in
                    if success {
                        let okAlert = UIAlertController(title: nil, message: "Comment Has Been Deleted", preferredStyle: .alert)
                        okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.viewController?.present(okAlert, animated: true, completion: nil)
                        self.onItemDeleted()
                    }
                })
            }))
        }
        self.viewController?.present(actionSheet, animated: true, completion: nil)
        
    }
    func onItemDeleted() {
        print(comment?.content as Any)
        delegate?.CommentSectionUpdared(sectionController: self, comment: comment!)
    }
    func handleProfileTransition(tapGesture: UITapGestureRecognizer){
        let userProfileController = NewProfileVC()
        userProfileController.user = comment?.sender
        userProfileController.navigationItem.title = comment?.sender.username
        userProfileController.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        userProfileController.navigationItem.leftBarButtonItem = backButton
        let navController = UINavigationController(rootViewController: userProfileController)
        if Auth.auth().currentUser?.uid != comment?.sender.uid{
                    self.viewController?.present(navController, animated: true, completion: nil)
        }else{
            //do nothing
            
        }
    }
    
    private func handleReply(){
       //will eliminate the placeholderText in the textView
        self.currentViewController.containerView.commentTextView.hidePlaceholderLabel()
        //will add the user's username and @symbol into the textView to get ready for reply
        self.currentViewController.containerView.commentTextView.text = "@" + (comment?.sender.username)! + " "
        //assures that the textView becomes the first respnder so the keyboard pops up and props you to tyoe
        self.currentViewController.containerView.commentTextView.becomeFirstResponder()
        //sets the isReplyingVariable to know if I am replying to someones comment or not
        self.currentViewController.isReplying = true
        UserService.show(forUID: (comment?.sender.uid)!) { (reciever) in
            self.currentViewController.notificationData = Notifications.init(eventKey: (self.comment?.eventKey)!, reciever: reciever!, content: User.current.username! + " has replied to your comment", type: notiType.comment.rawValue, commentId: (self.comment?.commentID)!)
        }
    }
    
    @objc func GoBack(){
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("CommentSectionController class removed from memory")
    }
    
    
}

