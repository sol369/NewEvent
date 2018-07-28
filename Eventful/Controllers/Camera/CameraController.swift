import Foundation
import SwiftyCam
import UIKit
import RecordButton

class CameraViewController: SwiftyCamViewController {
    
    var eventKey = ""
    var timer: Timer?
    var stackView: UIStackView?

    let captureButton : SwiftyRecordButton = {
        let captureButton = SwiftyRecordButton()
//        captureButton.setImage(#imageLiteral(resourceName: "Trigger"), for: .normal)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Tap))  //Tap function will call when user tap on button
//        tapGesture.delegate = self
//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector( captureAction(_:))) //Long function will call when user long press on button.
//        longGesture.delegate = self
//        tapGesture.numberOfTapsRequired = 1
//        captureButton.addGestureRecognizer(tapGesture)
//        captureButton.addGestureRecognizer(longGesture)
        return captureButton
    }()
    
    
    
    
    
    
    lazy var cancelButton : UIButton = {
        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "Back"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return cancelButton
    }()
    
    lazy var flashButton : UIButton = {
       let flashButton = UIButton()
        flashButton.setImage(#imageLiteral(resourceName: "Torch"), for: UIControlState())
        flashButton.addTarget(self, action: #selector(toggleFlashAction(_:)), for: .touchUpInside)
        return flashButton
    }()
    
    lazy var flipCameraButton : UIButton = {
        let flipCameraButton = UIButton()
        flipCameraButton.setImage(#imageLiteral(resourceName: "flip"), for: UIControlState())
        flipCameraButton.addTarget(self, action: #selector(cameraSwitchAction(_:)), for: .touchUpInside)
        return flipCameraButton
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        downSwipe.direction = .down
        view.addGestureRecognizer(downSwipe)
        // Setting the camera delegate
        cameraDelegate = self
        self.videoQuality = .high
        // Setting maximum duration for video
        maximumVideoDuration = 10.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = false
        audioEnabled = true
        addButtons()
        
    }
    
    @objc func swipeAction(_ swipe: UIGestureRecognizer){
        if let swipeGesture = swipe as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                break
            case UISwipeGestureRecognizerDirection.down:
                dismiss(animated: true, completion: nil)
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    
    @objc private func Tap(_ sender: Any) {
        takePhoto()
    }
 
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let containerView = PreviewPhotoContainerView()
        view.addSubview(containerView)
        containerView.previewImageView.image =  photo
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        captureButton.delegate = self
//        captureButton.isSelected = true
        //Hiding tab bar to allow the Camera view to be full screen
    }
    
    // MARK: - Action Functions (Buttons)
    
    // Function which controls the camera switch button
    @objc private func cameraSwitchAction(_ sender: Any) {
        switchCamera()
    }
    
    // Function which controls the flash button
    @objc private func toggleFlashAction(_ sender: Any) {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "Torch2"), for: UIControlState())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "Torch"), for: UIControlState())
        }
    }
    
    // Function which controls the cancel button
    @objc private func cancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    // Function which controls that capture button
    @objc private func captureAction(_ sender: UIGestureRecognizer){
        if sender.state == .began {
            print("Long tap recognized")
            startVideoRecording()
            timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }else if sender.state == .ended {
            stopVideoRecording()
        }
    }
    
    
    @objc func update()
    {
        stopVideoRecording()
    }
    // Adding buttons programatically to the Camera view
    private func addButtons() {
        self.view.addSubview(captureButton)
        
        stackView = UIStackView(arrangedSubviews: [ cancelButton, flipCameraButton,flashButton])
        stackView?.axis = .vertical
        stackView?.distribution = .fillEqually
        stackView?.spacing = 15.0
        if let firstStackView = stackView{
            self.view.addSubview(firstStackView)
            firstStackView.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(15)
            }
        }
        
        captureButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.height.width.equalTo(75)
        }

        

    }
}

// MARK: - SwiftyCamViewControllerDelegate
extension CameraViewController : SwiftyCamViewControllerDelegate
{
    //Allows camera to take images if allowed
    
    
   func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print(camera)
    }
    
    //Functin called when startVideoRecording() is called
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        captureButton.growButton()
        UIView.animate(withDuration: 0.25, animations: {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
            self.cancelButton.alpha = 0.0
        })
    }
    
    // Function called when stopVideoRecording() is called
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
         captureButton.shrinkButton()
//        timer?.invalidate()
        UIView.animate(withDuration: 0.25, animations: {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
            self.cancelButton.alpha = 1.0
        })
    }
    //look here
    
    // Function called once recorded has stopped. The URL for the video gets returned here.
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // I am passing the url to VideoViewController to show the video
        let videoPlayBackVC = VideoViewController()
        videoPlayBackVC.videoURL = url
        present(videoPlayBackVC, animated: true, completion: nil)
        videoPlayBackVC.eventKey = self.eventKey
        present(videoPlayBackVC, animated: true, completion: nil)
    }
    
    // Function which allows you to zoom. Added animation for User/UI purposes
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
    }
}
