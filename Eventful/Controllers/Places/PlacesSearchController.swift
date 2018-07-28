//
//  PlacesSearchController.swift
//  Eventful
//
//  Created by Shawn Miller on 4/6/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import GooglePlaces
import SVProgressHUD

class PlacesSearchController: UIViewController, UICollectionViewDelegateFlowLayout {
    let cellID = "cellID"
    var homeFeedController: HomeFeedController?
    let titleView = UILabel()
    var placesClient = GMSPlacesClient()
    var arrayAddress = [GMSAutocompletePrediction]()
    lazy var filter : GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        return filter
    }()

    lazy var searchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.setupShadow2()
        sb.sizeToFit()
        sb.barTintColor = UIColor.white
        sb.layer.borderWidth = 0.5
        sb.clipsToBounds = true
        sb.layer.cornerRadius = 2.0
        sb.placeholder = "Search"
        sb.delegate = self
        let searchIconImage = UIImage(named: "icons8-marker-48")
        sb.setImage(searchIconImage, for: UISearchBarIcon.search, state: UIControlState.normal)
        let textFieldInsideUISearchBar = sb.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.font = UIFont.systemFont(ofSize: 14)
        return sb
    }()
    
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
        label.text = "Hi \(String(describing: User.current.username!))!\nExplore and Discover \nNew Events\nIn Different Cities"
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        // Do any additional setup after loading the view.
    }
    

    @objc func setupViews(){
        //register a cell to the collectionView
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "homePageBG")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)
        searchCollectionView.register(SearchPlacesCell.self, forCellWithReuseIdentifier: cellID)
        searchCollectionView.keyboardDismissMode = .onDrag
        searchCollectionView.alwaysBounceVertical = true
        searchCollectionView.backgroundColor = .clear
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(searchBar)
        view.addSubview(searchCollectionView)
        searchBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).inset(5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.height.equalTo(40)
        }
        searchCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        searchCollectionView.addSubview(searchPromptLabel)
        searchPromptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(searchCollectionView.snp.top).offset(10)
            make.left.right.equalTo(searchCollectionView).inset(10)
        }
        
        titleView.font = UIFont(name: "Avenir", size: 18)
        titleView.text = "Location"
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        titleView.isUserInteractionEnabled = true

    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension PlacesSearchController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayAddress.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SearchPlacesCell
        cell.sectionNameLabel.attributedText = arrayAddress[indexPath.item].attributedFullText
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 55)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentLocation = arrayAddress[indexPath.item].placeID
       // print("cell tapped and current location is \(currentLocation)")
        let city = arrayAddress[indexPath.item].attributedPrimaryText.string
        let stateHolder = arrayAddress[indexPath.item].attributedSecondaryText?.string.split(separator: ",")
        let string = "\(city), \(String(describing: stateHolder![0])) ▼"
        self.homeFeedController?.titleView.text = string
        self.homeFeedController?.updateCVWithLocation(placeID: currentLocation!)
        self.homeFeedController?.navigationController?.popViewController(animated: true)
        SVProgressHUD.show(withStatus: "Grabbing Events")
    }
    
}

extension PlacesSearchController: UICollectionViewDelegate {

}

extension PlacesSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchPromptLabel.isHidden = true
        guard let searchText = searchBar.text else {
            return
        }
        if searchText == "" {
            self.arrayAddress = [GMSAutocompletePrediction]()
        }else{
            GMSPlacesClient.shared().autocompleteQuery(searchText, bounds: nil, filter: filter, callback: { (res, err) in
                if err == nil && res != nil {
                    self.arrayAddress = res!
                    self.searchCollectionView.reloadData()
                }
            })
        }
        
    }
    

}
