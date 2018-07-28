//
//  CategoryCell.swift
//  Eventful
//
//  Created by Shawn Miller on 3/21/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate {
    private let cellID = "cellID"
    var homeFeedController: HomeFeedController?
    let emptyView = UIView()
    var categoryEvents: [Event]?{
        didSet{
            categoryCollectionView.reloadData()
        }
    }
    lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "Sorry We Currently Have No Events, \n In This Category Near You"
        emptyLabel.font = UIFont(name: "Avenir", size: 14)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        return emptyLabel
    }()
    
    lazy var iconImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var titles: String? {
        didSet {
            guard let titles = titles else {
                return
            }
             sectionNameLabel.text = titles
        }
    }
    
    let sectionNameLabel : UILabel =  {
        let sectionNameLabel = UILabel()
        sectionNameLabel.font = UIFont(name:"HelveticaNeue-CondensedBlack", size: 25.0)
        return sectionNameLabel
    }()
    
    let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentEventCount = categoryEvents?.count else{
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryEventCell
        cell.event = categoryEvents?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: frame.height - 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventDetails = EventDetailViewController()
        eventDetails.currentEvent = categoryEvents?[indexPath.item]
        homeFeedController?.navigationController?.pushViewController(eventDetails, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 14, bottom: 5, right: 14)
    }
 
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.categoryCollectionView.scrollToNearestVisibleCollectionViewCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.categoryCollectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func setupViews(){
        backgroundColor = .clear
        addSubview(categoryCollectionView)
        addSubview(sectionNameLabel)
        sectionNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 14, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                categoryCollectionView.anchor(top: sectionNameLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                categoryCollectionView.delegate = self
                categoryCollectionView.dataSource = self
                categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.register(CategoryEventCell.self, forCellWithReuseIdentifier: cellID)
        
    }
}

extension UICollectionView {
    func scrollToNearestVisibleCollectionViewCell() {
        self.decelerationRate = UIScrollViewDecelerationRateFast
        let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<self.visibleCells.count {
            let cell = self.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = self.indexPath(for: cell)!.row
            }
        }
        if closestCellIndex != -1 {
            self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}




