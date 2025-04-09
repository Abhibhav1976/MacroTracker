//
//  ImageScaling.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 08/04/25.
//

import UIKit

extension UIImage {
    func scaledTo720p() -> UIImage? {
        let maxDimension: CGFloat = 1280 // 720p is 1280x720 or 720x1280
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if aspectRatio > 1 {
            // Landscape
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // Portrait or square
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage
    }
}
