//
//  NewEventSearchCell.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class NewEventSearchCell: BaseCell {
    var searchVc: NewSearchVC?
    var filteredEvents : [Event]? {
        didSet{
            guard filteredEvents != nil else {
                return
            }
            eventSearchCollectionView.reloadData()
        }
    }
    private let cellId = "cellId"
    let eventSearchCollectionView: UICollectionView = {
        let layout = CustomFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    override func setupViews() {
        backgroundColor = .clear
        addSubview(eventSearchCollectionView)
        eventSearchCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(5)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).inset(5)
        }
        eventSearchCollectionView.delegate = self
        eventSearchCollectionView.dataSource = self
        eventSearchCollectionView.register(SearchCell.self, forCellWithReuseIdentifier: cellId)

    }
}

extension NewEventSearchCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentCount = filteredEvents?.count else{
            return 0
        }
        return currentCount
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width - 40, height: 215)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 160, left: 5, bottom: 20, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = filteredEvents![indexPath.item]
        let currentEventDetailController = EventDetailViewController()
        currentEventDetailController.currentEvent = event
        searchVc?.navigationController?.pushViewController(currentEventDetailController, animated: true)

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        cell.event = filteredEvents?[indexPath.item]
        return cell
    }
    
    
}
