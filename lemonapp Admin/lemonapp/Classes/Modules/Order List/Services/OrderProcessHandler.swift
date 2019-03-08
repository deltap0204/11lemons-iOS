//
//  OrderProcessHandler.swift
//  lemonapp
//
//  Created by Lucas Pelizza on 24/06/2018.
//  Copyright © 2018 11lemons. All rights reserved.
//

import Foundation

final class OrderProcessHandler {
    static let Notification = "OrderProcessHandlerNotification"
    static let sharedInstance = OrderProcessHandler()
    
    var orderProcessed: [OrderProcess]
    
    init() {
        self.orderProcessed = [OrderProcess]()
    }
    
    func add(order: OrderProcess) {
        if let position = self.getPositionOf(orderID: order.id) {
            self.orderProcessed.remove(at: position)
        }
        
        self.orderProcessed.append(order)
        self.notificateChanges(in: order.id)
    }
    
    func remove(order: OrderProcess) {
        if let position = self.getPositionOf(orderID: order.id) {
            self.orderProcessed.remove(at: position)
        }
        self.notificateChanges(in: order.id)
    }
    
    func getStatusOf(orderID: Int) -> OrderProcessStatus? {
        if let position = self.getPositionOf(orderID: orderID) {
           return self.orderProcessed[position].status
        }
        return nil
    }
    
    func getOrderProcessed(by orderID: Int) -> OrderProcess? {
        if let position = self.getPositionOf(orderID: orderID) {
            return self.orderProcessed[position]
        }
        return nil
    }
    
    func increaseRetry(to orderID: Int) {
        if let position = self.getPositionOf(orderID: orderID) {
            self.orderProcessed[position].increaseRetry()
        }
    }
    
    func change(status: OrderProcessStatus, to order: OrderProcess) {
        if let position = self.getPositionOf(orderID: order.id) {
            self.orderProcessed[position].changeState(newState: status)
        }
        self.notificateChanges(in: order.id)
    }
    
    private func getPositionOf(orderID: Int) -> Int? {
        for (index, currentOrder) in self.orderProcessed.enumerated() {
            if currentOrder.id == orderID {
                return index
            }
        }
        return nil
    }
    
    private func notificateChanges(in orderID: Int) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: OrderProcessHandler.Notification),
            object: self,
            userInfo: ["id": orderID]
        )
    }
}

struct OrderProcess {
    let id: Int
    let total: Double
    var status: OrderProcessStatus
    var retryCount: Int = 0

    mutating func changeState(newState: OrderProcessStatus) {
        self.status = newState
    }
    
    mutating func increaseRetry() {
        self.retryCount += 1
    }
}

enum OrderProcessStatus {
    case processing
    case accepted
    case failed
    case failedAndProcessing
    case error
}
