//
//  BrandHelper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/16/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

final class BrandHelper {
    static func getImageSelectedBy(_ identifier: Int, brandName: String) -> UIImage? {
        let imageName = getBrandImageNameBy(identifier) + "Selected"
        
        if imageName.contains("NoIcon") {
            return BrandSelectedBackgroundWithText(brandName: brandName).asImage()
        }
        
        return UIImage(named: imageName)
    }
    
    static func getImageBy(_ identifier: Int, brandName: String) -> UIImage? {
        let imageName = getBrandImageNameBy(identifier)
        
        if imageName.contains("NoIcon") {
            return BrandDefaultBackgroundWithText(brandName: brandName).asImage()
        }
        return UIImage(named: imageName)
    }
    
    static func getIconBy(_ identifier: Int) -> UIImage? {
        let imageName = getBrandImageNameBy(identifier) + "Icon"
        return UIImage(named: imageName)
    }
    
    fileprivate static func getBrandImageNameBy(_ identifier: Int) -> String {
        var imageName = ""
        switch identifier {
        case Identifier.Brand.JCrew:
            imageName += "jCrew"
            break
        case Identifier.Brand.BrooksBrothers:
            imageName += "BrooksBrothers"
            break
        case Identifier.Brand.Bonobos:
            imageName += "Bonobos"
            break
        case Identifier.Brand.BananaRepublic:
            imageName += "BananaRepubic"
            break
        case Identifier.Brand.Clarks:
            imageName += "Clarks"
            break
        case Identifier.Brand.RalphLauren:
            imageName += "RalphLauren"
            break
        case Identifier.Brand.Theory:
            imageName += "Theory"
            break
        default:
            imageName += "NoIcon"
            break
        }
        return imageName
    }
}
