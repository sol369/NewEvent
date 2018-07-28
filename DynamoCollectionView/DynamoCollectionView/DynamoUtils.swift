//
//  DynamoUtils.swift
//  DynamoCollectionView
//
//  Created by Shawn Miller on 10/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import Accelerate

class DynamoUtils {
    
    static func computeComplementaryColor(image: UIImage) -> (complementaryColor: UIColor, complementaryOpacity: CGFloat) {
        
        var complementaryOpacity = CGFloat(0.0)
        
        if let dominantColors = CCColorCube().extractColors(from: image, flags: 0){
            for i in 0..<dominantColors.count {
                var redV = CGFloat(0), greenV = CGFloat(0), blueV = CGFloat(0), alphaV = CGFloat(0)
                (dominantColors[i] as! UIColor).getRed(&redV, green: &greenV, blue: &blueV, alpha: &alphaV)
                complementaryOpacity += (redV + greenV + blueV)/3.0
            }
            complementaryOpacity = complementaryOpacity / CGFloat(dominantColors.count)
        }

        if let brightColors = CCColorCube().extractBrightColors(from: image, avoid: nil, count: 4){
            
            for i in 0..<brightColors.count {
                var redV = CGFloat(0), greenV = CGFloat(0), blueV = CGFloat(0), alphaV = CGFloat(0)
                (brightColors[i] as! UIColor).getRed(&redV, green: &greenV, blue: &blueV, alpha: &alphaV)
                let a = 1 - ( 0.299 * redV + 0.587 * greenV + 0.114 * blueV)/255
                if a > 0.5 && (redV + greenV + blueV) < 2 {
                    return (UIColor(red: redV, green: greenV, blue: blueV, alpha: 1.0), 0.75*(1 - complementaryOpacity*complementaryOpacity))
                }
            }
        }
        return (UIColor.orange, 1.0)
    }

}
