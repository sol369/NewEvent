//
//  CalendarViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 4/15/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SVProgressHUD
import SwiftLocation
import CoreLocation
import SwipeCellKit
import GoogleMaps
import MapKit

class CalendarViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    let cellID = "cellID"
    let headerID = "headerID"
    let eventCellID = "eventCellID"
    var savedLocation1: CLLocation?
    let formatter = DateFormatter()
    let dateFormatterGet = DateFormatter()
    let dateFormatterPrint = DateFormatter()
    var selectedDate = Date()
    let emptyView = UIView()
    var passedDate: Date?
    var homeFeedController: HomeFeedController?
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    var allEvents:[String:[Event]] = [:]

    var yearAndMonthStackView: UIStackView?
    //day labels for calendar
    let yearLabel : UILabel =  {
        let yearLabel = UILabel()
        yearLabel.font = UIFont(name:"HelveticaNeue", size: 30.5)
        yearLabel.textColor = UIColor.lightGray
        return yearLabel
    }()
    let monthLabel : UILabel =  {
        let monthLabel = UILabel()
        monthLabel.font = UIFont(name:"HelveticaNeue", size: 30.5)
        return monthLabel
    }()
    

    
    let calendarCollectionView: JTAppleCalendarView = {
        let cv = JTAppleCalendarView(frame: .zero)
        cv.scrollDirection = .horizontal
        cv.allowsSelection = true
        cv.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255)
        cv.minimumInteritemSpacing = 0
        cv.minimumLineSpacing = 0
        cv.scrollingMode = .stopAtEachCalendarFrame
        return cv
    }()
    
    let eventsTableView: UITableView = {
       let eventsTableView = UITableView(frame: CGRect.zero, style: .grouped)
        eventsTableView.backgroundColor = .white
        eventsTableView.separatorStyle = .none
        eventsTableView.showsVerticalScrollIndicator = false
        return eventsTableView
    }()
    
    lazy var noEventsLabel: UILabel = {
        let noEventsLabel = UILabel()
        noEventsLabel.text = "No Events For The Selected Day"
        noEventsLabel.font = UIFont(name: "Avenir", size: 16)
        noEventsLabel.numberOfLines = 0
        noEventsLabel.textAlignment = .center
        return noEventsLabel
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        // Do any additional setup after loading the view.

    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    @objc func setupNavBar(){
        self.navigationController?.navigationBar.isTranslucent = false

        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(image: UIImage(named: "icons8-checkmark-64"), style: .plain, target: self, action: #selector(beginDateFilter))
        navigationItem.rightBarButtonItem = doneButton
    }

    
    @objc func setupVC(){
        getDatesFromServer()
        setupNavBar()
        calendarCollectionView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)

        }
        view.addSubview(yearLabel)
        view.addSubview(monthLabel)
        monthLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        yearLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(monthLabel.snp.right).offset(5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        })
        view.addSubview(calendarCollectionView)
        calendarCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(monthLabel.snp.bottom)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(view.bounds.height/2)
        }
        calendarCollectionView.isPagingEnabled = true
        calendarCollectionView.calendarDataSource = self
        calendarCollectionView.calendarDelegate = self
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: cellID)
        calendarCollectionView.register(CalendarHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        if let curerntDate = passedDate {
            calendarCollectionView.scrollToDate(curerntDate, animateScroll: false)
            calendarCollectionView.selectDates([curerntDate])
        }else{
            calendarCollectionView.scrollToDate(Date(), animateScroll: false)
            calendarCollectionView.selectDates([Date()])
        }
        
        view.addSubview(eventsTableView)
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.register(SelectionCell.self, forCellReuseIdentifier: eventCellID)
        eventsTableView.snp.makeConstraints { (make) in
            make.top.equalTo(calendarCollectionView.snp.bottom)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        guard let date = visibleDates.monthDates.first?.date else {
            return
        }
        self.formatter.dateFormat = "yyyy"
        self.yearLabel.text = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMM"
        self.monthLabel.text = self.formatter.string(from: date)
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func beginDateFilter(){
        self.homeFeedController?.getSelectedDateFromCal(from: self.selectedDate)
        self.navigationController?.popViewController(animated: true)
        SVProgressHUD.dismiss(withDelay: 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalendarViewController:JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell1 = cell as! CalendarCell
        cell1.sectionNameLabel.text = cellState.text
        handleCellSelected(view: cell1, cellState: cellState)
        handleCellTextColor(view: cell1, cellState: cellState)
    }
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Get the current year
        let year = Calendar.current.component(.year, from: Date())
        navigationItem.title = "Event Calendar"
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        UINavigationBar.appearance().titleTextAttributes = attributes
        let firstOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
        let lastOfYear = Calendar.current.date(from: DateComponents(year: year, month: 12, day: 13))
        let parameter = ConfigurationParameters(startDate: firstOfYear!, endDate: lastOfYear!, numberOfRows: 5, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        return parameter
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func handleCellSelected(view: JTAppleCell, cellState: CellState){
        guard let validCell = view as? CalendarCell else {
            return
        }
        if cellState.isSelected {
            validCell.daySelectionOverlay.isHidden = false
        }else {
            validCell.daySelectionOverlay.isHidden = true
        }
        
    }
    
    func handleCellTextColor(view: JTAppleCell, cellState: CellState){
        guard let validCell = view as? CalendarCell else {
            return
        }
        if cellState.isSelected {
            validCell.sectionNameLabel.textColor = UIColor.white
        }else {
            if cellState.dateBelongsTo == .thisMonth{
                validCell.sectionNameLabel.textColor = UIColor.black
            }else{
                validCell.sectionNameLabel.textColor = UIColor.lightGray

            }
        }
        
    }
    
    func handleCellEvents(view: JTAppleCell, cellState: CellState){
        guard let validCell = view as? CalendarCell else {
            return
        }
        validCell.eventDotView.isHidden = !allEvents.contains{$0.key == cellState.date.getFormattedDate(string: cellState.date.description)
}
        
    }
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    
    
    //display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CalendarCell
        cell.sectionNameLabel.text = cellState.text
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellEvents(view: cell, cellState: cellState)
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {
            return
        }
        validCell.bounce()
        selectedDate = date
        print(date.description)
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: validCell, cellState: cellState)
        self.eventsTableView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else {
            return
        }
        handleCellSelected(view: validCell, cellState: cellState)
        handleCellTextColor(view: validCell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: headerID, for: indexPath) as! CalendarHeader
        return header
    }
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentCount = self.allEvents[selectedDate.getFormattedDate(string: selectedDate.description)]?.count else {
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-the-toast-64")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(noEventsLabel)
            noEventsLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(50)
                make.left.right.equalTo(emptyView).inset(5)            }
            self.eventsTableView.backgroundView = emptyView
            return 0
        }
        self.eventsTableView.backgroundView = nil
        return currentCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: eventCellID, for: indexPath) as! SelectionCell
        cell.event = self.allEvents[selectedDate.getFormattedDate(string: selectedDate.description)]?[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let event = self.allEvents[selectedDate.getFormattedDate(string: selectedDate.description)]![indexPath.row]
        let eventDetailVC = EventDetailViewController()
        eventDetailVC.currentEvent = event
        self.navigationController?.pushViewController(eventDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    
}

extension CalendarViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
     let event = self.allEvents[selectedDate.getFormattedDate(string: selectedDate.description)]![indexPath.row]
        print(event.currentEventName)
        let commentAction = SwipeAction(style: .destructive, title: "Comment") { action, indexPath in
            // handle action by updating model with deletion
            print("navigating to comments screen for event")
            let newCommentsController = NewCommentsViewController()
            newCommentsController.eventKey = event.key!
            newCommentsController.comments.removeAll()
            newCommentsController.adapter.reloadData { (updated) in
            }
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(newCommentsController, animated: false)
        }
        
        let viewStoryAction = SwipeAction(style: .destructive, title: "View Story") { action, indexPath in
            // handle action by updating model with view story
            print("navigating to story screen for event")
        }
        
        
        let locationAction = SwipeAction(style: .destructive, title: "Location") { action, indexPath in
            // handle action by updating model with location
            print("navigating to googlemap for event")
            print("Trying to open a map")
             let currentZip = event.currentEventZip
            let geoCoder = CLGeocoder()
            
            let addressString = (event.currentEventStreetAddress) + ", "+(event.currentEventCity) +  ", "+(event.currentEventState) + " "+String(describing: currentZip)
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
                    let addressParse = (event.currentEventStreetAddress).components(separatedBy: " ")
                    print(addressParse[0])
                    print(addressParse[1])
                    print(addressParse[2])
                    let directionsRequest = "comgooglemaps-x-callback://" +
                        "?daddr=\(addressParse[0])+\(addressParse[1])+\(addressParse[2]),+\((event.currentEventCity)),+\((event.currentEventState))+\(String(describing: currentZip))" +
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
                //            print(currentPlaceMark)
            }
        }
        
        
        // customize the action appearance
        locationAction.backgroundColor = .white
        viewStoryAction.backgroundColor = .white
        commentAction.backgroundColor = .white

        locationAction.image = UIImage(named: "icons8-near-me-48")
        locationAction.font = UIFont(name:"HelveticaNeue", size: 10.5)
        locationAction.textColor = .black
        // customize the action appearance
        viewStoryAction.image = UIImage(named: "icons8-youtube-64")
        viewStoryAction.font = UIFont(name:"HelveticaNeue", size: 10.5)
        viewStoryAction.textColor = .black

        // customize the action appearance
        commentAction.image = UIImage(named: "icons8-chat-room-64")
        commentAction.font = UIFont(name:"HelveticaNeue", size: 10.5)
        commentAction.textColor = .black

        return [commentAction,viewStoryAction,locationAction]
    }
    
     func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }
    
    
}

extension CalendarViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "Events For Selected Day"
        label.font = UIFont(name:"HelveticaNeue", size: 16)
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
        }
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        view.addSubview(lineSeparatorView)
        lineSeparatorView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(1)
        }
        
        let lineSeparatorView2 = UIView()
        lineSeparatorView2.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        view.addSubview(lineSeparatorView2)
        lineSeparatorView2.snp.makeConstraints { (make) in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(1)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

extension CalendarViewController{
    @objc func getDatesFromServer(){
        if let passedLocation = savedLocation1 {
            PostService.showEvent(cameFromeHomeFeed: false, for: passedLocation) { (event) in
                for events in event{
                    print(events.startTime.getFormattedDate(string: events.startTime.description))
                    if self.allEvents[events.startTime.getFormattedDate(string: events.startTime.description)] == nil {
                        self.allEvents[events.startTime.getFormattedDate(string: events.startTime.description)] = []
                    }
                    if var arr = self.allEvents[events.startTime.getFormattedDate(string: events.startTime.description)] {
                        arr.append(events)
                        self.allEvents[events.startTime.getFormattedDate(string: events.startTime.description)] = arr
                        print( self.allEvents[events.startTime.getFormattedDate(string: events.startTime.description)]![0].startTime)
                        self.calendarCollectionView.reloadData()
                        self.eventsTableView.reloadData()
                    }
                    
                }
            }
        }
        
    }
    
}

