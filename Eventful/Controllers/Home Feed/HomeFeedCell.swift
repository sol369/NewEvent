//
//  HomeFeedCell.swift
//  Eventful
//
//  Created by Devanshu Saini on 22/09/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class HomeFeedCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    var homeFeedController: HomeFeedController?
    let emptyView = UIView()
    var scrollTimer: Timer?
    var x : Int = 0
    private let cellId = "cellId"
    var featuredEvents: [Event]?{
        didSet {
            homeFeedCollectionView.reloadData()
        }
    }
    
    var titles: String? {
        didSet {
            guard let titles = titles else {
            return
            }
            sectionNameLabel.text = titles
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"HelveticaNeue-CondensedBlack", size: 36.0)
        return sectionNameLabel
    }()
    
    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "Sorry We Currently Have No Events, \n In This Category Near You"
        emptyLabel.font = UIFont(name: "Avenir", size: 14)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        return emptyLabel
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let homeFeedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(homeFeedCollectionView)
        addSubview(sectionNameLabel)
        sectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeFeedCollectionView.anchor(top: sectionNameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        homeFeedCollectionView.delegate = self
        homeFeedCollectionView.dataSource = self
        homeFeedCollectionView.showsHorizontalScrollIndicator = false
        homeFeedCollectionView.register(HomeFeedEventCell.self, forCellWithReuseIdentifier: cellId)
    }
    
  

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentEventCount = featuredEvents?.count else{
            return 0
        }
        if currentEventCount == 0 {
            print("no events")
            setupEmptyDataSet()
        }else{
            emptyView.removeFromSuperview()
        }
        return currentEventCount
    }
    
    @objc func setupEmptyDataSet(){
        self.addSubview(emptyView)
        emptyView.backgroundColor = .clear
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        emptyView.addSubview(iconImageView)
        iconImageView.image = UIImage(named: "icons8-face-100")
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalTo(emptyView)
        }
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconImageView.snp.bottom).offset(30)
            make.left.right.equalTo(emptyView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: frame.width - 40, height: frame.height - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventDetails = EventDetailViewController()
        eventDetails.currentEvent = featuredEvents?[indexPath.item]
    homeFeedController?.navigationController?.pushViewController(eventDetails, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeFeedEventCell
        cell.event = featuredEvents?[indexPath.item]
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.homeFeedCollectionView.scrollToNearestVisibleCollectionViewCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.homeFeedCollectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }
}
