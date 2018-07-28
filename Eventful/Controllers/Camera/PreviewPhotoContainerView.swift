//
//  PreviewPhotoContainerView.swift
//  Eventful
//
//  Created by Shawn Miller on 3/30/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Photos
import FirebaseStorage
import AZDialogView


class PreviewPhotoContainerView: UIView {
    var event: Event? {
        didSet{
            print("event set")
        }
    }

    let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Close"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveToAlbum: UIButton = {
        let saveToAlbum = UIButton(type: .system)
        saveToAlbum.setImage(UIImage(named: "save_shadow"), for: .normal)
        saveToAlbum.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return saveToAlbum
    }()
    
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    let shareButton: UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "icons8-circled-right-48").withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return shareButton
    }()
    
    @objc func handleAdd(){
        if let currentEvent = event, let username = User.current.username {
            let dialog = AZDialogViewController(title: "\(username)", message: "Are you sure you want to add to the Haipe surrounding the \(currentEvent.currentEventName.capitalized) with your photo?")
            //set the title color
            dialog.titleColor = .black
            
            //set the message color
            dialog.messageColor = .black
            
            //set the dialog background color
            dialog.alertBackgroundColor = .white
            
            //set the gesture dismiss direction
            dialog.dismissDirection = .bottom
            
            //allow dismiss by touching the background
            dialog.dismissWithOutsideTouch = true
            //show seperator under the title
            dialog.showSeparator = true
            //set the seperator color
            dialog.separatorColor = UIColor.rgb(red: 44, green: 152, blue: 229)
            //enable/disable drag
            dialog.allowDragGesture = true
            //enable rubber (bounce) effect
            dialog.rubberEnabled = true
            //enable/disable backgroud blur
            dialog.blurBackground = true
            
            //set the background blur style
            dialog.blurEffectStyle = .prominent
            dialog.imageHandler = { (imageView) in
                imageView.image = UIImage(named: "appIcon")
                imageView.contentMode = .scaleAspectFit
                return true //must return true, otherwise image won't show.
            }
            dialog.addAction(AZDialogAction(title: "Add") { (dialog) -> (Void) in
                //add your actions here.
                self.handleAddToStory()
                
                dialog.dismiss()
            })
            
            dialog.buttonStyle = { (button,height,position) in
                button.setBackgroundImage(UIImage.from(color: UIColor.rgb(red: 44, green: 152, blue: 229)), for: .highlighted)
                button.setTitleColor(UIColor.white, for: .highlighted)
                button.setTitleColor(UIColor.rgb(red: 44, green: 152, blue: 229), for: .normal)
                button.layer.masksToBounds = true
                button.layer.borderColor = UIColor.rgb(red: 44, green: 152, blue: 229).cgColor
            }
            
            dialog.cancelEnabled = true
            
            dialog.cancelButtonStyle = { (button,height) in
                button.tintColor = UIColor.rgb(red: 44, green: 152, blue: 229)
                button.setTitle("CANCEL", for: [])
                return true //must return true, otherwise cancel button won't show.
            }
            
            dialog.show(in: self.viewContainingController()!)
        }
    }
    
    
    @objc func handleAddToStory(){
        print("Attempting to add to story")
        guard let eventKey = event?.key else {
            return
        }
        guard let currentImage = previewImageView.image else {
            return
        }
        let dateFormatter = ISO8601DateFormatter()
        let timeStamp = dateFormatter.string(from: Date())
        let uid = User.current.uid
        let storageRef = Storage.storage().reference().child("event_stories").child(eventKey).child(uid).child(timeStamp + ".PNG")
        StorageService.uploadImage(currentImage, at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
            PostService.create(for: eventKey, for: videoUrlString)
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Added Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        self.removeFromSuperview()
                    })
                    
                })
            }
        }
        
    }
    
    @objc func handleSave(){
        print("Attempting to save photo")
        guard let previewImage = previewImageView.image else {
            return
        }
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { (success, err) in
            if let err = err{
                print("Failed to save image to photo library:",err)
                return
            }
            print("Successfully saved image to library")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Saved Successfully"
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        //self.removeFromSuperview()
                    })
                    
                })
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    @objc func setupViews(){
        addSubview(previewImageView)
        previewImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).inset(15)
            make.height.width.equalTo(40)
        }
        addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).inset(10)
            make.height.width.equalTo(35)
        }
        
        addSubview(saveToAlbum)
        saveToAlbum.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).inset(10)
            make.height.width.equalTo(40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
