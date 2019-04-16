//
//  GarmentCardDryCleaningVM.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 3/16/18.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

class GarmentCardDryCleaningVM: GarmentCardServiceTypesVM {
    
    func getPrice(_ department: Service, orderDetail: OrderDetailGeneral) -> Double {
        var price: Double = 0
        if let services = department.typesOfService?.filter({$0.isSelected}) {
            if services.count > 0 {
                let serviceSelected = services[0]
                price = serviceSelected.price
            }
        }
        
        return price
    }
    
    func getImage(_ order: Order, orderDetail: OrderDetailGeneral) -> UIImage? {
        var imageToRet: UIImage? = order.shirt == .Folded ? order.shirt.image : UIImage(named: "ic_blue_hanger")

        //crear metodo para traer service seleccionado
        if let department = orderDetail.service, let services = department.typesOfService?.filter({$0.isSelected}) {
            if services.count > 0 {
                let serviceSelected = services[0]
                let imageName = GarmentsHelper.getIconName(serviceSelected.id)
                if !imageName.isEmpty {
                    imageToRet = UIImage(named: imageName)
                }
            }
        }
    
        if let brandImage = getBrandImage(order, orderDetail: orderDetail) {
            imageToRet = brandImage
        }
        
        return imageToRet
    }
    
    func isImageRounded() -> Bool {
        return false
    }
    
    func getOrderName(_ orderDetail: OrderDetailGeneral, order: Order) -> String {
        if let department = orderDetail.service, let services = department.typesOfService?.filter({$0.isSelected}) {
            if services.count > 0 {
                let serviceSelected = services[0]
                return serviceSelected.name
            }
        }
        return orderDetail.service?.name ?? ""
    }
    
    func getDescriptionLines(_ orderDetail: OrderDetailGeneral, order: Order) -> [GarmentCardLineDetailVM] {
        var linesToRet = [GarmentCardLineDetailVM]()
        
        if let service = orderDetail.service, let typesOfService = service.typesOfService {
            let typesOfServiceSelected = typesOfService.filter{$0.isSelected}
            if typesOfServiceSelected.count == 0 {
                let lineVM = GarmentCardLineDetailVM(text: "Select Garment Type", price: 0)
                linesToRet.append(lineVM)
                return linesToRet
            }
        }
        
        var firstLine = ""
        var secondLine = ""
        var attributesString = ""
        
        if let department = orderDetail.service {
            firstLine = "\(department.name)"
        }
        
        if order.shirt == Shirt.Hanger {
            firstLine = firstLine + ", Hanger"
        } else {
            secondLine = "Folded"
        }
        
        if order.starch != Starch.None {
            firstLine = firstLine + ", " + order.starch.rawValue
        }
        
        var attPrice = [GarmentCardLineDetailVM]()
        if let garment = orderDetail.garment {
            if let properties = garment.properties {
                for property in properties {
                    if let attributes = property.attributes {
                        for att in attributes {
                            if att.upcharge {
                                let price = att.upchargeAmount == 0.0 ? ((att.upchargeMarkup / 100 )  * (orderDetail.pricePer ?? 0)) : att.upchargeAmount
                                let lineVM = GarmentCardLineDetailVM(text: att.attributeName, price: price)
                                attPrice.append(lineVM)
                            } else if att.categoryId == 4 {
                                let lineVM = GarmentCardLineDetailVM(text: att.attributeName, price: 0)
                                attPrice.append(lineVM)
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
        
        let firstLineVM = GarmentCardLineDetailVM(text: firstLine, price: 0)
        linesToRet.append(firstLineVM)
        if !secondLine.isEmpty {
            let secondLineVM = GarmentCardLineDetailVM(text: secondLine, price: 0.5)
            linesToRet.append(secondLineVM)
        }
        
        if !attributesString.isEmpty {
            let attributeLineVM = GarmentCardLineDetailVM(text: attributesString, price: 0)
            linesToRet.append(attributeLineVM)
        }
        
        linesToRet.append(contentsOf: attPrice)
        return linesToRet
    }
    
    func shouldDisplayLbsLabel() -> Bool {
        return false
    }
}
