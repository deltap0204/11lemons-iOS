//
//  AddOrderDetailsViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 12/7/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond


final class AddOrderDetailsViewModel {
    //MARK: UI Properties
    let hiddenDoneBtn = Observable<Bool>(false)
    let isBusy = Observable<Bool>(false)
    let totalPrice = Observable<Double>(0)
    let numberOfOrderDetails = Observable<Int>(0)
    
    var cardEmpty = GarmentCardEmptyView(withRadius: true)
    var cardDetail:GarmentCardView?
    var garmentCardVM: GarmentCardViewModel?
    var lastOrderDetailCreated: OrderDetail?
    var paymentStatusImage = Observable<UIImage?>(nil)
    let paymentStatusColor = Observable<UIColor>(UIColor.appBlueColor)
    
    var order: Order!
    let userOrderID: Int!
    let orderDetailToAdd = Observable<OrderDetail?>(nil)
    weak var viewDelegate: AddOrderViewModelDelegate?
    
    var garmentType: AddOrderDetailGarmentTypesVM? = nil
    var somethingHasChanged = false
    
    init(order: Order, delegate: AddOrderViewModelDelegate) {
        self.viewDelegate = delegate
        self.order = order
        self.paymentStatusColor.value = order.paymentStatus.color
//        self.userOrderID = order.userId!
        if let user = order.createdBy {
             self.userOrderID = user.id
        } else {
            self.userOrderID = 0
            let appError = OrderHasNotCreatedByError()
            track(error: appError, additionalInfo: appError.errorUserInfo)
        }
        self.getWallet(self.userOrderID)
    }
    
    //MARK: Order Detail Methods
    func createOrderDetail() {
        lastOrderDetailCreated = nil
        self.orderDetailToAdd.value = OrderDetail(id: 0)
        if let orderDetail = orderDetailToAdd.value {
            orderDetail.orderId = self.order.id
            
            if orderDetail.garment == nil {
                orderDetail.garment = OrderGarment(id: 0)
                orderDetail.garment?.orderId = order.id
            }
            
            if orderDetail.garment?.properties == nil { orderDetail.garment?.properties = [] }
        }
        hiddenDoneBtn.value = true
    }
    
    func removeOrderDetail() {
        self.orderDetailToAdd.value = nil
        hiddenDoneBtn.value = false
    }
    
    func finishOrderDetailCreation(_ withSuccess: Bool) {
        viewDelegate?.clearScreen(withSuccess)
    }
    
    func addDepartmentToOrderDetail(_ department: Service) {
        createOrderDetail()
        garmentType = AddOrderDetailsMenShirtVM()
        orderDetailToAdd.value!.service = department
        orderDetailToAdd.value!.pricePer = department.price
        garmentCardVM?.orderDetail = orderDetailToAdd.value!
    }
    
    func updateDepartmentToOrderDetail(_ department: Service) {
        garmentType = AddOrderDetailsMenShirtVM()
        orderDetailToAdd.value!.service = department
        orderDetailToAdd.value!.pricePer = department.price
        garmentCardVM?.orderDetail = orderDetailToAdd.value!
    }
    
    func addDepartmentWashFoldToOrderDetail(_ department: Service) {
        createOrderDetail()
        garmentType = AddOrderDetailsWhasNFoldVM()
        orderDetailToAdd.value!.service = department
        orderDetailToAdd.value!.pricePer = 0.0
        orderDetailToAdd.value!.quantity = 1
        garmentCardVM?.orderDetail = orderDetailToAdd.value!
    }
    
    func updateDepartmentWashFoldToOrderDetail(_ department: Service) {
        garmentType = AddOrderDetailsWhasNFoldVM()
        orderDetailToAdd.value!.service = department
        orderDetailToAdd.value!.pricePer = 0.0
        orderDetailToAdd.value!.quantity = 1
        garmentCardVM?.orderDetail = orderDetailToAdd.value!
    }

    func getUserNameCreator() -> String {
        if let user = order.createdBy {
            return "\(user.firstName) \(user.lastName)"
        }
        return ""
    }
    
    func getServiceIDSelected() -> Int? {
        if let orderDetail = orderDetailToAdd.value, let department = orderDetail.service, let typesOfService = department.typesOfService {
            return typesOfService.filter {$0.active == true }[0].id
        }
        return nil
    }
    
    fileprivate func orderDetailUpdateTotalPrice(_ orderDetail: OrderDetail, order: Order) {
        guard let garmentType = garmentType else { return }
        
        orderDetail.subtotal = garmentType.getSubTotal(orderDetail, order: order)
        orderDetail.total = garmentType.getTotal(orderDetail, order: order)
        orderDetail.tax = garmentType.getTax(orderDetail)
    }
    
    func undoLastOrderDetail() {
        guard let lastOrderDetail = lastOrderDetailCreated else { return }
        
        deleteOrderDetail(lastOrderDetail)
    }
    
    func confirmOrderDetailAdded() {
        if order.status == OrderStatus.awaitingPickup || order.status == OrderStatus.pickedUp {
            order.status = OrderStatus.atFacility
        }
        updateOrder()
    }
    
    func updateOrders() {
        DataProvider.sharedInstance.refreshAdminOrdersFromBackend() { [weak self] _ in
            self?.somethingHasChanged = false
        }
    }
    
    //MARK: API's methods
    func updateOrder() {
        _ = LemonAPI.setOrderStatus(editedOrder: self.order, status: self.order.status).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()
                strongSelf.setupOrder(newOrder)
            } catch { }
            strongSelf.updateOrders()
        }
    }
    
    fileprivate func deleteOrderDetail(_ orderDetail: OrderDetail) {
        isBusy.value = true
        _ = LemonAPI.deleteOrderDetail(orderDetailID: orderDetail.id).request().observeNext { [weak self] (_: EventResolver<String>) in
            guard let strongSelf = self else { return }
            defer {
                strongSelf.isBusy.value = false
            }
            strongSelf.getOrder()
        }
    }
    
    func onAddToOrder() {
        if let orderDetail = orderDetailToAdd.value {
            isBusy.value = true
            lastOrderDetailCreated = orderDetail
            orderDetailUpdateTotalPrice(orderDetail, order: order)
            somethingHasChanged = true
            _ = LemonAPI.createGarment(orderDetail: orderDetail).request().observeNext { [weak self] (_: EventResolver<String>) in
                guard let strongSelf = self else { return }
                defer {
                    strongSelf.isBusy.value = false
                }
                strongSelf.getOrder()
                strongSelf.finishOrderDetailCreation(true)
            }
        }
    }
    
    //MARK: Order UI
    func getOrder() {
        _ = LemonAPI.getOrderByID(orderID: order.id).request().observeNext { [weak self] (result: EventResolver<Order>) in
            guard let strongSelf = self else { return }
            do {
                let newOrder = try result()
                strongSelf.setupOrder(newOrder)
            } catch { }
        }
    }
}

extension AddOrderDetailsViewModel: ComponentsViewModelDelegate {
    func resetServicesToOrderDetail() {
        if let orderDetail = orderDetailToAdd.value, let department = orderDetail.service, let typesOfService = department.typesOfService {
            typesOfService.forEach({ (serviceAttr) in
                serviceAttr.isSelected = false
            })
            orderDetailToAdd.value = orderDetailToAdd.value
        }
    }
    
    func resetAttributesToOrderDetail() {
        if let orderDetail = orderDetailToAdd.value, let garment = orderDetail.garment {
            garment.properties = []
            orderDetailToAdd.value = orderDetailToAdd.value
        }
    }
    
    func changeLbs(_ lbs: Double) {
        orderDetailToAdd.value!.weight = lbs
        orderDetailToAdd.value = orderDetailToAdd.value
    }
    
    func getCurrentLbs() -> Double? {
        return orderDetailToAdd.value?.weight
    }
    
    func setupOrder(_ order: Order) {
        self.order = order
        self.paymentStatusImage.value = OrderHelper.getPaymentStatusIcon(order)
        numberOfOrderDetails.value = order.orderDetails?.count ?? 0
        orderDetailToAdd.value = orderDetailToAdd.value
        self.getWallet(self.userOrderID)
    }
    
    func changeOrderDetailToAdd(_ order: Order) {
        orderDetailToAdd.value = orderDetailToAdd.value
    }
    
    func setTypeOfServiceToOrderDetail(_ position: Int, isSelected: Bool) {
        if let orderDetail = orderDetailToAdd.value, let department = orderDetail.service, let typesOfService = department.typesOfService {
            typesOfService.forEach {$0.isSelected = false }
            typesOfService[position].isSelected = isSelected
            let addPrice = isSelected ? typesOfService[position].price : (typesOfService[position].price * -1)
            orderDetailToAdd.value!.pricePer = addPrice
            orderDetailToAdd.value!.tax = typesOfService[position].taxable ? 0 : 0
            orderDetailToAdd.value = orderDetailToAdd.value
        }
    }
    
    func setupAttributesToOrderDetail(_ category: Category, attributes: [Attribute]) {
        if let orderDetail = orderDetailToAdd.value, let garment = orderDetail.garment, let properties = garment.properties {
            if (properties.filter{ $0.id == category.id }.count <= 0) {
                orderDetailToAdd.value!.garment!.properties!.append(category)
            }
            
            orderDetailToAdd.value!.garment!.properties!.filter{ $0.id == category.id }[0].attributes = attributes
            orderDetailToAdd.value = orderDetailToAdd.value
        }
    }
    
    func setTypeOfServiceWashFoldToOrderDetail(_ position: Int, isSelected: Bool) {
        if let orderDetail = orderDetailToAdd.value, let department = orderDetail.service, let typesOfService = department.typesOfService {
            typesOfService.forEach {$0.isSelected = false }
            typesOfService[position].isSelected = isSelected
            let addPrice = isSelected ? typesOfService[position].price : 0.0
            orderDetailToAdd.value!.pricePer = addPrice
            orderDetailToAdd.value!.tax = typesOfService[position].taxable ? 0 : 0
            orderDetailToAdd.value = orderDetailToAdd.value
        }
    }
    
    func showModal(_ alert: UIAlertController) {
        viewDelegate?.showModal(alert)
    }
    
    private func setTotalAmount(_ order: Order, wallet: NewWallet) {
        let walletAmount =  wallet.amount
        let orderTotal = self.getTotal(order)
        let tips = order.tips == 0 ? 0 : orderTotal * (Double(order.tips) / 100)
        let total = orderTotal + tips - walletAmount
        self.totalPrice.value = total
    }
    
    private func getSubtotal(_ order: Order, walletAmount: Double) -> Double {
        let total = self.getTotal(order)
        let subtotalAmount: Double = total - walletAmount
        return subtotalAmount < 0 ? 0 : subtotalAmount
    }
    
    private func getTotal(_ order: Order) -> Double {
        var total = 0.0
        order.orderDetails?.forEach { orderDetail in
            total = total + (orderDetail.total ?? 0)
        }
        
        return total
    }
    
    private func getPaymentStatusIcon(_ order: Order) -> UIImage? {
        if order.paymentStatus == OrderPaymentStatus.paymentProcessedSuccessfully {
            return UIImage(named:"paymentSuccess")
        } else if order.orderDetails != nil && order.orderDetails!.count > 0 {
            if order.paymentStatus == OrderPaymentStatus.paymentNotProcessed {
                return UIImage(named:"TagSyncIcon")
            } else if order.paymentStatus == OrderPaymentStatus.decline {
                return UIImage(named:"paymentError")
            }
        }
        return order.paymentStatus.icon
    }
    
    fileprivate func getWallet(_ userId: Int) {
        _ = LemonAPI.getWallet(userId: userId).request().observeNext { [weak self] (resolver: EventResolver<NewWallet>) in
            guard let `self` = self else {return}
            if let wallet: NewWallet = try? resolver() {
                self.setTotalAmount(self.order, wallet: wallet)
            }
        }
    }

}
