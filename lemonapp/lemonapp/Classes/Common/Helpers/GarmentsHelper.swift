//
//  GarmentsHelper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/16/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation
final class GarmentsHelper {
    static func getImageSelectedBy(_ identifier: Int) -> UIImage? {
        let imageName = getImageNameBy(identifier) + "Selected"
        return UIImage(named: imageName)
    }

    static func getImageBy(_ identifier: Int) -> UIImage? {
        let imageName = getImageNameBy(identifier)
        return UIImage(named: imageName)
    }


    fileprivate static func getImageNameBy(_ identifier: Int) -> String {
        switch identifier {
        case Identifier.Service.Blouse:
            return "Blouse"
        case Identifier.Service.Pants:
            return "Pants"
        case Identifier.Service.BaseballCap:
            return "BaseballCap"
        case Identifier.Service.Dress:
            return "Dress"
        case Identifier.Service.Gown:
            return "Gown"
        case Identifier.Service.Belt:
            return "Belt"
        case Identifier.Service.Jacket:
            return "Jacket"
        case Identifier.Service.Jumpsuit:
            return "Jumpsuit"
        case Identifier.Service.PoloShirt:
            return "Polo"
        case Identifier.Service.Bowtie:
            return "Bowtie"
        case Identifier.Service.Scarf:
            return "Scarf"
        case Identifier.Service.MenShirt:
            return "MensShirt"
        case Identifier.Service.Shorts:
            return "Shorts"
        case Identifier.Service.SkirtSuit:
            return "SkirtSuit"
        case Identifier.Service.Sweater:
            return "Sweater"
        case Identifier.Service.Tie:
            return "Tie"
        case Identifier.Service.Vest:
            return "Vest"
        case Identifier.Service.BridalGown:
            return "BridalDress"
        case Identifier.Service.CocktailDress:
            return "CocktailDress"
        case Identifier.Service.WomenShoes:
            return "WomensShoes"
        case Identifier.Service.AthleticShorts:
            return "AthleticShorts"
        case Identifier.Service.Hoodie:
            return "Hoodie"
        case Identifier.Service.Gloves:
            return "Gloves"
        case Identifier.Service.SweaterRobe:
            return "SweaterRobe"
        case Identifier.Service.MilitaryUniform:
            return "Military"
        case Identifier.Service.TShirt:
            return "TShirt"
        case Identifier.Service.Socks:
            return "Socks"
        case Identifier.Service.SportJacket:
            return "SportJacket"
        case Identifier.Service.Top:
            return "BathingSuit"
        case Identifier.Service.Cardigan:
            return "Cardigan"
        default:
            return ""
        }
    }

    static func getIconName(_ identifier: Int) -> String {
        let imageName = getImageNameBy(identifier)
        if imageName.isEmpty {
            return ""
        }
        return imageName + "Icon"
    }
}
