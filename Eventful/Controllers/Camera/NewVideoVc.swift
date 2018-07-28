//
//  NewVideoVc.swift
//  Eventful
//
//  Created by Shawn Miller on 5/24/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
class NewVideoViewController: UIViewController {
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
    
    
    
    let shareButton: UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "icons8-circled-right-48").withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return shareButton
    }()
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        setupViews()

    }
    
    
    @objc func setupViews(){
        
//        playerController = AVPlayerViewController()
//
//        guard player != nil && playerController != nil else {
//            return
//        }
//        playerController!.showsPlaybackControls = false
//        // Setting AVPlayer to the player property of AVPlayerViewController
//        playerController!.player = player!
//        self.addChildViewController(playerController!)
//        self.view.addSubview(playerController!.view)
//
//        playerController!.view.frame = view.frame
        
        self.view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).inset(15)
            make.height.width.equalTo(40)
        }
        self.view.addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.right.equalTo(self.safeAreaLayoutGuide.snp.right).inset(10)
            make.height.width.equalTo(35)
        }
        
        self.view.addSubview(saveToAlbum)
        saveToAlbum.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.left.equalTo(self.safeAreaLayoutGuide.snp.left).inset(10)
            make.height.width.equalTo(40)
        }
    }
}
