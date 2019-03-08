//
//  ReceiptHeaderViewModel.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 11/14/17.
//  Copyright © 2017 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

final class ReceiptHeaderViewModel {
    
    let orderNumber = Observable<Int>(0)
    let userName = Observable<String>("")
    let address = Observable<String>("")
    let city = Observable<String>("")
    let status = Observable<String>("")
    let orderDate = Observable<Date>(Date())
    let statusColor = Observable<UIColor>(UIColor.paymentNotProcessedColor)
    let avatarBackgroundColor = Observable<UIColor>(UIColor.appBlueColor)
    let order: Order
    let disposeBag = DisposeBag()
    init(order: Order) {
        self.order = order
        self.orderNumber.value = order.id
        self.status.value = order.status.subtitle
        if let user = order.createdBy {
            self.userName.value = "\(user.firstName) \(user.lastName)"
        }
        setStatusColor(order)
        setAvatarBackground()
        setAddress()
    }
    
    fileprivate func setStatusColor(_ order: Order) {
        self.statusColor.value = order.paymentStatus.color
    }
    
    fileprivate func setAddress() {
        
        let delivery = order.delivery
        if let address = delivery.dropoffAddress {
            self.address.value = "\(address.street) Apt \(address.aptSuite)"
            self.city.value = "\(address.city), \(address.state) \(address.zip)"
        }
    }
    
    var photoRequest: SafeSignal<UIImage?> {
        
        return SafeSignal/*(replayLength: 1)*/ { [weak self] sink in
            if let strongSelf = self {
                let user = strongSelf.order.createdBy
                if let lastModifiedUser = user {
                    let userWrapper = UserWrapper(user: lastModifiedUser)
                    userWrapper.profilePhoto.observeNext { imageURL in
                        if let cachedImage = ImageCache.getImage(imageURL ?? "profile_photo") {
                            sink.completed(with: cachedImage)
                        } else {
                            _ = LemonAPI.getProfileImage(imgURL: imageURL).request().observeNext { (resolver: ImageResolver) in
                                if let image = resolver,
                                    let imageURL = imageURL {
                                    ImageCache.saveImage(image, url: imageURL).observeNext { _ in sink.completed(with: resolver) }
                                } else {
                                    sink.completed(with: resolver)
                                }
                            }
                        }
                    }.dispose(in:strongSelf.disposeBag)
                }
            }
            //return nil
            return BlockDisposable {}
        }
    }
    
    fileprivate func setAvatarBackground() {
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
                avatarBackgroundColor.value = UIColor.appBlueColor
            } else if minutes >= 0 && seconds >= 0 {
                avatarBackgroundColor.value = UIColor.appYellowColor()
            } else {
                avatarBackgroundColor.value = UIColor.appRedColor()
            }
        }
    }
}
