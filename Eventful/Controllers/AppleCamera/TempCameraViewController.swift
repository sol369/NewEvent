//
//  TempCameraViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 5/19/18.
//  Copyright © 2018 Make School. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation
import RecordButton
import SVProgressHUD

var arrCameraPreferences = [String]()
var backCameraResolution = CGSize.zero
var frontCameraResolution = CGSize.zero
var isRecordingStartedWithBackCamera = true

class TempCameraViewController: UIViewController {
    var event: Event?{
        didSet {
            print("event set")
        }
    }
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    private var setupResult: SessionSetupResult = .success
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoURLArr = [URL]()
    var isRecordingStopped: Bool = true
    var isBackCamera: Bool = true

    var flashMode = AVCaptureDevice.FlashMode.off
    fileprivate var flashView:UIView?
    
    /// Returns true if the torch (flash) is currently enabled
    
    fileprivate var isCameraTorchOn              = false
    //allows tapToFocus fuctionality
    var tapToFocus = true;
    //will control the zoom in and out feature
    public var maxZoomScale = CGFloat.greatestFiniteMagnitude
    /// Variable for storing current zoom scale
    fileprivate var zoomScale = CGFloat(1.0)
    /// Variable for storing initial zoom scale before Pinch to Zoom begins
    fileprivate var beginZoomScale = CGFloat(1.0)
    
    /// Public access to Pinch Gesture
    fileprivate(set) public var pinchGesture  : UIPinchGestureRecognizer!
    
    // MARK: Capturing Photos
    
    private let photoOutput = AVCapturePhotoOutput()
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off
    
    
    // MARK: Recording Movies
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    private var outputURL: URL!
    
    let recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    
    
    
    /// Sets wether the taken photo or video should be oriented according to the device orientation
    public var shouldUseDeviceOrientation      = false
    
    /// Last changed orientation
    
    fileprivate var deviceOrientation:UIDeviceOrientation?
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
                                                                               mediaType: .video, position: .unspecified)
    // MARK: KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    
    
    var stackView: UIStackView?
    var stackView2: UIStackView?
    let captureButton : UIButton = {
        let captureButton = UIButton()
        captureButton.setImage(#imageLiteral(resourceName: "Trigger"), for: .normal)
        captureButton.addTarget(self, action: #selector(capturePhoto(_:)), for: .touchUpInside)
        
        return captureButton
    }()
    
    let resumeButton : UIButton = {
        let resumeButton = UIButton()
        resumeButton.setTitle("Resume", for: .normal)
        resumeButton.addTarget(self, action: #selector(resumeInterruptedSession(_:)), for: .touchUpInside)
        return resumeButton
    }()
    
    let cameraUnavailableLabel : UILabel =  {
        let cameraUnavailableLabel = UILabel()
        cameraUnavailableLabel.font = UIFont(name:"HelveticaNeue", size: 30.5)
        cameraUnavailableLabel.textAlignment = .center
        cameraUnavailableLabel.text = "Camera Unavaialble"
        return cameraUnavailableLabel
    }()
    
    lazy var cancelButton : UIButton = {
        let cancelButton = UIButton()
        cancelButton.setImage(UIImage(named: "icons8-left-60"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return cancelButton
    }()
    
    // Function which controls the cancel button
    @objc private func cancel()
    {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var capturePreviewView: PreviewView = {
        let capturePreviewView =  PreviewView()
        return capturePreviewView
    }()
    
    lazy var flashButton : UIButton = {
        let flashButton = UIButton()
        flashButton.setImage(UIImage(named: "icons8-the-flash-sign-60"), for: UIControlState())
        flashButton.addTarget(self, action: #selector(toggleFlashAction(_:)), for: .touchUpInside)
        return flashButton
    }()
    
    // Function which controls the flash button
    @objc private func toggleFlashAction(_ sender: Any) {
        if self.flashMode == .on {
            self.flashMode = .off
 flashButton.setImage(UIImage(named: "icons8-the-flash-sign-60"), for: UIControlState())
            
        }
            
        else {
            self.flashMode = .on
 flashButton.setImage(UIImage(named: "icons8-the-flash-sign-filled-60"), for: UIControlState())
            
        }
    }
    
    lazy var flipCameraButton : UIButton = {
        let flipCameraButton = UIButton()
        flipCameraButton.setImage(UIImage(named: "icons8-switch-camera-60"), for: UIControlState())
        flipCameraButton.addTarget(self, action: #selector(changeCamera(_:)), for: .touchUpInside)
        return flipCameraButton
    }()
    
    lazy var cameraButton : UIButton = {
        let cameraButton = UIButton()
        cameraButton.setImage(#imageLiteral(resourceName: "icons8-instagram-filled-50"), for: UIControlState())
        cameraButton.addTarget(self, action: #selector(setupPhotoSession(_:)), for: .touchUpInside)
        return cameraButton
    }()
    
    lazy var videoButton : UIButton = {
        let videoButton = UIButton()
        videoButton.setImage(#imageLiteral(resourceName: "icons8-documentary-filled-50"), for: UIControlState())
        videoButton.addTarget(self, action: #selector(setupVideoRecord(_:)), for: .touchUpInside)
        return videoButton
    }()
    
    //Intro View
    var introView: UIView?
    
    // MARK: Status Bar Presence
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.setupVC()
        }
        
        // Disable UI. The UI is enabled if and only if the session starts running.
        captureButton.isEnabled = false
        flashButton.isEnabled = false
        flipCameraButton.isEnabled = false
        cameraButton.isEnabled = false
        videoButton.isEnabled = false
        
        // Set up the video preview view.
        capturePreviewView.session = session
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    // Intro Tip View
    private func showTextIntroScreen() {
        DispatchQueue.main.async {
            if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.isFirstIntro.rawValue) {
                self.introView = UIView(frame: UIScreen.main.bounds)
                self.view.addSubview(self.introView!)
                
                //Showing Tip View
                self.applyGlobalTipViewConfiguration()
                
                let tipView = TipView()
                tipView.dismissClosure = { tipview in
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isFirstIntro.rawValue)
                    self.introView?.removeFromSuperview()
                    self.introView = nil
                }
                tipView.show(message: "Tap & Hold to Record",
                                     sourceView: self.recordButton,
                                     containerView: self.introView!,
                                     direction: TipView.Direction.top)
            }
        }
    }
    
    func applyGlobalTipViewConfiguration() {
        // Global configuration
        TipView.maxWidth = 160
        TipView.color = UIColor.darkGray
        TipView.font = UIFont.systemFont(ofSize: 14)
        TipView.enableDismissOnTapOverTip = true
        TipView.showAnimation = TipViewAnimation.showWithScale
        TipView.dismissAnimation = TipViewAnimation.dismissWithScale
        TipView.enableDismissOnTapOutsideTipInContainer = true
        TipView.enableDismissOnTapOutsideTipInContainer = true
    }
    
    // Call this on the session queue.
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        //session.automaticallyConfiguresApplicationAudioSession = false
        /*
         We do not create an AVCaptureMovieFileOutput when setting up the session because the
         AVCaptureMovieFileOutput does not support movie recording with AVCaptureSession.Preset.Photo.
         */
        session.sessionPreset = .photo
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
                isBackCamera = true
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If the back dual camera is not available, default to the back wide angle camera.
                defaultVideoDevice = backCameraDevice
                isBackCamera = true
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                /*
                 In some cases where users break their phones, the back wide angle camera is not available.
                 In this case, we should default to the front wide angle camera.
                 */
                defaultVideoDevice = frontCameraDevice
                isBackCamera = false
            }
            
            if defaultVideoDevice != nil {
                self.setCaptureResolution(isForBackCamera: isBackCamera, theDevice: defaultVideoDevice!)
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    /*
                     Why are we dispatching this to the main queue?
                     Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
                     can only be manipulated on the main thread.
                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.capturePreviewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
                
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            depthDataDeliveryMode = photoOutput.isDepthDataDeliverySupported ? .on : .off
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.captureButton.isEnabled = isSessionRunning
                self.flipCameraButton.isEnabled = isSessionRunning
                self.flashButton.isEnabled = isSessionRunning
                self.videoButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            resumeButton.isHidden = false
        }
    }
    
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios we want to enable the user to resume the session running.
         For example, if music playback is initiated via control center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in control center will not automatically resume the session
         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var showResumeButton = false
            
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Simply fade-in a label to inform the user that the camera is unavailable.
                cameraUnavailableLabel.alpha = 0
                cameraUnavailableLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel.alpha = 1
                }
            }
            
            if showResumeButton {
                // Simply fade-in a button to enable the user to try to resume the session running.
                resumeButton.alpha = 0
                resumeButton.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.resumeButton.alpha = 1
                }
            }
        }
    }
    
    @objc private func resumeInterruptedSession(_ resumeButton: UIButton) {
        sessionQueue.async {
            /*
             The session might fail to start running, e.g., if a phone or FaceTime call is still
             using audio or video. A failure to start the session running will be communicated via
             a session runtime error notification. To avoid repeatedly failing to start the session
             running, we only try to restart the session running in the session runtime error handler
             if we aren't trying to resume the session running.
             */
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            if !self.session.isRunning {
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.resumeButton.isHidden = true
                }
            }
        }
    }
    
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        
        if !resumeButton.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.resumeButton.alpha = 0
            }, completion: { _ in
                self.resumeButton.isHidden = true
            }
            )
        }
        if !cameraUnavailableLabel.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.cameraUnavailableLabel.alpha = 0
            }, completion: { _ in
                self.cameraUnavailableLabel.isHidden = true
            }
            )
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        recordButton.buttonState = .idle
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewLayerConnection = capturePreviewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                    return
            }
            
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    
    func setupVC(){
        addGestureRecognizers(on: capturePreviewView)
        view.addSubview(capturePreviewView)
        capturePreviewView.addSubview(captureButton)
        capturePreviewView.addSubview(recordButton)
        capturePreviewView.addSubview(resumeButton)
        
        capturePreviewView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        stackView = UIStackView(arrangedSubviews: [ cameraButton, videoButton])
        stackView?.axis = .vertical
        stackView?.distribution = .fillEqually
        stackView?.spacing = 15.0
        if let firstStackView = stackView{
            self.capturePreviewView.addSubview(firstStackView)
            firstStackView.snp.makeConstraints { (make) in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(15)
            }
        }
        
        stackView2 = UIStackView(arrangedSubviews: [ flashButton, flipCameraButton])
        stackView2?.axis = .vertical
        stackView2?.distribution = .fillEqually
        stackView2?.spacing = 15.0
        if let secondStackView = stackView2{
            self.capturePreviewView.addSubview(secondStackView)
            secondStackView.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(15)
                make.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(15)
            }
        }
        
        captureButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10.5)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.height.width.equalTo(65)
        }
        
        recordButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10.5)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.height.width.equalTo(65)
        }
        
        recordButton.isHidden = true
        
        resumeButton.snp.makeConstraints { (make) in
            make.center.equalTo(view.safeAreaLayoutGuide.snp.center)
        }
        resumeButton.isHidden = true
        
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(10)
            make.height.width.equalTo(40)
        }
        
    }
}

//will hold all of the enums
extension TempCameraViewController {
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
    
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}

//will hold most of the camera operations
// MARK: Camera Operations
extension TempCameraViewController {
    
    @objc func setupVideoRecord(_ sender: Any){
        
        sessionQueue.async {
            let movieFileOutput = AVCaptureMovieFileOutput()
            
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = .high
                if let connection = movieFileOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                    
                    connection.videoOrientation = .portrait
                    movieFileOutput.setRecordsVideoOrientationAndMirroringChangesAsMetadataTrack(true, for: connection)
                }
                self.session.commitConfiguration()
                
                DispatchQueue.main.async {
                    self.captureButton.isHidden = true
                    self.recordButton.isHidden = false
                }
                
                self.movieFileOutput = movieFileOutput
                
                DispatchQueue.main.async {
                    self.recordButton.isEnabled = true
                    self.recordButton.addTarget(self, action: #selector(self.record), for: .touchDown)
                    self.recordButton.addTarget(self, action: #selector(self.stop), for: UIControlEvents.touchUpInside)
                    self.showTextIntroScreen()
                }
            }
        }
    }
    
    @objc func setupPhotoSession(_ sender: Any){
        recordButton.isEnabled = false
        recordButton.isHidden = true
        captureButton.isHidden = false
        
        sessionQueue.async {
            /*
             Remove the AVCaptureMovieFileOutput from the session because movie recording is
             not supported with AVCaptureSession.Preset.Photo. Additionally, Live Photo
             capture is not supported when an AVCaptureMovieFileOutput is connected to the session.
             */
            if self.movieFileOutput != nil {
                self.session.beginConfiguration()
                self.session.removeOutput(self.movieFileOutput!)
                self.session.sessionPreset = .photo
                
                DispatchQueue.main.async {
                    // captureModeControl.isEnabled = true
                }
                
                self.movieFileOutput = nil
                
                if self.photoOutput.isLivePhotoCaptureSupported {
                    self.photoOutput.isLivePhotoCaptureEnabled = true
                    
                    DispatchQueue.main.async {
                        //    self.livePhotoModeButton.isEnabled = true
                        //  self.livePhotoModeButton.isHidden = false
                    }
                }
                
                if self.photoOutput.isDepthDataDeliverySupported {
                    self.photoOutput.isDepthDataDeliveryEnabled = true
                    
                    DispatchQueue.main.async {
                        // self.depthDataDeliveryButton.isHidden = false
                        //self.depthDataDeliveryButton.isEnabled = true
                    }
                }
                
                self.session.commitConfiguration()
            }
        }
    }
    
    
    @IBAction private func changeCamera(_ sender: Any) {
        captureButton.isEnabled = false
        flashButton.isEnabled = false
        flipCameraButton.isEnabled = false
        cameraButton.isEnabled = false
        videoButton.isEnabled = false
        
        if let movieFileOutput = self.movieFileOutput {
            if movieFileOutput.isRecording {
                movieFileOutput.stopRecording()
            }
        }
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
                self.isBackCamera = true
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
                
                self.isBackCamera = false
            }
            
            if arrCameraPreferences.count > 0 {
                arrCameraPreferences.append(self.isBackCamera ? "1" : "0")
            }
            
            //            if !self.isBackCamera {
            //                let theTransform = CGAffineTransform.identity.scaledBy(x: -1.0, y: 1.0)
            //                self.capturePreviewView.videoPreviewLayer.setAffineTransform(theTransform)
            //            } else {
            //                self.capturePreviewView.videoPreviewLayer.setAffineTransform(CGAffineTransform.identity)
            //            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if newVideoDevice != nil {
                self.setCaptureResolution(isForBackCamera: self.isBackCamera, theDevice: newVideoDevice!)
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.session.addInput(videoDeviceInput)
                        
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    /*
                     Set Live Photo capture and depth data delivery if it is supported. When changing cameras, the
                     `livePhotoCaptureEnabled and depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput gets set to NO when
                     a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput if it is supported.
                     */
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
            
            
            DispatchQueue.main.async {
                self.captureButton.isEnabled = true
                self.flashButton.isEnabled = true
                self.flipCameraButton.isEnabled = true
                self.cameraButton.isEnabled = true
                self.videoButton.isEnabled = true
            }
        }
    }
    
    @objc private func capturePhoto(_ sender: Any) {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. We do this to ensure UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = capturePreviewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            // Update the photo output's connection to match the video orientation of the video preview layer.
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            
            var photoSettings = AVCapturePhotoSettings()
            // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = self.flashMode
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            
            
            if self.depthDataDeliveryMode == .on && self.photoOutput.isDepthDataDeliverySupported {
                photoSettings.isDepthDataDeliveryEnabled = true
            } else {
                photoSettings.isDepthDataDeliveryEnabled = false
            }
            
            
            
            
            /*
             The Photo Output keeps a weak reference to the photo capture delegate so
             we store it in an array to maintain a strong reference to this object
             until the capture is completed.
             */
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
            
        }
    }
    
    
    
    @objc func record() {
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(TempCameraViewController.updateProgress), userInfo: nil, repeats: true)
        
        let currentPosition =  self.videoDeviceInput.device.position
        
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        if currentPosition == .back && self.flashMode == .on{
            //enable flash
            enableFlash()
        }
        
        
        /*
         Hide all buttons until recording finishes, and disable
         the Record button until recording starts or finishes.
         
         See the AVCaptureFileOutputRecordingDelegate methods.
         */
        flipCameraButton.isHidden = true
        flashButton.isHidden = true
        cameraButton.isHidden = true
        videoButton.isHidden = true
        cancelButton.isHidden = true
        
        /*
         Retrieve the video preview layer's video orientation on the main queue
         before entering the session queue. We do this to ensure UI elements are
         accessed on the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = capturePreviewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                
                if UIDevice.current.isMultitaskingSupported {
                    /*
                     Setup background task.
                     This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
                     callback is not received until AVCam returns to the foreground unless you request background execution time.
                     This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                     To conclude this background execution, endBackgroundTask(_:) is called in
                     `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
                     */
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                
                // Update the orientation on the movie file output video connection before starting recording.
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                //                movieFileOutputConnection?.isVideoMirrored = !self.isBackCamera
                //movieFileOutputConnection?.isVideoMirrored = true
                movieFileOutputConnection?.automaticallyAdjustsVideoMirroring = false
                
                //                movieFileOutput.recordsVideoOrientationAndMirroringChangesAsMetadataTrack(for: movieFileOutputConnection!)
                //                movieFileOutput.setRecordsVideoOrientationAndMirroringChangesAsMetadataTrack(true, for: movieFileOutputConnection!)
                
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                self.isRecordingStopped = false
                self.videoURLArr.removeAll()
                arrCameraPreferences.removeAll()
                //arrCameraPreferences.append(true)
                //arrCameraPreferences.append(false)
                
                isRecordingStartedWithBackCamera = self.isBackCamera
                
                arrCameraPreferences.append((self.isBackCamera ? "1" : "0"))
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    
    @objc func stop() {
        self.progressTimer.invalidate()
        //        if (movieFileOutput?.isRecording)! {
        print("====> Stop pressed")
        movieFileOutput?.stopRecording()
        isRecordingStopped = true
        
        flipCameraButton.isHidden = false
        flashButton.isHidden = false
        cameraButton.isHidden = false
        videoButton.isHidden = false
        cancelButton.isHidden = false
        progress = 0;
        //        }
    }
    
    @objc func updateProgress() {
        
        let maxDuration = CGFloat(15) // max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
            self.stop()
        }
    }
    
    fileprivate func enableFlash() {
        if self.isCameraTorchOn == false {
            toggleFlash()
        }
    }
    
    /// Disable flash
    
    fileprivate func disableFlash() {
        if self.isCameraTorchOn == true {
            toggleFlash()
        }
    }
    
    /// Toggles between enabling and disabling flash
    
    fileprivate func toggleFlash() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        // Check if device has a flash
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                    self.isCameraTorchOn = false
                } else {
                    do {
                        try device?.setTorchModeOn(level: 1.0)
                        self.isCameraTorchOn = true
                    } catch {
                        print("[SwiftyCam]: \(error)")
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: \(error)")
            }
        }
    }
    
}


//will handle orientation
// MARK: Orientation management
extension TempCameraViewController {
    
    fileprivate func subscribeToDeviceOrientationChangeNotifications() {
        self.deviceOrientation = UIDevice.current.orientation
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    fileprivate func unsubscribeFromDeviceOrientationChangeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        self.deviceOrientation = nil
    }
    
    @objc fileprivate func deviceDidRotate() {
        if !UIDevice.current.orientation.isFlat {
            self.deviceOrientation = UIDevice.current.orientation
        }
    }
    
    func getImageOrientation(forCamera: AVCaptureDevice.Position) -> UIImageOrientation {
        guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return forCamera == .back ? .right : .leftMirrored }
        
        
        switch deviceOrientation {
        case .landscapeLeft:
            return forCamera == .back ? .up : .downMirrored
        case .landscapeRight:
            return forCamera == .back ? .down : .upMirrored
        case .portraitUpsideDown:
            return forCamera == .back ? .left : .rightMirrored
        default:
            return forCamera == .back ? .right : .leftMirrored
        }
    }
}

// MARK: AVCapturePhotoCaptureDelegate
extension TempCameraViewController: AVCapturePhotoCaptureDelegate {
    /*
     This extension includes all the delegate callbacks for AVCapturePhotoCaptureDelegate protocol
     */
    
    //called after photo is taken
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            let photoData = photo.fileDataRepresentation()
            
            if let currentData = photoData {
                
                let image = UIImage(data: currentData)
                
                if let cgImage = image?.cgImage, let scale = image?.scale {
                    let newImage = UIImage(cgImage: cgImage, scale: scale, orientation:  self.getImageOrientation(forCamera: self.videoDeviceInput.device.position))
                    
                    
                    if let event = self.event {
                        let imgViewController = FilterImageViewController(image: newImage)
                        imgViewController.event = event
                        present(imgViewController, animated: false, completion: nil)
                    }
                
                    
                    /*
                    let containerView = PreviewPhotoContainerView()
                    containerView.event = event
                    self.view.addSubview(containerView)
                    containerView.previewImageView.image =  newImage
                    containerView.snp.makeConstraints { (make) in
                        make.edges.equalTo(self.view)
                    }
                    */
                    
                }
            }
        }
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate

extension TempCameraViewController: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        func cleanUp() {
            //            let path = outputFileURL.path
            //            if FileManager.default.fileExists(atPath: path) {
            //                do {
            //                    try FileManager.default.removeItem(atPath: path)
            //                } catch {
            //                    print("Could not remove file at url: \(outputFileURL)")
            //                }
            //                print("after url===>\(outputFileURL.path)")
            //            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskInvalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        print("video output===>\(outputFileURL.path)")
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            print("************** THE BACK \(self.isBackCamera)")
            //arrCameraPreferences.append(self.isBackCamera)
            videoURLArr.append(outputFileURL)
            
            print("******** THE ARRAY IS \(arrCameraPreferences)")
            
            if isRecordingStopped == false {
                
                if let movieFileOutput = self.movieFileOutput {
                    let movieFileOutputConnection = output.connection(with: .video)
                    //                    movieFileOutputConnection?.isVideoMirrored = !self.isBackCamera
                    
                    let outputFileName = NSUUID().uuidString
                    let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                    movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                }
            }
            else {
                print("Asset arr===>\(videoURLArr)")
                
                cleanUp()
                SVProgressHUD.show(withStatus: "Processing Video")
                SVProgressHUD.setDefaultMaskType(.gradient)
                VideoGenerator.mergeMovies(videoURLs: videoURLArr, andFileName: "finalOutput", success: { (videoURL) in
                    
                    print(videoURL)
                    
                    if let event = self.event {
                        let video = AVURLAsset(url: videoURL)
                        let videoViewController = FilterVideoViewController(video: video)
                        videoViewController.event = event
                        SVProgressHUD.dismiss(completion: {
                            self.present(videoViewController, animated: false, completion: nil)
                        })
                        
                    }

                    
                    /*
                    let videoPlayBackVC = VideoViewController()
                    videoPlayBackVC.event = self.event
                    videoPlayBackVC.videoURL = videoURL
                    SVProgressHUD.dismiss()
                    self.present(videoPlayBackVC, animated: true) {
                        
                    }
                    */
                    
                }) { (error) in
                    print(error)
                }
            }
        }
    }
}

//will add the gesture recognizers to the view and handle the corresponding functions
// MARK: Adding Gestures
extension TempCameraViewController {
    func addGestureRecognizers(on view: UIView){
        //will allow the camera to be focused to a point on tap of the screen
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.singleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        capturePreviewView.addGestureRecognizer(singleTapGesture)
        
        
        //will allow the camera to be switched from front to back with double tap of screen
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(changeCamera(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        capturePreviewView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        
        
        //will add a pinch gesture to enable pinch to zoom
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        capturePreviewView.addGestureRecognizer(pinchGesture)
    }
    
    //will take in a tap gesture and auto focus the camera
    @objc fileprivate func singleTapGesture(_ tap: UITapGestureRecognizer) throws {
        let device = self.videoDeviceInput.device
        let currentPosition =  self.videoDeviceInput.device.position
        
        
        guard tapToFocus == true else {
            // Ignore taps
            return
        }
        
        let screenSize = capturePreviewView.bounds.size
        let tapPoint = tap.location(in: capturePreviewView)
        let x = tapPoint.y / screenSize.height
        let y = 1.0 - tapPoint.x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)
        
        //adding animation for User/UI purposes
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = tapPoint
        focusView.alpha = 0.0
        capturePreviewView.addSubview(focusView)
        
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
        
        ///////////////////end ui
        
        switch currentPosition {
        case (.front):
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported == true {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                //Call delegate function and pass in the location of the touch
                
                DispatchQueue.main.async {
                    //self.cameraDelegate?.swiftyCam(self, didFocusAtPoint: tapPoint)
                }
            }
            catch {
                // just ignore
            }
            
            
        case (.back):
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported == true {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                //Call delegate function and pass in the location of the touch
                
                DispatchQueue.main.async {
                    //self.cameraDelegate?.swiftyCam(self, didFocusAtPoint: tapPoint)
                }
            }
            catch {
                // just ignore
            }
            
        case .unspecified:
            print("nothing could be done")
        }
    }
    
    
    /// Handle pinch gesture to zoom
    
    @objc  func zoomGesture(pinch: UIPinchGestureRecognizer) throws {
        
        let device = self.videoDeviceInput.device
        let currentPosition =  self.videoDeviceInput.device.position
        
        switch currentPosition {
        case .front:
            do {
                try device.lockForConfiguration()
                zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  (device.activeFormat.videoMaxZoomFactor))))
                device.videoZoomFactor = zoomScale
                
                // Call Delegate function with current zoom scale
                DispatchQueue.main.async {
                    // self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
                }
                
                device.unlockForConfiguration()
                
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
            print("current cam is front position")
        case .back:
            do {
                try device.lockForConfiguration()
                zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  (device.activeFormat.videoMaxZoomFactor))))
                device.videoZoomFactor = zoomScale
                
                // Call Delegate function with current zoom scale
                DispatchQueue.main.async {
                    // self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
                }
                
                device.unlockForConfiguration()
                
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
            print("current cam is back position")
            
        case .unspecified:
            print("")
        }
    }
}


// MARK: UIGestureRecognizerDelegate
extension TempCameraViewController : UIGestureRecognizerDelegate {
    
    /// Set beginZoomScale when pinch begins
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            beginZoomScale = zoomScale;
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}


extension TempCameraViewController {
          func setCaptureResolution(isForBackCamera: Bool, theDevice: AVCaptureDevice) {
                    let dimensions = CMVideoFormatDescriptionGetDimensions(theDevice.activeFormat.formatDescription)
        
                    if isForBackCamera {
                            backCameraResolution = CGSize(width: CGFloat(dimensions.height), height: CGFloat(dimensions.width))
                        } else {
                                frontCameraResolution = CGSize(width: CGFloat(dimensions.height), height: CGFloat(dimensions.width))
                            }
                }
        }
