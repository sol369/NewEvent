//
//  CategoryViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 4/3/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class CategoryViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout{
    var events = [Event]()
    let cellID = "cellID"
    let titleView = UILabel()
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.font = UIFont(name: "Avenir", size: 18)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        return emptyLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    self.collectionView!.register(CategoryEventCell.self, forCellWithReuseIdentifier: cellID)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }

    @objc func setupViews(){
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
        self.navigationItem.leftBarButtonItem = backButton
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "homePageBG")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.collectionView?.backgroundColor = UIColor(patternImage: image)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        titleView.font = UIFont.boldSystemFont(ofSize: 18)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        titleView.isUserInteractionEnabled = true
    }
    @objc func GoBack(){
        print("BACK TAPPED")
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if events.count == 0 {
            print("no events")
            setupEmptyDataSet()
        }
        return events.count
    }
    
    @objc func setupEmptyDataSet(){
        let emptyView = UIView()
        view.addSubview(emptyView)
        emptyView.backgroundColor = .clear
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        emptyView.addSubview(iconImageView)
        iconImageView.image = UIImage(named: "icons8-face-50")
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalTo(emptyView)
        }
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconImageView.snp.bottom).offset(30)
            make.left.right.equalTo(emptyView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 20)/3
        return CGSize(width: width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 5, right:5)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell selected")
        let eventDetails = EventDetailViewController()
        eventDetails.currentEvent = events[indexPath.item]
        self.navigationController?.pushViewController(eventDetails, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryEventCell
        cell.event = events[indexPath.item]
        // Configure the cell
        return cell
    }
    
  

}
