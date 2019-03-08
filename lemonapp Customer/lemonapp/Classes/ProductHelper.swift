//
//  ProductHelper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 10/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation

final class ProductHelper {
 
    static func getImageBy(_ identifier: Int) -> UIImage? {
        return UIImage(named: getImageNameBy(identifier))
    }
    
    static func getSelectedImageBy(_ identifier: Int) -> UIImage? {
        let selectedImageName = getImageNameBy(identifier) + "_selected"
        return UIImage(named: selectedImageName)
    }
    
    static func getImageNameBy(_ identifier: Int) -> String {
        var imageName = "ic_service_"
        switch identifier {
        case Identifier.Department.WashFold:
            imageName += "wash_fold"
            break
        case Identifier.Department.DryCleaning:
            imageName += "hanger"
            break
        case Identifier.Department.MenShirts:
            imageName += "launder_press"
            break
        case Identifier.Department.Specialty:
            imageName += "specialty_cleaning"
            break
        case Identifier.Department.Shoe:
            imageName += "shoe_shine_repairs"
        break
        case Identifier.Department.Storage:
            imageName += "clothing_storage"
            break
        case Identifier.Department.RepairsAlterations:
            imageName += "repairs_alterations"
            break
        case Identifier.Department.Travel:
            imageName += "travel_valet_service"
            break
        case Identifier.Department.Rentals:
            imageName += "rentals"
            break
        case Identifier.Department.BabyClothes:
            imageName += "baby_clothes"
            break
        case Identifier.Department.Maternity:
            imageName += "maternity_clothing"
            break
        case Identifier.Department.Donations:
            imageName += "clothing_donations"
            break
        case Identifier.Department.MilitaryUniforms:
            imageName += "military_uniforms"
            break
        case Identifier.Department.FirstResponders:
            imageName += "first_responders"
            break
        case Identifier.Department.FlagCleaning:
            imageName += "flag_cleaning"
            break
        default:
            imageName += "new"
            break
        }
        return imageName
    }
    
    static func getImageReceiptNameSelectedBy(_ identifier: Int) -> UIImage? {
        let imageName = getImageReceiptNameBy(identifier) + "Selected"
        return UIImage(named: imageName)
    }
    
    static func getImageReceiptNameNormalBy(_ identifier: Int) -> UIImage? {
        let imageName = getImageReceiptNameBy(identifier)
        return UIImage(named: imageName)
    }

    
    fileprivate static func getImageReceiptNameBy(_ identifier: Int) -> String {
        var imageName = ""
        switch identifier {
        case Identifier.Department.WashFold:
            imageName += "WashFold"
            break
        case Identifier.Department.DryCleaning:
            imageName += "DryCleaning"
            break
        case Identifier.Department.MenShirts:
            imageName += "Shirts"
            break
        case Identifier.Department.Specialty:
            imageName += "SpecialtyCleaning"
            break
        case Identifier.Department.Shoe:
            imageName += "Shoes"
            break
        case Identifier.Department.Storage:
            imageName += "Storage"
            break
        case Identifier.Department.RepairsAlterations:
            imageName += "Alterations"
            break
        case Identifier.Department.Travel:
            imageName += "LuggageValet"
            break
        case Identifier.Department.Rentals:
            imageName += "Rentals"
            break
        case Identifier.Department.BabyClothes:
            imageName += "BabyClothes"
            break
        case Identifier.Department.Maternity:
            imageName += "Maternity"
            break
        case Identifier.Department.Donations:
            imageName += "Donations"
            break
        case Identifier.Department.MilitaryUniforms:
            imageName += "MilitaryService"
            break
        case Identifier.Department.FirstResponders:
            imageName += "FirstResponders"
            break
        case Identifier.Department.FlagCleaning:
            imageName += "FlagCleaning"
            break
        default:
            imageName += "NewService"
            break
        }
        return imageName
    }
    
    //Mark: - Services
    static func getServiceImageSelectedBy(_ identifier: Int, serviceName: String) -> UIImage? {
        let imageName = getServiceImageNameBy(identifier) + "Selected"
        
        if imageName.contains("NoIconService") {
            return ServiceSelectedBackgroundWithText(serviceName: serviceName).asImage()
        }
        
        return UIImage(named: imageName)
    }
    
    static func getServiceImageBy(_ identifier: Int, serviceName: String) -> UIImage? {
        let imageName = getServiceImageNameBy(identifier)
        
        if imageName.contains("NoIconService") {
            return ServiceDefaultBackgroundWithText(serviceName: serviceName).asImage()
        }
        
        return UIImage(named: imageName)
    }
    
    
    fileprivate static func getServiceImageNameBy(_ identifier: Int) -> String {
        var imageName = ""
        switch identifier {
        case Identifier.Service.Regular:
            imageName += "Regular"
            break
        case Identifier.Service.White:
            imageName += "White"
            break
        case Identifier.Service.HangDry:
            imageName += "HangDry"
            break
        case Identifier.Service.LaunderPress:
            imageName += "LaunderPress"
            break
        case Identifier.Service.HangDry:
            imageName += "DryClean"
            break
        case Identifier.Service.LaunderHandPress:
            imageName += "HandPress"
            break
        default:
            imageName += "NoIconService"
            break
        }
        return imageName
    }
}
