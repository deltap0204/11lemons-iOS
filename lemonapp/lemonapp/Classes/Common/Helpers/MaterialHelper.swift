//
//  MaterialHelper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/16/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

final class MaterialHelper {
    static func getImageSelectedBy(_ identifier: Int, materialName: String) -> UIImage? {
        let imageName = getImageNameBy(identifier)
        if imageName.isEmpty {
            return MaterialSelectedBackgroundWithText(materialName: materialName).asImage()
        }
        
        return UIImage(named: "\(imageName)Selected")
    }
    
    static func getImageBy(_ identifier: Int, materialName: String) -> UIImage? {
        let imageName = getImageNameBy(identifier)
        if imageName.isEmpty {
            return MaterialDefaultBackgroundWithText(materialName: materialName).asImage()
        }
        return UIImage(named: imageName)
    }
    
    fileprivate static func getImageNameBy(_ identifier: Int) -> String {
        
        switch identifier {
        case Identifier.Material.Cotton:
            return "Cotton"
        case Identifier.Material.Polyester:
            return "Polyester"
        case Identifier.Material.Wool:
            return "Wool"
        case Identifier.Material.Rayon:
            return "Rayon"
        case Identifier.Material.Cashmere:
            return "Cashmere"
        case Identifier.Material.Denim:
            return "Denim"
        case Identifier.Material.Silk:
            return "Silk"
        case Identifier.Material.Wool2:
            return "Wool2"
        default:
            return ""
        }
    }
}
