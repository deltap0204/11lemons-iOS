//
//  GarmentCardViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/4/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond

final class GarmentCardViewModel {
    
    fileprivate let labelHeight = 18
    fileprivate let standarHeight = 66
    fileprivate let heightWithLines = 42
    
    let cellIdentifier: String
    let productImageRounded = Observable<Bool>(true)
    
    var orderDetail: OrderDetailGeneral {
        didSet {
            setup()
        }
    }
    
    let order: Order
    let orderName = Observable<String>("")
    let lbs = Observable<Double?>(nil)
    let orderProductPrice = Observable<Double>(0.0)
    let productImage = Observable<UIImage?>(nil)
    var listOfLines = MutableObservableArray<GarmentCardLineDetailVM>([])
    var garmentType: GarmentCardServiceTypesVM? = nil
    
    init(orderDetail: OrderDetailGeneral, order: Order, cellIdentifier: String = "") {
        self.orderDetail = orderDetail
        self.order = order
        self.cellIdentifier = cellIdentifier
        setup()
    }
    
    fileprivate func setup() {
        garmentType = getGarmentType(orderDetail)
        if orderDetail.service != nil {
            lbs.value = orderDetail.weight
        }

        setupPrice()
        setupImage(orderDetail)
        setupLines()
    }
    
    fileprivate func getGarmentType(_ orderDetail: OrderDetailGeneral) -> GarmentCardServiceTypesVM? {
        if let department = orderDetail.service {
            switch department.id {
            case 1:
                return GarmentCardWashNFoldVM()
            case 2:
                return GarmentCardDryCleaningVM()
            case 3:
                return GarmentCardMenShirtVM()
            default:
                return GarmentCardGenericVM()
            }
        }
        return nil
    }
    
    fileprivate func setupPrice() {
        var price = 0.0
        if let department = orderDetail.service, let garmentType = garmentType {
            price = garmentType.getPrice(department, orderDetail: orderDetail)
        }
        
        orderProductPrice.value = price
    }
    
    fileprivate func setupLines() {
        
        listOfLines.removeAll()
        self.orderName.value = garmentType?.getOrderName(orderDetail, order: order) ?? ""
        if let _ = orderDetail.service, let garmentType = garmentType {
            listOfLines.replace(with: garmentType.getDescriptionLines(orderDetail, order: order))
        }
    }

    func getHeight() -> CGFloat {
        
        if listOfLines.count > 6 {
            return CGFloat( standarHeight + ( 6 * labelHeight) )
        }
        
        let totalLines = listOfLines.count
        if totalLines == 0 {
            return CGFloat( standarHeight)
        }
        
        return CGFloat( heightWithLines + ( totalLines * labelHeight) )
    }
    
    func setupImage(_ orderDetail: OrderDetailGeneral) {
        if let department = orderDetail.service, let garmentType = garmentType {
            productImage.value = garmentType.getImage(order, orderDetail: orderDetail)
            productImageRounded.value = garmentType.isImageRounded()
        }
    }
    
    func getTotalPrice() -> Double {
        return orderDetail.total ?? 0.0
    }
    
    func shouldDisplayLbsLabel() -> Bool {
        return garmentType?.shouldDisplayLbsLabel() ?? false
    }
}

