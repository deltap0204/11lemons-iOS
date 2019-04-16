//
//  GarmentCardServiceTypesVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/5/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

protocol GarmentCardServiceTypesVM {
    func getImage(_ order: Order, orderDetail: OrderDetailGeneral) -> UIImage?
    func isImageRounded() -> Bool
    func getPrice(_ department: Service, orderDetail: OrderDetailGeneral) -> Double
    func getDescriptionLines(_ orderDetail: OrderDetailGeneral, order: Order) -> [GarmentCardLineDetailVM]
    func getOrderName(_ orderDetail: OrderDetailGeneral, order: Order) -> String
    func shouldDisplayLbsLabel() -> Bool
}

extension GarmentCardServiceTypesVM {
    func getBrandImage(_ order: Order, orderDetail: OrderDetailGeneral) -> UIImage? {
        if let garment = orderDetail.garment {
            if let properties = garment.properties {
                let brandCategories = properties.filter {$0.id == 1}
                if brandCategories.count > 0 {
                    let propertiesSelected = brandCategories[0].attributes?.filter {$0.isSelected}
                    if propertiesSelected != nil && propertiesSelected!.count > 0 {
                        let brandPropertySelected = propertiesSelected![0]
                        return BrandHelper.getIconBy(brandPropertySelected.id)
                    }
                }
            }
        }
        return nil
    }

}
