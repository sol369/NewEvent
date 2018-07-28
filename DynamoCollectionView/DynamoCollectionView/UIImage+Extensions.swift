//
//  UIImage+Extensions.swift
//  DynamoCollectionView
//
//  Created by Shawn Miller on 10/15/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation

extension UIImage {
    
    func featheredImageWithImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

        guard let ctx = UIGraphicsGetCurrentContext() else { return nil}
        let featherLocation = [CGFloat(0.9), CGFloat(1)]
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        let gradientColors = [UIColor.init(white: 0, alpha: 1.0).cgColor, UIColor.init(white: 0, alpha: 0.5).cgColor]
    
        guard let cgImage = self.cgImage else { return nil }
        guard let gradient = CGGradient(colorsSpace: cgImage.colorSpace, colors: gradientColors as CFArray, locations: featherLocation) else { return nil }
        
        ctx.saveGState()

        ctx.setBlendMode(.destinationIn)
    
        let offsetBorder = CGFloat(50)
        
        ctx.drawLinearGradient(gradient, start: CGPoint(x: self.size.width / 2, y:offsetBorder), end: CGPoint(x: self.size.width / 2, y:0), options: .drawsBeforeStartLocation)
        
        ctx.restoreGState()
    
        let featheredImage = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
    
        return featheredImage
    }
}

