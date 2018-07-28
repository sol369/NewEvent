//
//  DynamoCollectionView.swift
//  DynamoCollectionView
//
//  Created by Shawn Miller on 10/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

//protocol methods which serve as the blueprint for a function(s) that will inheir this protocol
public protocol DynamoCollectionViewDataSource: NSObjectProtocol {
    func topViewRatio(_ dynamoCollectionView: DynamoCollectionView) -> CGFloat // ratio in range [0,1]
//    func numberOfItems(_ dynamoCollectionView: DynamoCollectionView) -> Int
    //Aaks datasource object for the number of items in the specified section
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCellBottom
    //Asks datasource object for the cell that corresponds to the specified item in the collectionView
       func numberOfSections(_ dynamoCollectionView: DynamoCollectionView) -> Int
    //Asks the datasource object for the numberofItems that will be present in each section
    func numberOfItemsInSection(_ dynamoCollectionView: DynamoCollectionView) -> Int
}

public protocol DynamoCollectionViewDelegate: NSObjectProtocol {
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, didSelectItemAt indexPath: IndexPath)
    //Tells the delegate that the item at the specified index path was selected
    func dynamoCollectionView(_ dynamoCollectionView: DynamoCollectionView, willDisplay cell: UICollectionViewCell, indexPath: IndexPath)
    //Tells the delegate that the specified cells is about to be displayed
}

//A public immutable variable that contains the name of some notification that will be broadcast to some registered observer
public let DynamoCollectionViewEnableScrollingNotification = NSNotification.Name("DynamoCollectionViewEnableScrollingNotification")

//A public immutable variable that contains the name of some notification that will be broadcast to some registered observer
public let DynamoCollectionViewDisableScrollingNotification = NSNotification.Name("DynamoCollectionViewDisableScrollingNotification")

public class DynamoCollectionView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    //variable to control and make use of the DynamoCollectionViewDelegate
    public var delegate: DynamoCollectionViewDelegate?
    //variable to control and make use of the DynamoCollectionViewDatasource
    public var dataSource: DynamoCollectionViewDataSource?
    //variable that will instantiate and let you manage the bottomCollectionView inside this view
    private var bottomCollectionView: UICollectionView!
    //variable that will instantiate and manage the bottomUIView that this class will reference
    private var bottomContainerView: UIView!
    //the topViewRatio that will be used in the appropriate delegate method to create some type of spacing beteween views
    private var topViewRatio: CGFloat = 0
    // the default numberOfItems that will be used in the appropriate datasource method to managa the number of items in the collectionView
   // private var numberOfItems: Int = 0
    //wll set the number of sections
    private var numberOfSections: Int = 0
    //willset the number of items in the section
    private var numberOfItemsInSection: Int = 0
    //a cell identifier that will let you register a unique instance of a dynamoCollectionViewCell
    private let dynamoCollectionViewCellBottomIdentifier = "DynamoCollectionViewCellIdentifier"
   //Timer user for call autoscroller of top collection view
    private var timer:Timer?
    
    // MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    public func initViews() {
        // init containerview
        //creates a containerView which will usually serve the function of holding multiple views in it.
        //Most likely the view that will contain the bottom scroll cells that you see in the home feed screen
        bottomContainerView = UIView(frame: .zero)
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.backgroundColor = .white
        addSubview(bottomContainerView)
        
        NSLayoutConstraint.activateViewConstraints(bottomContainerView, inSuperView: self, withLeading: 0.0, trailing: 0.0, top: nil, bottom: 0.0, width: nil, height: nil)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: bottomContainerView, referenceView: self, multiplier: (1.0 - topViewRatio))
        
        // init collectionview
        //this collectionView is the bottom scrollable view
        //creates a layout variable and sets it equal to UICollectionViewFlowLayout. We need this to create it properly this is just practice
        let layout = UICollectionViewFlowLayout()
        //sets the scroll direction for this specfic collectionView
        layout.scrollDirection = .horizontal
        //creates/instantiates the collectionView so we can further reference and make use of it
        bottomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //A Boolean value that determines whether the view’s autoresizing mask is translated into Auto Layout constraints.
        bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        //sets the datsource of the collectionView to you so you can control where the data gets pulled from
        bottomCollectionView.dataSource = self
        //sets the delegate of the collectionView to self. By doing this all messages in regards to the  collectionView will be sent to the collectionView or you.
        //"Delegates send messages"
        bottomCollectionView.delegate = self
        //sets the background color of the bottom UIView/CollectionView to white
        bottomCollectionView.backgroundColor = .white
        
        backgroundColor = .white
        //adds the collectionView to the ContainerView
        bottomContainerView.addSubview(bottomCollectionView)
        //positions the collectionView inside of the containerView
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: bottomCollectionView, superView: bottomContainerView)
        _ = NSLayoutConstraint.activateCentreYConstraint(withView: bottomCollectionView, superView: bottomContainerView)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: bottomCollectionView, referenceView: bottomContainerView)
        _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: bottomCollectionView, referenceView: bottomContainerView)
        //registers a DynamoCollectionViewCell inside of the collectionVieww that we previously created
        bottomCollectionView.register(DynamoCollectionViewCellBottom.self, forCellWithReuseIdentifier: dynamoCollectionViewCellBottomIdentifier)
        // init view's gestures
        //will create a pan gesture inside the collection/ContainerView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGesture.delaysTouchesBegan = false
        //sets the delegate of the panGesture to self. By doing this all messages in regards to the  panGesture will be sent to the panGesture or you.
        //"Delegates send messages"
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(panGesture)

    }
    
    func closeTimer(){
        if let time = self.timer{
            time.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: Gesture Recognizers
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    }
    //Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //Ask the delegate if a gesture recognizer should receive an object representing a touch.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint  = touch.location(in: bottomContainerView)
        if touchPoint.y > 0 {
            // Creates a notification with a given name and sender and posts it to the notification center.
            //The Notification center A notification dispatch mechanism that enables the broadcast of information to registered observers.
            NotificationCenter.default.post(name: DynamoCollectionViewEnableScrollingNotification, object: nil)
            return true
        }
        //Creates a notification with a given name and sender and posts it to the notification center.
        //The Notification center A notification dispatch mechanism that enables the broadcast of information to registered observers.
        NotificationCenter.default.post(name: DynamoCollectionViewDisableScrollingNotification, object: nil)
        return false
    }
    
    // MARK: Public API
    //reloads the data in the views so we can recieve more content as database updates or we return to the screen from another
    public func reloadData() {
        //comes here third
        configureView()
    }
    //dequeReusable cell comes here when called in main
    //Returns a reusable collection-view cell object located by its identifier.
    //Returns a DynamaoCollectionViewCell specifically
    public func dequeueReusableCell(for indexPath: IndexPath) -> DynamoCollectionViewCellBottom {
        //if the indexpath.item is 0 or in other words you are the top big cell it will return the topView
        //please come back here on wednesday
        //the error seems to be stemming from here
   
        //do the proper dequeueReusable cell functionality because we will need multiple of them unlike the top one which seemingly only needs one at the momnent
            return
                bottomCollectionView.dequeueReusableCell(withReuseIdentifier: dynamoCollectionViewCellBottomIdentifier, for: IndexPath(item: indexPath.item, section: 0)) as! DynamoCollectionViewCellBottom
        
    }
    
    public func invalidateLayout() {
        //Invalidates the current layout and triggers a layout update.
        bottomCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - View Configuration
    
    private func configureView() {
        //configure view seems to also set the data that the collectionView/cell recieves
        //utilizes downcasting to check and assign a value at the same time for proper use
        // will force it to be of type datasource and will only work and execute that block inside if statement if it is
        //comes here fourth and goes back and forth with the fifth place
        if let source = dataSource {
            //use the info pullede from source to reconfigure the view
            topViewRatio = min(max(0, source.topViewRatio(self)), 1.0)
            //returns the greater of source.numberOfItems and 0
            //if x is 0 return Y which in this case is 0
            numberOfItemsInSection = max(source.numberOfItemsInSection(self), 0)
            //pulls the number of sections from the datasource
            numberOfSections = max(source.numberOfSections(self),0)
            if numberOfItemsInSection > 0 {
               // print("Entered here for number of items")
                //print("Number of items is: \(numberOfItems)")
                bottomCollectionView.reloadData()
            }
        }
    }
    
    // MARK: DynamoCollectionViewCell Delegate
    
    func dynamoCollectionViewCellDidSelect(sender: UICollectionViewCell) {
        if let viewDelegate = delegate {
            //this passes tghe indexpath into the didSelectItemAt function in the homefeedController so we know which cell is selected
           // print("Tag of sender is: \(sender.tag)")
            viewDelegate.dynamoCollectionView(self, didSelectItemAt: IndexPath(item: sender.tag, section: 0))
        }
    }
}

//methods for collectionView that is inside of containerView
extension DynamoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    // MARK: CollectionView Datasource
    //error was here this controls the number of items in each section
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return max(0, numberOfItemsInSection)
        }
        return max(0, numberOfItemsInSection)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return max(0,numberOfSections)
    }
    
    //seems to come here to determine what source data goes to the top or bottom based off the tag
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            //upon getting the source
            if let source = dataSource {
                //this creates a cell and uses the source to pass it to the homefeedcontroller
                //item is An index number identifying an item in a UICollectionView object in a section identified by the section parameter.
                //section is An index number identifying a section in a UICollectionView object.
                //by changing this to one the entire thing becomes one big cell with the wrong picture that goes to the same screen
                //error was also here
                let cell = source.dynamoCollectionView(self, cellForItemAt: IndexPath(item: indexPath.item, section: 0))
                //okay so this makes sure that it goes to the normal cell for the proper confiuration of cell elements
                cell.tag = indexPath.item
               // cell.delegate = self
                return cell
            }else {
              //  print("Entered else")
                let cell = DynamoCollectionViewCellBottom()
                cell.tag = indexPath.item + 1
               // cell.delegate = self
                return cell
            }
            
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //delegate method only call for bottom collection view
        delegate?.dynamoCollectionView(self, willDisplay: cell, indexPath: indexPath)
        
    }
    
    //Asks the delegate for the size of the header view in the specified section.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    //Asks the delegate for the size of the footer view in the specified section.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    //Asks the delegate for the size of the specified item’s cell.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (collectionView.bounds.size.width - CGFloat(numberOfItemsInSection))/2.2, height: collectionView.bounds.size.height - 50)
         return CGSize(width: (collectionView.bounds.size.width - 2)/3.3, height: (collectionView.bounds.size.height - 100))
        
    }
    //Asks the delegate for the margins to apply to content in the specified section.
    //in short in controls the amount of space between the items above,left,right, and below
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    //Asks the delegate for the spacing between successive rows or columns of a section.
    //controls the space in between rows and columns
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    //Asks the delegate for the spacing between successive items of a single row or column.
    //controls the space between each cell
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: CollectionView Delegate
    //tells the delegate that the item at the specified index path was selected
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

