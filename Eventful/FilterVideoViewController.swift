//
//  FilterVideoViewController.swift
//  InstagramFilter
//
//  Created by James Fong on 2018-01-05.
//  Copyright © 2018 James Fong. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import Photos
import SnapSliderFilters
import ColorSlider
import AZDialogView
import SVProgressHUD


public protocol FilterVideoViewControllerDelegate {
    func filterVideoViewControllerVideoDidFilter(video: AVURLAsset)
    func filterVideoViewControllerDidCancel()
}

class FilterVideoViewController: FiilterViewController {
    
    /// The current event
    var event: Event? {
        didSet {
            print("event set ")
            if let key = event?.key {
                eventKey = key
            }
        }
    }
    
    /// The current event key
    var eventKey = ""
    
    /// Delegate for the FilterVideoViewController
    public var delegate: FilterVideoViewControllerDelegate?
    
    /// The text field
    var textfield: SNTextField!
    
    /// Color slider to change text color
    var colorSlider: ColorSlider!
    
    /// View to show text field when user taps on this view
    var tapView: UIView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
    
    lazy var filterNameLabel: UILabel = {
        let frame = CGRect(x: view.center.x - 100, y: 20, width: 200, height: 40)
        let filterNameLabel = UILabel(frame: frame)
        filterNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        filterNameLabel.textColor = .white
        filterNameLabel.text = "No Filter"
        filterNameLabel.textAlignment = .center
        filterNameLabel.layer.cornerRadius = 10
        filterNameLabel.adjustsFontSizeToFitWidth = true
        return filterNameLabel
    }()
    
    @IBOutlet weak var videoView: UIView!
    
    // video player
    fileprivate var avpController: AVPlayerViewController!

    fileprivate var playerItem: AVPlayerItem!
    fileprivate var videoPlayer:AVPlayer?
    fileprivate var video: AVURLAsset?
    fileprivate var originalImage: UIImage?
    
    /// The composition for the current video playing
    fileprivate var avVideoComposition: AVVideoComposition!

    // App enter in forground.
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        videoPlayer?.play()
    }
    
    // App enter in forground.
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        videoPlayer?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the observers
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the observers to stop the video from freezing when the app goes to the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let video = self.video {
            self.playVideo(video:video, filterName: self.filterNameList[0])
        }
    }

    public init(video: AVURLAsset) {
        super.init(nibName: nil, bundle: nil)
        self.video = video
        self.image = video.videoToUIImage()
        self.originalImage = self.image
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func loadView() {
        guard let view = UINib(nibName: "FilterVideoViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        self.view = view
        
        if let image = self.image {
            imageView?.image = image
            smallImage = resizeImage(image: image)
        }
        
        // Setup the gestures for left and right swipes
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        leftSwipe.direction = .left
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        // Adding buttons programatically
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(15)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(shareButton)
        shareButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(10)
            make.height.width.equalTo(35)
        }
        
        view.addSubview(saveToAlbum)
        saveToAlbum.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(10)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(filterNameLabel)
        
        addFilterSliderAndTextField()
    }
    
    
    /// Add the text field and filter slider
    func addFilterSliderAndTextField() {
        textfield = SNTextField(y: SNUtils.screenSize.height/2, width: SNUtils.screenSize.width, heightOfScreen: SNUtils.screenSize.height)
        textfield.layer.zPosition = 100
        
        /// Setup the observers for the textfield
        NotificationCenter.default.addObserver(self.textfield, selector: #selector(SNTextField.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.textfield, selector: #selector(SNTextField.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self.textfield, selector: #selector(SNTextField.keyboardTypeChanged(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        // Setup the color slider
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.frame = CGRect(x: view.frame.maxX - 100, y: 30, width: 12, height: 150)
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    
    /// Called when the slider color is changed
    ///
    /// - Parameter slider: the color slider
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        // update the text color with the current colorslider color
        textfield.textColor = color
    }
    
    @objc func swipeAction(_ swipe: UIGestureRecognizer) {
        guard let swipeGesture = swipe as? UISwipeGestureRecognizer else { return }

        switch swipeGesture.direction {
            
        case UISwipeGestureRecognizerDirection.right:
            print("Swiped right")
            
            // Update the filterIndex for the current filter the user is on
            if filterIndex == 0 {
                filterIndex = filterNameList.count - 1
            } else {
                filterIndex -= 1
            }
            
            if filterIndex != 0 {
                applyFilter()
            } else {
                imageView?.image = image
            }
            
            updateCellFont()
            scrollCollectionViewToIndex(itemIndex: filterIndex)
            
            filterNameLabel.text = filterNameList[filterIndex]
            
            break
        case UISwipeGestureRecognizerDirection.left:
            print("Swiped left")
            
            if filterIndex == filterNameList.count - 1 {
                filterIndex = 0
                imageView?.image = image
            } else {
                filterIndex += 1
            }
            if filterIndex != 0 {
                applyFilter()
            }
            updateCellFont()
            scrollCollectionViewToIndex(itemIndex: filterIndex)
            
            filterNameLabel.text = filterNameList[filterIndex]
            
            break
        default:
            break
        }
    }
    
    
    /// Play the video with the filter
    ///
    /// - Parameters:
    ///   - video: the video to play
    ///   - filterName: the name of the filter to add over the video
    func playVideo(video:AVURLAsset, filterName:String) {
        let avPlayerItem = AVPlayerItem(asset: video)
        
        if (filterIndex != 0) {
            avVideoComposition = AVVideoComposition(asset: self.video!, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                let filter = CIFilter(name:filterName)!
                filter.setDefaults()
                filter.setValue(source, forKey: kCIInputImageKey)
                let output = filter.outputImage!
                request.finish(with:output, context: nil)
            })
            
            avPlayerItem.videoComposition = avVideoComposition
            
        } else {
            // No Filter
            avVideoComposition = AVVideoComposition(asset: self.video!, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                request.finish(with: source, context: nil)
            })
            avPlayerItem.videoComposition = avVideoComposition
        }

        
        if self.videoPlayer == nil {
            self.videoPlayer = AVPlayer(playerItem: avPlayerItem)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.videoPlayer
            self.avpController.view.frame = self.videoView.bounds
            
            self.addChildViewController(avpController)
            
            self.videoView.addSubview(avpController.view)
            
            // Add the tap gesture to the TapView
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapGesture.delegate = self
            
            tapView = UIView(frame: view.frame)
            tapView.backgroundColor = .clear
            tapView.isUserInteractionEnabled = true
            tapView.addGestureRecognizer(tapGesture)
            
            tapView.addSubview(textfield)
            tapView.addSubview(colorSlider)
            
            self.videoView.addSubview(tapView)
            
        } else {
            videoPlayer?.replaceCurrentItem(with: avPlayerItem)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.videoPlayer?.currentItem)

        
        avpController.showsPlaybackControls = false
        
        avVideoComposition = videoPlayer?.currentItem?.videoComposition
        
        videoPlayer?.play()
    }
    
    
    /// Add the filter and play the video
    override func applyFilter() {
        let filterName = filterNameList[filterIndex]
        if let image = self.image {
            self.originalImage = createFilteredImage(filterName: filterName, image: image)
        }
        if let video = self.video {
            self.playVideo(video:video, filterName:filterNameList[filterIndex])
        }
    }
    
    
    /// Create the filtered for the video
    ///
    /// - Parameters:
    ///   - filterName: the name of the filter to use
    ///   - image: image of the start of the video
    /// - Returns: return the filtered image
    override func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        if(filterName == filterNameList[0]){
            return self.image!
        }
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!, scale: image.scale, orientation: image.imageOrientation)
        
        return filteredImage
    }
   
    /// Close the view
    @IBAction func closeButtonTapped() {
        if let delegate = self.delegate {
            delegate.filterVideoViewControllerDidCancel()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtontapped() {
        video?.exportFilterVideo(videoComposition: avVideoComposition , completion: { (url) in
            if let delegate = self.delegate {
                let convertedVideo = AVURLAsset(url: url as URL!)
                delegate.filterVideoViewControllerVideoDidFilter(video: convertedVideo)
            }
        })
        dismiss(animated: true, completion: nil)
    }
    
    // Allows the video to keep playing on a loop
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if videoPlayer != nil {
            videoPlayer?.seek(to: kCMTimeZero)
            videoPlayer?.play()
        }
    }
    
    //Function to convert uiview to uiimage
    private func imageWithView(inView: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(inView.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            inView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
    
}

extension FilterVideoViewController: UIGestureRecognizerDelegate {
    
    @objc func handleTap() {
        self.textfield.handleTap()
    }
}

// will hold all of the functions that correspond to the buttons
extension FilterVideoViewController {
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAdd() {
        print("Next Button pressed")
        
        if let currentEvent = event, let username = User.current.username {
            let dialog = AZDialogViewController(title: "\(username)", message: "Are you sure you want to add to the Haipe surrounding the \(currentEvent.currentEventName.capitalized) with your video?")
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
            dialog.show(in: self)
        }
    }
    
    @objc func handleSave() {
        print("Attempting to save photo")
        
        
        guard let outputFileURL = video?.url else {
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Save the movie file to the photo library and cleanup.
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                }, completionHandler: { success, error in
                    if !success {
                        print("Could not save movie to photo library: \(String(describing: error))")
                    }
                    
                    DispatchQueue.main.async {
                        let savedLabel = UILabel()
                        savedLabel.text = "Saved Successfully"
                        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                        savedLabel.textColor = .white
                        savedLabel.numberOfLines = 0
                        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                        savedLabel.textAlignment = .center
                        
                        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                        savedLabel.center = self.view.center
                        
                        self.view.addSubview(savedLabel)
                        
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
                )
            } else {
            }
        }
    }
    
    
    /// Add the story to firebase
    func handleAddToStory() {
        print("Attempting to add to story")
        
        // hide the color slider so we can return the image of the tapView that contains the text field if they added one
        colorSlider.isHidden = true
        let videoImage = self.imageWithView(inView: self.tapView)
        colorSlider.isHidden = false
        
        // Show the loader
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.gradient)
        
        // Export the video
        video?.exportFilterVideo(videoComposition: avVideoComposition , completion: { (url) in
            
            if let videoImage = videoImage {
                
                let filterVideoAsset = AVAsset(url: url! as URL)
                
                // Now merge the filtered video with tapView image which will contain the textfield if the user added one
                Merge(config: .standard).overlayVideo(video: filterVideoAsset, overlayImage: videoImage, completion: { (finalVideoUrl) in
                    
                    // Upload to firebase storage
                    let dateFormatter = ISO8601DateFormatter()
                    let timeStamp = dateFormatter.string(from: Date())
                    let uid = User.current.uid
                    let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".mp4")
                    StorageService.uploadVideo(finalVideoUrl! as URL, at: storageRef) { (downloadUrl) in
                        guard let downloadUrl = downloadUrl else {
                            return
                        }
                        
                        let videoUrlString = downloadUrl.absoluteString
                        print(videoUrlString)
                        // Post to firebase
                        PostService.create(for: self.eventKey, for: videoUrlString)
                    }
                    
                    //svprogresshud insert here
                    SVProgressHUD.dismiss(completion: {
                        self.dismiss(animated: true, completion: nil)
                        self.videoPlayer?.replaceCurrentItem(with: nil)
                    })
                    
                }, progressHandler: { _ in })
                
                
            } else {
                
                let dateFormatter = ISO8601DateFormatter()
                let timeStamp = dateFormatter.string(from: Date())
                let uid = User.current.uid
                let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".mp4")
                StorageService.uploadVideo(url! as URL, at: storageRef) { (downloadUrl) in
                    guard let downloadUrl = downloadUrl else {
                        return
                    }
                    
                    let videoUrlString = downloadUrl.absoluteString
                    print(videoUrlString)
                    PostService.create(for: self.eventKey, for: videoUrlString)
                }
                //svprogresshud insert here
                SVProgressHUD.dismiss(completion: {
                    self.dismiss(animated: true, completion: nil)
                    self.videoPlayer?.replaceCurrentItem(with: nil)
                })
                
            }
            
        })
        
    }
    
    func handleDontAddToStory() {
        dismiss(animated: true, completion: nil)
        videoPlayer?.replaceCurrentItem(with: nil)
    }
    
    
    
    
}
