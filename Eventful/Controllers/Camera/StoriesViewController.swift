//
//  Stories.swift
//  Eventful
//
//  Created by Shawn Miller on 8/21/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import AFDateHelper
import Firebase

class StoriesViewController: UIViewController, SegmentedProgressBarDelegate {
    
    /// the event key
    var eventKey = ""
    
    /// Array of all the stories for this event
    var allStories = [Story]()
    
    /// Player Controller for the story that will contain the video if it has one
    var playerController: AVPlayerViewController!
    
    /// Loading indicator for loading a story
    var indicator: UIActivityIndicatorView!
    
    /// Blur View to make the transation for loading look nicer
    var blurView: UIVisualEffectView!
    
    /// Image view for the story if it contains an image
    var imageView: UIImageView!
    
    /// The current story index (allStories array)
    var currentIndex = 0
    
    /// The progress bar
    var spb: SegmentedProgressBar!
    
    /// Flags for to see if using is rewinding/forwarding/or on repeat
    var isRewinding = false
    var isForwarding = false
    var onRepeat = false
    
    /// Array of all the durations for each story
    var durations = [TimeInterval]()
    
    /// Gesture recoginzers for taps and swipes
    var tapInfoView: UITapGestureRecognizer!
    var swipeInfoView: UISwipeGestureRecognizer!
    
    /// Views to detect if user is tapping back or forward
    var leftRect: CGRect! // back
    var rightRect: CGRect!  // forward
    
    //The Info View for the username/time/profile image
    var infoView: UIView!
    var infoImageView: UIImageView!
    var infoNameLabel: UILabel!
    var infoTimeLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // App enter in forground.
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        playerController.player?.play()
    }
    
    // App enter in forground.
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        playerController.player?.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the observers to stop the video from freezing when the app goes to the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        tapInfoView = UITapGestureRecognizer(target: self, action: #selector(self.tapInfoViewPressed(_:)))
        swipeInfoView = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedInfoView(_:)))
        
        tapInfoView.numberOfTapsRequired = 1
        swipeInfoView.direction = .down
        
        // Setup the views for detecting back and forward taps
        let width = self.view.frame.width / 4
        leftRect = CGRect(x: 0, y: 0, width: width, height: self.view.frame.height)
        rightRect = CGRect(x: self.view.frame.maxX - width, y: 0, width: width, height: self.view.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the observers
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
        
        // CLEAN EVERYTHING UP
        if spb != nil {
            spb.removeFromSuperview()
            playerController.view.removeFromSuperview()
            imageView.removeFromSuperview()
            infoView.removeFromSuperview()
            
            infoImageView.image = nil
            playerController.player = nil
            playerController = nil
            imageView = nil
            spb = nil
            
            infoNameLabel.text = ""
            infoTimeLabel.text = ""
        }
        
        // Since user is leaving stories we need to save their current index for what story they are on
        UserService.setCurrentIndexOfStory(currentIndex: currentIndex, eventId: eventKey, completion: { (user) in
            
            if user != nil {
                print("worked")
            }
        })
    }
    
    @IBAction func tapInfoViewPressed(_ sender: AnyObject) {
        let tapLocation = sender.location(in: self.view)
        handleTap(tappedLocation: tapLocation)
    }
    
    @IBAction func swipedInfoView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// Handle left and right taps aka back and forward taps
    ///
    /// - Parameter tapLocation: where the user tapped
    private func handleTap(tappedLocation: CGPoint) {
        
        if rightRect.contains(tappedLocation) {
            // next pressed
            
            let tempIndex = currentIndex + 1
            
            if tempIndex < allStories.count {
                
                // you can go to the next story
                playerController.player = nil
                infoImageView.image = nil
                infoNameLabel.text = ""
                infoTimeLabel.text = ""
                
                self.spb.skip()
                
            } else {
                // reached end of story so repeat
                segmentedProgressBarFinished()
            }
            
        } else if leftRect.contains(tappedLocation) {
            // back pressed
            
            if currentIndex > 0 {
                
                // you can go back
                isRewinding = true
                
                playerController.player = nil
                infoImageView.image = nil
                infoNameLabel.text = ""
                infoTimeLabel.text = ""
                
                self.spb.rewind()
                
            } else {
                //can't go back so leave the story vc
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// Get the stories
    fileprivate func fetchStories(){
        
        StoryService.showEvent(for: self.eventKey) { (stories) in
            
            // reset the current index
            self.currentIndex = 0
            
            // clear the arrays
            self.allStories.removeAll()
            self.durations.removeAll()
            
            self.allStories = stories
            
            if self.allStories.count > 0 {
                
                // Loop through the stories and get their duration
                for s in self.allStories {
                    if s.Url.contains(".mp4") {
                        
                        let videoUrl = URL(string: s.Url)
                        
                        let asset = AVAsset(url: videoUrl!)
                        let secAsset = CMTimeGetSeconds(asset.duration)
                        self.durations.append(secAsset)
                        
                    } else {
                        //IMAGE DURATION - CURRENTLY AT 5 SECONDS
                        self.durations.append(5)
                    }
                }
                
                self.playStories()
                
            } else {
                // No stories
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    /// Setup the view for stories
    private func setupViews() {
        
        // Setup the blur view for loading
        blurView = UIVisualEffectView(frame: view.frame)
        blurView.effect = UIBlurEffect(style: .regular)
        
        self.view.addSubview(blurView)
        
        // Indicator for loading
        let indicatorFrame = CGRect(x: view.center.x - 20, y: view.center.y - 20, width: 40, height: 40)
        indicator = UIActivityIndicatorView(frame: indicatorFrame)
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .whiteLarge
        
        blurView.contentView.addSubview(indicator)
        
        // Setup the Progress bar
        spb = SegmentedProgressBar(numberOfSegments: allStories.count)
        spb.frame = CGRect(x: 0, y: 1, width: self.view.frame.width, height: 9)
        self.view.addSubview(spb)
        
        spb.delegate = self
        
        // Player Controller
        playerController = AVPlayerViewController()
        playerController.showsPlaybackControls = false
        
        self.addChildViewController(playerController)
        
        // Image view for the story
        imageView = UIImageView(frame: self.view.frame)
        
        infoView = UIView(frame: self.view.frame)
        infoView.backgroundColor = UIColor.clear

        // The image view for the user of the current story
        let infoImageViewFrame = CGRect(x: 10, y: 17, width: 30, height: 30)
        
        infoImageView = UIImageView(frame: infoImageViewFrame)
        infoImageView.layer.cornerRadius = 15
        infoImageView.layer.masksToBounds = true
        
        self.view.addSubview(imageView)
        self.view.addSubview(playerController.view)
        self.view.bringSubview(toFront: spb)
        
        self.view.addSubview(infoView)
        
        self.infoView.addSubview(infoImageView)
        
        // The name for the user of the current story
        let infoNameLabelFrame = CGRect(x: infoImageView.frame.origin.x + infoImageView.frame.width + 5, y: 17, width: 80, height: 30)
        infoNameLabel = UILabel(frame: infoNameLabelFrame)
        infoNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        infoNameLabel.textColor = UIColor.white
        infoNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        infoNameLabel.adjustsFontSizeToFitWidth = true
        
        self.infoView.addSubview(infoNameLabel)
        
        // Time label for long ago the story was posted
        let infoTimeLabelFrame = CGRect(x: infoNameLabel.frame.origin.x + infoNameLabel.frame.width + 10, y: 17, width: 50, height: 30)
        infoTimeLabel = UILabel(frame: infoTimeLabelFrame)
        infoTimeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        infoTimeLabel.textColor = UIColor.white
        
        self.infoView.addSubview(infoTimeLabel)
        
        infoView.isUserInteractionEnabled = true
        infoView.addGestureRecognizer(tapInfoView)
        infoView.addGestureRecognizer(swipeInfoView)
        
        infoTimeLabel.layer.cornerRadius = 10
        infoTimeLabel.layer.masksToBounds = true
        infoTimeLabel.textAlignment = .center
        
        infoNameLabel.layer.cornerRadius = 10
        infoNameLabel.layer.masksToBounds = true
        infoNameLabel.textAlignment = .center
        
        playerController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        playerController.view.frame = view.frame
        
        spb.durations = durations
    }
    
    private func playStories() {
        
        self.setupViews()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            // Get the current index for what story the user left on if it exists
            UserService.getCurrentIndexOfStory(eventId: eventKey, userId: uid, completion: { (savedIndex) in
                
                if var savedIndex = savedIndex {
                    
                    if savedIndex >= self.allStories.count {
                        savedIndex = 0
                    }
                    
                    self.currentIndex = savedIndex
                    self.spb.savedIndex = savedIndex
                    
                    // if the current index isn't equal to 0 then skip to the correct story and bar
                    if self.currentIndex != 0 {
                        self.spb.skipBars(number: self.currentIndex - 1)
                    }
                }
                let story = self.allStories[self.currentIndex]
                
                self.getStoryInfo(story: story)
                self.playStory(story: story, isFirst: true)
            })
        }
    }
    
    
    /// Freeze the view until the video is loaded
    private func freezeViewsUntilLoaded() {
        if playerController != nil {
            playerController.view.isUserInteractionEnabled = false
            imageView.isUserInteractionEnabled = false
        }
    }
    
    /// Unfreeze the view
    private func unfreeze() {
        if playerController != nil {
            playerController.view.isUserInteractionEnabled = true
            imageView.isUserInteractionEnabled = true
        }
    }
    
    //SEGMENT BAR DELEGATES
    func segmentedProgressBarFinished() {
        currentIndex = 0
        
        // finished the story so set the onRepeat flag to true
        onRepeat = true
        
        // reset the progress bar
        spb.reset()
    }
    
    
    /// Delegate called everytime the progressbar index is changed
    ///
    /// - Parameter index: new index
    func segmentedProgressBarChangedIndex(index: Int) {
        
        spb.isPaused = true
        
        if playerController.player != nil {
            playerController.player = nil
        }
        
        // Update the flags and the current index
        if isRewinding {
            currentIndex -= 1
            isRewinding = false
            
        } else if isForwarding {
            return
            
        } else if onRepeat {
            onRepeat = false
            
        } else {
            currentIndex += 1
        }
        
        // if the current index is greater than the stories array count then the user finished viewing
        if currentIndex < allStories.count {
            let story = allStories[currentIndex]
            getStoryInfo(story: story)
            playStory(story: story, isFirst: false)
            
        } else {
            segmentedProgressBarFinished()
        }
        
    }
    
    
    /// Get the user info from the story
    ///
    /// - Parameter story: the current story
    private func getStoryInfo(story: Story) {
        
        // setup the time label
        setupTimeLabel(date: story.date)
        
        UserService.show(forUID: story.uid) { (user) in
            
            if let user = user {
                // Set the name label to the username
                self.infoNameLabel.text = user.username
                
                let imageUrl = URL(string: user.profilePic!)
                
                if user.profilePic != "" {
                    print("Tried to load default pic")
                    // Set the image view to the current users profile image
                    self.infoImageView.af_setImage(withURL: imageUrl!)
                    
                } else {
                    print("Set image Url")
                    self.infoImageView.image = UIImage(named: "no-profile-pic")
                }
                
            } else {
                //user doesnt exist for some reason
                print("the user doesnt exist in the database...")
            }
            
        }
    }
    
    
    /// Play the story
    ///
    /// - Parameters:
    ///   - story: the current story
    ///   - isFirst: flag to see if its the first story
    private func playStory(story: Story, isFirst: Bool) {
        
        // Check if the url is a video or image
        if story.Url.contains(".mp4") {
            // video
            self.playerController.view.isHidden = false
            self.view.bringSubview(toFront: playerController.view)
            self.view.bringSubview(toFront: spb)
            self.view.bringSubview(toFront: infoView)
            
            let videoUrl = URL(string: story.Url)
            playerController.player = AVPlayer(url: videoUrl!)
            
            // Freeze the view from user interaction and show the loader
            freezeViewsUntilLoaded()
            showLoader()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.unfreeze()
                
                self.hideLoader()
                
                if self.playerController != nil {
                    self.playerController.player?.play()
                    
                    // If this is the first story that the user is watching than start the animation
                    // for the progress bar else unpause the progress bar if its not the first story
                    if isFirst {
                        self.spb.startAnimationAt(index: self.currentIndex)
                    } else {
                        self.spb.isPaused = false
                    }
                }
                
            })
            
        } else {
            // photo
            self.view.bringSubview(toFront: imageView)
            self.view.bringSubview(toFront: spb)
            self.view.bringSubview(toFront: infoView)
            
            let url = URL(string: story.Url)
            let data = try! Data(contentsOf: url!)
            let image = UIImage(data: data)
            
            showLoader()
            
            self.spb.currentAnimationIndex = self.currentIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                
                self.hideLoader()
                
                // If this is the first story that the user is watching than start the animation
                // for the progress bar else unpause the progress bar if its not the first story
                if isFirst {
                    self.spb.startAnimationAt(index: self.currentIndex)
                } else {
                    self.spb.isPaused = false
                }
                
                self.imageView.image = image
                
            })
            
        }
    }
    
    
    /// Setup up the time label for the current story
    ///
    /// - Parameter date: the upload date of the current story
    private func setupTimeLabel(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        let start = dateFormatter.date(from: date)
        let minutes = Int(Date().since(start!, in: .minute))
        
        // Format the date
        if minutes > 60 {
            let hours = minutes / 60
            
            if hours < 24 {
                infoTimeLabel.text = "\(hours)hr"
                
            } else {
                let days = Int(Date().since(start!, in: .day))
                infoTimeLabel.text = "\(days)d"
            }
            
        } else {
            infoTimeLabel.text = "\(minutes)min"
        }
    }
    
    private func showLoader() {
        blurView.alpha = 1
        self.view.bringSubview(toFront: blurView)
        indicator.startAnimating()
    }
    
    private func hideLoader() {
        UIView.animate(withDuration: 0.40, animations: {
            self.blurView.alpha = 0
            self.indicator.stopAnimating()
        }) { (complete) in
            self.view.sendSubview(toBack: self.blurView)
        }
        
    }
    
}
