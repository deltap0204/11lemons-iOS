//
//  Shirts.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


enum Shirt: String {
    case Folded, Hanger
    
    var image: UIImage {
        switch self {
            case .Folded:
                return UIImage(named: "GarmentCardFolded")!
            case .Hanger:
                return UIImage(named: "GarmentCardMenShirt")!
        }
    }
}