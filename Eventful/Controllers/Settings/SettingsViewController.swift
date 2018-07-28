//
//  SettingsViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 8/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth


class SettingsViewController: UITableViewController {
    var authHandle: AuthStateDidChangeListenerHandle?
    let settingsCell = "settingsCell"
    let settingsCell2 = "settingsCell2"
    let settingsOptionsTwoDimArray = [["Logout"],["Make Profile Private"],["Privacy Policy"],
                                      ["Contact Us"],["Submit an Event"]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        setupVc()
    }
    
    @objc func setupVc(){
        view.backgroundColor = UIColor.white
        navigationItem.title = "Settings"
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: settingsCell)
        self.tableView.register(PrivateCell.self, forCellReuseIdentifier: settingsCell2)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tabBarController?.tabBar.isHidden = true
        authHandle = AuthService.authListener(viewController: self)
    }
    deinit {
        AuthService.removeAuthListener(authHandle: authHandle)
    }
    
 
    //will log the user out
    @objc func handleLogout(){
        print("Logout button pressed")
      AuthService.presentLogOut(viewController: self)
        
    }
    //will dismiss the screen
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsOptionsTwoDimArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptionsTwoDimArray[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if[indexPath.section][indexPath.row] == [1][0]{
            let cell = tableView.dequeueReusableCell(withIdentifier: settingsCell2, for: indexPath) as! PrivateCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: settingsCell, for: indexPath) as UITableViewCell
            let currentSetting = settingsOptionsTwoDimArray[indexPath.section][indexPath.row]
            cell.textLabel?.text = currentSetting
            cell.textLabel?.textAlignment = .left
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if [indexPath.section][indexPath.row] == [0][0]{
            print("Logout Clicked")
            self.handleLogout()
        }
        if [indexPath.section][indexPath.row] == [3][0]{
            print("Contact US Clicked")
            let contactVc = ContactUsVC()
            self.navigationController?.pushViewController(contactVc, animated: false)
        }
        if [indexPath.section][indexPath.row] == [4][0]{
            print("Submit an Event Clicked")
            let submit = submitEvent()
            self.navigationController?.pushViewController(submit, animated: false)
        }
    }


}
