
//
//  StroyCell.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import  UIKit
import AVFoundation
import AVKit

class StoryDisplayCell: UICollectionViewCell{
    
    var playerController : AVPlayerViewController?
    var avplay : AVPlayer?
    var video: String = ""

    var cellStry: Story? {
        didSet{
            video = (cellStry?.Url)!
        }
    }
    
    let mediaContentView: UIView = {
       let mediaContent = UIView()
        mediaContent.backgroundColor = UIColor.white
        return mediaContent
    }()
    
//    let storyImageView: CustomImageView = {
//        let storyImage = CustomImageView()
//        
//    }()
  
    override init(frame: CGRect){
        super.init(frame: frame)
//        let url = URL(string: StoriesViewController.url!)
//        avplay  = AVPlayer(url: url!)
//        playerController = AVPlayerViewController()
//        
//        guard avplay != nil && playerController != nil else { return }
//        
//        playerController?.player = avplay
//        mediaContentView.frame = frame
//        mediaContentView.addSubview(playerController!.view)
//        playerController?.view.frame = mediaContentView.frame
//        
//        addSubview(mediaContentView)
//        avplay?.play()
        
    }
    
//    func showEventImage(urlEntered: String){
//        let url = URL(string: urlEntered)
//        mediaContentView.frame = frame
//        
//    }
    
    
    func startPlayingVideo(urlEntered: String) {
        let url = URL(string: urlEntered)
        avplay  = AVPlayer(url: url!)
        playerController = AVPlayerViewController()
        
        guard avplay != nil && playerController != nil else { return }
        
        playerController?.player = avplay
        mediaContentView.frame = frame
        mediaContentView.addSubview(playerController!.view)
        playerController?.view.frame = mediaContentView.frame
        playerController?.showsPlaybackControls = true
        addSubview(mediaContentView)
        avplay?.play()

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
