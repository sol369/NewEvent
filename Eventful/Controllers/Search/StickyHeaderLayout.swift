//
//  StickyHeaderLayout.swift
//  Eventful
//
//  Created by Shawn Miller on 6/26/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit

class StickyHeaderLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect) as! [UICollectionViewLayoutAttributes]
        let headerNeedingLayout = NSMutableIndexSet()
        for attributes in layoutAttributes {
            if attributes.representedElementCategory == .cell {
                headerNeedingLayout.add(attributes.indexPath.section)
            }
        }
        
        for attributes in layoutAttributes {
            if let elementKind = attributes.representedElementKind {
                if elementKind == UICollectionElementKindSectionHeader {
                    headerNeedingLayout.remove(attributes.indexPath.section)
                }
            }
        }
        
        headerNeedingLayout.enumerate { (index, stop) in
            let indexPath  = IndexPath(item: 0, section: index)
            let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath)
            layoutAttributes.append(attributes!)
        }
        
        for attributes in layoutAttributes {
            if let elementKind = attributes.representedElementKind {
                if elementKind == UICollectionElementKindSectionHeader {
                    let section  = attributes.indexPath.section
                    let attributsForItemInSection = layoutAttributesForItem(at: IndexPath(item: 0, section: section))
                    _ = layoutAttributesForItem(at: IndexPath(item: (collectionView?.numberOfItems(inSection: section))! - 1, section: section))
                    var frame = attributes.frame
                    let offset = collectionView?.contentOffset.y
                    let minY = (attributsForItemInSection?.frame.minY)! - frame.height
                    let maxY = (attributsForItemInSection?.frame.maxX)! - frame.height
                    let y = min(max(offset!,minY),maxY)
                    frame.origin.y = y
                    attributes.frame = frame
                    attributes.zIndex = 99
                }
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
