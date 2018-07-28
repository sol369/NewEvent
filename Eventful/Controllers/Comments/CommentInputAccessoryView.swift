//
//  CommentInputAccessoryView.swift
//  Eventful
//
//  Created by Shawn Miller on 1/5/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
protocol CommentInputAccessoryViewDelegate:NSObjectProtocol {
    func handleSubmit(for comment: String?)
}

class CommentInputAccessoryView: UIView, UITextViewDelegate {
    weak var delegate: CommentInputAccessoryViewDelegate?
    
   fileprivate let submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        //submitButton.isEnabled = false
        return submitButton
    }()
    
    lazy var commentTextView: CommentInputTextView = {
        let textView = CommentInputTextView()
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        textView.textContainer.lineBreakMode = .byWordWrapping
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //1
        autoresizingMask = .flexibleHeight
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right:rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        addSubview(commentTextView)
        //3
        if #available(iOS 11.0, *){
                    commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        }else{
            //fallback on earlier versions
        }

        setupLineSeparatorView()

    }
    // 2
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeparatorView(){
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top:topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSubmit(){
        guard let commentText = commentTextView.text else{
            return
        }
        delegate?.handleSubmit(for: commentText)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextView) {
        let isCommentValid = commentTextView.text?.count ?? 0 > 0
        if isCommentValid {
            submitButton.isEnabled = true
        }else{
            submitButton.isEnabled = false
        }
    }
    func clearCommentTextField(){
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
