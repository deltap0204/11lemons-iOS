//
//  GarmentCardWashNFoldVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/5/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class GarmentCardWashNFoldVM: GarmentCardServiceTypesVM {
    
    func getPrice(_ department: Service, orderDetail: OrderDetailGeneral) -> Double {
        var price: Double = 0
        if let services = department.typesOfService?.filter({$0.isSelected}) {
            if services.count > 0 {
                let serviceSelected = services[0]
                if serviceSelected.id == 180 {
                    // Whats happend with this IDs?
                } else {
                    if let weight = orderDetail.weight {
                        if weight != 0.0 {
                            price = weight * serviceSelected.price
                        }
                    }
                }
            }
        }
        
        return price
    }
    
    func getImage(_ order: Order, orderDetail: OrderDetailGeneral) -> UIImage? {
        return order.detergent.image
    }
    
    func isImageRounded() -> Bool {
        return true
    }
    
    func getOrderName(_ orderDetail: OrderDetailGeneral, order: Order) -> String {
        guard let service = orderDetail.service else { return "" }
        return service.name ?? String(service.id)
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
        var secondLineVM: GarmentCardLineDetailVM? = nil
        
        if let department = orderDetail.service, let services = department.typesOfService?.filter({$0.isSelected}) {
            if services.count > 0 {
                let serviceSelected = services[0]
                let text = serviceSelected.unitType.lowercased() == "pounds" ? "pound" : serviceSelected.unitType.lowercased()
                attributesString = "\(serviceSelected.name): \(String(format: "$%.2f", serviceSelected.price)) per \(text)"
            }
        }
        if let libras = orderDetail.weight {
            if libras != 0.0 {
                
                var productsLine = ""
                if order.detergent == Detergent.MountainSpring {
                    productsLine = "Mountain Spring"
                } else {
                    productsLine = order.detergent == Detergent.FreeNGentle ? "Free & Gentle" : order.detergent.rawValue
                }
                if order.softener != Softener.None {
                    productsLine = productsLine + ", " + order.softener.rawValue
                }
                if order.dryer != Dryer.None {
                    productsLine = productsLine + ", " + order.dryer.rawValue
                }
                secondLineVM = GarmentCardLineDetailVM(text: productsLine, price: 0)
            }
        }
        
        let firstLineVM = GarmentCardLineDetailVM(text: attributesString, price: 0)
        linesToRet.append(firstLineVM)
        if secondLineVM != nil {
            linesToRet.append(secondLineVM!)
        }
        
        return linesToRet
    }
    
    func shouldDisplayLbsLabel() -> Bool {
        return true
    }
}
