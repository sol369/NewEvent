//
//  CommentCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwipeCellKit

protocol CommentCellDelegate: class {
    func optionsButtonTapped(cell: CommentCell)
    func handleProfileTransition(tapGesture: UITapGestureRecognizer)
}
class CommentCell: UICollectionViewCell {
    weak var delegate: CommentCellDelegate? = nil
    override var reuseIdentifier : String {
        get {
            return "cellID"
        }
        set {
            // nothing, because only red is allowed
        }
    }
    var didTapOptionsButtonForCell: ((CommentCell) -> Void)?
    
    weak var comment: CommentGrabbed?{
        didSet{
            guard let comment = comment else{
                return
            }
          //  print("apples")
            // textLabel.text = comment.content
            //shawn was also here
            profileImageView.loadImage(urlString: (comment.sender.profilePic!))
            //  print(comment.user.username)
            let attributedText = NSMutableAttributedString(string: (comment.sender.username!), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            
            attributedText.append(NSAttributedString(string: " " + (comment.content), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            
            attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 4)]))
            let timeAgoDisplay = comment.creationDate.timeAgoDisplay()
            attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]))
          
            textView.attributedText = attributedText
            
            
        }
    }
    
    let cellView: UIView = {
        let cellView = UIView()
        cellView.backgroundColor = .white
        cellView.setupShadow2()
        return cellView
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.isEditable = false
        return textView
    }()
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTransition)))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var flagButton: UIButton = {
        let flagButton = UIButton(type: .system)
        flagButton.setImage(#imageLiteral(resourceName: "icons8-more-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
        flagButton.addTarget(self, action: #selector(CommentCell.onOptionsTapped), for: .touchUpInside)
        return flagButton
    }()
    
    @objc func optionsButtonTapped (){
        didTapOptionsButtonForCell?(self)
    }
    
    @objc func onOptionsTapped() {
        delegate?.optionsButtonTapped(cell: self)
    }
    @objc func handleProfileTransition(tapGesture: UITapGestureRecognizer){
        delegate?.handleProfileTransition(tapGesture: tapGesture)
    }
    
    
    
    override init(frame: CGRect){
        super.init(frame: frame)

        setupViews()
    }
    
    @objc func setupViews(){
        let notCurrentUserDividerView = UIView()
        notCurrentUserDividerView.backgroundColor = UIColor.lightGray
        addSubview(cellView)
        
        cellView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        cellView.addSubview(flagButton)

        cellView.addSubview(profileImageView)
        cellView.addSubview(textView)
        profileImageView.snp.makeConstraints { (make) in
            make.top.equalTo(cellView.snp.top).inset(8)
            make.left.equalTo(cellView.snp.left).offset(8)
            make.height.width.equalTo(40)
            
        }
        
        textView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(cellView).inset(4)
            make.left.equalTo(profileImageView.snp.right).offset(4)
            make.right.equalTo(flagButton.snp.left).offset(4)
        }
        
        profileImageView.layer.cornerRadius = 40/2
        cellView.addSubview(notCurrentUserDividerView)
        notCurrentUserDividerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(0.5)
        }
        flagButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(40)
            make.right.equalTo(cellView.snp.right).inset(4)
            make.top.bottom.equalTo(cellView).inset(4)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
