//
//  CustomFlowLayout.swift
//  Eventful
//
//  Created by Shawn Miller on 6/27/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit

class CustomFlowLayout : UICollectionViewFlowLayout {
    var insertingIndexPaths = [IndexPath]()
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertingIndexPaths.removeAll()
        
        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate,
                update.updateAction == .insert {
                insertingIndexPaths.append(indexPath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
        insertingIndexPaths.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if insertingIndexPaths.contains(itemIndexPath) {
        attributes?.alpha = 0.0
        attributes?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        //attributes?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        
        }
    
        return attributes
    }
}
