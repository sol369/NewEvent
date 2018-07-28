//
//  CameraHelper.swift
//  Eventful
//
//  Created by Shawn Miller on 5/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraHelper: NSObject{
    //standard avcapturesession to facilitate the use of the camera
    var captureSession: AVCaptureSession?
    //avcapture device to rep the front camera
    var frontCamera: AVCaptureDevice?
    //avcapture device to rep the back camera
    var rearCamera: AVCaptureDevice?
    
    //capture device inputs,
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    //capture device outputs for photo
    var photoOutput: AVCapturePhotoOutput?
    //capture preview that will be displayed on the view
    var previewLayer: AVCaptureVideoPreviewLayer?
    //ability to enable and disable flashmode
    //default is off
    var flashMode = AVCaptureDevice.FlashMode.off
    //temporary UIView to use for other methods
    var UIViewTemp: UIView?
    
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
    
    /// Sets wether the taken photo or video should be oriented according to the device orientation
    public var shouldUseDeviceOrientation      = false
    
    /// Last changed orientation
    
    fileprivate var deviceOrientation:UIDeviceOrientation?
    
    /// UIView for front facing flash
    
    fileprivate var flashView:UIView?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    //prepares our capture session for use and calls a completion handler when it’s done.
    //setting a capture session consist of four steps
        // Creating a capture session
        // Obtaining and configuring the necessary capture devices.
        // Creating inputs using the capture devices.
        // Configuring a photo output object to process captured images.
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        //created boilerplate functions for performing the 4 key steps in preparing an AVCaptureSession for photo capture
        //also set up an asynchronously executing block that calls the four functions, catches any errors if necessary, and then calls the completion handler
        func createCaptureSession() {
            //creates a new AVCaptureSession and stores it in the captureSession property.
            self.captureSession = AVCaptureSession()
            
        }
        func configureCaptureDevices() throws {
        
            //1
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            
            let cameras = (session.devices.compactMap { $0 })
            if !cameras.isEmpty{
                
                //2
                for camera in cameras {
                    if camera.position == .front {
                        self.frontCamera = camera
                    }
                    
                    if camera.position == .back {
                        self.rearCamera = camera
                        
                        try camera.lockForConfiguration()
                        camera.focusMode = .continuousAutoFocus
                        camera.unlockForConfiguration()
                    }
                }
            }else{
                throw CameraControllerError.noCamerasAvailable
            }
            
        }
        func configureDeviceInputs() throws {
            
            //3 ensures that captureSession exists. If not, we throw an error.
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            //4 These if statements are responsible for creating the necessary capture device input to support photo capture
            //AVFoundation only allows one camera-based input per capture session at a time. Since the rear camera is traditionally the default, we attempt to create an input from it and add it to the capture session. If that fails, we fall back on the front camera. If that fails as well, we throw an error.
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
            
        }
        func configurePhotoOutput() throws {
            
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            
            captureSession.startRunning()
            
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
        
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.UIViewTemp = view;
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        addGestureRecognizers(on: view)
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
        
    }
    
    func addGestureRecognizers(on view: UIView){
        //will allow the camera to be focused to a point on tap of the screen
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.singleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        view.addGestureRecognizer(singleTapGesture)
        
        
        //will allow the camera to be switched from front to back with double tap of screen
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(cameraSwitchAction(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        view.addGestureRecognizer(doubleTapGesture)

        singleTapGesture.require(toFail: doubleTapGesture)

        
        //will add a pinch gesture to enable pinch to zoom
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
    }
    
    
    //will control the switching of the camera
    func switchCameras() throws {
        
        //5 ensures that we have a valid, running capture session before attempting to switch cameras. It also verifies that there is a camera that’s currently active.
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        //6  tells the capture session to begin configuration.
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {

            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        func switchToRearCamera() throws {
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        //7 calls either switchToRearCamera or switchToFrontCamera, depending on which camera is currently active.
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        //8 This line commits, or saves, our capture session after configuring it.
        captureSession.commitConfiguration()
        
    }
    
    //will capture an image when shutter but is pressed
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    
    /// Handle pinch gesture to zoom
    
    @objc  func zoomGesture(pinch: UIPinchGestureRecognizer) throws {
        //5 ensures that we have a valid, running capture session before attempting to zoom. It also verifies that there is a camera that’s currently active.
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        switch currentCameraPosition {
        case .front:
            do {
                
                try self.frontCamera?.lockForConfiguration()
                
                zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  (self.frontCamera?.activeFormat.videoMaxZoomFactor)!)))
                
                self.frontCamera?.videoZoomFactor = zoomScale
                
                // Call Delegate function with current zoom scale
                DispatchQueue.main.async {
                   // self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
                }
                
                self.frontCamera?.unlockForConfiguration()
                
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
            print("current cam is front position")
        case .rear:
            do {
                
                try self.rearCamera?.lockForConfiguration()
                
                zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  (self.rearCamera?.activeFormat.videoMaxZoomFactor)!)))
                
                self.rearCamera?.videoZoomFactor = zoomScale
                
                // Call Delegate function with current zoom scale
                DispatchQueue.main.async {
                    // self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
                }
                
                self.rearCamera?.unlockForConfiguration()
                
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
            print("current cam is back position")

        }
    }
    
    
    
    //will take in a tap gesture and auto focus the camera
    @objc fileprivate func singleTapGesture(_ tap: UITapGestureRecognizer) throws {
        //5 ensures that we have a valid, running capture session before attempting to focus. It also verifies that there is a camera that’s currently active.
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        guard tapToFocus == true else {
            // Ignore taps
            return
        }
        if let passedView = UIViewTemp {
            
            let screenSize = passedView.bounds.size
            let tapPoint = tap.location(in: passedView)
            let x = tapPoint.y / screenSize.height
            let y = 1.0 - tapPoint.x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            //adding animation for User/UI purposes
             let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
            focusView.center = tapPoint
            focusView.alpha = 0.0
            passedView.addSubview(focusView)
            
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
            
            switch currentCameraPosition {
            case (.front):
                if let device = self.frontCamera {
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
                }
                
            case (.rear):
                if let device = self.rearCamera {
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
                }
                
                
            }
        }
        
        
    }
    
    @objc func cameraSwitchAction(_ tap: UITapGestureRecognizer){
        //will switch the camera
        try! switchCameras()
    }
    
    
    
}
//using this embedded type to manage the various errors we might encounter while creating a capture session:

extension CameraHelper {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}


extension CameraHelper: AVCapturePhotoCaptureDelegate {
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }

        let imageData = photo.fileDataRepresentation()
        
        if let currentData = imageData {
            
            let dataProvider = CGDataProvider(data: currentData as CFData)
            let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
            let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: self.getImageOrientation(forCamera: self.currentCameraPosition!))
            self.photoCaptureCompletionBlock?(image, nil)
        }else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
        
    }
    
    
}

// MARK: UIGestureRecognizerDelegate

extension CameraHelper : UIGestureRecognizerDelegate {
    
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


extension CameraHelper {
    /// Orientation management
    
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
    
    fileprivate func getImageOrientation(forCamera: CameraPosition) -> UIImageOrientation {
        guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return forCamera == .rear ? .right : .leftMirrored }
        
        switch deviceOrientation {
        case .landscapeLeft:
            return forCamera == .rear ? .up : .downMirrored
        case .landscapeRight:
            return forCamera == .rear ? .down : .upMirrored
        case .portraitUpsideDown:
            return forCamera == .rear ? .left : .rightMirrored
        default:
            return forCamera == .rear ? .right : .leftMirrored
        }
    }
}

