//
//  NewSearchVC.swift
//  Eventful
//
//  Created by Shawn Miller on 6/25/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import Foundation
import ScrollableSegmentedControl
import Firebase


class NewSearchVC: UICollectionViewController {
    var cellID = "cellID"
    var cellID2 = "cellID2"
    var headerID = "headerID"
    //two arrays both of type Event
    //one for appending the results of the database search
    //one for grabbing the results of the search bar
    var filteredEvents = [Event]()
    var eventsArray = [Event]()
    var filteredUsers = [User]()
    var usersArray = [User]()
    var selectedIndex: Int?
    lazy var searchPromptLabel : UILabel = {
        let label = UILabel()
        guard let customFont = UIFont(name: "ProximaNovaSoft-Regular", size: 34) else {
            fatalError("""
        Failed to load the "CustomFont-Light" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        label.setCellShadow()
        label.font = UIFontMetrics.default.scaledFont(for: customFont)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.text = "Hi \(String(describing: User.current.username!))!\nSearch For Users\nand Events Near You"
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func setupVC(){
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "homePageBG")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        view.addSubview(searchPromptLabel)
        searchPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(150)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(11)
        }
        setupCV()

    }
    
    @objc func setupCV(){
        collectionView?.register(NewEventSearchCell.self, forCellWithReuseIdentifier: cellID)
       collectionView?.register(NewUserSearchCell.self, forCellWithReuseIdentifier: cellID2)
         collectionView?.register(NewEventSearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.isScrollEnabled = false
    }
    
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
        searchPromptLabel.isHidden = false
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
        filteredEvents.removeAll()
        filteredUsers.removeAll()
    }
}

extension NewSearchVC:UICollectionViewDelegateFlowLayout{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NewEventSearchCell
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID2, for: indexPath) as! NewUserSearchCell
        switch selectedIndex{
        case 0:
            eventCell.filteredEvents = self.filteredEvents
            eventCell.searchVc = self
            return eventCell
        case 1:
            userCell.filteredUsers = self.filteredUsers
            userCell.searchVc = self
            return userCell
        default:
            return eventCell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID, for: indexPath) as! NewEventSearchHeader
        header.searchVC = self
        return header
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 90)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}

extension NewSearchVC {
    
    @objc func fetchUsers(stringValue: String){
        //create a reference to the location in the database that you want to pull from and observe the value there
        let ref = Database.database().reference().child("users")
        let endString = stringValue + "\\uf8ff"
        ref.queryOrdered(byChild: "username").queryStarting(atValue: stringValue).queryEnding(atValue: endString).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dictionaries = snapshot.value as? [String: Any] else{
                return print(snapshot.value ?? "nil")
            }
            
            //  print(dictionaries)
            //does the job of sorting dictionary elements by key and value
            //displaying the key and each corresponding value
            dictionaries.forEach({ (key,value) in
                // print(key, value)
                //creating an eventDictionary to store the results of previous call
                guard let userDictionary = value as? [String: Any] else{
                    return
                }
                let newUser = User(key: key, postDictionary: userDictionary)
                let filteredArr = self.usersArray.filter { (user) -> Bool in
                    //  print(user.uid)
                    return user.uid == newUser?.uid
                }
                //  print(newUser?.uid ?? "nil")
                //If arrat equals 0 append newPost
                if filteredArr.count == 0 {
                    //append
                    self.usersArray.append(newUser!)
                }
                self.filteredUsers = self.usersArray.filter { (user) -> Bool in
                    return (user.username?.lowercased().contains(stringValue.lowercased()))!
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.searchPromptLabel.isHidden = true
                }
                
            })

            
        }) { (err) in
            print("Failed to fetch posts for search")
        }
    }
    
    
     @objc func fetchEvents(searchString: String){
        print("Fetching events....")
        //create a reference to the location in the database that you want to pull from and observe the value there
        let ref = Database.database().reference().child("events")
        // this will retur a snapshot with all the data at that location in the database and cast the results as a dictionary for later use
        let endString = searchString + "\\uf8ff"
        let query = ref.queryOrdered(byChild: "event:name").queryStarting(atValue: searchString).queryEnding(atValue: endString)
        //print(query)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else{
                //  print(snapshot.value ?? "")
                return
            }
            print(snapshot.value ?? "")
            dictionary.forEach({ (key,value) in
                // print(key,value)
                guard let eventDictionary = value as? [String: Any] else{
                    return
                }
                let events = Event(currentEventKey: key, dictionary:eventDictionary)
                
                let filteredEvents = self.eventsArray.filter { (event) -> Bool in
                    return event.key == events.key
                }
                
                if filteredEvents.count == 0 {
                    //append
                    self.eventsArray.append(events)
                }
                
                
                self.filteredEvents = self.eventsArray.filter { (event) -> Bool in
                    return event.currentEventName.lowercased().contains(searchString.lowercased())
                    
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
                
            })
            
        }) { (err) in
            print("Failed to fetch event data", err)
        }
    }
    
}

