//
//  FilterImageViewController.swift
//  InstagramFilter
//
//  Created by James Fong on 2018-01-05.
//  Copyright © 2018 James Fong. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import Photos
import AZDialogView

import SnapSliderFilters
import ColorSlider

public protocol FilterImageViewControllerDelegate {
    func filterImageViewControllerImageDidFilter(image: UIImage)
    func filterImageViewControllerDidCancel()
}

class FilterImageViewController: FiilterViewController {
    
    var event: Event? {
        didSet {
            print("event set ")
            if let key = event?.key {
                eventKey = key
            }
        }
    }
    
    var eventKey = ""
    
    var textfield: SNTextField!
    var colorSlider: ColorSlider!
    
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
    
    
    public var delegate: FilterImageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    public init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func loadView() {
        if let view = UINib(nibName: "FilterImageViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
            if let image = self.image {
                imageView?.image = image
                smallImage = resizeImage(image: image)
            }
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
            leftSwipe.direction = .left
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
            rightSwipe.direction = .right
            
            view.addGestureRecognizer(leftSwipe)
            view.addGestureRecognizer(rightSwipe)
            
            // add these last so there clickable
            view.addSubview(cancelButton)
            cancelButton.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(15)
                make.height.width.equalTo(40)
            }
            
            view.addSubview(saveToAlbum)
            saveToAlbum.snp.makeConstraints { (make) in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(10)
                make.height.width.equalTo(40)
            }
            
            view.addSubview(shareButton)
            shareButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
                make.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(10)
                make.height.width.equalTo(35)
            }
            
            view.addSubview(filterNameLabel)
            
            addFilterSliderAndTextField()

        }
    }
    
    func addFilterSliderAndTextField() {
        
        textfield = SNTextField(y: SNUtils.screenSize.height/2, width: SNUtils.screenSize.width, heightOfScreen: SNUtils.screenSize.height)
        textfield.layer.zPosition = 100
        view.addSubview(textfield)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self.textfield, selector: #selector(SNTextField.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.textfield, selector: #selector(SNTextField.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self.textfield, selector: #selector(SNTextField.keyboardTypeChanged(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
        colorSlider.frame = CGRect(x: view.frame.maxX - 40, y: 30, width: 12, height: 150)
        view.addSubview(colorSlider)
        
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        textfield.textColor = color
    }
    
    @objc func swipeAction(_ swipe: UIGestureRecognizer){
        
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                
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
    }
    
    override func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
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
    
    @IBAction func closeButtonTapped() {
        if let delegate = self.delegate {
            delegate.filterImageViewControllerDidCancel()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtontapped() {
        if let delegate = self.delegate {
            delegate.filterImageViewControllerImageDidFilter(image: (imageView?.image)!)
        }
       dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave(){
        print("Attempting to save photo")

        shareButton.isHidden = true
        saveToAlbum.isHidden = true
        cancelButton.isHidden = true
        colorSlider.isHidden = true
        filterNameLabel.isHidden = true
        
        guard let previewImage = SNUtils.screenShot(self.view) else {
            return
        }
        
        shareButton.isHidden = false
        saveToAlbum.isHidden = false
        cancelButton.isHidden = false
        colorSlider.isHidden = false
        filterNameLabel.isHidden = false
        
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
    }
    
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
            
            dialog.show(in: self)
        }
    }

    @objc func handleAddToStory(){
        saveToAlbum.isHidden = true
        cancelButton.isHidden = true
        colorSlider.isHidden = true
        colorSlider.isHidden = true
        filterNameLabel.isHidden = true
        shareButton.isHidden = true
        
        guard let currentImage = SNUtils.screenShot(self.view) else {
            return
        }
        
        saveToAlbum.isHidden = false
        cancelButton.isHidden = false
        colorSlider.isHidden = false
        colorSlider.isHidden = false
        filterNameLabel.isHidden = false
        shareButton.isHidden = false
        
        //guard let currentImage = imageView?.image else { return }
        
        print("Attempting to add to story")
        print(self.eventKey)
        
        let dateFormatter = ISO8601DateFormatter()
        let timeStamp = dateFormatter.string(from: Date())
        let uid = User.current.uid
        let storageRef = Storage.storage().reference().child("event_stories").child(self.eventKey).child(uid).child(timeStamp + ".PNG")
        StorageService.uploadImage(currentImage, at: storageRef) { (downloadUrl) in
            guard let downloadUrl = downloadUrl else {
                return
            }
            let videoUrlString = downloadUrl.absoluteString
            print(videoUrlString)
            PostService.create(for: self.eventKey, for: videoUrlString)
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Added Successfully"
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
                        self.dismiss(animated: true, completion: nil)
                        //self.removeFromSuperview()
                    })
                    
                })
            }
        }
        
    }
}

extension FilterImageViewController: UIGestureRecognizerDelegate {
    
    @objc func handleTap() {
        self.textfield.handleTap()
    }
}
