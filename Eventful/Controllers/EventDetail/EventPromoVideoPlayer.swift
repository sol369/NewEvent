//
//  EventPromoVideoPlayer.swift
//  Eventful
//
//  Created by Shawn Miller on 11/28/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class EventPromoVideoPlayer: UIViewController {
    public var eventKey = ""
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //URL of promo video that is about to be played
    private var videoURL: URL
    // Allows you to play the actual mp4 or video
    var player: AVPlayer?
    // Allows you to display the video content of a AVPlayer
    var playerController : AVPlayerViewController?
    
    // App enter in forground.
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        player?.play()
    }
    
    // App enter in forground.
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        player?.pause()
    }
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the observers to stop the video from freezing when the app goes to the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        self.view.backgroundColor = UIColor.gray
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        downSwipe.direction = .down
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(downSwipe)
        view.addGestureRecognizer(rightSwipe)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        //Setting the video url of the AVPlayer
        player = AVPlayer(url: videoURL)
        playerController = AVPlayerViewController()
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        // Setting AVPlayer to the player property of AVPlayerViewController
        playerController!.player = player!
        self.addChildViewController(playerController!)
        self.view.addSubview(playerController!.view)
        playerController!.view.frame = view.frame
        // Added an observer for when the video stops playing so it can be on a continuous loop
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        //TODO: Need to fix frame of x and y
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    func transformViewToLansdcape(){
        var rotationDir : Int
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            rotationDir = 1
        }else{
            rotationDir = -1
        }
        var transform = self.view.transform
        //90 for landscapeLeft and 270 for landscapeRight
        transform = transform.rotated(by: (rotationDir*270).degreesToRadians)
        self.view.transform = transform
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the observers
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transformViewToLansdcape()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    // Allows the video to keep playing on a loop
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
    
    
    @objc func swipeAction(_ swipe: UIGestureRecognizer){
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
               // print("Swiped right")
                dismiss(animated: true, completion: nil)
                break
            case UISwipeGestureRecognizerDirection.down:
               // print("Swiped Down")
                dismiss(animated: true, completion: nil)
                break
            case UISwipeGestureRecognizerDirection.left:
               // print("Swiped left")
                break
            case UISwipeGestureRecognizerDirection.up:
              //  print("Swiped up")
                break
            default:
                break
            }
        }
    }

}
extension BinaryInteger {
    var degreesToRadians: CGFloat {
        return CGFloat(Int(self)) * .pi / 180
    }
}


