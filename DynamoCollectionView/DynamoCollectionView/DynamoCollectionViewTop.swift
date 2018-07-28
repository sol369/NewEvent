//
//  DynamoCollectionViewTop.swift
//  DynamoCollectionView
//
//  Created by Shawn Miller on 1/19/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
//protocol methods which serve as the blueprint for a function(s) that will inheir this protocol
public protocol DynamoCollectionViewTopDataSource: NSObjectProtocol {
    func topViewRatioTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop) -> CGFloat // ratio in range [0,1]
    func numberOfItemsTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop) -> Int
    //Aaks datasource object for the number of items in the specified section
    func dynamoCollectionViewTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop, cellForItemAt indexPath: IndexPath) -> DynamoCollectionViewCell
    //Asks datasource object for the cell that corresponds to the specified item in the collectionView
}

public protocol DynamoCollectionViewTopDelegate: NSObjectProtocol {
    func dynamoCollectionViewTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop, didSelectItemAt indexPath: IndexPath)
    //Tells the delegate that the item at the specified index path was selected
    func dynamoCollectionViewTop(_ dynamoCollectionViewTop: DynamoCollectionViewTop, willDisplay cell: UICollectionViewCell, indexPath: IndexPath)
    //Tells the delegate that the specified cells is about to be displayed
}

//A public immutable variable that contains the name of some notification that will be broadcast to some registered observer
public let DynamoCollectionViewTopEnableScrollingNotification = NSNotification.Name("DynamoCollectionViewEnableScrollingNotification")

//A public immutable variable that contains the name of some notification that will be broadcast to some registered observer
public let DynamoCollectionViewTopDisableScrollingNotification = NSNotification.Name("DynamoCollectionViewDisableScrollingNotification")



public class DynamoCollectionViewTop: UIView, DynamoCollectionViewCellDelegate, UIGestureRecognizerDelegate{
    // MARK: - Variables
    //variable to control and make use of the DynamoCollectionViewDelegate
    public var delegateTop: DynamoCollectionViewTopDelegate?
    //variable to control and make use of the DynamoCollectionViewDatasource
    public var dataSourceTop: DynamoCollectionViewTopDataSource?
    //variable that will instantiate and let you manage the bottomCollectionView inside this view
    private var topCollectionView: UICollectionView!
    //variable that will instantiate and manage the bottomUIView that this class will reference
    private var topContainerView: UIView!
    //the topViewRatio that will be used in the appropriate delegate method to create some type of spacing beteween views
    private var topViewRatio: CGFloat = 0
    // the default numberOfItems that will be used in the appropriate datasource method to managa the number of items in the collectionView
    private var numberOfItems: Int = 0
    //a cell identifier that will let you register a unique instance of a dynamoCollectionViewCell
    private let dynamoCollectionViewTopCellIdentifier = "DynamoCollectionViewTopCellIdentifier"
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
    public func initViews(){
        topContainerView = UIView(frame: .zero)
    topContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        topContainerView.backgroundColor = .white
        
         addSubview(topContainerView)
        
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: topContainerView, superView: self)
         _ = NSLayoutConstraint.activateCentreYConstraint(withView: topContainerView, superView: self)
         _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: topContainerView, referenceView: self)
          _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: topContainerView, referenceView: self)
        let topLayout = UICollectionViewFlowLayout()
        topLayout.scrollDirection = .horizontal
        topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: topLayout)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
                //sets the datsource of the topCollectionView to you so you can control where the data gets pulled from
        topCollectionView.dataSource = self
                //sets the delegate of the topCollectionView to self. By doing this all messages in regards to the  topCollectionView will be sent to the topCollectionView or you.
                //"Delegates send messages"
        topCollectionView.delegate = self
                //sets the background color of the top UIView/CollectionView to white
            topCollectionView.backgroundColor = .white
                topContainerView.addSubview(topCollectionView)
                _ = NSLayoutConstraint.activateCentreXConstraint(withView: topCollectionView, superView: topContainerView)
                _ = NSLayoutConstraint.activateCentreYConstraint(withView: topCollectionView, superView: topContainerView)
                _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: topCollectionView, referenceView: topContainerView)
          _ = NSLayoutConstraint.activateEqualHeightConstraint(withView: topCollectionView, referenceView: topContainerView)
          //registers a DynamoCollectionViewCell inside of the collectionVieww that we previously created
        topCollectionView.register(DynamoCollectionViewCell.self, forCellWithReuseIdentifier: dynamoCollectionViewTopCellIdentifier)
        // init view's gestures
        //will create a pan gesture inside the collection/ContainerView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panGesture.delaysTouchesBegan = false
        //sets the delegate of the panGesture to self. By doing this all messages in regards to the  panGesture will be sent to the panGesture or you.
        //"Delegates send messages"
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(panGesture)
        //set timer
         self.setTimer()
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    }
        func setTimer(){
            //auto scroll method to call every 2.5 seconds interval
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.autoScroller), userInfo: nil, repeats: true)
        }
    
    func closeTimer(){
        if let time = self.timer{
            time.invalidate()
            self.timer = nil
        }
    }
    
    //Auto scroller timer call this method after X = 3 seconds time interval
    @objc func autoScroller(){
        //retireve last visible cell from top collection view
        if let currentIndexPath = self.topCollectionView.indexPathsForVisibleItems.last{
            
            //Check visible cell is last cell of top collection view then set first index as visible
            if currentIndexPath.item == self.topCollectionView.numberOfItems(inSection: 0)-1{
                let nextIndexPath = NSIndexPath(item: 0, section: 0)
                //top collection view scroller in first item
                self.topCollectionView.scrollToItem(at: nextIndexPath as IndexPath, at: .right, animated: false)
            }else{
                //create next index path from current index path of the top collection view
                let nextIndexPath = NSIndexPath(item: currentIndexPath.item + 1, section: 0)
                //top collection view scroller to next item
                self.topCollectionView.scrollToItem(at: nextIndexPath as IndexPath, at: .left, animated: true)
            }
        }
    }
    
    //Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    //Ask the delegate if a gesture recognizer should receive an object representing a touch.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let topTouchPoint = touch.location(in: topContainerView)
        if topTouchPoint.y > 0 {
            // Creates a notification with a given name and sender and posts it to the notification center.
            //The Notification center A notification dispatch mechanism that enables the broadcast of information to registered observers.
            NotificationCenter.default.post(name: DynamoCollectionViewTopEnableScrollingNotification, object: nil)
            return true
        }
        
        
        //Creates a notification with a given name and sender and posts it to the notification center.
        //The Notification center A notification dispatch mechanism that enables the broadcast of information to registered observers.
        NotificationCenter.default.post(name: DynamoCollectionViewTopDisableScrollingNotification, object: nil)
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
    public func dequeueReusableCell(for indexPath: IndexPath) -> DynamoCollectionViewCell {
        //if the indexpath.item is 0 or in other words you are the top big cell it will return the topView
        //please come back here on wednesday
        //the error seems to be stemming from here
        
        //do the proper dequeueReusable cell functionality because we will need multiple of them unlike the top one which seemingly only needs one at the momnent
        return
            topCollectionView.dequeueReusableCell(withReuseIdentifier: dynamoCollectionViewTopCellIdentifier, for: IndexPath(item: indexPath.item, section: 0)) as! DynamoCollectionViewCell
        
    }
    public func invalidateLayout() {
        //Invalidates the current layout and triggers a layout update.
        topCollectionView.collectionViewLayout.invalidateLayout()
    }
    // MARK: - View Configuration
    
    private func configureView() {
        //configure view seems to also set the data that the collectionView/cell recieves
        //utilizes downcasting to check and assign a value at the same time for proper use
        // will force it to be of type datasource and will only work and execute that block inside if statement if it is
        //comes here fourth and goes back and forth with the fifth place
        if let source = dataSourceTop {
            //use the info pullede from source to reconfigure the view
            topViewRatio = min(max(0, source.topViewRatioTop(self)), 1.0)
            //returns the greater of source.numberOfItems and 0
            //if x is 0 return Y which in this case is 0
            numberOfItems = max(source.numberOfItemsTop(self), 0)
            if numberOfItems > 0 {
               // print("Entered here for number of items")
               // print("Number of items is: \(numberOfItems)")
                //may need to change this to seems to set the topView back to a dynamic collectionView with one item or sets the tag to zero as well as setting the section number back to 0 and returns that cell
                
                
                // topCollectionView.reloadData()
                
                //reloads the collectionView
                //comes here sixth
                topCollectionView.reloadData()
            }
        }
    }
    
    // MARK: DynamoCollectionViewCell Delegate
    
    func dynamoCollectionViewCellDidSelect(sender: UICollectionViewCell) {
        if let viewDelegate = delegateTop {
            //this passes tghe indexpath into the didSelectItemAt function in the homefeedController so we know which cell is selected
           // print("Tag of sender is: \(sender.tag)")
            viewDelegate.dynamoCollectionViewTop(self, didSelectItemAt: IndexPath(item: sender.tag, section: 0))
        }
    }
}
    
//methods for collectionView that is inside of containerView
extension DynamoCollectionViewTop: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    // MARK: CollectionView Datasource
    //error was here this controls the number of items in each section
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(0, numberOfItems)
        
    }
    
    //seems to come here to determine what source data goes to the top or bottom based off the tag
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      //  print("Current indexPath.item value in DynamoCollectionView.swift is : \(indexPath.item)")
        //Bottom collection view
       // print("Configuring bottom collection view")
        //upon getting the source
        if let source = dataSourceTop {
            //c1
          //  print("Number of items in source is \(source.numberOfItemsTop(self))")
            // print(source.description)
            //print("Assigning source")
            //print("Current indexPath item is : \(indexPath.item)")
            //this creates a cell and uses the source to pass it to the homefeedcontroller
            //item is An index number identifying an item in a UICollectionView object in a section identified by the section parameter.
            //section is An index number identifying a section in a UICollectionView object.
            //by changing this to one the entire thing becomes one big cell with the wrong picture that goes to the same screen
            //error was also here
            let cell = source.dynamoCollectionViewTop(self, cellForItemAt: IndexPath(item: indexPath.item, section: 0))
            //okay so this makes sure that it goes to the normal cell for the proper confiuration of cell elements
            cell.tag = indexPath.item
            cell.delegate = self
            return cell
        }else {
           // print("Entered else")
            let cell = DynamoCollectionViewCell()
            cell.tag = indexPath.item + 1
            cell.delegate = self
            return cell
        }
        
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //delegate method only call for top collection view
            delegateTop?.dynamoCollectionViewTop(self, willDisplay: cell, indexPath: indexPath)
        
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
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        
    }
    //Asks the delegate for the margins to apply to content in the specified section.
    //in short in controls the amount of space between the items above,left,right, and below
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    //Asks the delegate for the spacing between successive rows or columns of a section.
    //controls the space in between rows and columns
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    //Asks the delegate for the spacing between successive items of a single row or column.
    //controls the space between each cell
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK: CollectionView Delegate
    //tells the delegate that the item at the specified index path was selected
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


