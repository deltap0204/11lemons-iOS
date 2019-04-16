//
//  IdentifierHelper.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/17/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation


struct Identifier
{
    //MARK: - Department
    struct Department {
        static let WashFold = 1
        static let DryCleaning = 2
        static let MenShirts = 3
        static let Specialty = 126
        static let Shoe = 127
        static let Storage = 128
        static let RepairsAlterations = 129
        static let Travel = 130
        static let Rentals = 131
        static let BabyClothes = 132
        static let Maternity = 133
        static let Donations = 134
        static let MilitaryUniforms = 135
        static let FirstResponders = 136
        static let FlagCleaning = 137
    }
    
    //MARK: - Service
    struct Service {
        static let Blouse = 33
        static let Pants = 34
        static let BaseballCap = 35
        static let Dress = 38
        static let Gown = 41
        static let Belt = 43
        static let Jacket = 45
        static let Jumpsuit = 46
        static let PoloShirt = 53
        static let Bowtie = 55
        static let Scarf = 56
        static let MenShirt = 57
        static let Shorts = 58
        static let SkirtSuit = 60
        static let Sweater = 64
        static let Tie = 65
        static let Vest = 67
        static let BridalGown = 76
        static let CocktailDress = 77
        static let WomenShoes = 78
        static let AthleticShorts = 79
        static let Hoodie = 80
        static let Gloves = 89
        static let SweaterRobe = 90
        static let MilitaryUniform = 91
        static let TShirt = 98
        static let Socks = 99
        static let Regular = 145
        static let White = 147
        static let HangDry = 148
        static let ServicePostman12 = 169
        static let ServicePostman13 = 171
        static let ServicePostman133 = 173
        static let LaunderPress = 176
        static let DryClean = 179
        static let ShoeShine = 181
        static let BootShine = 186
        static let ButtonReplacement = 187
        static let LaunderHandPress = 188
        static let SportJacket = 189
        static let Top = 190
        static let Cardigan = 191
        static let ZipUpSweater = 192
    }
    
    //MARK: - Category
    struct Category {
        static let Brand = 1
        static let Garment = 2
        static let Color = 3
        static let Pattern = 4
        static let Material = 5
        static let LleroneTestCategory = 8
    }
    
    //MARK: - Attribute
    struct Brand {
        static let JCrew = 1
        static let BrooksBrothers = 59
        static let Bonobos = 68
        static let BananaRepublic = 69
        static let Clarks = 70
        static let RalphLauren = 71
        static let Theory = 72
    }
    
    struct Pattern {
        static let Solid = 38
        static let Striped = 39
        static let Checkered = 40
        static let Floral = 41
        static let Dots = 73
    }
    
    struct Material {
        static let Cotton = 42
        static let Polyester = 43
        static let Wool = 44
        static let Rayon = 45
        static let Cashmere = 46
        static let Denim = 47
        static let Silk = 48
        static let Wool2 = 58
    }
}
