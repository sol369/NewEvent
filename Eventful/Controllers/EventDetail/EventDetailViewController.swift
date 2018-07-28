//
//  EventDetailViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/7/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SnapKit
import GoogleMaps
import CoreLocation
import MapKit
import SimpleImageViewer


class EventDetailViewController: UIViewController,UIScrollViewDelegate {
    var imageURL: URL?
    var currentEvent : Event?{
        didSet{
            imageURL = URL(string: (currentEvent?.currentEventImage)!)
            
            DispatchQueue.main.async {
                self.currentEventImage.af_setImage(withURL: self.imageURL!, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .main, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: false, completion: { (response) in
                    _ = response.result.value // UIImage Object
                })
            }
            //will pass the event description to the corresponding label
            infoText.text = currentEvent?.currentEventDescription
            updateWithSpacing(lineSpacing: 5.0)
            guard let currentZip = currentEvent?.currentEventZip else{
                return
            }
            let firstPartOfAddress = (currentEvent?.currentEventStreetAddress)!  + "\n" + (currentEvent?.currentEventCity)! + ", " + (currentEvent?.currentEventState)!
            let secondPartOfAddress = firstPartOfAddress + " " + String(describing: currentZip)
            addressLabel.text = secondPartOfAddress
            
            let dateComponets = getDayAndMonthFromEvent(currentEvent!)
            currentEventDate.text = dateComponets.1 + ", \(dateComponets.0)\n\(currentEvent?.currentEventTime?.lowercased() ?? "")"
            eventKey = (currentEvent?.key)!
            eventPromo = (currentEvent?.currentEventPromo)!
            setupAttendInteraction()
            titleView.text = currentEvent?.currentEventName.uppercased()
            camera.event = currentEvent
            if let price = currentEvent?.eventPrice {
                let formatter = NumberFormatter()
                formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
                formatter.numberStyle = .currency
                if let formattedTipAmount = formatter.string(from:                     NSNumber(value: Int(price)!)) {
                    costLabel.text = "Cost: \(formattedTipAmount)"
                }

            }
           
        }
    }
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let textContainer = UIView()
    private var userInteractStackView: UIStackView?
    private var userInteractStackView1: UIStackView?
    private var tagStackView: UIStackView?
    private var eventKey = ""
    private var eventPromo = ""
    let titleView = UILabel()
    let camera = TempCameraViewController()
    
    
    

    
    private let infoText: UILabel = {
        let infoText = UILabel()
        infoText.textColor = .black
        infoText.textAlignment = .natural
        infoText.font = UIFont.systemFont(ofSize: 16.5)
        infoText.numberOfLines = 0
        return infoText
    }()
    
     lazy var costLabel: UILabel = {
        let costLabel = UILabel()
        costLabel.textColor = .black
        costLabel.textAlignment = .natural
        costLabel.font = UIFont.boldSystemFont(ofSize: 15)
        costLabel.numberOfLines = 0
        return costLabel
    }()
    
    
    lazy var currentEventDate: UILabel = {
        let currentEventDate = UILabel()
        currentEventDate.numberOfLines = 0
        currentEventDate.textAlignment = .center
        currentEventDate.font = UIFont.boldSystemFont(ofSize: 15)
        return currentEventDate
    }()
    
    lazy var currentEventImage : UIImageView = {
        let currentEvent = UIImageView()
        currentEvent.setCellShadow()
        currentEvent.clipsToBounds = true
        currentEvent.translatesAutoresizingMaskIntoConstraints = false
        currentEvent.contentMode = .scaleToFill
        currentEvent.layer.masksToBounds = true
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handlePromoVid))
        singleTap.numberOfTapsRequired = 1
        
        currentEvent.isUserInteractionEnabled = true
        currentEvent.addGestureRecognizer(singleTap)
        let doubleTap =  UITapGestureRecognizer(target: self, action: #selector(handleImageZoom))
        doubleTap.numberOfTapsRequired = 2
        currentEvent.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
        return currentEvent
    }()
    fileprivate func extractedFunc(_ url: URL?) -> EventPromoVideoPlayer {
        return EventPromoVideoPlayer(videoURL: url!)
    }
    
    @objc func handleImageZoom(){
        print("double tap recognized")
        let configuration = ImageViewerConfiguration { config in
            config.imageView = currentEventImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
        
        
    }
    
    @objc func handlePromoVid(){
        let url = URL(string: eventPromo)
        let videoLauncher = extractedFunc(url)
        present(videoLauncher, animated: true, completion: nil)
    }
    
    //wil be responsible for creating the address  label
    lazy var addressLabel : UILabel = {
        let currentAddressLabel = UILabel()
        currentAddressLabel.numberOfLines = 0
        currentAddressLabel.textColor = UIColor.lightGray
        currentAddressLabel.font = UIFont.boldSystemFont(ofSize: 16)
        currentAddressLabel.isUserInteractionEnabled = true
        currentAddressLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMaps)))
        return currentAddressLabel
    }()
    //will ad the location marker to potentially bring up google maps
    lazy var LocationMarkerViewButton : UIButton = {
        let locationMarker = UIButton(type: .system)
        locationMarker.setImage(UIImage(named: "icons8-marker-50 (1)")?.withRenderingMode(.alwaysOriginal), for: .normal)
        locationMarker.addTarget(self, action: #selector(openMaps), for: .touchUpInside)
        return locationMarker
    }()
    
    
    @objc func openMaps() {
        print("Trying to open a map")
        guard let currentZip = currentEvent?.currentEventZip else{
            return
        }
        let geoCoder = CLGeocoder()
        
        let addressString = (currentEvent?.currentEventStreetAddress)! + ", "+(currentEvent?.currentEventCity)! +  ", "+(currentEvent?.currentEventState)! + " "+String(describing: currentZip)
        print(addressString)
        geoCoder.geocodeAddressString(addressString) { (placeMark, err) in
            guard let currentPlaceMark = placeMark?.first else{
                return
            }
            guard let lat = currentPlaceMark.location?.coordinate.latitude else {
                return
            }
            guard let long = currentPlaceMark.location?.coordinate.longitude else {
                return
            }
            print(lat)
            print(long)
            if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                let addressParse = (self.currentEvent?.currentEventStreetAddress)!.components(separatedBy: " ")
                print(addressParse[0])
                print(addressParse[1])
                print(addressParse[2])
                let directionsRequest = "comgooglemaps-x-callback://" +
                    "?daddr=\(addressParse[0])+\(addressParse[1])+\(addressParse[2]),+\((self.currentEvent?.currentEventCity)!),+\((self.currentEvent?.currentEventState)!)+\(String(describing: currentZip))" +
                "&x-success=sourceapp://?resume=true&x-source=Haipe"
                
                let directionsURL = URL(string: directionsRequest)!
                UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
                
            } else {
                print("Opening in Apple Map")
                
                let coordinate = CLLocationCoordinate2DMake(lat, long)
                let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.02))
                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
                mapItem.name = addressString
                mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    
    lazy var commentsViewButton : UIButton = {
        let viewComments = UIButton(type: .system)
        viewComments.setCellShadow()
        viewComments.setImage(#imageLiteral(resourceName: "icons8-chat-50").withRenderingMode(.alwaysOriginal), for: .normal)
        viewComments.layer.cornerRadius = 5
        viewComments.setTitle("Comments", for: .normal)
        viewComments.titleLabel?.font = UIFont(name: "GillSans", size: 15)
        viewComments.setTitleColor(.white, for: .normal)
        viewComments.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        viewComments.layer.borderWidth = 0.1
        viewComments.layer.borderColor = UIColor.clear.cgColor
        viewComments.addTarget(self, action: #selector(presentComments), for: .touchUpInside)
        return viewComments
    }()
    
    @objc func presentComments(){
        let newCommentsController = NewCommentsViewController()
        newCommentsController.eventKey = eventKey
        newCommentsController.comments.removeAll()
        newCommentsController.adapter.reloadData { (updated) in
        }
        self.navigationController?.pushViewController(newCommentsController, animated: true)
    }
    
    lazy var attendingButton: UIButton = {
        let attendButton = UIButton(type: .system)
        attendButton.setCellShadow()
        attendButton.setImage(#imageLiteral(resourceName: "icons8-walking-50").withRenderingMode(.alwaysOriginal), for: .normal)
        attendButton.layer.cornerRadius = 5
        attendButton.titleLabel?.font = UIFont(name: "GillSans", size: 15)
        attendButton.setTitleColor(.white, for: .normal)
        attendButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        attendButton.layer.borderWidth = 0.1
        attendButton.layer.borderColor = UIColor.clear.cgColor
        attendButton.addTarget(self, action: #selector(handleAttend), for: .touchUpInside)
        return attendButton
    }()
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        if parent != nil && self.navigationItem.titleView == nil {
            initNavigationItemTitleView()
        }
    }
    
    private func initNavigationItemTitleView() {
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center;
        self.navigationItem.titleView = titleView
        self.titleView.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleView.adjustsFontSizeToFitWidth = true
        
    }
    
    @objc func handleAttend(){
        // 2
        attendingButton.isUserInteractionEnabled = false
        
        if (currentEvent?.isAttending)! {
            
            AttendService.setIsAttending(!((currentEvent?.isAttending)!), from: currentEvent) { [unowned self] (success) in
                // 5
                
                defer {
                    self.attendingButton.isUserInteractionEnabled = true
                }
                
                // 6
                guard success else { return }
                
                // 7
                self.currentEvent?.isAttending = !((self.currentEvent!.isAttending))
                
                self.currentEvent?.currentAttendCount += !((self.currentEvent!.isAttending)) ? 1 : -1
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Not Attending", for: .normal)
            }
            
        }else{
            
            AttendService.setIsAttending(!((currentEvent?.isAttending)!), from: currentEvent) {[unowned self] (success) in
                // 5
                
                defer {
                    self.attendingButton.isUserInteractionEnabled = true
                }
                
                // 6
                guard success else { return }
                
                // 7
                self.currentEvent?.isAttending = !((self.currentEvent!.isAttending))
                
                self.currentEvent?.currentAttendCount += !((self.currentEvent!.isAttending)) ? 1 : -1
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Attending", for: .normal)
            }
            
        }
        
    }
    
    fileprivate func setupAttendInteraction(){
        Database.database().reference().child("attending").child(eventKey).child(User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let isAttending = snapshot.value as? Int, isAttending == 1 {
                print("User is attending")
                self.currentEvent?.isAttending = true
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Attending", for: .normal)
            }else{
                print("User is not attending")
                self.currentEvent?.isAttending = false
                self.attendingButton.setImage(#imageLiteral(resourceName: "icons8-walking-50").withRenderingMode(.alwaysOriginal), for: .normal)
                self.attendingButton.setTitle("Not Attending", for: .normal)
                
            }
        }) { (err) in
            print("Failed to check if attending", err)
        }
    }
    
    lazy var addToStoryButton : UIButton =  {
        let addToStory = UIButton(type: .system)
        addToStory.setCellShadow()
        addToStory.setImage(#imageLiteral(resourceName: "icons8-screenshot-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)
        addToStory.layer.cornerRadius = 5
        addToStory.titleLabel?.font = UIFont(name: "GillSans", size: 15)
        addToStory.setTitle("Add to Story", for: .normal)
        addToStory.setTitleColor(.white, for: .normal)
        addToStory.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        addToStory.layer.borderWidth = 0.1
        addToStory.layer.borderColor = UIColor.clear.cgColor
        addToStory.addTarget(self, action: #selector(beginAddToStory), for: .touchUpInside)
        return addToStory
    }()
    
    @objc func beginAddToStory(){
        //Animation 1
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)
        present(camera, animated: false, completion: nil)
    }
    
    lazy var viewStoryButton : UIButton = {
        let viewStoryButton = UIButton(type: .system)
        viewStoryButton.setCellShadow()
        viewStoryButton.setImage(#imageLiteral(resourceName: "icons8-next-50").withRenderingMode(.alwaysOriginal), for: .normal)
        viewStoryButton.layer.cornerRadius = 5
        viewStoryButton.setTitle("View Story", for: .normal)
        viewStoryButton.titleLabel?.font = UIFont(name: "GillSans", size: 15)
        viewStoryButton.setTitleColor(.white, for: .normal)
        viewStoryButton.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        viewStoryButton.layer.borderWidth = 0.1
        viewStoryButton.layer.borderColor = UIColor.clear.cgColor
        
        viewStoryButton.addTarget(self, action: #selector(handleViewStory), for: .touchUpInside)

        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewStory))
//        viewStoryButton.addGestureRecognizer(tapGesture)
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewStory))
        //        viewStoryButton.addGestureRecognizer(tapGesture)
        return viewStoryButton
    }()
    
    @objc func handleViewStory(){
        let vc = StoriesViewController()
        vc.eventKey = self.eventKey
        present(vc, animated: false, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        if let start = currentEvent?.startTime, let end = currentEvent?.endTime {
            print(start)
            print(end)
        }
        
        setupVc()
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func shareWithFollowers(){
        print("Attempting to share with friends")
        let share = ShareViewController()
        print(eventKey)
        share.eventKey = eventKey
        self.navigationController?.pushViewController(share, animated: true)
    }
    
    @objc func setupVc(){
        self.navigationController?.navigationBar.isTranslucent = false
        
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        
        let shareButton = UIBarButtonItem(image: UIImage(named: "icons8-upload-50")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(shareWithFollowers))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = shareButton
        
        
        view.backgroundColor = .white
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        
        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor.rgb(red: 245, green: 255, blue: 250)
        
        textContainer.backgroundColor = .clear
        
        let textBacking = UIView()
        textBacking.backgroundColor = .white
        
        
        userInteractStackView = UIStackView(arrangedSubviews: [commentsViewButton, attendingButton])
        userInteractStackView?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView?.distribution = .fillEqually
        userInteractStackView?.axis = .horizontal
        userInteractStackView?.spacing = 5.0
        
        userInteractStackView1 = UIStackView(arrangedSubviews: [addToStoryButton,viewStoryButton])
        userInteractStackView1?.translatesAutoresizingMaskIntoConstraints = false
        userInteractStackView1?.distribution = .fillEqually
        userInteractStackView1?.axis = .horizontal
        userInteractStackView1?.spacing = 5.0
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageContainer)
        scrollView.addSubview(textBacking)
        scrollView.addSubview(textContainer)
        scrollView.addSubview(currentEventImage)
        
        textContainer.addSubview(addressLabel)
        textContainer.addSubview(currentEventDate)
        textContainer.addSubview(LocationMarkerViewButton)
        textContainer.addSubview(costLabel)
        textContainer.addSubview(infoText)
        textContainer.addSubview(userInteractStackView!)
        textContainer.addSubview(userInteractStackView1!)
        scrollView.snp.makeConstraints {
            make in
            
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        imageContainer.snp.makeConstraints {
            make in
            
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.height.equalTo(imageContainer.snp.width).multipliedBy(1.3)
        }
        
        currentEventImage.snp.makeConstraints {
            make in
            
            make.left.right.equalTo(imageContainer)
            
            //** Note the priorities
            make.top.equalTo(view).priority(.high)
            
            //** We add a height constraint too
            make.height.greaterThanOrEqualTo(imageContainer.snp.height).priority(.required)
            
            //** And keep the bottom constraint
            make.bottom.equalTo(imageContainer.snp.bottom)
        }
        
        textContainer.snp.makeConstraints {
            make in
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(scrollView)
        }
        
        textBacking.snp.makeConstraints {
            make in
            
            make.left.right.equalTo(view)
            make.top.equalTo(textContainer)
            make.bottom.equalTo(view)
        }
        
        LocationMarkerViewButton.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top).offset(10)
            make.left.equalTo(textContainer.snp.left)
        }
        currentEventDate.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top).offset(7)
            make.right.equalTo(textContainer).inset(5)
        }
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textContainer.snp.top).offset(7)
            make.left.equalTo(LocationMarkerViewButton.snp.right).offset(2.5)
        }
        
        costLabel.snp.makeConstraints({ (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
           make.height.equalTo(30)
            make.left.right.equalTo(textContainer).inset(5)

        })
        
        infoText.snp.makeConstraints {
            make in
            make.top.equalTo(costLabel.snp.bottom).offset(10)
            make.left.right.equalTo(textContainer).inset(10)
        }
        
        userInteractStackView?.snp.makeConstraints { (make) in
            make.top.equalTo(infoText.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.left.right.equalTo(textContainer).inset(5)
        }
        
        userInteractStackView1?.snp.makeConstraints({ (make) in
            make.top.equalTo((userInteractStackView?.snp.bottom)!).offset(5)
            make.height.equalTo(40)
            make.left.right.equalTo(textContainer).inset(5)
            make.bottom.equalTo(textContainer.snp.bottom).inset(10)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.scrollIndicatorInsets = view.safeAreaInsets
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    //MARK: - Update Line Spacing
    func updateWithSpacing(lineSpacing: Float) {
        // The attributed string to which the
        // paragraph line spacing style will be applied.
        let attributedString = NSMutableAttributedString(string: infoText.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        // Customize the line spacing for paragraph.
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        mutableParagraphStyle.alignment = .justified
        if let stringLength = infoText.text?.count {
            attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
        }
        // textLabel is the UILabel subclass
        // which shows the custom text on the screen
        infoText.attributedText = attributedString
        
    }
    
    //MARK: - Date Componets
    
    fileprivate func getDayAndMonthFromEvent(_ event:Event) -> (String, String) {
        let apiDateFormat = "MM/dd/yyyy"
        let df = DateFormatter()
        df.dateFormat = apiDateFormat
        let eventDate = df.date(from: event.currentEventDate!)!
        df.dateFormat = "dd"
        let dayElement = df.string(from: eventDate)
        df.dateFormat = "MMM"
        let monthElement = df.string(from: eventDate)
        return (dayElement, monthElement)
    }
    
    
    
}
