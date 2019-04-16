//
//  PatterHelper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/16/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

final class PatterHelper {
    static func getImageSelectedBy(_ identifier: Int, patternName: String) -> UIImage? {
        let imageName = getImageNameBy(identifier)
        if imageName.isEmpty {
            return MaterialSelectedBackgroundWithText(materialName: patternName).asImage()
        }
        
        return UIImage(named: "\(imageName)Selected")
    }
    
    static func getImageBy(_ identifier: Int, patternName: String) -> UIImage? {
        let imageName = getImageNameBy(identifier)
        if imageName.isEmpty {
            return MaterialDefaultBackgroundWithText(materialName: patternName).asImage()
        }
        return UIImage(named: imageName)
    }
    
    fileprivate static func getImageNameBy(_ identifier: Int) -> String {
        
        switch identifier {
        case Identifier.Pattern.Solid:
            return "Solid"
        case Identifier.Pattern.Striped:
            return "Striped"
        case Identifier.Pattern.Checkered:
            return "Checkered"
        case Identifier.Pattern.Floral:
            return "Floral"
        case Identifier.Pattern.Dots:
            return "Dots"
        default:
            return ""
        }
    }
}
