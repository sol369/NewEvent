//
//  CommentsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/8/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase




class CommentsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate{
    //arrray of comments that will determine how many cells are displayed as well as hold on to all comments in comment box
    // database handles for observing data with real time syncing
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    //eventkey for database use
    public var eventKey = ""
    let cellID = "cellID"
    //function that will handle observing messages in the database
    var bottomConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        collectionView?.backgroundColor = UIColor.white
        //        self.navigationItem.hidesBackButton = true
        //        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        //        self.navigationItem.leftBarButtonItem = backButton
        self.collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom:-50, right: 0)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        view.addSubview(containerView)
        view.addConstraintsWithFormatt("H:|[v0]|", views: containerView)
        view.addConstraintsWithFormatt("V:[v0(48)]", views: containerView)
        bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.collectionView?.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        collectionView?.register(CommentHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        fetchComments()
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        if let userinfo = notification.userInfo{
            
            let keyboardFrame = (userinfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.bottomConstraint?.constant = -(keyboardFrame.height)
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            self.bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame.height) : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completion) in
                if self.comments.count > 0  && isKeyboardShowing{
                    let indexPath = NSIndexPath(item: self.comments.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
                }
            })
        }
    }
    var comments = [CommentGrabbed]()
    var isFinishedPaging = false
    // will do the work of fetching the comments and populate the array
    fileprivate func fetchComments(){
        messagesRef = Database.database().reference().child("Comments").child(eventKey)
print(eventKey)
       // print(comments.count)
        let query = messagesRef?.queryOrderedByKey()
        query?.observe(.value, with: { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            print(snapshot)
            
            allObjects.forEach({ (snapshot) in
                guard let commentDictionary = snapshot.value as? [String: Any] else{
                    return
                }
                guard let uid = commentDictionary["uid"] as? String else{
                    return
                }
                UserService.show(forUID: uid, completion: { (user) in
                    if let user = user {
                        let commentFetched = CommentGrabbed(user: user, dictionary: commentDictionary)
                        commentFetched.commentID = snapshot.key
                        let filteredArr = self.comments.filter { (comment) -> Bool in
                            return comment.commentID == commentFetched.commentID
                        }
                        if filteredArr.count == 0 {
                            self.comments.append(commentFetched)
                            
                        }
                    }
                    self.comments.sort(by: { (comment1, comment2) -> Bool in
                        return comment1.creationDate.compare(comment2.creationDate) == .orderedAscending
                    })
                    self.comments.forEach({ (comments) in
                    })
                    self.collectionView?.reloadData()
                })
                
            })
            
        }, withCancel: { (error) in
             print("Failed to observe comments")
        })
        
        //first lets fetch comments for current event
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //will let you dynamically adjust height of cell based on text or any other object element that you are building to contain your cell
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        // will force the layout of subviews before drawing
        dummyCell.layoutIfNeeded()
        let targgetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targgetSize)
        let height = max(40+8+8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //fire off pagination
        let cell: CommentCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        cell.didTapOptionsButtonForCell = flagButtonTapped(from:)
        return cell
    }
    
    
    func flagButtonTapped (from cell: CommentCell){
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        // 2
        let comment = comments[indexPath.item]
        _ = comment.uid
        
        // 3
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 4
        if comment.uid != User.current.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
                ChatService.flag(comment)
                
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(flagAction)
        }else{
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete Comment", style: .default, handler: { _ in
                ChatService.deleteComment(comment, self.eventKey)
                let okAlert = UIAlertController(title: nil, message: "Comment Has Been Deleted", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
                self.collectionView?.reloadData()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
        }
        
        // 5
        
        // 6
        present(alertController, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
        tabBarController?.tabBar.isHidden = true
        submitButton.isUserInteractionEnabled = true
        fetchComments()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //commentTextField.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
        tabBarController?.tabBar.isHidden = false
        self.comments.removeAll()
    }
    lazy var submitButton : UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        submitButton.isEnabled = false
        return submitButton
    }()
    
    //allows you to gain access to the input accessory view that each view controller has for inputting text
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.addSubview(self.submitButton)
        self.submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: self.submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.commentTextField.delegate = self
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a comment"
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let isCommentValid = commentTextField.text?.count ?? 0 > 0
        if isCommentValid {
            submitButton.isEnabled = true
        }else{
            submitButton.isEnabled = false
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! CommentHeader
        header.backButton.addTarget(self, action: #selector(handleCommentDismiss), for: .touchUpInside)
        return header
    }
    
    @objc func handleCommentDismiss(){
        print("Button pressed")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func handleSubmit(){
        guard let comment = commentTextField.text, comment.count > 0 else{
            return
        }
        let userText = Comments(content: comment, uid: User.current.uid, profilePic: User.current.profilePic!, eventKey: eventKey)
        sendMessage(userText)
        // will remove text after entered
        self.commentTextField.text = nil
    }
    
    //need this function to make the inputAccessory view actually appear
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // stops the observing of messages
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    
    
    //    func GoBack(){
    //        _ = self.navigationController?.popViewController(animated: false)
    //    }
    
}


extension CommentsViewController {
    func sendMessage(_ message: Comments) {
        ChatService.sendMessage(message, eventKey: eventKey)
        
    }
}


