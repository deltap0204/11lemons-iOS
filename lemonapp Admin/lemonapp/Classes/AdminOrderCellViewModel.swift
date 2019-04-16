//
//  AdminOrderCellViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import MessageUI
import ReactiveKit

class AdminOrderCellViewModel: ViewModel {

    let orderId: String
    let deliveryStatus: String
    let orderStatus: OrderStatus
    let shouldWarnUser: Bool
    let shouldMessageButtons: Bool
    let shouldPhoneButtons: Bool
    let shouldAccessoryArrow: Bool
    let statusImage = Observable<UIImage?>(nil)
    let statusChangedDate: String?
    var statusColor: UIColor
    let canArchive: Bool
    let viewed: Observable<Bool>
    let updated: Observable<Bool>
    let orderTotal: Observable<Double> = Observable<Double>(0)
    var lastModified: Date?
    let avatarBackgroundColor = Observable<UIColor>(UIColor.appRedColor())
    let showStartBadge = Observable<Bool>(false)
    let order: Order
    let avatarImage = Observable<UIImage?>(nil)
    let processStatus = Observable<OrderProcessStatus?>(nil)
    
    weak var navigationDelegate: AdminOrderCellNavigationDelegate? = nil
    let canCancel: Bool

    init(order: Order, withOldTotal: Double? = nil) {
        self.order = order
        self.viewed = order.viewed
        orderId = "\(NSLocalizedString("Order", comment: "")) #\(order.id)"
        switch order.status {
        case .awaitingPickup:
            deliveryStatus = order.status.comments(order.delivery.estimatedPickupDate)
        default:
            deliveryStatus = order.status.comments(order.delivery.estimatedArrivalDate)
        }
        self.orderTotal.value = withOldTotal ?? 0
        
        showStartBadge.value = order.orderDetails == nil || order.orderDetails!.count == 0
        orderStatus = order.status
        shouldWarnUser = order.status.isExceptional
        shouldMessageButtons = order.status == .hold && MFMessageComposeViewController.canSendText()
        shouldPhoneButtons = order.status == .hold && UIApplication.shared.canOpenURL(URL(string: "tel://")!)
        statusImage.value = OrderHelper.getPaymentStatusIcon(order)
        if let modified = order.lastModified {
            statusChangedDate = modified.smartDateString()
        } else {
            statusChangedDate = ""
        }
        
        shouldAccessoryArrow = (order.orderDetails != nil && !order.orderDetails!.isEmpty && order.status != .pickedUp) || order.status == .awaitingPickup
        canArchive = order.status == .canceled || order.status == .delivered
        canCancel = order.status == OrderStatus.awaitingPickup
        statusColor = OrderHelper.getPaymentStatusColor(order)
        updated = order.updated
        lastModified = order.lastModified
        self.avatarBackgroundColor.value = self.setAvatarBackground(order)
        if let userId = order.userId {
            self.getWallet(userId)
        }
    }

    var photoRequest: SafeSignal<UIImage?> {

        return SafeSignal/*(replayLength: 1)*/ { [weak self] sink in
            if let strongSelf = self {
                let user = strongSelf.order.lastModifiedUser ?? strongSelf.order.createdBy
                if let lastModifiedUser = user {
                    let userWrapper = UserWrapper(user: lastModifiedUser)
                    userWrapper.profilePhoto.observeNext { imageURL in
                        if let cachedImage = ImageCache.getImage(imageURL ?? "profile_photo") {
                            sink.completed(with: cachedImage)
                        } else {
                            _ = LemonAPI.getProfileImage(imgURL: imageURL).request().observeNext { (resolver: ImageResolver) in
                                        if let image = resolver,
                                           let imageURL = imageURL {
                                            ImageCache.saveImage(image, url: imageURL).observeNext { _ in sink.completed(with:resolver) }
                                        } else {
                                            sink.completed(with:resolver)
                                        }
                                    }
                        }
                    }
                }
            }
            //return nil
            return BlockDisposable {}
        }
    }

    func onBadgeView() {
        if showStartBadge.value {
            navigationDelegate?.completeDetailOf(order)
        } else {
            navigationDelegate?.receiptDetailOf(order)
        }
    }
    
    func setAvatarBackground(_ order: Order) -> UIColor {
        let date: Date?
        if order.status == .awaitingPickup {
            date = order.delivery.estimatedPickupDate
        } else {
            date = order.delivery.estimatedArrivalDate
        }
        
        if let date = date {
            let minutes = date.minutesFrom(Date())
            let seconds = date.secondsFrom(Date()) % 60
            if minutes >= 30 {
                return UIColor.appBlueColor
                
            } else if minutes >= 0 && seconds >= 0 {
                return UIColor.appYellowColor()
            } else {
                return UIColor.appRedColor()
            }
        }
        return UIColor.clear
    }

    private func setTotalAmount(_ order: Order, wallet: NewWallet? = nil) {
        let walletAmount =  wallet?.amount ?? Double(0)
        let subtotalAmount = self.getSubtotal(order, walletAmount: walletAmount)
        let priceTips = order.tips == 0 ? 0 : subtotalAmount * (Double(order.tips) / 100)
        
        let total = subtotalAmount + priceTips
        self.orderTotal.value = total
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
