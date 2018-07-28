//
//  SearchViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class EventSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    //resue identifier for the cell that you are constructing
    let cellId = "cellID"
    var scopeIndex: Int = 0
    let cellID2 = "newCellID"
    let emptyView = UIView()

    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "Search For Users and Events Near You"
        emptyLabel.font = UIFont(name: "Avenir", size: 14)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        return emptyLabel
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icons8-face-100")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.contentInset = UIEdgeInsetsMake(20, 10, 0, 10)
        collectionView?.backgroundColor = .white
        collectionView?.register(SearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerID")
        self.collectionView?.register(NewEventSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        self.collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellID2)
        
    }
    
    //two arrays both of type Event
    //one for appending the results of the database search
    //one for grabbing the results of the search bar
    var filteredEvents = [Event]()
    var eventsArray = [Event]()
    fileprivate func fetchEvents(searchString: String){
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

 

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as! SearchHeader
        header.searchBar.delegate = self
        return header
    }

    
    // this function will detect change in the search bar and filter out the results returned based off what is entered in the search bar

    var filteredUsers = [User]()
    var usersArray = [User]()
    
    fileprivate func fetchUsers(stringValue: String){
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
                }
                
            })
            
           // print(self.usersArray)
            // will sort the array elements based off the name
            
            
           // print(self.usersArray)
            // will again reload the data
            
        }) { (err) in
            print("Failed to fetch posts for search")
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //make sure that the screen is loaded with the proper number of cells when you first go to the screen
        if filteredEvents.isEmpty == false || filteredUsers.isEmpty == false
        {
            switch scopeIndex {
            case 0:
                self.collectionView?.backgroundView = nil
                return filteredEvents.count
            case 1:
                self.collectionView?.backgroundView = nil
                return filteredUsers.count
            default:
                return 0
            }
        } else
        {
            emptyView.backgroundColor = .clear
            emptyView.addSubview(iconImageView)
            iconImageView.image = UIImage(named: "icons8-search-filled-50")
            iconImageView.snp.makeConstraints { (make) in
                make.center.equalTo(emptyView)
            }
            
            emptyView.addSubview(emptyLabel)
            emptyLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(iconImageView.snp.bottom).offset(50)
                make.left.right.equalTo(emptyView).inset(5)            }
            self.collectionView?.backgroundView = emptyView
            
            return 0
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch scopeIndex {
        case 0:
            let event = filteredEvents[indexPath.item]
            let currentEventDetailController = EventDetailViewController()
            currentEventDetailController.currentEvent = event
            self.filteredEvents.removeAll()
            self.eventsArray.removeAll()
            self.collectionView?.reloadData()
            self.navigationController?.pushViewController(currentEventDetailController, animated: true)
            //  navigationController?.pushViewController(currentEventDetailController, animated: true)
            navigationController?.navigationBar.isHidden = false
            break
        case 1:
            //change needs to be made here
            navigationController?.navigationBar.isHidden = false
            let user = filteredUsers[indexPath.item]
           // print(user.username ?? "")
            let userProfileController = NewProfileVC()
            userProfileController.user = user
            userProfileController.navigationItem.title = user.username
            userProfileController.navigationItem.hidesBackButton = true
            let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
            userProfileController.navigationItem.leftBarButtonItem = backButton
            self.navigationController?.pushViewController(userProfileController, animated: true)

            break
        default:
            break
        }
        
    }
    
    @objc func GoBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
        filteredEvents.removeAll()
        filteredUsers.removeAll()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //creates a cell and cast it as the Appropriate type
        let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewEventSearchCell
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID2, for: indexPath) as! NewUserSearchCell
        
        switch scopeIndex {
        case 0:
            //eventCell.event = filteredEvents[indexPath.row]
            return eventCell
        case 1:
           // userCell.user = filteredUsers[indexPath.row]
            return userCell
        default:
            return eventCell
        }
        
    }
    
    //constrols size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
}

// MARK: UISearchBarDelegate

extension EventSearchController: UISearchBarDelegate {
    //detects when search bar text is done editing
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        guard let searchText = searchBar.text else{
            return
        }
        let lowerText = searchText.lowercased()
        
        if scopeIndex == 0 {
            fetchEvents(searchString: lowerText)
        }else if scopeIndex == 1{
            fetchUsers(stringValue: lowerText)
        }
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.isEmpty == true
        {
            filteredEvents.removeAll()
            self.collectionView?.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Changes the first responder to the search bar
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            searchBar.text = ""
            self.scopeIndex = selectedScope
            self.filteredEvents.removeAll()
            self.filteredUsers.removeAll()
            self.collectionView?.reloadData()
            break
        case 1:
            searchBar.text = ""
            self.scopeIndex = selectedScope
            self.filteredUsers.removeAll()
            self.filteredEvents.removeAll()
            self.collectionView?.reloadData()
            break
        default:
            break
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
//        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
    }
}
