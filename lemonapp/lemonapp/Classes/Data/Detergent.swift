//
//  Detergent.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation


enum Detergent: String {
    case Original,MountainSpring,Lavender,FreeNGentle
    
    var image: UIImage {
        switch self {
            case .Original:
                return UIImage(named: "Original")!
            case .MountainSpring:
                return UIImage(named: "MountainSpring")!
            case .Lavender:
                return UIImage(named: "Lavender")!
            case .FreeNGentle:
                return UIImage(named: "Free&Gentle")!
        }
    }
}