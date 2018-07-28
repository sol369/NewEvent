//
//  NewEventSearchHeader.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class NewEventSearchHeader: BaseCell,UITextFieldDelegate{
    var searchVC: NewSearchVC?
    lazy var searchTextField: LeftPaddedTextField = {
        let searchTextField = LeftPaddedTextField()
        searchTextField.setupShadow2()
        searchTextField.backgroundColor = UIColor.white
        searchTextField.placeholder = "Search"
        searchTextField.layer.borderWidth = 0.2
        searchTextField.returnKeyType = .search
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.delegate = self
        return searchTextField
    }()
    
    lazy var segmentedControl: ScrollableSegmentedControl = {
        let segmentedControl = ScrollableSegmentedControl()
        segmentedControl.segmentStyle = .textOnly
        segmentedControl.setupShadow2()
        segmentedControl.tintColor = UIColor.rgb(red: 45, green: 162, blue: 232)
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.segmentSelected(sender:)), for: .valueChanged)
        segmentedControl.backgroundColor = UIColor.white
        return segmentedControl
    }()
    
    @objc func setupSegment(){
        self.segmentedControl.insertSegment(withTitle: "Events", at: 0)
        self.segmentedControl.insertSegment(withTitle: "Users", at: 1)
    }
    
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
        searchVC?.selectedIndex = sender.selectedSegmentIndex
        searchTextField.text = ""
        searchVC?.filteredUsers.removeAll()
        searchVC?.filteredEvents.removeAll()
        searchVC?.searchPromptLabel.isHidden = false
        searchVC?.collectionView?.reloadData()


    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        if textField.text?.count != 0 {
            //do search
            guard let lowerText = textField.text?.lowercased() else {
                return false
            }
            textField.resignFirstResponder()
            textField.text = ""
            switch segmentedControl.selectedSegmentIndex{
            case 0:
                print("looking for events")
                searchVC?.fetchEvents(searchString: lowerText)
            case 1:
                print("looking for users")
                searchVC?.fetchUsers(stringValue: lowerText)
            default:
                print("doing nothing")
            }
        }
        //else do nothing
        return true
    }
    
    override func setupViews() {
        backgroundColor = .clear
        addSubview(searchTextField)
        addSubview(segmentedControl)
        setupSegment()
        searchTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.left.right.equalTo(self).inset(11)
            make.height.equalTo(40)
        }
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(searchTextField.snp.bottom).offset(5)
            make.left.right.equalTo(self).inset(11)
            make.height.equalTo(40)

        }
    }
    
}
