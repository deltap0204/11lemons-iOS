//
//  GarmentCardGenericVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/5/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class GarmentCardGenericVM: GarmentCardServiceTypesVM {
    
    func getPrice(_ department: Service, orderDetail: OrderDetailGeneral) -> Double {
        var price: Double = 0
        price = price + department.price
        if let services = department.typesOfService?.filter({$0.isSelected}) {
            if services.count > 0 {
                price = price + services[0].price
            }
        }
        
        return price
    }
    
    func getImage(_ order: Order, orderDetail: OrderDetailGeneral) -> UIImage? {
        return nil
    }
    
    func isImageRounded() -> Bool {
        return false
    }
    
    func getOrderName(_ orderDetail: OrderDetailGeneral, order: Order) -> String {
        return orderDetail.service?.name ?? ""
    }
    
    func getDescriptionLines(_ orderDetail: OrderDetailGeneral, order: Order) -> [GarmentCardLineDetailVM] {
        var linesToRet = [GarmentCardLineDetailVM]()
        
        if let service = orderDetail.service, let typesOfService = service.typesOfService {
            let typesOfServiceSelected = typesOfService.filter{$0.isSelected}
            if typesOfServiceSelected.count == 0 {
                let lineVM = GarmentCardLineDetailVM(text: "Select Service", price: 0)
                linesToRet.append(lineVM)
                return linesToRet
            }
        }
        
        var attributesString = ""
        if let garment = orderDetail.garment {
            if let properties = garment.properties {
                for property in properties {
                    if let attributes = property.attributes {
                        for att in attributes {
                            if att.upcharge {
                                let price = att.upchargeAmount == 0.0 ? ((att.upchargeMarkup / 100 )  * (orderDetail.pricePer ?? 0)) : att.upchargeAmount
                                let lineVM = GarmentCardLineDetailVM(text: att.attributeName, price: price)
                                linesToRet.append(lineVM)
                            } else {
                                attributesString = attributesString + att.attributeName + ", "
                            }
                        }
                    }
                }
            }
        }
        
        if attributesString != "" {
            attributesString = attributesString.substring(to: attributesString.index(before: attributesString.endIndex))
            attributesString = attributesString.substring(to: attributesString.index(before: attributesString.endIndex))
        }
        let lineVM = GarmentCardLineDetailVM(text: attributesString, price: 0)
        linesToRet.append(lineVM)
        
        return linesToRet
    }
    
    func shouldDisplayLbsLabel() -> Bool {
        return false
    }
}

