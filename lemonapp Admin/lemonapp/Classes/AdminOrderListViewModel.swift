//
//  AdminOrderListViewModel.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol AdminOrderListViewModelDelegate: class {
    func showAcceptedNotificationbar()
    func showDeclinedNotificationbar()
    func showFinalDeclinedNotificationbar()
    func showNotificationSent()
    func showErrorNotificationbar()
}

class AdminOrderListViewModel: ViewModel {
    
    let dashboardItems: MutableObservableArray<DashboardItem>
    var dashboardViewModels = MutableObservableArray<ViewModel>([])
    let pickupETA: Observable<Int> = Observable(Config.StandardPickupETA)
    let shouldHideHints: SafeSignal<Bool>
    var headerItems = [String]()
    var pickedHeaderIndex: Observable<Int> = Observable(0)
    var orderedAscending = false
    var nextRetryID: Int? = nil
    weak var delegate: AdminOrderListViewModelDelegate?
    
    init() {
        self.dashboardItems = DataProvider.sharedInstance.adminDashboardItems
        
        shouldHideHints = dashboardItems.map { [weak dashboardItems] _ in dashboardItems?.count > 0 }
        
        dashboardItems.observeNext { [weak self] event in
            //switch event.operation {
            switch event.change {
            //case .remove(let range):
            case .deletes(let range):
                self?.dashboardViewModels.removeSubrange(range)
                break
            default:
                if let strongSelf = self {
                    let dashboardViewModelsArray: [ViewModel] = strongSelf.dashboardItems.array.compactMap {
                        if let order = $0 as? Order {
                            return AdminOrderCellViewModel(order: order)
                        }
                        return nil
                    }

                    strongSelf.dashboardViewModels.replace(with: dashboardViewModelsArray)
                }
            }
        }
        
        for status in OrderStatus.allValues {
            headerItems.append(status.subtitle)
        }
        headerItems.insert("Open Orders", at: 0)
        headerItems.insert("All Orders", at: headerItems.count)
        
        DataProvider.sharedInstance.pickupETA.bind(to: pickupETA)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdminOrderListViewModel.orderProcessChanged(_:)), name: NSNotification.Name(rawValue: OrderProcessHandler.Notification), object: nil)

    }
    
    func archiveOrder(_ order: Order) -> Action<() throws -> ()> {
        return Action { [weak self] in
            Signal { sink in
                _ = LemonAPI.archiveOrder(order: order).request().observeNext { (resolver: EventResolver<Void>) in
                    do {
                        try resolver()
                        order.status = .archived
                        // replace SaveData COMPLETE
//                        order.syncDataModel()
                        DataProvider.sharedInstance.refreshAdminOrdersFromBackend()
                        let dashboardItem = order as DashboardItem
                        if let orderIndex = self?.dashboardItems.array.index(where: { $0 == dashboardItem }) {
                            self?.dashboardItems.remove(at: orderIndex)
                        }
                    } catch let error {
                        sink.completed(with: { throw error })
                    }
                }
                //return nil
                return BlockDisposable {}
            }
        }
    }
    
    func changeOrderStatus(_ order: Order, fromViewController viewController: UIViewController) -> OrderStatusFlow {
        return OrderStatusFlow(withOrder: order, fromViewController: viewController) {
            return
        }
    }
    
    func addNoteToOrder(_ order: Order, fromViewController viewController: UIViewController) -> AddNoteFlow {
        return AddNoteFlow(withOrder: order, fromViewController: viewController) {
            return
        }
    }
    
    func bumpOrderStatus(_ order: Order, fromViewController viewController: UIViewController) {
        if let nextStatus = order.status.nextStatus {
            _ = LemonAPI.setOrderStatus(editedOrder: order, status: nextStatus).request().observeNext { (result: EventResolver<Order>) in
                DataProvider.sharedInstance.refreshAdminOrdersFromBackend()
            }
        }
    }
    
    func callToOrderCreator(_ order: Order, fromViewController viewController: UIViewController) {
        if let phone = order.createdBy?.mobilePhone,
            let phoneUrl = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))"), UIApplication.shared.canOpenURL(phoneUrl) {
            UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
        }
    }

    func snoozeOrder(_ order: Order, fromViewController viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)

        let viewContact = UIAlertAction(title: "View Contact", style: UIAlertActionStyle.destructive) { _ in
            alert.dismiss(animated: true, completion: nil)
            //TODO: Show the contact
        }
        alert.addAction(viewContact)

        let snoozeToClosing = UIAlertAction(title: "ClosingTime", style: UIAlertActionStyle.default) { [weak self] _ in
            alert.dismiss(animated: true, completion: nil)
            //TODO: Calc closing time in seconds
            let seconds = 0
            self?.snoozeOrderFor(seconds, order: order)
        }
        alert.addAction(snoozeToClosing)

        let snoozeFor2Hours = UIAlertAction(title: "+2 Hours", style: UIAlertActionStyle.default) { [weak self] _ in
            alert.dismiss(animated: true, completion: nil)
            let seconds = 2 * 60 * 60
            self?.snoozeOrderFor(seconds, order: order)
        }
        alert.addAction(snoozeFor2Hours)

        let snoozeFor1Hours = UIAlertAction(title: "+1 Hours", style: UIAlertActionStyle.default) { [weak self] _ in
            alert.dismiss(animated: true, completion: nil)
            let seconds = 1 * 60 * 60
            self?.snoozeOrderFor(seconds, order: order)
        }
        alert.addAction(snoozeFor1Hours)

        let snoozeFor30Minutes = UIAlertAction(title: "+30 Minutes", style: UIAlertActionStyle.default) { [weak self] _ in
            alert.dismiss(animated: true, completion: nil)
            let seconds = 30 * 60
            self?.snoozeOrderFor(seconds, order: order)
        }
        alert.addAction(snoozeFor30Minutes)

        let chooseTime = UIAlertAction(title: "Choose Time", style: UIAlertActionStyle.destructive) { [weak self] _ in
            alert.dismiss(animated: true, completion: nil)
            
            DatePickerDialog().show("Choose Time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .dateAndTime) { [weak order](date) -> Void in
                if let date = date, let order = order, date.secondsFrom(Date()) > 0 {
                    self?.snoozeOrderFor(date, order: order)
                } else {
                    //TODO: Show error message
                }
            }
        }
        alert.addAction(chooseTime)

        viewController.present(alert, animated: true, completion: nil)
    }

    func snoozeOrderFor(_ seconds: Int, order: Order) {
        let newDate: Date
        
        if order.status == .awaitingPickup {
            if let estimatedPickupDate = order.delivery.estimatedPickupDate {
                newDate = estimatedPickupDate.addingTimeInterval(Double(seconds))
            } else {
                newDate = Date().addingTimeInterval(Double(seconds))
            }
        } else {
            if let deliveryDate = order.delivery.deliveryDate {
                newDate = deliveryDate.addingTimeInterval(Double(seconds))
            } else {
                newDate = Date().addingTimeInterval(Double(seconds))
            }
        }
        snoozeOrderFor(newDate, order: order)
    }
    
    func snoozeOrderFor(_ date: Date, order: Order) {
        if order.status == .awaitingPickup {
            order.delivery.estimatedPickupDate = date
        } else {
            order.delivery.estimatedArrivalDate = date
        }
        
        _ = LemonAPI.editOrder(editedOrder: order).request().observeNext { (result: EventResolver<Order>) in
// replace SaveData COMPLETE
            //            order.syncDataModel()
            DataProvider.sharedInstance.refreshAdminOrdersFromBackend()
        }
    }
    
    func notifyOrderCreator(_ order: Order, fromViewController viewController: UIViewController) {
        //TODO:
    }
    
    func filterOrders(_ object:ViewModel) -> Bool {
        guard let orderViewModel = object as? AdminOrderCellViewModel else { return false; }
        
        let pickedStatus = headerItems[pickedHeaderIndex.value]
        switch pickedStatus {
        case "Open Orders":
            return orderViewModel.orderStatus != .canceled && orderViewModel.orderStatus != .archived && orderViewModel.orderStatus != .delivered
        case "All Orders":
            return true
        default:
            return orderViewModel.orderStatus.subtitle == pickedStatus;
        }
    }
    
    func sortOrders(_ object1:ViewModel, object2:ViewModel) -> Bool {
        guard let object1 = object1 as? AdminOrderCellViewModel else { return false; }
        guard let object2 = object2 as? AdminOrderCellViewModel else { return false; }
        
        let order = orderedAscending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending
        if let lastModified1 = object1.lastModified, let lastModified2 = object2.lastModified{
            return lastModified1.compare(lastModified2 as Date) == order
        }
        return false
    }
    
    func reorderBySearchString(_ searchText: String) {
        let dashboardViewModelsArray:[ViewModel] = dashboardItems.array.compactMap {
            if let order = $0 as? Order {
                if (searchText.count == 0) {
                    return AdminOrderCellViewModel(order: order)
                } else {
                    let orderNumber: NSString = String(order.id) as NSString
                    let rangeOrderNumber = orderNumber.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return rangeOrderNumber.location != NSNotFound ? AdminOrderCellViewModel(order: order) : nil
                }
            }
            return nil
        }
        dashboardViewModels.replace(with: dashboardViewModelsArray)
    }
    
    func update(_ completion: ( () -> Void )? = nil) {
        DataProvider.sharedInstance.refreshPickupETA()
        DataProvider.sharedInstance.refreshAdminOrdersFromBackend() { _ in completion?() }
        DataProvider.sharedInstance.refreshCloudCloset()
    }
    
    func sendNotification() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.delegate?.showNotificationSent()
        }
    }
}

extension AdminOrderListViewModel{
    @objc func orderProcessChanged(_ notification: Notification) {
        if let orderID = notification.userInfo?["id"] as? Int {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.reviewPaymentOrderSatuses(id: orderID)
            }
        }
    }
    
    private func reviewPaymentOrderSatuses(id: Int) {
        var array = self.dashboardViewModels.array
        array.forEach { [weak self] (item) in
            if let adminCell = item as? AdminOrderCellViewModel {
                if adminCell.order.id == id {
                    let newStatus = OrderProcessHandler.sharedInstance.getStatusOf(orderID: id)
                    adminCell.processStatus.value = newStatus
                    if let status = newStatus {
                        self?.showProcessDialog(for: id, with: status)
                    }
                }
            }
        }
        self.dashboardViewModels.replace(with: array)
    }
    
    private func showProcessDialog(for orderID: Int, with processStatus: OrderProcessStatus) {
        switch processStatus {
        case .processing:
            return
        case .accepted:
            self.delegate?.showAcceptedNotificationbar()
        case .failed:
            self.nextRetryID = orderID
            self.showRetry(orderID: orderID)
        case .failedAndProcessing:
            return
        case .error:
            self.nextRetryID = orderID
            self.delegate?.showErrorNotificationbar()
        }
    }
    
    private func showRetry(orderID: Int) {
        if let processOrder = OrderProcessHandler.sharedInstance.getOrderProcessed(by: orderID) {
            if processOrder.retryCount >= 1 {
                self.delegate?.showFinalDeclinedNotificationbar()
            } else {
                self.delegate?.showDeclinedNotificationbar()
            }
        }
    }
    
    func retryPaymentProcess() {
        guard let orderID = self.nextRetryID else {return}
        self.nextRetryID = nil
        if let processOrder = OrderProcessHandler.sharedInstance.getOrderProcessed(by: orderID) {
            OrderProcessHandler.sharedInstance.increaseRetry(to: orderID)
            OrderProcessHandler.sharedInstance.change(status: .failedAndProcessing, to: processOrder)
            _ = LemonAPI.processPayment(amount: processOrder.total, orderID: processOrder.id).request().observeNext { (result: EventResolver<String>) in
                
                do {
                    let resultString = try result()
                    if resultString == "Success" {
                        OrderProcessHandler.sharedInstance.change(status: .accepted, to: processOrder)
                    } else {
                        OrderProcessHandler.sharedInstance.change(status: .failed, to: processOrder)
                    }
                } catch {
                    OrderProcessHandler.sharedInstance.change(status: .error, to: processOrder)
                }
            }
        }
    }
}


